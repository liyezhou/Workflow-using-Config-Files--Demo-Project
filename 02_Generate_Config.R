#### Generate Analysis Config ####
# you can either generate in R, or write it by hand in excel
CG <- list() # Config Gen

# Generate 8 different analysis configurations
CG$cfg <-
  expand.grid(maxHeight = c(190, 200), 
              minWeight = c(60, 70),
              bananaProcMethod = c("Conservative", "AutoClassification")) %>% as_tibble() %>% 
    mutate(index = row_number(), .before = 1) %T>% print


#### Export Config ####
CG$cfg %>% write_csv(file.path(dirs$config, "analysis config.csv"))

# also write a template for writing configuration output files after preprocessing
CG$cfg %>% openxlsx::write.xlsx(file.path(dirs$config, "analysis config output.xlsx"), overwrite = T)
