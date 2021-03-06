library("htmltools")

data_latest$label <- paste0(
  '<b>', ifelse(is.na(data_latest$`Province/State`), data_latest$`Country/Region`, data_latest$`Province/State`), '</b><br>
  Confirmed: ', data_latest$confirmed, '<br>
  Deaths: ', data_latest$death, '<br>
  Recovered: ', data_latest$recovered
)
data_latest$label <- lapply(data_latest$label, HTML)

map <- leaflet(data_latest) %>%
  setMaxBounds(-180, -90, 180, 90) %>%
  setView(0, 0, zoom = 2) %>%
  addTiles()

observe({
  zoomLevel <- input$overview_map_zoom
  leafletProxy("overview_map", data = data_latest) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(confirmed^(zoomLevel / 2)),
      stroke       = FALSE,
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15)
    )
})

output$overview_map <- renderLeaflet(map)


