theme_jelle <- function() {
  font <- "Helvetica"
  theme <- list(
    ggplot2::theme(
      ## TITLES
      plot.title = ggplot2::element_text(
        size = 18,
        color = "black",
        family = font,
        hjust = 0.5
      ),
      plot.subtitle = ggplot2::element_text(
        size = 16,
        color = "black",
        family = font
      ),
      ## LEGEND
      legend.title = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(
        family = font, size = 16,
        color = "black"
      ),
      legend.position = c(.98, .99),
      legend.justification = c("right", "top"),
      legend.box.just = "right",

      ## AXIS
      axis.title = ggplot2::element_text(family = font, face = "bold", size = 16),
      axis.text = ggplot2::element_text(family = font, size = 12, color = "black"),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),

      ## PANELS
      panel.grid.major.y = ggplot2::element_line(color = "#cbcbcb"),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),

      ## FACETS
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(
        family = font, size = 16, face = "bold"
      ),
      strip.placement = "inside"
    ) # end of ggplot2::theme
    ,
    ggplot2::guides(
      colour = guide_legend(label.position = "left"), # second item in list
      fill = guide_legend(label.position = "left")
    ) # third item in list
  )

  return(theme)
}

colours <- list(
  "sampling" = "#148AAD",
  "jittering" = "#804559"
)
