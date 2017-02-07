#   Description:
#       contribution_articulation_anthropo is used to get weight and height of all subjects
#   Output:
#       contribution_articulation_traitement gives Rdata
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________


# Load data ---------------------------------------------------------------
lapply(c("tidyr", "dplyr", "readxl", "magrittr", "knitr"),
       require,
       character.only = T)

IRSST <- read_excel(
    "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/IRSST_infos_sujets.xlsx",
    sheet = "Global")


# Reshape data ------------------------------------------------------------------

IRSSwT <- IRSST %>% 
  select(Sexe, Poids, Taille, Traitement)

filter(IRSST, Traitement == 'x')
