file <- commandArgs(trailingOnly = TRUE)[1]
file |>
    readr::read_tsv(show_col_types = FALSE) |>
    openxlsx::write.xlsx(paste0(tools::file_path_sans_ext(file),
                                        ".xlsx"))
