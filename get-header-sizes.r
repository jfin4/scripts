rm(list = ls())
get_heading_sizes <- function(p = 12, r = 1.33, n = 3, output = NULL) {
    # creates series of font sizes with constant rate of increase for word
    # document headings
    # p, point size of text
    # r, rate of heading level increase
    # n, number of heading levels
    heading_size <- p * r
    output <- c(output, heading_size)
    heading_level <- n - 1
    if ( heading_level  > 0 ) {
        get_heading_sizes(p = heading_size, n = heading_level, output = output)
    } else {
        return(output)
    }
}
get_heading_sizes()
