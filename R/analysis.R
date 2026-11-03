library(dplyr)
# Snapshot cumulative counts at the latest available week; never sum cumulative rows.
latest_snapshot <- function(df) {
  df %>% arrange(desc(reporting_year), desc(reporting_week)) %>%
    group_by(prname) %>% slice_head(n = 1) %>% ungroup()
}

provincial_trends <- function(df) {
  df %>%
    group_by(reporting_year, reporting_week, prname) %>%
    summarise(
      cases = if (all(is.na(numtotal_last7))) {
        NA_real_
      } else {
        sum(numtotal_last7, na.rm = TRUE)
      },
      .groups = "drop"
    ) %>%
    arrange(reporting_year, reporting_week) %>%
    mutate(
      period = sprintf(
        "%d-W%02d",
        reporting_year,
        reporting_week
      )
    )
}


weekly_trends <- function(df) {
  df %>%
    group_by(reporting_year, reporting_week) %>%
    summarise(
      cases = if (all(is.na(numtotal_last7))) {
        NA_real_
      } else {
          if (all(is.na(numtotal_last7))) {
            NA_real_
          } else {
            sum(numtotal_last7, na.rm = TRUE)
          }
      },
      deaths = if (all(is.na(numdeaths_last7))) {
        NA_real_
      } else {
        sum(numdeaths_last7, na.rm = TRUE)
      },
      .groups = "drop"
    ) %>%
    arrange(reporting_year, reporting_week) %>%
    mutate(
      period = sprintf("%d-W%02d", reporting_year, reporting_week),
      index = row_number()
    )
}


