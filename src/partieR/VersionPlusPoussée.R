library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  
  dashboardHeader(title = "Exploration de distributions"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Simulation", tabName = "simu", icon = icon("chart-bar")),
      menuItem("À propos", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "simu",
              fluidRow(
                box(
                  title = "Paramètres", width = 4, status = "primary", solidHeader = TRUE,
                  selectInput("dist", "Choisir une distribution :",
                              choices = c("Normale", "Uniforme", "Exponentielle")),
                  numericInput("n", "Nombre d'observations :", 100, min = 10, max = 10000),
                  
                  conditionalPanel(
                    condition = "input.dist == 'Normale'",
                    numericInput("mean", "Moyenne :", 0),
                    numericInput("sd", "Écart-type :", 1, min = 0.1)
                  ),
                  
                  conditionalPanel(
                    condition = "input.dist == 'Uniforme'",
                    numericInput("min", "Minimum :", 0),
                    numericInput("max", "Maximum :", 1)
                  ),
                  
                  conditionalPanel(
                    condition = "input.dist == 'Exponentielle'",
                    numericInput("rate", "Taux (lambda) :", 1, min = 0.1)
                  ),
                  
                  actionButton("go", "Générer !", class = "btn-primary")
                ),
                
                box(
                  title = "Résultats", width = 8, status = "info", solidHeader = TRUE,
                  plotOutput("distPlot", height = 250),
                  verbatimTextOutput("summary")
                )
              )
      ),
      
      tabItem(tabName = "about",
              h2("À propos du projet"),
              p("Cette application Shiny permet d'explorer visuellement des distributions aléatoires."),
              p("Elle a été développée dans le cadre d’un projet universitaire pour illustrer 
                les principes de base de Shiny : interface utilisateur, logique serveur, 
                et interactivité en temps réel.")
      )
    )
  )
)

server <- function(input, output) {
  
  data <- eventReactive(input$go, {
    n <- input$n
    switch(input$dist,
           "Normale" = rnorm(n, mean = input$mean, sd = input$sd),
           "Uniforme" = runif(n, min = input$min, max = input$max),
           "Exponentielle" = rexp(n, rate = input$rate))
  })
  
  output$distPlot <- renderPlot({
    hist(data(), col = "lightblue", border = "white",
         main = paste("Distribution", input$dist),
         xlab = "Valeurs simulées")
  })
  
  output$summary <- renderPrint({
    summary(data())
  })
}

shinyApp(ui = ui, server = server)

