file <- commandArgs(trailingOnly = TRUE)[1]
file |>
    readxl::read_excel() |>
    readr::write_tsv(paste0(tools::file_path_sans_ext(file),
                            ".txt"))
