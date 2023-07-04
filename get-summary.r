# get summary of day's tasks

args <- commandArgs(trailingOnly=TRUE)
dir <- args[1]
supervisor <- "Lori"

# defaults to today
file <- file.path(dir, "current.csv")
date <- format(Sys.time(), '%m%d')
date_string <- paste0("today, ", format(Sys.Date(), "%A, %B %d, %Y"))

# for past date
if (! is.na(args[2])) {
    if (args[2] == "-h") {
        cat('Usage: summary yyyy-mm-dd\n')
        quit()
    }

    # get year from argument
    mm_dd <- substr(args[2], 6, 10)
    mmdd <- sub("-", "", mm_dd)
    pat <- paste0("^", mmdd)

    for (f in list.files(dir)) {
        YY <- substr(f, 1, 2)
        yy <- substr(args[2], 3, 4)

        # compare arg year to file name year
        # do not filter out "current.csv"
        if (YY != yy & YY != "cu") {
            next
        }
        mmdd_is_in_f <- any(grepl(pat, readLines(file.path(dir, f))))

        # get data if desired date is in file
        if (mmdd_is_in_f) {
            file <- file.path(dir, f)
            date <- mmdd
            date_string <- paste0("on ", format(as.Date(args[2]), "%A, %B %d, %Y"))
            break
        }
    }
    # if (date == format(Sys.time(), '%m%d')) {
    #     cat(paste0('No data for ', args[2], '.\n'))
    #     quit()
    # }
} 

data <- read.csv(file, strip.white=T, colClasses = "character", comment.char = "#")
data <- data[data$date == date, ]
data <- data[data$task != 'misc', ]
summary <- unique(data[[4]])
summary <- paste0('\t', summary)
summary <- paste0(summary, collapse='\n')
opening <- paste0('Hi ', supervisor, ', \n\nI worked on these tasks ', 
                  date_string,
                  ':\n\n') 
dow <- format(as.Date(date, '%m%d'), '%a')
closing <- ifelse(dow == 'Fri',
                  "\n\nThank you and happy Friday,",
                  "\n\nThank you and good day,")
message <- paste0(opening, summary, closing)
writeClipboard(message)
cat('summary copied to clipboard:\n\n')
cat(paste0(message, '\n'))
