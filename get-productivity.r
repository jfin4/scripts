# get hours worked per day

workday_hours <- 8
allowable_misc <- 2

#                         arg[1]           arg[2]
# Usage: Rscript SCRIPT.R HOURS_LOGS_DIR [ DATE ]
args = commandArgs(trailingOnly=TRUE)
dir <- args[1]
# args <- NA
# dir <- "C:/Users/jinman/AppData/Local/Programs/msys64/home/JInman/hours"

pat <- ".*(\\d{2}-\\d{2}).*" # matches date string in file name
month <- ifelse(is.na(args[2]), 
                format(Sys.Date(), "%y-%m"),
                sub(pat, "\\1", args[2]))
file <- ifelse(is.na(args[2]), 
               file.path(dir, "current.csv"),
               file.path(dir, paste0(month, ".csv")))
data <- read.csv(file,
                strip.white=T,
                colClasses = "character",
                comment.char = "#")
data$from <- as.POSIXlt(data$from, format = "%H%M")
data$to <- as.POSIXlt(data$to, format = "%H%M")
data$diff <- as.numeric(difftime(data$to, data$from, units = "hours"))

misc <- data$task == "misc"
work <- !misc

df_misc <- aggregate(diff ~ date, data[misc, ], sum)
df_work <- aggregate(diff ~ date, data[work, ], sum)
df_tot <- aggregate(diff ~ date, data, sum)

hours_mw <- merge(df_misc, df_work, by = 1, all = T)
hours <- merge(hours_mw, df_tot, by = 1, all = T)
hours[is.na(hours)] <- 0

names(hours) <- c("Date", "Misc", "Work", "Total")

# aggregate does not work if date is converted first
date <- as.Date(hours$Date, format = "%m%d")

hours$Day <- format(date, "%a")
hours$Date <- format(date, "%m/%d")
make_bar <- function(hours_worked) {
    bar <- rep(" ", workday_hours * 4) # 15 minute increments
    bar[0:(4 * hours_worked)] <- "="
    bar <- paste(bar, collapse = "")
    bar <- paste0("|", bar, "|")
}
hours$Bar <- sapply(hours$Work, make_bar)
hours[c("Misc", "Work", "Total")] <- 
  as.data.frame(lapply(hours[c("Misc", "Work", "Total")], 
                \(x) sprintf("%.2f", x)))
hours[c("Misc", "Work", "Total")] <- 
  format(hours[c("Misc", "Work", "Total")], 
         width = 5, 
         justify = "right")
hours["Day"] <- format(hours["Day"], width = 4, justify = "right")
hours["Bar"] <- format(hours["Bar"], 
                       width = workday_hours * 4 + 2, # plus 2 for bar ends
                       justify = "left")
names(hours)[names(hours) == "Bar"] <- ""

week1_dates <- as.Date(paste0(month, "-", 1:7), format = "%y-%m-%d")
week1_days <- format(week1_dates , "%a")
sun_char <- match("Sun", week1_days)
sun_date <- as.Date(paste0(month, "-", sun_char), format = "%y-%m-%d")
N <- 6 # possible number of weeks in a month
sun <- seq(sun_date, by = 7, length.out = N)

work_col <- which(names(hours) == "Work")
tot_col <- which(names(hours) == "Total")
cat('\n')
for (i in 1:N) {
    if (i == 1) {
        out <- hours[date < sun[i], ]
    } else {
        out <- hours[date >= sun[i - 1] & date < sun[i], ]
    }
    if (nrow(out) > 0) {
        mean_work <- mean(as.numeric(out[[work_col]]))
        mean_tot <- mean(as.numeric(out[[tot_col]]))
        mean_prop <- mean_work / mean_tot # mean proportion of work per day
        mean_norm <- mean_prop  * workday_hours # normalize by workday_hours
        mean <- sprintf("%.2f", mean_norm)
        pad_len <- allowable_misc * 4 + 1
        pad <- paste0(rep(" ", pad_len), collapse = "")
        target <- paste0("^", pad)
        out <- rbind(out, c("Mean:", "", mean, "", "", target))
        print(out, row.names = F)
        names(hours) <- NULL
        cat('\n')
    }
}
