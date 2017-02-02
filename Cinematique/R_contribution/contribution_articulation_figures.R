#   Description:
#       contribution_articulation_traitement is used to generate figures
#   Output:
#       contribution_articulation_traitement gives figures in pdf, svg and Rdata
#   Functions:
#       contribution_articulation_traitement uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
#
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________

# preparation ----------------------------------------------------------------
# packages
lapply(c("tidyr", "dplyr", "ggplot2", "readxl", "magrittr", "knitr", "grid", "ggthemes", "ggradar", "scales"),
       require,
       character.only = T)
# path
setwd("C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution/")

# switch
plot_gantt  <- TRUE
plot_radar  <- TRUE
delete.zone <- FALSE
variable    <- 'hauteur'
comparison  <- 'absolute'

# load data ---------------------------------------------------------------
datapath <- file.path("//10.89.24.15/e/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM", paste(variable,"_",comparison,"_posthoc.xlsx", sep = ""))
data.sex <- read_excel(datapath,
                   sheet = "posthoc",
                   na = "NA")
# reshape data ------------------------------------------------------------
factor.height <- function(x){factor(x = x, 
                   levels = c(1,2,4,3,5,6),
                   labels = c("hips-shoulders","hips-eyes","shoulders-eyes","shoulders-hips","eyes-hips","eyes-shoulders"))}
factor.weight <- function(x){factor(x = x, 
                    levels = c(1,2),
                    labels = c("12kg-6kg","18kg-12kg"))}
factor.sex <- function(x){factor(x = x, 
                    levels = c(1,2),
                    labels = c("men","women"))}
data.sex$delta <- data.sex$delta %>% factor(labels = c("hand + EL", "GH", "SCAC", "RoB"))

# AB
AB <- data.sex %>% 
  filter(comp == 'Interaction AB') %>% 
  rename(height = facteur2, weight = facteur3)
AB$sup <- AB$sup %>% factor.sex
AB$inf <- AB$inf %>% factor.sex
AB$height <- AB$height %>% factor.height
AB$weight <- AB$weight %>% factor.weight

# AC
AC <- data.sex %>% 
  filter(comp == 'Interaction AC') %>% 
  rename(weight = facteur2, height = facteur3)
AC$sup <- AC$sup %>% factor.sex
AC$inf <- AC$inf %>% factor.sex
AC$height <- AC$height %>% factor.height
AC$weight <- AC$weight %>% factor.weight

# BC
BC <- data.sex %>% 
  filter(comp == 'Interaction BC') %>% 
  rename(weight = facteur2, sexe = facteur3)
BC$sup <- BC$sup %>% factor.height
BC$inf <- BC$inf %>% factor.height
BC$weight <- BC$weight %>% factor.weight
BC$sexe <- BC$sexe %>% factor.sex 

data.sex <- union(AB,AC); rm(AB,AC)
data.height <- BC;rm(BC)

data.0d.sex <- data.sex %>% select(delta,height,weight,contains("inf"),contains("sup"))
data.0d.height <- data.height %>% select(delta,weight,sexe,contains("inf"),contains("sup"))

# Delete zone < 10 % ------------------------------------------------------
if (delete.zone == TRUE) {
  data.sex <- data.sex %>% filter(end - start > 10)
}

# Create output table -----------------------------------------------------
saveRDS(data.sex,"output/table.posthoc.sex.rds")
saveRDS(data.height,"output/table.posthoc.height.rds")

# gantt plot --------------------------------------------------------------
source("functions/plot.gantt.R")
plot.gantt(data.sex, annotation = FALSE, save = TRUE, scale.free = FALSE)


# test --------------------------------------------------------------------
data.0d.sex <- data.0d.sex  %>%
  gather(key = key, value = value, 4:9) %>%
  separate(key, c("valeur", "sex"), sep = "_") %>%
  spread(valeur, value)

bar <- ggplot(data = zeroD_bar, aes(x = delta, y = moy, fill = sex))
bar <- bar + geom_bar(stat = "identity", position = position_dodge())
bar <- bar + facet_grid(height ~ weight)
bar