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
# datapath <- "/media/E/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/"
# path.current <- '/home/romain/Documents/codes/Kinematics/Cinematique/R_contribution'
datapath <- "//10.89.24.15/e/Projet_IRSST_LeverCaisse/ElaboratedData/contribution_articulation/SPM/"
path.current <- 'C:/Users/marti/Documents/Codes/Kinematics/Cinematique/R_contribution'
setwd(path.current)

# switch
variable    <- 'hauteur'
#comparison  <- '18vs6'
#keepMainB <- 0

# load data ---------------------------------------------------------------
anova <- read.table(file.path(datapath, variable, 'anova.csv', fsep = ''), header = TRUE, sep = ",")
posthoc <- read.table(file.path(datapath, variable, 'posthoc.csv', fsep = ''), header = TRUE, sep = ",")

# reshape data ------------------------------------------------------------
# format p-value
source("functions/format_pvalue.R")
anova$p <- format_pvalue(anova$p)

anova$delta <- anova$delta %>% factor(levels = c(1:4), labels = c("WR/EL", "GH", "SC/AC", "TR/PE"))
posthoc$delta <- posthoc$delta %>% factor(levels = c(1:4), labels = c("WR/EL", "GH", "SC/AC", "TR/PE"))

anova$effect <- anova$effect %>%
  factor(levels = c('Main A', 'Main B', 'Interaction AB'),
         labels = c("main effect: sex","main effect: mass","interaction: sex-mass"))

posthoc$sex <- posthoc$sex %>%
  factor(levels = c('1-1', '2-2', '1-2'),
         labels = c("men vs. men", "women vs. women", "men vs. women"))

posthoc$weight <- posthoc$weight %>%
  factor(levels = c('12-6','6-6', '12-12', '6-12'),
         labels = c("12\ kg vs. 6\ kg (50%)", "6\ kg vs. 6\ kg (100%)", "12\ kg vs. 12\ kg (100%)", "6\ kg vs. 12\ kg (200%)"))

# gantt plot --------------------------------------------------------------
plot_limit <- c(posthoc$diff,anova$diff) %>% abs() %>% max() %>% round() + 1
#plot_limit <- 15
source("functions/plot_gantt.R")
plot_gantt(anova, plot_limit, case = 'anova')
plot_gantt(posthoc, plot_limit, case = 'posthoc')
