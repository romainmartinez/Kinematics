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
rm(list = ls())

# Packages ----------------------------------------------------------------
lapply(c("tidyr","dplyr","ggplot2", "readxl", "magrittr"), require, character.only = T)


# Load data ---------------------------------------------------------------
anova <- read_excel("Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx", sheet = "anova", na = "NA")
anova$delta <- factor(x = anova$delta, labels = c("delta hand + EL", "delta GH", "delta SCAC", "delta RoB"))
  
  
  posthoc <- read_excel("Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_hauteur/SPM/relative_ANOVA.xlsx",
                        sheet = "posthoc", na = "NA")
  