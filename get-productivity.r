# get hours worked per day

args = commandArgs(trailingOnly=TRUE)
pat <- ".*(\\d{2}-\\d{2}).*"
dir <- args[1]
# dir <- 'C:/msys64/home/jfin/hours'
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
work <- data$task != "misc"

df_misc <- aggregate(diff ~ date, data[misc, ], sum)
df_work <- aggregate(diff ~ date, data[work, ], sum)
df_tot <- aggregate(diff ~ date, data, sum)

hours_mw <- merge(df_misc, df_work, by = 1, all = T)
hours <- merge(hours_mw, df_tot, by = 1, all = T)
hours[is.na(hours)] <- 0

names(hours) <- c("DATE", "MISC", "WORK", "TOTAL")

# aggregate does not work if date is converted first
date <- as.Date(hours$DATE, format = "%m%d")

hours$DAY <- format(date, "%a")
hours$DATE <- format(date, "%m/%d")
make_bar <- function(x) {
    bar <- rep(" ", 32)
    bar[1:(4 * x)] <- "="
    bar <- paste(bar, collapse = "")
    bar <- paste0("|", bar, "|")
}
hours$BARCHART <- sapply(hours$WORK, make_bar)
hours[2:4] <- as.data.frame(lapply(hours[2:4], \(x) sprintf("%.2f", x)))
hours[2:5] <- format(hours[2:5], width = 6, justify = "right")
hours[6] <- format(hours[6], width = 32, justify = "left")
names(hours)[6] <- "BARCHART                          "

week1_dates <- as.Date(paste0(month, "-", 1:7), format = "%y-%m-%d")
week1_days <- format(week1_dates , "%a")
sun_char <- match("Sun", week1_days)
sun_date <- as.Date(paste0(month, "-", sun_char), format = "%y-%m-%d")
N <- 6
sun <- seq(sun_date, by = 7, length.out = N)

for (i in 1:N) {
    if (i == 1) {
        out <- hours[date < sun[i], ]
    } else {
        out <- hours[date >= sun[i - 1] & date < sun[i], ]
    }
    if (nrow(out) > 0) {
        mean_work <- mean(as.numeric(out[[3]]))
        mean_tot <- mean(as.numeric(out[[4]]))
        mean_prop <- mean_work / mean_tot # mean proportion of work per day
        mean_norm <- mean_prop  * 8 # normalize by 8 hour day
        mean <- sprintf("%.2f", mean_norm)
        out <- rbind(out, c("Mean:", "", mean, "", "", "                        ^         "))
        print(out, row.names = F)
        names(hours) <- NULL
    }
}
