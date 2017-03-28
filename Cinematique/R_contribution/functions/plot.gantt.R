plot.gantt <-
  function(data1,
           data2,
           path.output,
           scale.free,
           save.fig) {
    # interaction -------------------------------------------------------------
    gantt1 <- ggplot(data1, aes())
    # create segment
    gantt1 <- gantt1 + geom_segment(aes(
      x     = start,
      xend  = end,
      y     = delta,
      yend  = delta,
      color = diff
    ),
    size = 4)
    # X axis
    gantt1 <- gantt1 + scale_x_continuous(
      name   = "normalized time (% of trial)",
      limits = c(0, 100),
      breaks = c(0, 20, 40, 60, 80, 100)
    )
    # Y axis
    gantt1 <- gantt1 + ylab("delta")
    # Facet
    if (scale.free == TRUE) {
      gantt1 <- gantt1 + facet_grid(height ~ .,
                                    scales = "free",
                                    space = "free")
    } else {
      gantt1 <- gantt1 + facet_grid(height ~ sens)
    }
    # vLine
    gantt1 <-
      gantt1 + geom_vline(xintercept = c(20, 80), linetype = "dotted")
    # Legend
    plot.limit <- round(max(abs(data1$diff))) + 1
    gantt1 <-
      gantt1 + scale_colour_gradient2(
        "mean difference\n(% height)",
        limits = c(-plot.limit, plot.limit),
        low  = "firebrick3",
        mid  = "white",
        high = "deepskyblue2"
      )
    # Theme
    gantt1 <- gantt1 + theme_classic() +
      theme(panel.border = element_rect(
        colour = "black",
        fill = NA,
        size = 0.5
      )) +
      theme(text = element_text(size = 12)) +
      theme(legend.key = element_rect(colour = NA),
            legend.position = "top") +
      theme(
        strip.background = element_blank(),
        strip.text.y = element_blank(),
        strip.text.x = element_blank()
      )

    # main effect -------------------------------------------------------------
    gantt2 <- ggplot(data2, aes())
    # create segment
    gantt2 <- gantt2 + geom_segment(aes(
      x     = start,
      xend  = end,
      y     = delta,
      yend  = delta,
      color = diff
    ),
    size = 4)
    # X axis
    gantt2 <- gantt2 + scale_x_continuous(
      name   = "normalized time (% of trial)",
      limits = c(0, 100),
      breaks = c(0, 20, 40, 60, 80, 100)
    )
    # Y axis
    gantt2 <- gantt2 + ylab("delta")
    # vLine
    gantt2 <-
      gantt2 + geom_vline(xintercept = c(20, 80), linetype = "dotted")
    # Legend
    gantt2 <-
      gantt2 + scale_colour_gradient2(
        "mean difference\n(% height)",
        limits = c(-plot.limit, plot.limit),
        low  = "firebrick3",
        mid  = "white",
        high = "deepskyblue2"
      )
    # Theme
    gantt2 <- gantt2 + theme_classic() +
      theme(panel.border = element_rect(
        colour = "black",
        fill = NA,
        size = 0.5
      )) +
      theme(text = element_text(size = 12)) +
      theme(legend.key = element_rect(colour = NA),
            legend.position = "top")
    # combine -----------------------------------------------------------------
    gantt <-
      plot_grid(
        gantt2 + theme(
          legend.position = "none",
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
        ),
        gantt1 + theme(
          legend.position = "none",
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
        ),
        nrow = 2,
        rel_heights  = c(1, 4)
      )
    legend_top <- get_legend(gantt1 + theme(legend.position = "top"))
    gantt <-
      plot_grid(legend_top,
                gantt,
                ncol = 1,
                rel_heights = c(0.15, 1))
    # ggdraw(add_sub(gantt,
    #                "normalized time (% of trial)", vpadding = grid::unit(0,"lines"),
    #                y = 5, x = 0.5, vjust = 4.5))
    # save --------------------------------------------------------------------
    if (save.fig == TRUE) {
      save(gantt, file = file.path(path.output, "plot.gantt.Rdata"))
    }

    print(gantt)
  }

# ggsave(file="test.svg", plot=gantt, width=10, height=8)
