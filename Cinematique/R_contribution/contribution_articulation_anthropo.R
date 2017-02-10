#   Description: used to get weight and height of all subjects
#   Output: gives Rdata
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
men <- IRSST %>% 
  filter(Sexe == 'H')
women <- IRSST %>% 
  filter(Sexe == 'F')

# Parameters ------------------------------------------------------------------
# Numbers
number.m <- men %>% filter(Traitement == 'x')
number.w <- women %>% filter(Traitement == 'x')
# Weight
# Height

