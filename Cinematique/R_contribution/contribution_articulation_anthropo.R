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
    "//10.89.24.15/e/Projet_IRSST_LeverCaisse/ElaboratedData/IRSST_subjects.xlsx",
    sheet = "Global")

# Reshape data ------------------------------------------------------------------
IRSST[, c(5:7)] <- sapply(IRSST[, c(5:7)], as.numeric)
IRSST <- IRSST[ !(IRSST$Modèle %in% 'x'), ]

men <- IRSST %>%
  filter(sex == 'H')

women <- IRSST %>%
  filter(sex == 'F')

# Parameters ------------------------------------------------------------------
anthropo <- data.frame(number = c(men %>% nrow,women %>% nrow),
                       mean.age = c(mean(men$age, na.rm = TRUE), mean(women$age, na.rm = TRUE)),
                       std.age = c(sd(men$age, na.rm = TRUE), sd(women$age, na.rm = TRUE)),
                       mean.weight = c(mean(men$weight), mean(women$weight)),
                       std.weight = c(sd(men$weight), sd(women$weight)),
                       mean.height = c(mean(men$height),mean(women$height)),
                       std.height = c(sd(men$height), sd(women$height)))

anthropo[,-1] <- anthropo[,-1] %>% round(digits = 2)

saveRDS(anthropo, file.path(paste(path.output,"anthropo.rds", sep = "")))
