# Canadian-COVID-19-Analytics-Dashboard

An interactive dashboard developed using **R, SQL, SQLite, Shiny, ggplot2, and Plotly** to explore COVID-19 trends across Canadian provinces and territories.

The dashboard provides visualizations, numerical comparisons, and data-quality insights to help users understand historical COVID-19 reporting patterns.

## ✨ Features

- 📊 **Interactive Overview** — View cumulative cases, deaths, and weekly trends.
- 📈 **Provincial Trends** — Compare weekly reported COVID-19 cases across provinces using interactive line graphs.
- 🔢 **Numerical Comparisons** — Compare provincial case counts and cumulative statistics in sortable tables.
- 🔍 **Dynamic Filters** — Select reporting years and provinces to explore specific data.
- 🗄️ **SQLite Integration** — Store and query 3,630 COVID-19 records using SQL.
- 📥 **CSV Export** — Download filtered datasets and comparison results.
- 🧹 **Data Quality Analysis** — Identify missing values and distinguish unavailable data from actual zero cases.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| R | Data processing and analysis |
| SQL / SQLite | Database storage and queries |
| Shiny | Interactive web application |
| bslib | Dashboard layout and styling |
| dplyr | Data manipulation |
| ggplot2 | Data visualization |
| Plotly | Interactive charts |
| DT | Interactive tables |
| DBI / RSQLite | Database connectivity |

## 📁 Project Structure

```text
Canadian-COVID19-Analytics/
│
├── app.R
├── R/
│   ├── analysis.R
│   └── database.R
├── scripts/
│   └── import_data.R
├── data/
│   └── covid.csv
├── database/
│   └── covid.sqlite
└── README.md
```

**Note:** `covid.sqlite` is generated during database initialization and does not need to be uploaded to GitHub.

## 🚀 Installation and Setup

### 1. Prerequisites

Install the following software:

- [R](https://cran.r-project.org/)
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/)

### 2. Clone the Repository

```bash
git clone https://github.com/LavenGit/Canadian-COVID19-Analytics.git
cd Canadian-COVID19-Analytics
```

Alternatively, download the repository as a ZIP file and extract it.

### 3. Open the Project in RStudio

Open the project folder in RStudio.

Ensure the R working directory points to the `Canadian-COVID19-Analytics` folder. You can verify this using:

```r
getwd()
```

If necessary, change it to the folder where you cloned or downloaded the project:

setwd("path/to/Canadian-COVID19-Analytics")

Replace the example path with the actual location of the project on your computer.

You can now run:

source("scripts/import_data.R")
shiny::runApp()

Note: You only need to import the CSV into SQLite the first time, or whenever you want to rebuild the database.
### 4. Install Required Packages

Run the following in the RStudio Console:

```r
install.packages(c(
  "shiny",
  "bslib",
  "dplyr",
  "ggplot2",
  "plotly",
  "DT",
  "DBI",
  "RSQLite",
  "scales"
))
```

Packages only need to be installed once.

### 5. Initialize the Database

Run:

```r
source("scripts/import_data.R")
```

This imports the CSV dataset into a local SQLite database containing 3,630 COVID-19 records.

**This step is only required during the initial setup or when rebuilding the database.**

### 6. Run the Dashboard

Run:

```r
shiny::runApp(".")
```

The dashboard will launch in RStudio's Viewer or your web browser.

Once the application is running, select a reporting year and provinces to explore the available data.

## 📊 Dashboard Sections

| Section | Description |
|---|---|
| Overview | Cumulative statistics, weekly case trends, and numerical comparisons |
| Province Comparison | Compare cumulative case counts across selected provinces |
| Data Explorer | Browse and search filtered COVID-19 records |
| Data Quality | Examine missing values across dataset columns |

## 🧹 Data Processing and Quality

The dashboard includes data-processing logic to improve the accuracy and interpretation of COVID-19 statistics.

- Distinguishes missing (`NA`) values from reported zero cases.
- Preserves missing observations in weekly trend visualizations.
- Supports selecting the latest available cumulative case records.
- Provides reporting-period information to help interpret historical statistics.

**Data limitation:** Some reporting fields are unavailable in later weeks of 2024. Missing values should not be interpreted as zero cases or deaths. The latest available cumulative values may not represent year-end totals.

## ▶️ Quick Start

After completing the initial setup, launch the application from the project directory using:

```r
shiny::runApp(".")
```

The application automatically loads its database and analysis functions from the `R/` directory.

## 🎯 Skills Demonstrated

- R programming and data manipulation
- SQL queries and SQLite database integration
- Interactive dashboard development
- Data cleaning and missing-value handling
- Statistical summaries and trend analysis
- Data visualization with ggplot2 and Plotly
- Interactive tables and CSV exports

## 👨‍💻 Author

**Laven Joshi**

GitHub: [LavenGit](https://github.com/LavenGit)
