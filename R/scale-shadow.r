
waiver <- function() 
  structure(list(), class = "waiver")

is.waive <- function (x) 
  inherits(x, "waiver")


#' @importFrom ggplot2 continuous_scale
#' @importFrom ggplot2 ScaleContinuous
#' @importFrom ggplot2 ScaleContinuousDate
#' @importFrom ggplot2 ScaleContinuousDatetime
#' @importFrom scales pretty_breaks
#' @importFrom scales date_format
#' @importFrom scales date_trans
#' @importFrom scales time_trans
datetime_scale <- function(aesthetics, trans, palette,
                           breaks = pretty_breaks(), minor_breaks = waiver(),
                           labels = waiver(), date_breaks = waiver(),
                           date_labels = waiver(),
                           date_minor_breaks = waiver(), timezone = NULL,
                           guide = "legend", ...) {


  # Backward compatibility
  if (is.character(breaks)) breaks <- date_breaks(breaks)
  if (is.character(minor_breaks)) minor_breaks <- date_breaks(minor_breaks)

  if (!is.waive(date_breaks)) {
    breaks <- date_breaks(date_breaks)
  }
  if (!is.waive(date_minor_breaks)) {
    minor_breaks <- date_breaks(date_minor_breaks)
  }
  if (!is.waive(date_labels)) {
    labels <- function(self, x) {
      tz <- if (is.null(self$timezone)) "UTC" else self$timezone
      date_format(date_labels, tz)(x)
    }
  }

  name <- switch(trans,
    date = "date",
    time = "datetime"
  )

  # x/y position aesthetics should use ScaleContinuousDate or
  # ScaleContinuousDatetime; others use ScaleContinuous
  if (all(aesthetics %in% c("x", "xmin", "xmax", "xend", "y", "ymin", "ymax", "yend"))) {
    scale_class <- switch(
      trans,
      date = ScaleContinuousDate,
      time = ScaleContinuousDatetime
    )
  } else {
    scale_class <- ScaleContinuous
  }

  trans <- switch(trans,
    date = date_trans(),
    time = time_trans(timezone)
  )

  sc <- continuous_scale(
    aesthetics,
    name,
    palette = palette,
    breaks = breaks,
    minor_breaks = minor_breaks,
    labels = labels,
    guide = guide,
    trans = trans,
    ...,
    super = scale_class
  )
  sc$timezone <- timezone
  sc
}



#' @importFrom ggplot2 waiver
#' @importFrom ggplot2 discrete_scale
#' @importFrom cli cli_abort
#' @importFrom rlang is_missing
manual_scale <- function(aesthetic, values = NULL, breaks = waiver(), ..., limits = NULL) {
  # check for missing `values` parameter, in lieu of providing
  # a default to all the different scale_*_manual() functions
  if (is_missing(values)) {
    values <- NULL
  } else {
    force(values)
  }

  if (is.null(limits) && !is.null(names(values))) {
    # Limits as function to access `values` names later on (#4619)
    limits <- function(x){
      a <- intersect(x, names(values))
      if (is.null(a)){
          character()
      } else {
          a
      }
    }
  }

  # order values according to breaks
  if (is.vector(values) && is.null(names(values)) && !is.waive(breaks) &&
      !is.null(breaks) && !is.function(breaks)) {
    if (length(breaks) <= length(values)) {
      names(values) <- breaks
    } else {
      names(values) <- breaks[1:length(values)]
    }
  }

  pal <- function(n) {
    if (n > length(values)) {
      cli_abort("Insufficient values in manual scale. {n} needed but only {length(values)} provided.")
    }
    values
  }
  discrete_scale(aesthetic, "manual", pal, breaks = breaks, limits = limits, ...)
}

#' @importFrom scales rescale_mid
mid_rescaler <- function(mid) {
  function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
    rescale_mid(x, to, from, mid)
  }
}



#### binned_pal <- function (palette) {
####     function(x) {
####         palette(length(x))
####     }
#### }
####
####
#### #' @rdname scale_brewer
#### #' @importFrom scales brewer_pal
#### #' @importFrom ggplot2 binned_scale
#### #' @export
#### #'
#### #' @examples
#### #' library( ggplot2 )
#### #' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=as.factor(gear)))
#### #' p + geom_shadowpoint() + scale_shadowcolour_fermenter()
#### #'
#### #'
#### scale_shadowcolour_fermenter <- function(..., type = "seq", palette = 1, direction = -1, na.value = "grey50", guide = "coloursteps", aesthetics = "shadowcolour") {
####   # warn about using a qualitative brewer palette to generate the gradient
####   type <- match.arg(type, c("seq", "div", "qual"))
####   if (type == "qual") {
####     warn("Using a discrete colour palette in a binned scale.\n  Consider using type = \"seq\" or type = \"div\" instead")
####   }
####   binned_scale(aesthetics, "fermenter", binned_pal(brewer_pal(type, palette, direction)), na.value = na.value, guide = guide, ...)
#### }




