#### Generate some fake data ####
DG <- list() # DG for data generation, create a list to encompass all related variables
DG$n <- 100
DG$data <- tibble(
  id = paste0("A", sprintf("%03d", 1:DG$n)),
  height = runif(DG$n) * 40 + 165,
  weight = height * 0.4 + rnorm(DG$n) * 10,
  eat.banana = sample(c("Yes", "No", "sometimes", "lol"), size = DG$n, replace = T, prob = c(0.4, 0.4, 0.1, 0.1))
) %T>% ggscatter(x = "height", y = "weight", cor.coef = T, add = "reg.line")

# Export
DG$data %>% openxlsx::write.xlsx(file.path(dirs$repo, "sample_data.xlsx"), overwrite = T)

#### Generate Variable Description Config ####
DG$varCfg <- list("id" = "Patient id", 
     "height" = "Patient height",
     "weight" = "Patient weight",
     "eat.banana" = "Do they eat banana?") %>% 
  {tibble(name = names(.), description = as.character(.))}

list("general" = DG$varCfg) %>% openxlsx::write.xlsx(file.path(dirs$config, "variable cfg.xlsx"), overwrite = T)

dirs$config %>% reveal_in_finder()
