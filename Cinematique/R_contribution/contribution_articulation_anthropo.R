#   Description: used to get weight and height of all subjects
#   Output: gives Rdata
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________

# Packages
lapply(c("tidyr", "dplyr", "readxl", "magrittr", "knitr"),
       require,
       character.only = T)
# path
path.current <- "C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution/"
path.output  <- "C:/Users/marti/Documents/Codes/Writting/article-contributions/inputs/"
setwd(path.current)

# Load data ---------------------------------------------------------------
IRSST <- read_excel(
    "//10.89.24.15/e/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/IRSST_infos_sujets.xlsx",
    sheet = "Global")

# Reshape data ------------------------------------------------------------------
IRSST[, c(5:6)] <- sapply(IRSST[, c(5:6)], as.numeric)
men <- IRSST %>%
  filter(Sexe == 'H' & Traitement == 'x')
women <- IRSST %>%
  filter(Sexe == 'F' & Traitement == 'x')

# Parameters ------------------------------------------------------------------
anthropo <- data.frame(number = c(men %>% nrow,women %>% nrow),
                       mean.weight = c(mean(men$Poids), mean(women$Poids)),
                       std.weight = c(sd(men$Poids), sd(women$Poids)),
                       mean.height = c(mean(men$Taille),mean(women$Taille)),
                       std.height = c(sd(men$Taille), sd(women$Taille)))

anthropo[,-1] <- anthropo[,-1] %>% round(digits = 2)

saveRDS(anthropo, file.path(paste(path.output,"anthropo.rds", sep = "")))