#' @rdname scale_colour_hue
#' @importFrom scales hue_pal
#' @importFrom ggplot2 discrete_scale
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=as.factor(gear)))
#' p + geom_shadowpoint() + scale_shadowcolour_hue()
#'
#' @export
scale_shadowcolour_hue <- function(..., h = c(0, 360) + 15, c = 100, l = 65, h.start = 0,
                                        direction = 1, na.value = "grey50", aesthetics = "shadowcolour") {
  discrete_scale(aesthetics, "hue", hue_pal(h, c, l, h.start, direction),
                 na.value = na.value, ...)
}

#' @rdname scale_colour_hue
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=as.factor(gear)))
#' p + geom_shadowpoint() + scale_shadowcolour_discrete()
#'
#' @export
scale_shadowcolour_discrete <- scale_shadowcolour_hue

#' @rdname scale_brewer
#' @importFrom scales brewer_pal
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=as.factor(gear)))
#' p + geom_shadowpoint() + scale_shadowcolour_brewer()
#'
#' @export
scale_shadowcolour_brewer <- function(..., type = "seq", palette = 1, direction = 1, aesthetics = "shadowcolour") {
  discrete_scale(aesthetics, "brewer", brewer_pal(type, palette, direction), ...)
}

#' @rdname scale_brewer
#' @importFrom scales brewer_pal
#' @importFrom scales gradient_n_pal
#' @importFrom ggplot2 continuous_scale
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p + geom_shadowpoint() + scale_shadowcolour_distiller() + guides(shadowcolor='none')
#'
#' @export
scale_shadowcolour_distiller <- function(..., type = "seq", palette = 1, direction = -1, values = NULL, space = "Lab", na.value = "grey50", guide = "colourbar", aesthetics = "shadowcolour") {
  # warn about using a qualitative brewer palette to generate the gradient
  type <- match.arg(type, c("seq", "div", "qual"))
  if (type == "qual") {
    warn("Using a discrete colour palette in a continuous scale.\n  Consider using type = \"seq\" or type = \"div\" instead")
  }
  continuous_scale(aesthetics, "distiller",
                   gradient_n_pal(brewer_pal(type, palette, direction)(7), values, space), na.value = na.value, guide = guide, ...)
  # NB: 6-7 colours per palette gives nice gradients; more results in more saturated colours which do not look as good
  # For diverging scales, you need an odd number to make sure the mid-point is in the center
}




#' @rdname scale_identity
#' @importFrom scales identity_pal
#' @importFrom ggplot2 ScaleDiscreteIdentity
#' @importFrom ggplot2 discrete_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor='red'))
#' p + geom_shadowpoint() + scale_shadowcolour_identity()
#'
#'
scale_shadowcolour_identity <- function(..., guide = "none", aesthetics = "shadowcolour") {
  sc <- discrete_scale(aesthetics, "identity", identity_pal(), ..., guide = guide,
                       super = ScaleDiscreteIdentity)

  sc
}

#' @rdname scale_continuous
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p + geom_shadowpoint() + scale_shadowcolour_continuous() + guides(shadowcolour='none')
#'
#'
scale_shadowcolour_continuous <- function(...,
                                    type = getOption("ggplot2.continuous.colour", default = "gradient")) {
  if (is.function(type)) {
    type(...)
  } else if (identical(type, "gradient")) {
    scale_shadowcolour_gradient(...)
  } else if (identical(type, "viridis")) {
    scale_shadowcolour_viridis_c(...)
  } else {
    abort("Unknown scale type")
  }
}

#' @rdname scale_continuous
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p + geom_shadowpoint() + scale_shadowcolour_binned() + guides(shadowcolour='none')
#'
scale_shadowcolour_binned <- function(...,
                                type = getOption("ggplot2.binned.colour", default = getOption("ggplot2.continuous.colour", default = "gradient"))) {
  if (is.function(type)) {
    type(...)
  } else if (identical(type, "gradient")) {
    scale_shadowcolour_steps(...)
  } else if (identical(type, "viridis")) {
    scale_shadowcolour_viridis_b(...)
  } else {
    abort("Unknown scale type")
  }
}

