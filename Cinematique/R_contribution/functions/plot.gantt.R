plot.gantt <- function(data, annotation, save, scale.free) {

  gantt <- ggplot(data, aes())
  # Theme
  
  # create segment
  gantt <- gantt + geom_segment(aes(
                   x     = start,
                   xend  = end,
                   y     = delta,
                   yend  = delta,
                   color = diff),size = 4)
  
  # X axis
  gantt <- gantt + scale_x_continuous(
                   name   = "normalized time (% of trial)",
                   limits = c(0, 100),
                   breaks = c(0, 20, 40, 60, 80, 100))
  
  # Y axis
  gantt <- gantt + ylab("delta")
  
  # Facet
  if (scale.free == TRUE){
  gantt <- gantt + facet_grid(height ~ weight,
                       scales = "free",
                       space = "free")
  } else {
    gantt <- gantt + facet_grid(height ~ weight)
  }
  
  # vLine
  gantt <-
    gantt + geom_vline(xintercept = c(20, 80), linetype = "dotted")
  
  # Legend
  gantt <- gantt + scale_colour_gradient2(
                  "mean difference\n(% contribution)",
                  low  = "deepskyblue2",
                  mid  = "white",
                  high = "firebrick3")
  gantt
  
 if (annotation == TRUE){
  # Movement phase
  phase1 <- grobTree(textGrob("extract", x=0.05,  y=0.05, hjust=0,
                              gp=gpar(col="black", fontsize=8, fontface="italic")))
  phase2 <- grobTree(textGrob("lift", x=0.48,  y=0.05, hjust=0,
                              gp=gpar(col="black", fontsize=8, fontface="italic")))
  phase3 <- grobTree(textGrob("storage", x=0.82,  y=0.05, hjust=0,
                              gp=gpar(col="black", fontsize=8, fontface="italic")))
  
  # add to plot
  gantt <- gantt + annotation_custom(phase1)
  gantt <- gantt + annotation_custom(phase2)
  gantt <- gantt + annotation_custom(phase3)
 }
  
  # Theme
  gantt <-gantt + theme_classic() +
                  theme(panel.border = element_rect(colour = "black", fill=NA, size=0.5)) + 
                  theme(text = element_text(size = 12)) + 
                  theme(legend.key = element_rect(colour = NA),legend.position = "top")
  
  # Print graph
  print(gantt)
  
  if (save == TRUE){
    save(gantt, file =  "output/plot.gantt.Rdata")
    }
}