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
anova$delta   <- factor(x = anova$delta,
                       labels = c("hand + EL", "GH", "SCAC", "RoB"))
posthoc$delta <- factor(x = posthoc$delta,
                       labels = c("hand + EL", "GH", "SCAC", "RoB"))
zeroD$delta   <- factor(x = zeroD$delta,
                       labels = c("hand + EL", "GH", "SCAC", "RoB"))

## effect
anova$effect <- factor(x = anova$effect,
                       levels = c("Main A", "Main B", "Main C", "Interaction AB", "Interaction AC", "Interaction BC", "Interaction ABC"),
                       labels = c("sexe", "hauteur", "poids", "sexe-hauteur", "sexe-poids", "hauteur-poids", "sexe-hauteur-poids"))

## Height
height <- c(rep(c("hips-shoulders", "hips-eyes", "shoulders-eyes"), times = 2), rep(c("shoulder-hips", "eyes-hips", "eyes-shoulder"), times = 2))

posthoc$men <- factor(x = posthoc$men,
                        levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                        labels = height)
zeroD$men <- factor(x = zeroD$men,
                      levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                      labels = height)
## Weight
weight <- c(rep("12kg-6kg", times = 6), rep("18kg-12kg", times = 6))

posthoc$women <- factor(x = posthoc$women,
                      levels = c(1:12),
                      labels = weight)
zeroD$women <- factor(x = zeroD$women,
                        levels = c(1:12),
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
  anova   <- dplyr::filter(anova,   h0reject == 1)
  posthoc <- dplyr::filter(posthoc, h0reject == 1)
}

# Create output table -----------------------------------------------------
saveRDS(anova,   "output/table.anova.rds")
saveRDS(posthoc, "output/table.posthoc.rds")
saveRDS(zeroD,   "output/table.zeroD.rds")

# gantt plot --------------------------------------------------------------
source("functions/plot.gantt.R")
plot.gantt(posthoc, annotation = FALSE, save = TRUE, scale.free = FALSE)


# test --------------------------------------------------------------------


ggradar(zeroD)