#' @rdname scale_colour_steps
#' @importFrom scales seq_gradient_pal
#' @importFrom ggplot2 binned_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p + geom_shadowpoint() + scale_shadowcolour_steps() + guides(shadowcolour='none')
#'
scale_shadowcolour_steps <- function(..., low = "#132B43", high = "#56B1F7", space = "Lab",
                               na.value = "grey50", guide = "coloursteps", aesthetics = "shadowcolour") {
  binned_scale(aesthetics, "steps", seq_gradient_pal(low, high, space),
               na.value = na.value, guide = guide, ...)
}

#' @rdname scale_colour_steps
#' @importFrom scales div_gradient_pal
#' @importFrom scales muted
#' @importFrom ggplot2 binned_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p + geom_shadowpoint() + scale_shadowcolour_steps2() + guides(shadowcolour='none')
#'
scale_shadowcolour_steps2 <- function(..., low = muted("red"), mid = "white", high = muted("blue"),
                                midpoint = 0, space = "Lab", na.value = "grey50", guide = "coloursteps",
                                aesthetics = "shadowcolour") {
  binned_scale(aesthetics, "steps2", div_gradient_pal(low, mid, high, space),
               na.value = na.value, guide = guide, rescaler = mid_rescaler(mid = midpoint), ...)
}

#' @rdname scale_colour_steps
#' @importFrom scales gradient_n_pal
#' @importFrom ggplot2 binned_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolor=gear))
#' p <- p + geom_shadowpoint() + scale_shadowcolour_stepsn(colours=c('red', 'yellow'))
#' p + guides(shadowcolour='none')
#'
scale_shadowcolour_stepsn <- function(..., colours, values = NULL, space = "Lab", na.value = "grey50",
                                guide = "coloursteps", aesthetics = "shadowcolour", colors) {
  colours <- if (missing(colours)) colors else colours
  binned_scale(aesthetics, "stepsn",
               gradient_n_pal(colours, values, space), na.value = na.value, guide = guide, ...)
}

#' @rdname scale_gradient
#' @importFrom scales seq_gradient_pal
#' @importFrom ggplot2 continuous_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(economics, aes(date, unemploy, shadowcolor=pce))
#' p + geom_shadowline() + scale_shadowcolour_gradient() + guides(shadowcolour='none')
#'
scale_shadowcolour_gradient <- function(..., low = "#132B43", high = "#56B1F7", space = "Lab",
                                  na.value = "grey50", guide = "colourbar", aesthetics = "shadowcolour") {
  continuous_scale(aesthetics, "gradient", seq_gradient_pal(low, high, space),
                   na.value = na.value, guide = guide, ...)
}

#' @rdname scale_gradient
#' @importFrom scales div_gradient_pal
#' @importFrom scales muted
#' @importFrom ggplot2 continuous_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(economics, aes(date, unemploy, shadowcolor=pce))
#' p + geom_shadowline() + scale_shadowcolour_gradient2() + guides(shadowcolour='none')
#'
scale_shadowcolour_gradient2 <- function(..., low = muted("red"), mid = "white", high = muted("blue"),
                                   midpoint = 0, space = "Lab", na.value = "grey50", guide = "colourbar",
                                   aesthetics = "shadowcolour") {
  continuous_scale(aesthetics, "gradient2",
                   div_gradient_pal(low, mid, high, space), na.value = na.value, guide = guide, ...,
                   rescaler = mid_rescaler(mid = midpoint))
}

#' @rdname scale_gradient
#' @importFrom scales gradient_n_pal
#' @importFrom ggplot2 continuous_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(economics, aes(date, unemploy, shadowcolor=pce))
#' p <- p + geom_shadowline() + scale_shadowcolour_gradientn(colours=c('red', 'green'))
#' p + guides(shadowcolour='none')
#'
scale_shadowcolour_gradientn <- function(..., colours, values = NULL, space = "Lab", na.value = "grey50",
                                   guide = "colourbar", aesthetics = "shadowcolour", colors) {
  colours <- if (missing(colours)) colors else colours

  continuous_scale(aesthetics, "gradientn",
                   gradient_n_pal(colours, values, space), na.value = na.value, guide = guide, ...)
}

