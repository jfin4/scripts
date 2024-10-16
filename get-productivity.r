# get hours worked per day

rm(list = ls())
#import data
file <- "C:/msys64/home/jinman/notes/hours.csv"
df_raw <- read.csv(file, strip.white = TRUE, colClasses = "character", comment.char = "#")
df_raw <- within(df_raw, {
                   date <- as.Date(date, format = "%Y%m%d")
                   from <- as.POSIXlt(from, format = "%H%M")
                   to <- as.POSIXlt(to, format = "%H%M")
                   diff <- as.numeric(difftime(to, from, units = "hours"))
                   task <- ifelse(task == "misc", "misc", "work")
})
# aggregate tasks into work/non-work
df_agg <- aggregate(diff ~ task + date, df_raw, sum)
# pivot long to wide
df_wide <- reshape(df_agg, direction = "wide",
                   idvar = "date", # mandatory
                   timevar = "task", # mandatory
                   v.names = c("diff"),    # time-varying variables
                   varying = list(c("work", "misc"))) # auto-generated if missing
# calculate weekly avg of work
df_wide <- within(df_wide, {
                    week <- format(date, format = "%Y%U")
                    work <- replace(work, is.na(work), 0)
                    misc <- replace(misc, is.na(misc), 0)
                    total <- work + misc
                    perc <- work / total
                   })
df_wkly_avg <- aggregate(perc ~ week, df_wide, mean)
df_week_of <- aggregate(date ~ week, df_wide, max)
df_summary <- merge(df_wkly_avg, df_week_of)
names(df_summary) <- c("week", "wkly_avg", "date")
df_summary <- within(df_summary, {
                       week <- NULL
                   })
df_gapless <- merge(df_wide, df_summary, all = TRUE) 
# order table
rows <- with(df_gapless, order(date))
cols <- c("date", "total", "work", "wkly_avg")
df_gapless <- df_gapless[rows, cols]
df_gapless <- within(df_gapless, {
                   week <- NULL
                   wkly_avg <- round(wkly_avg, 2)
                   wkly_avg <- replace(wkly_avg, is.na(wkly_avg), "")
                   total <- as.character(total)
                   work <- as.character(work)
                   date_sort <- date
                   date <- format(date, "%a, %b %d")
                   })
# create gap rows for presentation
week_number <- with(df_gapless, format(date_sort, "%U"))
is_new_week <- c(TRUE, week_number[-1] != week_number[-length(week_number)])  
df_gaps <- df_gapless[is_new_week, ]
df_gaps <- within(df_gaps, {
                    date <- ""
                    total <- ""
                    work <- ""
                    wkly_avg <- ""
                   })
df_out <- rbind(df_gaps, df_gapless)
rows_order <- with(df_out, order(date_sort))
df_out <- df_out[rows_order, ]
df_out <- within(df_out, {
                        date_sort <- NULL
                   })
# subset to last two weeks
gap_rows <- with(df_out, which(date == ""))
start <- gap_rows[length(gap_rows) - 4]
names(df_out) <- c("Date", "Total", "Work", "Average")
print(df_out[start:nrow(df_out), ], row.names = FALSE)
