## ----include=FALSE------------------------------------------------------------
knitr::opts_chunk$set(warning = FALSE, message = TRUE)

library(ggplot2)
library(ggshadow)

## ----fig.height=7, fig.width=7------------------------------------------------
library(ggshadow)

ggplot(economics_long, aes(date, value01, colour = variable)) + geom_shadowline()


## ----fig.height=7, fig.width=7------------------------------------------------
library(ggshadow)

ggplot(economics_long, aes(date, value01, group = variable, colour=value01, shadowcolor='grey', shadowalpha=0.5, shadowsize=5*(1-value01))) + geom_shadowline()


## ----fig.height=7, fig.width=7------------------------------------------------
ggplot(mtcars, aes(wt, mpg)) + geom_shadowpoint(aes( color = carb, shadowcolour = ifelse(vs == 1, 'red', 'blue') ))


