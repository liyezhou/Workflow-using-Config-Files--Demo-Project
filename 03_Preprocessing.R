#### Control Center ####
# IMPORTANT: Run this section last, run the sections below first
{
  tictoc::tic("Preprocess Data")
  success <- numeric()
  failure <- numeric()
  for(i in c(1:8)){
    status <- preprocess_data(i)  
    if(status==0){
      success <- c(success, i)
    } else {
      failure <- c(failure, i)
    }
  }
  print("\n\n")
  print(glue("Finished with {length(success)} successes and {length(failure)} failures."))
  if(length(failure)!=0){
    print(glue("failed at {paste0(failure, collapse = \", \")}."))
  }
  tictoc::toc()
  reveal_in_finder(dirs$analysis)
}


#### Read Config ####
# This file mainly cleans up the data and set up the analysis folders
DPCfg <- list() #Data Preprocessing Config
DPCfg$cfgs <- read.csv(file.path(dirs$config, "analysis config.csv")) %>% as_tibble()


#### Define Function ####
index <- 1 # This is for debugging, pass index = 1 and run the function below manually

preprocess_data <- function(index) {
  tryCatch(
    {
      cat("\n\n\n\n\n\n\n\n")
      cat(glue("------ analysis index: {index}------"))
      cat("\n")
      #### Import Data ####
      DP <- list()
      DP$cfg <- DPCfg$cfgs[index,] %T>% print
      DP$data <- openxlsx::read.xlsx(file.path(dirs$repo, "sample_data.xlsx")) %>% as_tibble()
      
      #### Data Selection ####
      DP$data <- DP$data %>% filter(
        height <= DP$cfg$maxHeight,
        weight >= DP$cfg$minWeight
      ) %T>% {print(glue("There are {nrow(.)} participants left after selection."))}
      
      #### Process Some Columns ####
      process_banana_eating_habits <- function(eat.banana) {
        # Write your own function here to determine how you deal with random answers it
        if(eat.banana == "sometimes") {return("Yes")}
        if(eat.banana == "lol") {return(sample(c("Yes", "No"), 1))} else {
          return(eat.banana)
        }
      }
      
      if(DP$cfg$bananaProcMethod == "Conservative"){
        DP$data <- DP$data %>% mutate(
          eat.banana = ifelse(eat.banana %in% c("Yes", "No"), eat.banana, NA)
        ) 
      } else if(DP$cfg$bananaProcMethod == "AutoClassification"){
        DP$data <- DP$data %>% mutate(
          eat.banana = eat.banana %>% map_chr(process_banana_eating_habits)
        ) 
      }
      
      DP$data <- DP$data %>% mutate(
        eat.banana.yes = plyr::mapvalues(eat.banana, c("Yes", "No"), c(1, 0))
      )
      
      #### Establish Directory ####
      DP$hash <- digest::digest(list(ids = DP$data$id, cfg = DP$cfg), algo = "xxhash32") # Generate a unique id for this analysis
      # SE = smaller or equal to
      DP$analysis.name <- glue("analysis_{DP$cfg$index}_heightSE{DP$cfg$maxHeight}_weightLE{DP$cfg$minWeight}_{DP$hash}")
      DP$cfg$dir <- file.path(dirs$analysis, DP$analysis.name) %T>% print
      if(!dir.exists(DP$cfg$dir)) {dir.create(DP$cfg$dir)}
      
      #### Export Selected Data ####
      DP$data %>% openxlsx::write.xlsx(file.path(DP$cfg$dir, "selected_data.xlsx"), overwrite = T)
      saveRDS(DP, file.path(DP$cfg$dir, glue("{DP$analysis.name}.RDS")))
      
      #### Export Manifest ####
      sink(file.path(DP$cfg$dir, "manifest.txt"))
      cat("analysis name:", DP$analysis.name,"\n\n")
      cat("-----participant list-----\n")
      cat(paste(DP$data$id, sep = ";"))
      cat("\n\n\n preprocessor V1.0")
      sink()
      
      #### Write Analysis Config Output ####
      # add metadata
      DP$cfg <-
        DP$cfg %>% 
        add_column(time = format(Sys.time(), "%Y-%m-%d %X"), .before = 1) %>% 
        add_column(
          included.participants = DP$data$id %>% paste0(collapse = ";"),
          exporter.version = "V1.0",
          absTime = as.numeric(Sys.time())*1000,
          hash = DP$hash) %T>% print_tibble_row()
      
      # save to local folder
      DP$cfg %>% write_csv(file.path(DP$cfg$dir, "configs.csv"))
      
      # save to config folder
      if(!file.exists(file.path(dirs$config, "analysis config output.xlsx"))) {
        # create new
        DP$cfg %>% 
          relocate(index) %>% 
          openxlsx::write.xlsx(file.path(dirs$config, "analysis config output.xlsx"), overwrite = T)
      } else {
        # Append to existing
        openxlsx::read.xlsx(file.path(dirs$config, "analysis config output.xlsx")) %>% as_tibble() %>% 
          bind_rows(DP$cfg) %>% 
          arrange(desc(absTime)) %>% 
          distinct(index, .keep_all = T) %>% 
          relocate(index) %>% 
          openxlsx::write.xlsx(file.path(dirs$config, "analysis config output.xlsx"), overwrite = T)
      }
      
      #### Post Export Checks ####
      assertthat::assert_that(nrow(DP$data) > 10, msg = "Too few participants")
      
      return(0)
    },
    error=function(cond) {
      message("Here's the original error message:")
      message(cond)
      beepr::beep(sound = 7)
      # Choose a return value in case of error
      return(1)
    },
    warning=function(cond) {
      message("Here's the original warning message:")
      message(cond)
      beepr::beep(sound = 7)
      # Choose a return value in case of warning
      return(1)
    },
    finally = {
      # Something regardless of success or failure
    }
  )
}

