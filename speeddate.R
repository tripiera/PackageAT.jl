library(shiny)
library(shinydashboard)

# ---- Données des stars ----
stars <- data.frame(
  star = c("Zendaya", "Timothée Chalamet", "Taylor Swift", "Ryan Gosling"),
  humour = c(5, 3, 4, 4),
  sport = c(3, 4, 2, 5),
  musique = c(4, 5, 5, 3),
  voyages = c(5, 4, 3, 4),
  stringsAsFactors = FALSE
)

# ---- Interface utilisateur ----
ui <- dashboardPage(
  dashboardHeader(title = "💘 SpeedDating de Stars 💫"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Questionnaire", tabName = "quiz", icon = icon("heart")),
      menuItem("Résultats", tabName = "resultats", icon = icon("star")),
      menuItem("À propos", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # ---- Onglet Questionnaire ----
      tabItem(tabName = "quiz",
              fluidRow(
                box(
                  title = "Tes réponses 💭", status = "primary", solidHeader = TRUE, width = 4,
                  sliderInput("humour", "Tu aimes l'humour ?", 1, 5, 3),
                  sliderInput("sport", "Tu es sportif(ve) ?", 1, 5, 3),
                  sliderInput("musique", "Tu adores la musique ?", 1, 5, 3),
                  sliderInput("voyages", "Tu aimes voyager ?", 1, 5, 3),
                  actionButton("go", "Voir mes compatibilités 💞", class = "btn-success")
                ),
                box(
                  title = "Aperçu des stars", status = "info", solidHeader = TRUE, width = 8,
                  p("🪩 Rencontre avec nos stars disponibles :"),
                  tags$ul(
                    tags$li("🌟 Zendaya – drôle, aime voyager et la musique"),
                    tags$li("🎬 Timothée Chalamet – artiste passionné, aime le sport"),
                    tags$li("🎤 Taylor Swift – romantique et mélomane"),
                    tags$li("💪 Ryan Gosling – sportif et plein d’humour")
                  )
                )
              )
      ),
      
      # ---- Onglet Résultats ----
      tabItem(tabName = "resultats",
              fluidRow(
                box(
                  title = "Tableau de compatibilités", width = 6, status = "warning", solidHeader = TRUE,
                  tableOutput("resultats")
                ),
                box(
                  title = "Graphique", width = 6, status = "danger", solidHeader = TRUE,
                  plotOutput("plot", height = 300)
                )
              ),
              fluidRow(
                box(
                  title = "Ta star la plus compatible 💖", width = 12, status = "success", solidHeader = TRUE,
                  h3(textOutput("best_star"), align = "center")
                )
              )
      ),
      
      # ---- Onglet À propos ----
      tabItem(tabName = "about",
              h2("À propos de l’application"),
              p("Ce projet universitaire a été réalisé avec R Shiny dans le cadre d’un exercice de développement interactif."),
              p("L’objectif est de proposer une expérience ludique : simuler un speed-dating entre l’utilisateur et plusieurs stars célèbres."),
              p("Les compatibilités sont calculées sur la base de 4 critères : humour, sport, musique et voyages."),
              p("Projet développé par : [Ton Nom], [Nom de ton université].")
      )
    )
  )
)

# ---- Serveur ----
server <- function(input, output) {
  
  # Calcul des compatibilités
  resultat <- eventReactive(input$go, {
    reponses <- c(input$humour, input$sport, input$musique, input$voyages)
    
    scores <- apply(stars[, -1], 1, function(star_traits) {
      100 - mean(abs(star_traits - reponses)) / 4 * 100
    })
    
    data.frame(
      Star = stars$star,
      Compatibilité = round(scores, 1)
    )
  })
  
  output$resultats <- renderTable({
    resultat()
  })
  
  output$plot <- renderPlot({
    req(resultat())
    barplot(resultat()$Compatibilité, names.arg = resultat()$Star,
            col = c("hotpink", "skyblue", "lightgreen", "orange"),
            ylim = c(0, 100),
            main = "Compatibilité avec les stars 💞",
            ylab = "Compatibilité (%)")
  })
  
  output$best_star <- renderText({
    req(resultat())
    best <- resultat()[which.max(resultat()$Compatibilité), "Star"]
    paste("💘 Ta star la plus compatible est :", best, "!")
  })
}

# ---- Lancer l'app ----
shinyApp(ui = ui, server = server)

