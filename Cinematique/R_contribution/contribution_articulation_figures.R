#   Description: generate figures
#   Output: gives figures in pdf, svg and Rdata
#   Author:  Romain Martinez
#   email:   martinez.staps@gmail.com
#   Website: https://github.com/romainmartinez
#_____________________________________________________________________________

# preparation ----------------------------------------------------------------
# packages
lapply(c("tidyr", "dplyr", "cowplot", "magrittr", "knitr", "grid", "ggthemes", "gridExtra"),
       require,
       character.only = T)

# path
datapath <- "/media/E/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/"
path.current <- '/home/romain/Documents/codes/Kinematics/Cinematique/R_contribution'
setwd(path.current)

# switch
variable    <- 'hauteur'
comparison  <- '18vs6'
keepMainB <- 0

# load data ---------------------------------------------------------------
anova <- read.table(file.path(datapath, variable, 'anova', comparison, '.csv', fsep = ''), header = TRUE, sep = ",")
interaction <- read.table(file.path(datapath, variable, 'interaction', comparison, '.csv', fsep = ''), header = TRUE, sep = ",")

# reshape data ------------------------------------------------------------
source("functions/reshape_interaction.R")
interaction <- reshape_interaction(interaction)

anova$delta <- anova$delta %>% factor(levels = c(1:4), labels = c("WR/EL", "GH", "SC/AC", "TR/PE"))
interaction$delta <- interaction$delta %>% factor(levels = c(1:4), labels = c("WR/EL", "GH", "SC/AC", "TR/PE"))

anova$effect <- anova$effect %>%
  factor(levels = c('Main A', 'Main B', 'Interaction AB'),
         labels = c("main effect: sex","main effect: task","interaction: sex-task"))

interaction$height <- interaction$height %>% factor(levels = c('hips-shoulders','hips-eyes','shoulders-eyes') )

interaction$sens <- interaction$sens %>% factor(levels = c(1:2), labels = c("upward","downward"))

# delete diff < 1%
anova <- anova %>% filter(abs(diff) > 1)

# delete main effect task (not needed)
if (keepMainB == 0) {
  anova <- anova %>% filter(effect != 'main effect: task')
}

# gantt plot --------------------------------------------------------------
plot_limit <- c(interaction$diff,anova$diff) %>% abs() %>% max() %>% round() + 1
#plot_limit <- 15
source("functions/plot_gantt.R")
plot_gantt(anova, plot_limit, case = 'anova')
plot_gantt(interaction, plot_limit, case = 'interaction')
