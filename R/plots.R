

# ggplot_heatmap(as.matrix(mtcars))
# plotly_heatmap(as.matrix(mtcars))
# style(plotly_heatmap(as.matrix(mtcars)), xgap = 5, ygap = 5)




#
# library(ggplot2)
# library(plotly)
# # library(heatmaply)
# ggplot_heatmap <- heatmaply:::ggplot_heatmap
# class_to <- function(x, new_class) {
#   class(x) <- new_class
#   x
# }
# na_mat <- function(x) {
#   x %>% is.na %>% class_to("numeric")
# }
#
# p <- heatmaply:::ggplot_heatmap(na_mat(airquality),
#                     scale_fill_gradient_fun = scale_fill_gradientn(colors= c("white","black")) ,
#                     grid_color = "grey", grid_size = 1)
# plot(p)
# ggplotly(p)
# p <- ggplot_heatmap(mtcars,
#                     grid_color = "white")
# p
#


# heatmaply:::ggplot_heatmap(as.matrix(mtcars))


# xx is a data matrix
ggplot_heatmap <- function(xx,
                           row_text_angle = 0,
                           column_text_angle = 45,
                           scale_fill_gradient_fun =
                             scale_fill_gradientn(colors = viridis(n=256, alpha = 1, begin = 0,
                                                                   end = 1, option = "viridis"),
                                                  na.value = "grey50", limits = NULL),
                           grid_color = NA,
                           grid_size = 0.1,
                           key.title = NULL,
                           layers,
                           row_dend_left = FALSE,
                           label_names,
                           fontsize_row = 10,
                           fontsize_col = 10,
                           ...) {
  theme_clear_grid_heatmap <- theme(axis.line = element_line(color = "black"),
                                    panel.grid.major = element_blank(),
                                    panel.grid.minor = element_blank(),
                                    panel.border = element_blank(),
                                    panel.background = element_blank())
  # heatmap
  # xx <- x$matrix$data
  if(!is.data.frame(xx)) df <- as.data.frame(xx)

  if (missing(label_names)) {
    if (is.null(dim_names <- names(dimnames(xx)))) {
      label_names <- c("row", "column", "value")
    }
  } else {
    assert_that(length(label_names) == 3)
  }
  row <- label_names[[1]]
  col <- label_names[[2]]
  val <- label_names[[3]]

  # colnames(df) <- x$matrix$cols
  if(!is.null(rownames(xx))) {
    df[[row]] <- rownames(xx)
  } else {
    df[[row]] <- 1:nrow(xx)
  }

  df[[row]] <- factor(
    df[[row]],
    levels = df[[row]],
    ordered = TRUE
  )

  mdf <- reshape2::melt(df, id.vars=row)
  colnames(mdf)[2:3] <- c(col, val) # rename "variable" and "value"

  # TODO:
  # http://stackoverflow.com/questions/15921799/draw-lines-around-specific-areas-in-geom-tile
  # https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
  p <- ggplot(mdf, aes_string(x = col, y = row)) +
    geom_tile(aes_string(fill = val), color = grid_color, size = grid_size) +
    # scale_linetype_identity() +
    # scale_fill_viridis() +
    coord_cartesian(expand = FALSE) +
    scale_fill_gradient_fun +
    theme_bw()+ theme_clear_grid_heatmap +
    theme(axis.text.x = element_text(angle = column_text_angle,
            size = fontsize_col, hjust = 1),
          axis.text.y = element_text(angle = row_text_angle,
            size = fontsize_row, hjust = 1)
          )

  if(!missing(layers)) p <- p + layers
    ## Passed in to allow users to alter (courtesy of GenVisR)

  # p <- p + scale_x_discrete(limits = unique(mdf))
  # http://stats.stackexchange.com/questions/5007/how-can-i-change-the-title-of-a-legend-in-ggplot2
  p <- p + labs(fill=key.title)

  # until this bug is fixed: https://github.com/ropensci/plotly/issues/699
  # we are forced to use geom_hline and geom_vline
  if(!is.na(grid_color)) {
    p <- p + geom_hline(yintercept =c(0:nrow(xx))+.5, color = grid_color) # , size = grid_size # not implemented since it doesn't work with plotly
    p <- p + geom_vline(xintercept =c(0:ncol(xx))+.5, color = grid_color) # , size = grid_size # not implemented since it doesn't work with plotly

  }

  if(row_dend_left) p <- p + scale_y_discrete(position = "right") # possible as of ggplot 2.1.0 !

  p
}


