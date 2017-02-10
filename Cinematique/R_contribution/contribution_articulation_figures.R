#   Description: generate figures
#   Output: gives figures in pdf, svg and Rdata
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________

# preparation ----------------------------------------------------------------
# packages
lapply(c("tidyr", "dplyr", "ggplot2", "readxl", "magrittr", "knitr", "grid", "ggthemes"),
       require,
       character.only = T)
# path
setwd("C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution/")

# switch
plot_gantt  <- TRUE
plot_radar  <- TRUE
variable    <- 'hauteur'
comparison  <- 'relative'

# load data ---------------------------------------------------------------
datapath <- file.path("//10.89.24.15/e/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM",
                      paste(variable, "_", comparison, ".xlsx", sep = ""))

data.sheet <- c("anova", "interaction", "mainA", "mainB")
for (isheet in 1:4) {
  assign(data.sheet[isheet],
         read_excel(datapath,
                    sheet = data.sheet[isheet],
                    na = "NA"))
  }
# reshape data ------------------------------------------------------------
interaction$sens[interaction$height == 1 | interaction$height == 2 | interaction$height == 4] <- "1"
interaction$sens[interaction$height == 3 | interaction$height == 5 | interaction$height == 6] <- "2"

factor.delta <- function(x){
  factor(x = x, levels = c(1:4), labels = c("hand + EL", "GH", "SCAC", "RoB"))
}

anova$delta <- anova$delta %>% factor.delta
interaction$delta <- interaction$delta %>% factor.delta
mainA$delta <- mainA$delta %>% factor.delta
mainB$delta <- mainB$delta %>% factor.delta

interaction$height <- interaction$height %>% 
  factor(levels = c(1:6),
         labels = c("hips-shoulder","hips-eyes","hips-shoulder","shoulders-eyes","hips-eyes","shoulders-eyes"))

interaction$sens <- interaction$sens %>% 
  factor(levels = c(1:2),
         labels = c("upward","downward"))

# Create output table -----------------------------------------------------
# saveRDS(data.sex,"output/table.posthoc.sex.rds")
# saveRDS(data.height,"output/table.posthoc.height.rds")

# gantt plot --------------------------------------------------------------
source("functions/plot.gantt.R")
plot.gantt(interaction, annotation = FALSE, save = TRUE, scale.free = FALSE)


# test --------------------------------------------------------------------
# data.0d.sex <- data.0d.sex  %>%
#   gather(key = key, value = value, 4:9) %>%
#   separate(key, c("valeur", "sex"), sep = "_") %>%
#   spread(valeur, value)
# 
# bar <- ggplot(data = zeroD_bar, aes(x = delta, y = moy, fill = sex))
# bar <- bar + geom_bar(stat = "identity", position = position_dodge())
# bar <- bar + facet_grid(height ~ weight)
# bar