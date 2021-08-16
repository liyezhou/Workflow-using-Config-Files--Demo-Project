# rm(list = ls())
library(plyr)
library(rstatix)
library(ggpubr)
library(broom)
library(glue)
library(ggsignif)
library(magrittr)
# renv::install(file.path(getwd(), "YZUtils_0.1.4.tgz"))
library(YZUtils) # Some of my own utilities!
library(tidyverse)
# renv::install("DiagrammeRsvg")

#### Directories ####
dirs <- list(
  repo = file.path("data"),
  export = file.path("export"),
  config = file.path("config"),
  analysis = file.path("analyses")
)
for(dir in dirs) {
  if(!dir.exists(dir)) {dir.create(dir)}
}

#### Names ####
vars <- list()
vars$gen <- openxlsx::read.xlsx(file.path(dirs$config, "variable cfg.xlsx"), sheet = "general") # This is later generated, doens't matter for this demonstration

#### Index Data Files ####
repo.files <- tibble(full.name = list.files(dirs$repo, full.names = T, recursive = T, include.dirs = F)) %>%
  mutate(
    file.name = full.name %>% basename,
    dir = full.name %>% map_chr(dirname),
    extension = full.name %>% map_chr(tools::file_ext)
  )


### Styles
accentColor <- "#449FD9"
colors <- list(Pair1 = c("#EA4D95", "#FFDC91"), Pair2 = c("#65B33A","#FBC531"), Pair3 = c("#E74219","#FBC531"), 
               DarkPair1 = c("#6F98AD", "#FFDC91"),
               Contrast1 = c("#65B33A", "#FBC531","#E74219", "#449FD9", "#8B84BF"), 
               Contrast2 = c("#E28726","#EA4D95","#0073B6","#BD3C28","#7876B2"),
               RedGreen = c("#E74219","#65B33A"),
               LowSat = c("#F5F6FA","#7F8FA6","#353B48"),
               Gray4 = c("#333333","#666666","#999999", "#CCCCCC") %>% rev,
               Gray6 = c("#222222","#444444","#666666", "#888888", "#AAAAAA", "#CCCCCC") %>% rev,
               AccentColor = accentColor)
currentPalette <- "npg"
textStyles <- list(label = list(size = 15, face = "plain", color ="#AAAAAA"))
currentTheme <- theme_gray()

