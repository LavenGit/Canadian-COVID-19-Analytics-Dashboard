
library(DBI)
library(RSQLite)

connect_db <- function() {
  dir.create("database", showWarnings = FALSE)
  dbConnect(SQLite(), "database/covid.sqlite")
}

get_reports <- function(con, year = NULL, provinces = NULL) {
  sql <- "SELECT * FROM covid_reports WHERE 1=1"
  params <- list()
  
  if (!is.null(year)) {
    sql <- paste0(sql, " AND reporting_year = ?")
    params <- c(params, list(as.integer(year)))
  }
  
  if (!is.null(provinces) && length(provinces) > 0) {
    placeholders <- paste(rep("?", length(provinces)), collapse = ",")
    sql <- paste0(sql, " AND prname IN (", placeholders, ")")
    params <- c(params, as.list(provinces))
  }
  
  sql <- paste0(sql, " ORDER BY reporting_year, reporting_week, prname")
  
  if (length(params) == 0) {
    dbGetQuery(con, sql)
  } else {
    dbGetQuery(con, sql, params = params)
  }
}
