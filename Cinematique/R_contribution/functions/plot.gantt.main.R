plot.gantt.main <- function(data, path.output, annotation) {
  # main effect -------------------------------------------------------------
  gantt2 <- ggplot(data, aes())
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