# get hours worked today

month <- format(Sys.time(), '%y-%m')
today <- format(Sys.time(), '%m%d')
file <- paste0('hours/', month, '.csv')
data <- read.csv(file, strip.white=T, colClasses = "character")
data_today <- data[data$date == today, ]
data_today$from <- as.POSIXlt(data_today$from, format = "%H%M")
data_today$to <- as.POSIXlt(data_today$to, format = "%H%M")

diffs_tot <- difftime(data_today$to, data_today$from, units = "hours")
hours_tot <- as.numeric(sum(diffs_tot))

data_today_misc <- data_today[data_today$task == "misc", ]
diffs_misc <- difftime(data_today_misc$to, data_today_misc$from, units = "hours")
hours_misc <- as.numeric(sum(diffs_misc))

data_today_work <- data_today[data_today$task != "misc", ]
diffs_work <- difftime(data_today_work$to, data_today_work$from, units = "hours")
hours_work <- as.numeric(sum(diffs_work))

hours <- c(hours_misc, hours_work, hours_tot)
names(hours) <- c("Misc", "Worked", "Total")
print(hours)

