# get hours worked per day
month <- format(Sys.time(), '%y-%m')
home <- 'C:/Users/JInman/msys/home/jfin/'
file <- paste0(home, 'hours/', month, '.csv')
data_all <- read.csv(file, strip.white=T, colClasses = "character")
date <- format(Sys.time(), '%m%d')
data_today <- data_all[data_all$date == date, ]
data_work <- data_today[data_today$task != "misc", ]
out <- unique(data_work[[4]])
cat(paste("\t", out, "\n"))