plotly_heatmap <- function(x, limits = range(x), colors = viridis(n=256, alpha = 1, begin = 0,
                                                                  end = 1, option = "viridis"),
    row_text_angle = 0, column_text_angle = 45, grid.color, grid.size, key.title = NULL,
    row_dend_left = FALSE, fontsize_row = 10, fontsize_col = 10, colorbar_xanchor = "left",
    key_title = "", colorbar_yanchor = "bottom", colorbar_xpos = 1.1, colorbar_ypos = 1, colorbar_len = 0.3) {

  if (is.function(colors)) colors <- colors(256)

  p <- plot_ly(z = x, x = 1:ncol(x), y = 1:nrow(x),
    type = "heatmap", showlegend = FALSE, colors = colors,
    zmin = limits[1], zmax = limits[2]) %>%
      layout(
        xaxis = list(
          tickfont = list(size = fontsize_col),
          tickangle = column_text_angle,
          tickvals = 1:ncol(x), ticktext = colnames(x),
          linecolor = "#ffffff",
          range = c(0.5, ncol(x) + 0.5),
          showticklabels = TRUE
        ),
        yaxis = list(
          tickfont = list(size = fontsize_row),
          tickangle = row_text_angle,
          tickvals = 1:nrow(x), ticktext = rownames(x),
          linecolor = "#ffffff",
          range = c(0.5, nrow(x) + 0.5),
          showticklabels = TRUE
        )
      )
  p <- plotly::colorbar(p, lenmode = "fraction", title = key_title,
    xanchor = colorbar_xanchor, x = colorbar_xpos, y = colorbar_ypos,
    yanchor = colorbar_yanchor, len=colorbar_len)
  p
}





# Create a plotly colorscale from a list of colors in any format.
# Probably not needed currently
make_colorscale <- function(colors) {
    seq <- seq(0, 1, by = 1 / length(colors))
    scale <- lapply(seq_along(colors),
        function(i) {
            # eg
            # list(c(0, "rgb(255, 0, 0)"), c(1, "rgb(0, 255, 0)")),
            if (i == 1) {
                list(0, col2plotlyrgb(colors[i]))
            } else if (i == length(colors)) {
                list(1, col2plotlyrgb(colors[i]))
            } else {
                list(seq[i], col2plotlyrgb(colors[i]))
            }
        }
    )
    scale
}

#' @title Color to RGB Text
#' @description
#' Plotly takes colors in this format "rgb(255, 0, 0)"
#'
#' @param col vector of any of the three kinds of R color specifications,
#' i.e., either a color name (as listed by colors()),
#' a hexadecimal string of the form "#rrggbb" or "#rrggbbaa" (see rgb),
#' or a positive integer i meaning palette()[i].
#'
#' @return
#' A character of the form "rgb(value1,value1,value3)"
#'
#' @seealso \link{col2rgb}
#' @examples
#' \dontrun{
#' col2rgb("peachpuff")
#' col2plotlyrgb("peachpuff")
#' }
col2plotlyrgb <- function(col) {
    rgb <- grDevices::col2rgb(col)
    paste0(
      "rgb(",
      rgb["red", ], ",",
      rgb["green", ], ",",
      rgb["blue", ], ")"
    )
}

## Helper function to generate "normal" colors for dendrograms
## ie black if one k or rainbow_hcl otherwise
k_colors <- function(k) {
  if (k > 1) {
    colorspace::rainbow_hcl(k)
  } else {
    "black"
  }
}

