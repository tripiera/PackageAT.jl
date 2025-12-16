# =======================================================================
# GENESIS — Simulation du vivant 
# Auteur : Amine Allache
# Langage principal : R (Shiny)
# Technologies utilisées : R + CSS intégré via tags$style (aucun JavaScript)
# =======================================================================

# === 1 Importation des bibliothèques principales ===
library(shiny)     # Framework principal pour créer l'application web interactive
library(ggplot2)   # Pour générer les graphiques (courbes, points, etc.)
library(bslib)     # Pour appliquer un thème visuel Bootstrap personnalisé (couleurs, police)

# =======================================================================
# === 2 Interface utilisateur (UI) ===
# =======================================================================
ui <- fluidPage(
  
  # --- Thème global défini avec bslib ---
  theme = bs_theme(
    bg = "#000000",       # Couleur de fond (noir)
    fg = "#00ffff",       # Couleur de texte principale (cyan néon)
    primary = "#00ffff",  # Couleur d'accent
    base_font = font_google("Orbitron") # Police importée depuis Google Fonts
  ),
  
  # --- Section CSS intégrée (aucun fichier externe) ---
  # Ici on applique les styles visuels (animations, couleurs, marges, effets néon)
  # Ce bloc utilise uniquement du CSS pur, pas de JavaScript.
  tags$head(
    tags$style(HTML("
      /* Animation du logo ADN (effet de pulsation lumineuse) */
      @keyframes pulseDNA {
        0% { transform: scale(1); opacity: 0.8; filter: drop-shadow(0 0 5px #00ffff); }
        50% { transform: scale(1.1); opacity: 1; filter: drop-shadow(0 0 15px #00ffff); }
        100% { transform: scale(1); opacity: 0.8; filter: drop-shadow(0 0 5px #00ffff); }
      }

      /* Classe appliquée au logo ADN */
      .dna-logo {
        animation: pulseDNA 2.5s infinite ease-in-out;
        display: block;
        margin-left: auto;
        margin-right: auto;
        width: 90px;
      }

      /* Titre principal */
      h1 {
        text-align: center;
        color: #00ffff;
        font-family: 'Orbitron', sans-serif;
      }

      /* Sous-titre */
      .subtitle {
        text-align: center;
        color: #00cccc;
        margin-top: -5px;
        margin-bottom: 20px;
      }

      /* Boîte d'informations stylisée (stats) */
      .neon-box {
        border: 1px solid #00ffff;
        border-radius: 10px;
        padding: 8px;
        text-align: center;
        color: #00ffff;
        background-color: rgba(0,0,0,0.3);
      }
    "))
  ),
  
  # =======================================================================
  # === 3⃣ En-tête graphique : Logo + Titre ===
  # =======================================================================
  tags$div(
    # Logo ADN animé par le CSS (voir classe .dna-logo ci-dessus)
    tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/8/87/DNA_chemical_structure.svg",
             class = "dna-logo"),
    
    # Titre principal
    h1(" GENESIS — Monde vivant"),
    
    # Sous-titre explicatif
    div("Simulation d'évolution artificielle", class = "subtitle")
  ),
  
  # =======================================================================
  # === 4 Son d’ambiance (fichier dans le dossier www/) ===
  # =======================================================================
  # Le son est lu automatiquement et tourne en boucle, sans contrôles visibles.
  #  c’est du HTML standard intégré.
  tags$audio(
    src = "ambient.mp3",      # Le fichier doit être dans le dossier www/
    type = "audio/mp3",
    autoplay = NA,            # Lecture automatique au lancement
    loop = NA,                # Boucle infinie
    controls = NA             # Pas de boutons visibles
  ),
  
  # =======================================================================
  # === 5 Mise en page principale (Sidebar + Graphiques) ===
  # =======================================================================
  sidebarLayout(
    
    # --- Panneau latéral gauche : Contrôles utilisateur ---
    sidebarPanel(
      sliderInput("n", "Population initiale", 50, 500, 200),
      sliderInput("grav", "Gravité", 0, 1, 0.2, step = 0.01),
      sliderInput("mutation", "Taux de mutation", 0, 1, 0.05, step = 0.01),
      
      # Boutons d’action
      actionButton("create", "Créer le monde", class = "btn-success w-100"),
      actionButton("pause", " Lecture / Pause", class = "btn-warning w-100"),
      
      br(), br(),
      h4(" Statistiques actuelles", style="color:#00ffff;text-align:center;"),
      
      # Boîtes stylisées avec classe CSS .neon-box
      div(textOutput("stats"), class="neon-box"),
      div(textOutput("energy"), class="neon-box"),
      div(textOutput("births"), class="neon-box")
    ),
    
    # --- Zone principale : Graphiques dynamiques ---
    mainPanel(
      plotOutput("p", height = "500px"),      # Simulation principale
      br(),
      plotOutput("pop_curve", height = "200px")  # Courbe d’évolution
    )
  )
)

# =======================================================================
# ===  Serveur (logique et calculs) ===

server <- function(input, output, session) {
  
  # --- Variables réactives ---
  world  <- reactiveVal(NULL)   # Contient la liste des êtres vivants
  running <- reactiveVal(FALSE) # Indique si la simulation est en cours
  births  <- reactiveVal(0)     # Compteur de naissances
  history <- reactiveVal(data.frame(step=0, population=0)) # Historique population
  tick <- reactiveTimer(150)    # Intervalle de mise à jour (en ms)
  
  # --- Création du monde initial ---
  observeEvent(input$create, {
    n <- input$n
    df <- data.frame(
      x = runif(n),             # Position horizontale aléatoire
      y = runif(n),             # Position verticale aléatoire
      vx = rnorm(n, 0, 0.005),  # Vitesse horizontale
      vy = rnorm(n, 0, 0.005),  # Vitesse verticale
      energy = runif(n, 0.5, 1) # Énergie initiale
    )
    world(df)
    births(0)
    history(data.frame(step=0, population=n))
    running(TRUE)
  })
  
  # --- Bouton Pause : inverse l'état du booléen ---
  observeEvent(input$pause, { running(!running()) })
  
  # --- Boucle principale d'animation ---
  observeEvent(tick(), {
    req(world(), running())     # Exécute seulement si le monde existe et tourne
    df <- world()
    
    # Gravité : modifie la vitesse verticale
    df$vy <- df$vy - input$grav * 0.002
    
    # Déplacement : positions mises à jour
    df$x <- (df$x + df$vx) %% 1
    df$y <- (df$y + df$vy) %% 1
    
    # Perte d’énergie à chaque "tick"
    df$energy <- pmax(0, df$energy - 0.002)
    
    # Suppression des êtres morts (énergie <= 0)
    df <- df[df$energy > 0, ]
    
    # Mutation / reproduction aléatoire
    if (runif(1) < input$mutation && nrow(df) > 0) {
      new <- data.frame(
        x = runif(3),
        y = runif(3),
        vx = rnorm(3, 0, 0.005),
        vy = rnorm(3, 0, 0.005),
        energy = runif(3, 0.4, 0.8)
      )
      df <- rbind(df, new)
      births(births() + nrow(new))
    }
    
    # Sauvegarde de l'état du monde
    world(df)
    
    # Historique des populations
    hist <- history()
    hist <- rbind(hist, data.frame(step = nrow(hist)+1, population = nrow(df)))
    if (nrow(hist) > 100) hist <- tail(hist, 100)  # Garde les 100 dernières étapes
    history(hist)
  })
  
  # =======================================================================
  # === 7 Sorties graphiques ===
  # =======================================================================
  
  # --- Simulation principale ---
  output$p <- renderPlot({
    req(world())
    df <- world()
    
    # Couleur des points dépend de l’énergie (du rouge au vert)
    cols <- rgb(1 - df$energy, df$energy, 0, 0.8)
    
    par(bg="#000000") # Fond noir
    plot(df$x, df$y,
         pch = 19,
         cex = df$energy * 3,
         col = cols,
         xlim = c(0,1), ylim = c(0,1),
         xaxt="n", yaxt="n",
         main = " Monde vivant — Simulation dynamique",
         col.main="#00ffff")
  })
  
  # --- Courbe de population ---
  output$pop_curve <- renderPlot({
    req(history())
    h <- history()
    ggplot(h, aes(x=step, y=population)) +
      geom_line(color="#00ffff", linewidth=1) +
      geom_point(color="#00ffff") +
      theme_void() +
      theme(plot.background = element_rect(fill="#000000", color=NA)) +
      labs(title="Évolution de la population (100 dernières étapes)") +
      theme(plot.title=element_text(color="#00ffff", hjust=0.5))
  })
  
  # --- Textes dynamiques ---
  output$stats <- renderText({
    req(world())
    paste(" Êtres vivants :", nrow(world()))
  })
  
  output$energy <- renderText({
    req(world())
    paste("nergie moyenne :", round(mean(world()$energy), 3))
  })
  
  output$births <- renderText({
    paste(" Naissances :", births())
  })
}

# =======================================================================
# ===  Options globales et lancement de l'app ===
# =======================================================================
options(device = "windows")        # Nécessaire pour R sous Windows
options(shiny.usecairo = FALSE)    # Améliore les performances graphiques
options(viewer = NULL)             # Force l'ouverture dans le navigateur

# Démarrage de l'application
shinyApp(ui, server)
