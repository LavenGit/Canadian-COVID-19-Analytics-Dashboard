# Canadian COVID-19 Analytics Dashboard

R + SQLite + Shiny dashboard for provincial Canadian COVID-19 surveillance data.

## Setup
1. Install R and RStudio.
2. In RStudio, open this folder as a project or set working directory to this folder.
3. Install packages:
   `install.packages(c("shiny", "bslib", "DBI", "RSQLite", "dplyr", "ggplot2", "plotly", "DT", "readr"))`
4. Put your original CSV at `data/covid.csv`.
5. Run `source("scripts/import_data.R")` to create/populate SQLite.
6. Run `shiny::runApp()`.

## Notes
- Each row should be unique per province, reporting year and week. Duplicate keys cause the importer to stop.
- Cumulative counts must not be summed over weeks; the app takes latest available snapshots per province.
- Weekly totals use `numtotal_last7`.
- Canada and repatriated travellers are excluded from province aggregates to prevent double counting.
- The import replaces previous data after validation. Do not modify the source CSV for this purpose.
- A reporting week may contain revisions or inconsistent reporting across jurisdictions.
