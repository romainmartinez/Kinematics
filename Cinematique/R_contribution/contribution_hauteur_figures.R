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

# Packages ----------------------------------------------------------------
lapply(c("tidyr", "dplyr", "ggplot2", "readxl", "magrittr", "knitr"),
       require,
       character.only = T)


# Load data ---------------------------------------------------------------
anova <-
  read_excel(
    "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx",
    sheet = "anova",
    na = "NA"
  )


# Factor ------------------------------------------------------------------
anova$delta  <- factor(x = anova$delta,
                       labels = c("delta hand + EL", "delta GH", "delta SCAC", "delta RoB"))
anova$effect <- factor(x = anova$effect,
                       levels = c("Main A", "Main B", "Main C", "Interaction AB", "Interaction AC", "Interaction BC", "Interaction ABC"),
                       labels = c("sexe", "hauteur", "poids", "sexe-hauteur", "sexe-poids", "hauteur-poids", "sexe-hauteur-poids"))

# Create output table

table.anova <- knitr::kable(x = anova)
saveRDS(anova, "output/table.anova.rds")


# posthoc <- read_excel("Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx",
#                       sheet = "posthoc", na = "NA")
