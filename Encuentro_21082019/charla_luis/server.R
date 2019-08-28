server <- function (input, output, session) {
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      
      addCircleMarkers(data = pts,
                       popup = popup,
                       layerId = datos$beach,
                       radius = 6)
  })
  
  observeEvent(input$mymap_marker_click, {
    updateTabsetPanel(session, inputId = input$tabset, selected = "Playas")
    updateSelectInput(session, inputId = input$Playa, selected = input$mymap_marker_clicked$id)
    print(input$mymap_marker_clicked$layerId)
  })
  
  
  
  output$myplot <- renderPlot({
    if (input$tabset == "Playas") {
      active <- filter(areas2, beach %in% input$Playa)
      if (!input$vegeta)
        active <- filter(active, Tipo == "Arena")
      ggplot(data = active) +
        geom_line(aes(
          x = year,
          y = Sup,
          colour = Tipo
        )) + xlab ("Años")+ ylab ("Superficie (m2)")
    } else {
      p <- ggplot(areas) +
        geom_line()
      if (input$area_std) {
        p <- p + aes(x = year,
                     y = na,
                     color = beach)+ xlab ("Años") + ylab ("Superficie") 
      } else {
        p <- p + aes(x = year,
                     y = Arena + Vegetacion,
                     color = beach)+ xlab ("Años") + ylab ("Superficie (m2)")
      }
      p
    }
  })
  
  
}
