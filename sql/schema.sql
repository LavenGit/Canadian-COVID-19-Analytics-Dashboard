CREATE TABLE IF NOT EXISTS covid_reports (
 pruid INTEGER NOT NULL,
 prname TEXT NOT NULL,
 date TEXT,
 reporting_week INTEGER NOT NULL,
 reporting_year INTEGER NOT NULL,
 totalcases REAL,
 numtotal_last7 REAL,
 ratecases_total REAL,
 numdeaths REAL,
 numdeaths_last7 REAL,
 ratedeaths REAL,
 ratecases_last7 REAL,
 ratedeaths_last7 REAL,
 PRIMARY KEY (pruid, reporting_year, reporting_week)
);
CREATE INDEX IF NOT EXISTS idx_covid_period ON covid_reports(reporting_year, reporting_week);
