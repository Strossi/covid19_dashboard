output$case_evolution <- renderPlotly({
  data <- data_evolution %>%
    group_by(date, var) %>%
    summarise(
      "value" = sum(value)
    ) %>%
    as.data.frame()

  plot_ly(
    data,
    x     = ~date,
    y     = ~value,
    name  = sapply(data$var, capFirst),
    color = ~var,
    type  = 'scatter',
    mode  = 'lines') %>%
    layout(
      yaxis = list(title = "# cases"),
      xaxis = list(title = "Date")
    )
})

output$selectize_countries <- renderUI({
  column(
    selectizeInput(
      "caseEvolution_country",
      label    = "Select countries",
      choices  = unique(data_evolution$`Country/Region`),
      selected = c("China", "Italy", "Iran"),
      multiple = TRUE
    ),
    width = 3
  )
})

getDataByCountry <- function(countries) {
  data_confirmed <- data_evolution %>%
    filter(`Country/Region` %in% countries & var == "confirmed") %>%
    arrange(date) %>%
    as.data.frame()

  data_recovered <- data_evolution %>%
    filter(`Country/Region` %in% countries & var == "recovered") %>%
    arrange(date) %>%
    as.data.frame()

  data_death <- data_evolution %>%
    filter(`Country/Region` %in% countries & var == "death") %>%
    arrange(date) %>%
    as.data.frame()

  return(list(
    "confirmed" = data_confirmed,
    "recovered" = data_recovered,
    "death"     = data_recovered
  ))
}

output$case_evolution_byCountry <- renderPlotly({
  data <- getDataByCountry(input$caseEvolution_country)
  browser()
  req(nrow(data$confirmed) > 0)
  p <- plot_ly(data = data$confirmed, x = ~date, y = ~value, color = ~`Country/Region`, type = 'scatter', mode = 'lines',
    legendgroup     = ~`Country/Region`) %>%
    add_trace(data = data$recovered, x = ~date, y = ~value, color = ~`Country/Region`, line = list(dash = 'dash'),
      legendgroup  = ~`Country/Region`, showlegend = FALSE) %>%
    add_trace(data = data$death, x = ~date, y = ~value, color = ~`Country/Region`, line = list(dash = 'dot'),
      legendgroup  = ~`Country/Region`, showlegend = FALSE) %>%
    layout(
      yaxis = list(title = "# cases"),
      xaxis = list(title = "Date")
    )

  return(p)
})

output$box_caseEvolution <- renderUI({
  tagList(
    box(
      title = "Evolution of Cases since Outbreak",
      plotlyOutput("case_evolution"),
      width = 6
    ),
    box(
      title = "Cases per Country",
      plotlyOutput("case_evolution_byCountry"),
      uiOutput("selectize_countries"),
      width = 6
    ))
})