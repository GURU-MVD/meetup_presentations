###rm(list=ls())
# library(rgdal)
library(sp) ##clases espec?ficas para spatial
library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(xts)
library(tidyr)
library(shinythemes)
library(reshape2)

# creating a sample data.frame with your lat/lon points
datos<- read.csv("Mdeoppclasificacion.csv", dec=".", sep=";", header=T)
areas<- read.csv("DatArea.csv", dec=".", sep=";", header=T)



attach(datos)

pts <- cbind(lon, lat)


dat <- data.frame(areas %>%
                    group_by( beach ) %>%
                    summarise( sand = round(mean(Arena),0), veg = round(mean(Vegetacion),0)) )

areas2 <- areas %>% gather(key = "Tipo", value = "Sup", Arena, Vegetacion)


# left join ---------------------------------------------------------------


datos<- left_join (datos, dat, by= "beach")

popup <- paste0("<strong>Sitio: </strong>", 
                datos$beach, 
                "<br><strong>Arena promedio(m2): </strong>", 
                datos$sand,
                "<br><strong>Vegetacion promedio(m2): </strong>", 
                datos$veg,
                "<br><strong>Largo de Playa(m): </strong>", 
                datos$len,
                "<br><strong>Orientacion: </strong>", 
                datos$orcat
)

# UI ---------------------------------------------------------------
ui <- fluidPage (title = "Playas de Montevideo",
                 shinytheme ("sandstone"),
                 
                 titlePanel(p("Evolución del Área en playas de Montevideo", style = "color:#3474A7")),
                 sidebarLayout(
                   sidebarPanel(
                     p("Desarrollado con ", a("Shiny", href = "http://shiny.rstudio.com"), a("       METODOLOGIA", href = "http://shiny.rstudio.com"), a("      PUBLICACION", href = "https://www.sciencedirect.com/science/article/pii/S0272771418307686") ),
                     br(),
                     img(src = "http://undecimar.fcien.edu.uy/wp-content/uploads/2017/11/cropped-logos.jpg", height = "90px"), 
                     br(),                  
                     p(" Las playas arenosas son sistemas de interfase dinámica entre el mar y la tierra,
                       su area es altamente variable y esta influenciada por procesos climáticos como 
                       mareas, viento y temperatura del agua. La ciudad depende de la playa para la proteccion contra
                       la accion erosiva del mar y la mejora de la calidad del agua. Los humanos dependemos de la playa
                       para el esparcimiento y desarrollo económico. Otras especies utilizan la playa como refugio,
                       área de cría, zona de alimentacion o como habitat para todo su ciclo de vida. Son muchos los 
                       beneficios que se obtienen al tener playas sanas y extensas."),
                     
                     
                     # Tabset ----------------------------------------------------------
                     tabsetPanel(id = "tabset",
                                 tabPanel(
                                   "Playas",
                                   id = "Playas",
                                   checkboxInput(
                                     inputId = "vegeta",
                                     label = "Vegetacion",
                                     value = F
                                   ),
                                   selectInput(
                                     inputId = "Playa",
                                     label = "Playa",
                                     choices = datos$beach,
                                     selected = "Malvin"
                                   )),
                                 tabPanel(
                                   "Costa",
                                   id = "Costa",
                                   checkboxInput(
                                     inputId = "area_std",
                                     label = "Estandarizar",
                                     value = F
                                   )
                                 )
                     )),
                   mainPanel(
                     leafletOutput("mymap", height=300),
                     plotOutput("myplot", height = 400)
                   )
                   ))
