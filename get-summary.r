# get hours worked per day

args <- commandArgs(trailingOnly=TRUE)
month <- ifelse(args[1] == "", format(Sys.time(), '%y-%m'), args[1])
home <- 'C:/Users/JInman/msys/home/jfin/'
file <- paste0(home, 'hours/', month, '.csv')
data_all <- read.csv(file, strip.white=T, colClasses = "character")
today <- format(Sys.time(), '%m%d')
date <- ifelse(args[2] == "", today, args[2]) 
date <- today
data_date <- data_all[data_all$date == date, ]
data_work <- data_date[data_date$task != "misc", ]
out <- unique(data_work[[4]])
for (i in 1:length(out)) {
    cat(paste("        ", out[i], "\n"))
}
