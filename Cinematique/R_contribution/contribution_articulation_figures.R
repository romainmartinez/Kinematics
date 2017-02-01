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
delete.na   <- TRUE
plot_gantt  <- TRUE
plot_radar  <- TRUE
delete.zone <- TRUE

# load data ---------------------------------------------------------------
data <- read_excel(
  "Z:/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/hauteur_relative_posthoc.xlsx",
  sheet = "posthoc",
  na = "NA")

# reshape data ------------------------------------------------------------
AB <- data %>% 
  filter(comp == 'Interaction AB') %>% 
  rename(hauteur = facteur2, poids = facteur3) %>% 
  mutate()

AC <- data %>% 
  filter(comp == 'Interaction AC') %>% 
  rename(poids = facteur2, hauteur = facteur3)

BC <- data %>% 
  filter(comp == 'Interaction BC')

mtcars <- mtcars %>%
  mutate(mpg=replace(mpg, cyl==4, NA))
  
# Factor ------------------------------------------------------------------
## Delta
data$delta   <- data$delta %>% factor(labels = c("hand + EL", "GH", "SCAC", "RoB"))

## effect
anova$effect <- anova$effect %>% factor(levels = c("Main A", "Main B", "Main C", "Interaction AB", "Interaction AC", "Interaction BC", "Interaction ABC"),
                                        labels = c("sexe", "hauteur", "poids", "sexe-hauteur", "sexe-poids", "hauteur-poids", "sexe-hauteur-poids"))

## Height
height <- c(rep(c("hips-shoulders", "hips-eyes", "shoulders-eyes"), times = 2), 
            rep(c("shoulders-hips", "eyes-hips", "eyes-shoulders"), times = 2))

posthoc$men <- posthoc$men %>% factor(levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                                      labels = height)
zeroD$men <- zeroD$men %>% factor(levels = c(7,8,10,13,14,16,9,11,12,15,17,18), 
                                  labels = height)
## Weight
weight <- c(rep("12kg-6kg",  times = 6), 
            rep("18kg-12kg", times = 6))

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

# Delete zone < 10 % ------------------------------------------------------
if (delete.zone == TRUE) {
  posthoc <- posthoc %>% filter(end - start > 10)
}

# Delete non-significant row ----------------------------------------------
if (delete.na == TRUE) {
  anova   <- anova   %>% filter(h0reject == 1)
  posthoc <- posthoc %>% filter(h0reject == 1)
}

# main effect of gender ---------------------------------------------------
gendereffect <- filter(anova, effect == "sexe")

# Create output table -----------------------------------------------------
saveRDS(gendereffect,"output/table.gendereffect.rds")
saveRDS(anova,       "output/table.anova.rds")
saveRDS(posthoc,     "output/table.posthoc.rds")
saveRDS(zeroD,       "output/table.zeroD.rds")

# gantt plot --------------------------------------------------------------
source("functions/plot.gantt.R")
plot.gantt(posthoc, annotation = FALSE, save = TRUE, scale.free = FALSE)


# test --------------------------------------------------------------------
zeroD_bar <- zeroD %>%
  gather(key = key, value = value, 4:9) %>%
  separate(key, c("valeur", "sex"), sep = "_") %>%
  spread(valeur, value)

bar <- ggplot(data = zeroD_bar, aes(x = delta, y = moy, fill = sex))
bar <- bar + geom_bar(stat = "identity", position = position_dodge())
bar <- bar + facet_grid(height ~ weight)
bar

