#### Read Analysis Config ####
HA <- list() # Height analysis
HA$cfgs <- openxlsx::read.xlsx(file.path(dirs$config, "analysis config output.xlsx")) %>% tibble()

#### Run a simple multiple regression ####
glm <- list()
i <- 1 # again, for individual debugging
for(i in 1:nrow(HA$cfgs)){
  glm[[i]] <- list()
  glm[[i]]$data.cfg <- HA$cfgs %>% slice(i)
  glm[[i]]$data <- openxlsx::read.xlsx(file.path(glm[[i]]$data.cfg$dir, "selected_data.xlsx")) %>% as_tibble()
  glm[[i]]$res <- glm[[i]]$data %>% mutate(
    eat.banana.yes = as.numeric(eat.banana.yes)
  ) %>% 
    lm(height ~ weight + eat.banana.yes, data = .) %>% 
    summary %>% 
    tidy
}
#### Combine Results ####
# One way to write this
1:8 %>% map(~{
  glm[[.x]]$res %>% mutate(
    analysis.index = HA$cfgs$index[[.x]]
  ) %>% add_signif_and_format(p.col = "p.value")
  }) %>% bind_rows %>% view

# Another way to write this
HA$glm.res <- HA$cfgs %>% mutate(
  glm = 1:n() %>% map(~glm[[.x]]$res)
) %>% unnest(glm)  %>% 
  add_signif_and_format(p.col = "p.value") %T>% 
  view

#### Review Results ####
# see how filtering maxHeight influence the effect of weight
HA$glm.res %>% names
HA$glm.res %>% 
  filter(term == "weight") %>%
  ggscatter(x = "maxHeight", y = "estimate") + currentTheme
HA$glm.res %>% 
  filter(term == "weight") %>%
  ggscatter(x = "maxHeight", y = "p.value") + currentTheme

# See how the participant count affects p.value
HA$glm.res %>% mutate(
  n.participant = included.participants %>% map_int(~length(str_split(.x, ";")[[1]]))
) %>% 
  filter(term == "weight") %>%
  ggscatter(x = "n.participant", y = "p.value", cor.coef = T, add = "reg.line") + currentTheme