plotly_dend <- function(dend, side = c("row", "col"), flip = FALSE) {
  side <- match.arg(side)
  dend_data <- as.ggdend(dend)
  segs <- dend_data$segments
  ## Have to get colors back from dendrogram otherwise plotly will make some up
  if (is.null(segs$col) || all(is.na(segs$col))) {
    segs$col <- rep(1, length(segs$col))
  }
  segs$col[is.na(segs$col)] <- "black" # default value for NA is "black"

  if (is.numeric(segs$col)) segs$col <- factor(segs$col)

  ## Need to somehow convert to colors that plotly will understand
  # colors <- unique(dendextend::get_leaves_branches_col(dend))
  # if(!is.null(colors)) colors <- sort(colors)
  colors <- sort(unique(segs$col))
  if (is.numeric(colors)) colors <- gplots::col2hex(grDevices::palette()[seq_along(colors)])
  # if (is.null(colors)) colors <- "black"


  lab_max <- nrow(dend_data$labels)
  if (side == "row") lab_max <- lab_max + 0.5

  axis1 <- list(
    title = "",
    range = c(0,  max(segs$y)),
    linecolor = "#ffffff",
    showgrid = FALSE
  )
  axis2 <- list(
    title = "",
    range = c(0, lab_max),
    linecolor = "#ffffff",
    showgrid = FALSE
  )

  ## Have to change x and y depending on which orientation
  if (side == "row") {
    add_plot_lines <- function(p) {
      p %>% add_segments(x = ~y, xend = ~yend, y = ~x, yend = ~xend, color = ~col,
        showlegend = FALSE,
        colors = colors,
        hoverinfo = "x"
        ) %>%
      layout(
        hovermode = "closest",
        xaxis = axis1,
        yaxis = axis2
      )
    }
  }
  else {
    add_plot_lines <- function(p) {
      p %>% add_segments(x = ~x, xend = ~xend, y = ~y, yend = ~yend, color = ~col,
        showlegend = FALSE,
        colors = colors,
        hoverinfo = "y"
      ) %>%
      layout(
        hovermode = "closest",
        xaxis = axis2,
        yaxis = axis1
      )
    }
  }

  p <- plot_ly(segs) %>% add_plot_lines()

  if (flip) {
    p <- layout(p, xaxis = list(autorange = "reversed"))
  }
  p
}

#' @title Side color plots for heatmaps
#' @description
#' Important for creating annotation.
#'
#' @param df A "molten" data.frame as produced by (eg) reshape2::melt
#' @param palette A function which can return colors to be used in the sidebar
#' plot
#' @param scale_title Title of the color scale. Not currently used.
#' @param type Horizontal or vertical plot? Valid values are "column" and "row"
#' @param text_angle the angle of the text of the rows/columns.
#' @param is_colors Use if the values in df are valid colours and should not be mapped
#'  to a color scheme, and instead should be plotted directly.
#' @param label_name Name for the mouseover label, usually "row" or "column"
#'
#' @return A ggplot geom_tile object
#'
side_color_plot <- function(df, palette,
  scale_title = paste(type, "side colors"), type = c("column", "row"),
  text_angle = if (type == "column") 0 else 90, is_colors = FALSE,
  label_name = type) {

  if (is.matrix(df)) df <- as.data.frame(df)
  assert_that(is.data.frame(df))

  ## Cooerce to character
  df[] <- lapply(df, as.character)

  ## TODO: Find out why names are dropped when ncol(df) == 1
  original_dim <- dim(df)

  if (missing(palette)) palette <- colorspace::rainbow_hcl

  type <- match.arg(type)
  ## Custom label
  if (!missing(label_name)) type <- label_name
  if (type %in% colnames(df))
    stop("Having", type, "in the colnames of the side_color df will drop data!")

  df[[type]] <- if(!is.null(rownames(df))) rownames(df) else 1:nrow(df)

  df[[type]] <- factor(df[[type]], levels = df[[type]], ordered = TRUE)
  df <- reshape2::melt(df, id.vars = type)
  df[["value"]] <- factor(df[["value"]])

  id_var <- colnames(df)[1]

  if (type == "column") {
    mapping <- aes_string(x = id_var, y = "variable", fill = "value")
    if(original_dim[2] > 1) {
      text_element <- element_text(angle = text_angle)
    } else text_element <- element_blank()

    theme <- theme(
        panel.background = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = text_element,
        axis.ticks = element_blank())
  } else {
    if(original_dim[2] > 1) {
      text_element <- element_text(angle = text_angle)
    } else text_element <- element_blank()

    mapping <- aes_string(x = "variable", y = id_var, fill = "value")
    theme <- theme(
        panel.background = element_blank(),
        axis.text.x = text_element,
        axis.text.y = element_blank(),
        axis.ticks = element_blank())
  }

  color_vals <- if (is_colors) levels(df[["value"]])
  else palette(nlevels(df[["value"]]))

  g <- ggplot(df, mapping = mapping) +
    # geom_raster() +
    geom_tile() +
    xlab("") +
    ylab("") +
    scale_fill_manual(
      name = NULL,
      breaks = levels(df[["value"]]),
      values = color_vals) +
    theme
  return(g)
}
