# get hours worked per day

args <- commandArgs(trailingOnly=TRUE)
dir <- 'C:/Users/jinman/msys/home/jfin/hours'
files <- list.files(dir)
file <- file.path(dir, files[length(files)])
data <- read.csv(file, strip.white=T, colClasses = "character", comment.char = "#")
today <- format(Sys.time(), '%m%d')
date <- ifelse(is.na(args[1]), today, args[1]) 
data <- data[data$date == date, ]
data <- data[data$task != "misc", ]
opening <- "Hi Mary and Daniel, \n\nI worked on these tasks today:\n\n"
summary <- unique(data[[4]])
summary <- paste0("\t", summary)
summary <- paste0(summary, collapse='\n')
dow <- format(as.Date(date, '%m%d'), '%a')
closing <- ifelse(dow == "Fri", 
                  "\n\nHave an excellent weekend,", 
                  "\n\nHave a pleasant evening,")
message <- paste0(opening, summary, closing)
writeClipboard(message)
cat("summary copied to clipboard:\n\n")
cat(paste0(message, '\n'))
