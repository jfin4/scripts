# get hours worked per day
month <- format(Sys.time(), '%y-%m')
home <- 'C:/Users/JInman/msys/home/jfin/'
file <- paste0(home, 'hours/', month, '.csv')
data_all <- read.csv(file, strip.white=T, colClasses = "character")
arg <- commandArgs(trailingOnly = T)
today <- format(Sys.time(), '%m%d')
date <- ifelse(length(arg) == 1, arg, today) 
data_date <- data_all[data_all$date == date, ]
data_work <- data_date[data_date$task != "misc", ]
out <- unique(data_work[[4]])
cat(paste("\t", out, "\n"))