#' @rdname scale_gradient
#' @importFrom scales seq_gradient_pal
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(economics, aes(uempmed, unemploy, shadowcolor=as.POSIXct(date)))
#' p + geom_shadowpath() + scale_shadowcolour_datetime() + guides(shadowcolour='none')
#'
scale_shadowcolour_datetime <- function(...,
                                  low = "#132B43",
                                  high = "#56B1F7",
                                  space = "Lab",
                                  na.value = "grey50",
                                  guide = "colourbar") {
  datetime_scale(
    "shadowcolour",
    "time",
    palette = seq_gradient_pal(low, high, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}

#' @rdname scale_gradient
#' @importFrom scales seq_gradient_pal
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(economics, aes(uempmed, unemploy, shadowcolor=date))
#' p + geom_shadowpath() + scale_shadowcolour_date() + guides(shadowcolour='none')
#'
scale_shadowcolour_date <- function(...,
                              low = "#132B43",
                              high = "#56B1F7",
                              space = "Lab",
                              na.value = "grey50",
                              guide = "colourbar") {
  datetime_scale(
    "shadowcolour",
    "date",
    palette = seq_gradient_pal(low, high, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}

#' @rdname scale_grey
#' @importFrom scales grey_pal
#' @importFrom ggplot2 discrete_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=as.factor(gear)))
#' p + geom_glowpoint() + scale_shadowcolour_grey() + guides(shadowcolour='none')
#'
#'
scale_shadowcolour_grey <- function(..., start = 0.2, end = 0.8, na.value = "red", aesthetics = "shadowcolour") {
  discrete_scale(aesthetics, "grey", grey_pal(start, end),
                 na.value = na.value, ...)
}

#' @rdname scale_viridis
#' @importFrom scales viridis_pal
#' @importFrom ggplot2 discrete_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=as.factor(gear)))
#' p + geom_glowpoint() + scale_shadowcolour_viridis_d() + guides(shadowcolour='none')
#'
scale_shadowcolour_viridis_d <- function(..., alpha = 1, begin = 0, end = 1,
                                   direction = 1, option = "D", aesthetics = "shadowcolour") {
  discrete_scale(
    aesthetics,
    "viridis_d",
    viridis_pal(alpha, begin, end, direction, option),
    ...
  )

}

#' @rdname scale_viridis
#' @importFrom scales viridis_pal
#' @importFrom scales gradient_n_pal
#' @importFrom ggplot2 continuous_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=gear))
#' p + geom_glowpoint() + scale_shadowcolour_viridis_c() + guides(shadowcolour='none')
#'
scale_shadowcolour_viridis_c <- function(..., alpha = 1, begin = 0, end = 1,
                                   direction = 1, option = "D", values = NULL,
                                   space = "Lab", na.value = "grey50",
                                   guide = "colourbar", aesthetics = "shadowcolour") {
  continuous_scale(
    aesthetics,
    "viridis_c",
    gradient_n_pal(
      viridis_pal(alpha, begin, end, direction, option)(6),
      values,
      space
    ),
    na.value = na.value,
    guide = guide,
    ...
  )
}

#' @rdname scale_viridis
#' @importFrom scales gradient_n_pal
#' @importFrom scales viridis_pal
#' @importFrom ggplot2 binned_scale
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=gear))
#' p + geom_glowpoint() + scale_shadowcolour_viridis_b() + guides(shadowcolour='none')
#'
scale_shadowcolour_viridis_b <- function(..., alpha = 1, begin = 0, end = 1,
                                   direction = 1, option = "D", values = NULL,
                                   space = "Lab", na.value = "grey50",
                                   guide = "coloursteps", aesthetics = "shadowcolour") {
  binned_scale(
    aesthetics,
    "viridis_b",
    gradient_n_pal(
      viridis_pal(alpha, begin, end, direction, option)(6),
      values,
      space
    ),
    na.value = na.value,
    guide = guide,
    ...
  )
}

#' @rdname scale_viridis
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=as.factor(gear)))
#' p + geom_glowpoint() + scale_shadowcolour_ordinal() + guides(shadowcolour='none')
#'
scale_shadowcolour_ordinal <- scale_shadowcolour_viridis_d

#' @rdname scale_manual
#' @importFrom ggplot2 waiver
#' @export
#'
#' @examples
#' library( ggplot2 )
#' p <- ggplot(mtcars, aes(wt, mpg, shadowcolour=as.factor(gear)))
#' p <- p + geom_glowpoint() + guides(shadowcolour='none')
#' p + scale_shadowcolour_manual(values=c('red', 'blue', 'green'))
#'
scale_shadowcolour_manual <- function(..., values, aesthetics = "shadowcolour", breaks = waiver()) {
  manual_scale(aesthetics, values, breaks, ...)
}

