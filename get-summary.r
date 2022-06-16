# get hours worked per day


args <- commandArgs(trailingOnly=TRUE)

dir <- args[1]

if (! is.na(args[2])) {
    mm_dd <- substr(args[1], 6, 10)
    mmdd <- sub("-", "", mm_dd)
    pat <- paste0("^", mmdd)
    for (f in list.files(dir)) {
        YY <- substr(f, 1, 2)
        yy <- substr(args[2], 3, 4)
        if (YY != yy & YY != "cu") {
            next
        }
        mmdd_is_in_f <- any(grepl(pat, readLines(file.path(dir, f))))
        if (mmdd_is_in_f) {
            file <- file.path(dir, f)
            date <- mmdd
            opening <- paste0("Hi Daniel, \n\nI worked on these tasks and projects on ", 
                              format(as.Date(args[2]), "%A, %B %d, %Y"),
                              ":\n\n")
            break
        }
    }
} else {
    file <- file.path(dir, "current.csv")
    date <- format(Sys.time(), '%m%d')
    opening <- paste0("Hi Daniel, \n\nI worked on these tasks and projects today, ", 
                        format(Sys.Date(), "%A, %B %d, %Y"),
                        ":\n\n")
}

data <- read.csv(file, strip.white=T, colClasses = "character", comment.char = "#")
data <- data[data$date == date, ]
data <- data[data$task != "misc", ]
summary <- unique(data[[4]])
summary <- paste0("\t", summary)
summary <- paste0(summary, collapse='\n')
dow <- format(as.Date(date, '%m%d'), '%a')
closing <- ifelse(dow == "Fri",
                  "\n\nThank you and happy Friday,",
                  "\n\nThank you and good day,")
message <- paste0(opening, summary, closing)
writeClipboard(message)
cat("summary copied to clipboard:\n\n")
cat(paste0(message, '\n\n'))
cat("Pushing repos...\n")
