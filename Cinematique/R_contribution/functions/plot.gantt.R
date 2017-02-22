plot.gantt <- function(data1, data2, path.output, scale.free) {
  # interaction -------------------------------------------------------------
  gantt1 <- ggplot(data1, aes())
  # create segment
  gantt1 <- gantt1 + geom_segment(aes(
    x     = start,
    xend  = end,
    y     = delta,
    yend  = delta,
    color = diff),size = 4)
  # X axis
  gantt1 <- gantt1 + scale_x_continuous(
    name   = "normalized time (% of trial)",
    limits = c(0, 100),
    breaks = c(0, 20, 40, 60, 80, 100))
  # Y axis
  gantt1 <- gantt1 + ylab("delta")
  # Facet
  if (scale.free == TRUE){
    gantt1 <- gantt1 + facet_grid(height ~.,
                                  scales = "free",
                                  space = "free")
  } else {
    gantt1 <- gantt1 + facet_grid(height ~ sens)
  }
  # vLine
  gantt1 <- gantt1 + geom_vline(xintercept = c(20, 80), linetype = "dotted")
  # Legend
  plot.limit <- round(max(abs(data1$diff)))+1
  gantt1 <- gantt1 + scale_colour_gradient2("mean difference\n(% contribution)",
                                            limits=c(-plot.limit, plot.limit),
                                            low  = "firebrick3",
                                            mid  = "white",
                                            high = "deepskyblue2")
  # Theme
  gantt1 <-gantt1 + theme_classic() +
    theme(panel.border = element_rect(colour = "black", fill=NA, size=0.5)) + 
    theme(text = element_text(size = 12)) + 
    theme(legend.key = element_rect(colour = NA),legend.position = "top")
  # Print graph
  print(gantt1)
  
  # main effect -------------------------------------------------------------
  gantt2 <- ggplot(data2, aes())
  # create segment
  gantt2 <- gantt2 + geom_segment(aes(
    x     = start,
    xend  = end,
    y     = delta,
    yend  = delta),size = 4)
  # X axis
  gantt2 <- gantt2 + scale_x_continuous(
    name   = "normalized time (% of trial)",
    limits = c(0, 100),
    breaks = c(0, 20, 40, 60, 80, 100))
  # Y axis
  gantt2 <- gantt2 + ylab("delta")
  # vLine
  gantt2 <- gantt2 + geom_vline(xintercept = c(20, 80), linetype = "dotted")
  # Theme
  gantt2 <-gantt2 + theme_classic() +
    theme(panel.border = element_rect(colour = "black", fill=NA, size=0.5)) +
    theme(text = element_text(size = 12)) +
    theme(legend.key = element_rect(colour = NA),legend.position = "top")
  # Print graph
  print(gantt2)
}

# combine -----------------------------------------------------------------
ggdraw() +
  draw_plot(gantt1, 0, .5, 1, .5) +
  draw_plot(gantt2, 0, 0, .5, .5) + 
  draw_plot_label(c("A", "B"), c(0, 0, 0.5), c(1, 0.5, 0.5), size = 15)


plot_grid(gantt1, gantt2, labels=c("A", "B"), ncol = 1, nrow = 2)
plot_grid(gantt1, gantt2, nrow=2, labels="AUTO", label_size=12, rel_heights  = c(4,1))

# save --------------------------------------------------------------------
path.output <- 'coucou'

