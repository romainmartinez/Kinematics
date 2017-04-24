plot_gantt <- function(data,plot_limit,case='None') {

# plot theme --------------------------------------------------------------
gantt_theme <- theme_classic() + theme(panel.border = element_rect(colour = "black",fill = NA,size = 0.5)) +
  theme(text = element_text(size = 12)) +
  theme(legend.key = element_rect(colour = NA),legend.position = "top") +
  theme(strip.background = element_blank(),strip.text.y = element_blank(),strip.text.x = element_blank())

# plot --------------------------------------------------------------------

  gantt <- ggplot(data, aes())
  # create segment
  gantt <- gantt + geom_segment(aes(x = start,xend = end,y = delta,yend = delta,color = diff),size = 4)
  # X axis
  gantt <- gantt + scale_x_continuous(name = "normalized time (% of trial)",limits = c(0, 100),breaks = c(0, 20, 40, 60, 80, 100))
  # Y axis
  gantt <- gantt + ylab("DoF")
  # Facet
  if (case == 'interaction') {
    gantt <- gantt + facet_grid(height ~ sens)
  } else {
    gantt <- gantt + facet_grid(effect ~ .)
  }

  # Legend
  #plot_limit <- round(max(abs(data$diff))) + 1
  gantt <- gantt + scale_colour_gradient2("mean difference\n(% height)",limits = c(-plot_limit, plot_limit),
      low = "firebrick3",
      mid = "#ecf0f1",
      high = "deepskyblue2")
  # Theme
  gantt <- gantt + gantt_theme

print(gantt)
}
