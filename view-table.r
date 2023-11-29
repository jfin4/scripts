args = commandArgs(trailingOnly=TRUE)
write.xlsx(args[1], tempfile(fileext = ".xlsx"))
