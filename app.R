library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
source("R/database.R")
source("R/analysis.R")
if (!file.exists("database/covid.sqlite")) stop("First run: source('scripts/import_data.R')")
con <- connect_db()
all_data <- get_reports(con)
if (!nrow(all_data)) stop("Database empty. Run the import script.")
provinces <- sort(setdiff(unique(all_data$prname), c("Canada", "Repatriated travellers")))
years <- sort(unique(all_data$reporting_year))
ui <- page_sidebar(
  title = "Canadian COVID-19 Analytics",
  theme = bs_theme(bootswatch = "flatly"),
  sidebar = sidebar(
    selectInput("year", "Reporting year", choices = years, selected = max(years)),
    
    selectizeInput(
      "provinces",
      "Compare provinces / territories",
      choices = provinces,
      selected = c("Ontario", "Quebec", "Alberta"),
      multiple = TRUE,
      options = list(
        placeholder = "Search and select provinces...",
        plugins = list("remove_button")
      )
    )
    ,
    helpText("Cumulative metrics show the latest available record in the selected year."),
    downloadButton("download", "Download filtered CSV")
  ),
  navset_card_tab(
    nav_panel("Overview",
              layout_columns(
                value_box(
                  title = "Cumulative Cases",
                  value = textOutput("cases"),
                  showcase = icon("calendar"),
                  p(textOutput("cases_period")),
                  theme = "primary"
                ),
                value_box("Cumulative deaths", textOutput("deaths"), theme = "secondary"),
                value_box("Latest weekly cases", textOutput("weekcases"), theme = "info"),
                value_box("Latest weekly deaths", textOutput("weekdeaths"), theme = "warning"),
                col_widths = c(3,3,3,3)
              ),
              card(
                card_header("Weekly COVID-19 Cases by Province"),
                plotlyOutput("trend", height = "500px")
              ),
              
              card(
                card_header("Provincial Statistics Comparison"),
                p("Latest available weekly and cumulative figures for each selected province."),
                DTOutput("province_stats")
              )
    ),
    nav_panel("Province comparison",
              card(card_header("Latest cumulative cases by province"), plotlyOutput("comparison", height = "480px"))
    ),
    nav_panel("Data explorer",
              card(card_header("Filtered records"), DTOutput("records"))
    ),
    nav_panel("Data quality",
              card(card_header("Missing values by field"), tableOutput("quality"))
    )
  )
)
latest_common_snapshot <- function(df, column = "totalcases") {
  
  if (nrow(df) == 0) return(df)
  
  coverage <- df %>%
    group_by(reporting_year, reporting_week) %>%
    summarise(
      complete = all(!is.na(.data[[column]])) &&
        n_distinct(prname) == n_distinct(df$prname),
      .groups = "drop"
    ) %>%
    filter(complete) %>%
    arrange(desc(reporting_year), desc(reporting_week))
  
  if (nrow(coverage) == 0) return(df[0, ])
  
  df %>%
    semi_join(
      coverage %>% slice_head(n = 1),
      by = c("reporting_year", "reporting_week")
    )
}
server <- function(input, output, session) {
  filtered <- reactive({
    req(input$year)
    if (!length(input$provinces)) return(all_data[0, ])
    get_reports(con, year = input$year, provinces = input$provinces)
  })
  
  output$province_stats <- renderDT({
    
    x <- filtered()
    
    validate(
      need(nrow(x) > 0, "Select at least one province.")
    )
    
    latest_cumulative <- latest_snapshot(x) %>%
      select(prname, totalcases)
    
    latest_weekly <- x %>%
      filter(!is.na(numtotal_last7)) %>%
      arrange(
        prname,
        desc(reporting_year),
        desc(reporting_week)
      ) %>%
      group_by(prname) %>%
      slice_head(n = 1) %>%
      ungroup() %>%
      select(
        prname,
        reporting_year,
        reporting_week,
        numtotal_last7
      )
    
    comparison <- latest_cumulative %>%
      left_join(latest_weekly, by = "prname") %>%
      mutate(
        reporting_period = ifelse(
          is.na(reporting_week),
          "Not reported",
          sprintf(
            "%d-W%02d",
            reporting_year,
            reporting_week
          )
        )
      ) %>%
      transmute(
        Province = prname,
        `Latest weekly cases` = numtotal_last7,
        `Reporting period` = reporting_period,
        `Cumulative cases` = totalcases
      )
    
    datatable(
      comparison,
      rownames = FALSE,
      extensions = "Buttons",
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = "Bftip",
        buttons = c("copy", "csv")
      )
    ) %>%
      formatRound(
        columns = c("Latest weekly cases", "Cumulative cases"),
        digits = 0,
        mark = ","
      )
  })
  snapshot <- reactive({
    latest_common_snapshot(filtered(), "totalcases")
  })
  output$cases_period <- renderText({
    x <- snapshot()
    
    if (!nrow(x)) return("No complete reporting week available")
    
    paste0(
      "As of Week ",
      x$reporting_week[1],
      ", ",
      x$reporting_year[1]
    )
  })
  fmt <- function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return("N/A")
    }
    
    
    format(
      sum(x, na.rm = TRUE),
      big.mark = ",",
      scientific = FALSE,
      trim = TRUE
    )
  }
  output$cases <- renderText(fmt(snapshot()$totalcases))
  output$deaths <- renderText(fmt(snapshot()$numdeaths))
  latest_week <- reactive({
    x <- filtered()
    if (!nrow(x)) return(x)
    x %>% filter(reporting_week == max(reporting_week, na.rm = TRUE))
  })
  output$weekcases <- renderText(fmt(latest_week()$numtotal_last7))
  output$weekdeaths <- renderText(fmt(latest_week()$numdeaths_last7))
  
  output$trend <- renderPlotly({
    
    x <- provincial_trends(filtered())
    
    validate(
      need(nrow(x) > 0, "Select at least one province.")
    )
    
    x <- x %>%
      mutate(
        hover_text = paste0(
          "<b>", prname, "</b>",
          "<br>Week: ", period,
          "<br>New cases: ",
          ifelse(
            is.na(cases),
            "Not reported",
            format(cases, big.mark = ",")
          )
        )
      )
    
    p <- ggplot(
      x,
      aes(
        x = reporting_week,
        y = cases,
        color = prname,
        group = prname,
        text = hover_text
      )
    ) +
      geom_line(linewidth = 1.1, na.rm = TRUE) +
      geom_point(size = 1.8, na.rm = TRUE) +
      scale_x_continuous(
        breaks = scales::breaks_pretty(n = 10)
      ) +
      scale_y_continuous(
        labels = scales::label_comma()
      ) +
      labs(
        title = "Weekly COVID-19 Cases by Province",
        subtitle = "Compare reported cases across selected provinces",
        x = "Reporting week",
        y = "New reported cases",
        color = "Province"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold", size = 17),
        plot.subtitle = element_text(color = "gray45"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom"
      )
    
 
    ggplotly(p, tooltip = "text") %>%
      layout(
        hovermode = "closest",
        margin = list(
          l = 85,
          r = 35,
          t = 65,
          b = 105
        ),
        legend = list(
          orientation = "h",
          x = 0,
          y = -0.3
        )
      )
  })
  output$comparison <- renderPlotly({
    x <- snapshot()
    validate(need(nrow(x), "Choose at least one province."))
    p <- ggplot(x, aes(x = reorder(prname, totalcases), y = totalcases)) +
      geom_col(fill = "#2878B5") + coord_flip() +
      labs(x = "Province / territory", y = "Cumulative cases") + theme_minimal()
    ggplotly(p)
  })
  output$records <- renderDT(datatable(filtered(), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE))
  output$quality <- renderTable({
    x <- filtered()
    data.frame(column = names(x), missing = vapply(x, function(v) sum(is.na(v)), integer(1)))
  })
  output$download <- downloadHandler(
    filename = function() paste0("covid_", input$year, ".csv"),
    content = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
  session$onSessionEnded(function() {})
}
shinyApp(ui, server)



