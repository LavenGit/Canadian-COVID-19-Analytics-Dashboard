library(DBI)
library(RSQLite)
library(readr)
source("R/database.R")
path <- "data/covid.csv"
if (!file.exists(path)) stop("Place your CSV at data/covid.csv")
raw <- read_csv(path, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))
required <- c("pruid", "prname", "reporting_week", "reporting_year", "totalcases", "numtotal_last7", "numdeaths", "numdeaths_last7")
missing <- setdiff(required, names(raw))
if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
columns <- c("pruid", "prname", "date", "reporting_week", "reporting_year", "totalcases", "numtotal_last7", "ratecases_total", "numdeaths", "numdeaths_last7", "ratedeaths", "ratecases_last7", "ratedeaths_last7")
for (nm in setdiff(columns, names(raw))) raw[[nm]] <- NA
raw <- as.data.frame(raw[columns])
for (nm in setdiff(columns, c("prname", "date"))) raw[[nm]] <- suppressWarnings(as.numeric(raw[[nm]]))
raw$date <- as.character(raw$date)
raw <- raw[!is.na(raw$pruid) & !is.na(raw$reporting_year) & !is.na(raw$reporting_week) & !is.na(raw$prname), ]
key <- paste(raw$pruid, raw$reporting_year, raw$reporting_week, sep = "-")
if (anyDuplicated(key)) stop("Duplicate province-year-week records found. Inspect source before importing.")
con <- connect_db()

schema <- readLines("sql/schema.sql", warn = FALSE)
for (statement in strsplit(paste(schema, collapse = "\n"), ";", fixed = TRUE)[[1]]) {
  if (nzchar(trimws(statement))) dbExecute(con, statement)
}
dbWithTransaction(con, {
  dbExecute(con, "DELETE FROM covid_reports")
  dbAppendTable(con, "covid_reports", raw)
})
cat("Imported", nrow(raw), "records into SQLite.\n")

dbDisconnect(con)
