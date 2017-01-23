#   Description:
#       contribution_hauteur_traitement is used to generate figures
#   Output:
#       contribution_hauteur_traitement gives figures in pdf, svg and Rdata
#   Functions:
#       contribution_hauteur_traitement uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
#
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________

# Preparation ----------------------------------------------------------------
# Packages
lapply(c("tidyr", "dplyr", "ggplot2", "readxl", "magrittr", "knitr"),
       require,
       character.only = T)
# Path
setwd("C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution/")

# Load data ---------------------------------------------------------------
anova <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx",
  sheet = "anova",
  na = "NA")

posthoc <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx",
  sheet = "posthoc",
  na = "NA")

# Factor ------------------------------------------------------------------
anova$delta  <- factor(x = anova$delta,
                       labels = c("delta hand + EL", "delta GH", "delta SCAC", "delta RoB"))
anova$effect <- factor(x = anova$effect,
                       levels = c("Main A", "Main B", "Main C", "Interaction AB", "Interaction AC", "Interaction BC", "Interaction ABC"),
                       labels = c("sexe", "hauteur", "poids", "sexe-hauteur", "sexe-poids", "hauteur-poids", "sexe-hauteur-poids"))

posthoc$delta <- factor(x = posthoc$delta,
                       labels = c("delta hand + EL", "delta GH", "delta SCAC", "delta RoB"))

# Height
height <- rep(c("hips-shoulders", "hips-eyes", "shoulders-hips", "shoulder-eyes", "eyes-hips", "eyes-shoulder"), times = 2)
posthoc$men <- factor(x = posthoc$men,
                        levels = c(7:18),
                        labels = height)
# Weight
weight <- c(rep("12kg-6kg", times = 6), rep("18kg-12kg", times = 6))
posthoc$women <- factor(x = posthoc$women,
                      levels = c(1:12),
                      labels = weight)

# Rename column
names(posthoc)[names(posthoc) == 'men'] <- 'height'
names(posthoc)[names(posthoc) == 'women'] <- 'weight'


# Create output table -----------------------------------------------------
saveRDS(anova, "output/table.anova.rds")
saveRDS(posthoc, "output/table.posthoc.rds")


