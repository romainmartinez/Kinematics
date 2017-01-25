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

# Preparation ----------------------------------------------------------------
# Packages
lapply(c("tidyr", "dplyr", "ggplot2", "readxl", "magrittr", "knitr", "grid", "ggthemes", "ggradar", "scales"),
       require,
       character.only = T)
# Path
setwd("C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution/")

# Switch
delete.na  <- TRUE
plot_gantt <- TRUE
plot_radar <- TRUE

# Load data ---------------------------------------------------------------
anova <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/height_relative_ANOVA.xlsx",
  sheet = "anova",
  na = "NA")

posthoc <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/height_relative_ANOVA.xlsx",
  sheet = "posthoc",
  na = "NA")

zeroD <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/height_relative_ANOVA.xlsx",
  sheet = "zeroD",
  na = "NA")

# Factor ------------------------------------------------------------------
## Delta
anova$delta   <- anova$delta %>% factor(labels = c("hand + EL", "GH", "SCAC", "RoB"))
posthoc$delta <- posthoc$delta %>% factor(labels = c("hand + EL", "GH", "SCAC", "RoB"))
zeroD$delta   <- zeroD$delta %>% factor(labels = c("hand + EL", "GH", "SCAC", "RoB"))

## effect
anova$effect <- anova$effect %>% factor(
                       levels = c("Main A", "Main B", "Main C", "Interaction AB", "Interaction AC", "Interaction BC", "Interaction ABC"),
                       labels = c("sexe", "hauteur", "poids", "sexe-hauteur", "sexe-poids", "hauteur-poids", "sexe-hauteur-poids"))

## Height
height <- c(rep(c("hips-shoulders", "hips-eyes", "shoulders-eyes"), times = 2), rep(c("shoulders-hips", "eyes-hips", "eyes-shoulders"), times = 2))

posthoc$men <- posthoc$men %>% factor(levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                                      labels = height)
zeroD$men <- zeroD$men %>% factor(levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                                  labels = height)
## Weight
weight <- c(rep("12kg-6kg", times = 6), rep("18kg-12kg", times = 6))

posthoc$women <- posthoc$women %>% factor(levels = c(1:12),
                                          labels = weight)
zeroD$women <- zeroD$women %>% factor(levels = c(1:12),
                                      labels = weight)

## Rename column
posthoc <- posthoc %>%
  rename(height = men) %>% 
  rename(weight = women)
zeroD <- zeroD %>%
  rename(height = men) %>% 
  rename(weight = women)

# Delete non-significant row ----------------------------------------------
if(delete.na == TRUE){
  anova   <- anova   %>% filter(h0reject == 1)
  posthoc <- posthoc %>% filter(h0reject == 1)
  
}

# Create output table -----------------------------------------------------
saveRDS(anova,   "output/table.anova.rds")
saveRDS(posthoc, "output/table.posthoc.rds")
saveRDS(zeroD,   "output/table.zeroD.rds")

# gantt plot --------------------------------------------------------------
source("functions/plot.gantt.R")
plot.gantt(posthoc, annotation = FALSE, save = TRUE, scale.free = FALSE)


# test --------------------------------------------------------------------
zeroD_radar <- cbind(zeroD$delta, zeroD$moy_men)
zeroD_radar <- zeroD %>%
  gather(key = key, value = value, 4:9) %>%
  filter(height != "eyes-shoulders" & height != "shoulders-eyes")


ggradar(zeroD_radar)
