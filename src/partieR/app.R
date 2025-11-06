# app.R
library(shiny)
library(shinythemes)
library(plotly)

# --- Compat tables (identiques à Julia) ---
MBTI_COMP <- list(
  ESTJ = c("INFP","ENFP","ISTP"), ISTJ = c("ENFJ","INFJ","ESTP"),
  ESFJ = c("INTP","ENTP","ISFP"), ISFJ = c("ENTJ","INTJ","ESFP"),
  ESTP = c("INFJ","ENFJ","ISTJ"), ISTP = c("ENFP","INFP","ESTJ"),
  ESFP = c("INTJ","ENTJ","ISFJ"), ISFP = c("ENTP","INTP","ESFJ"),
  ENTJ = c("ISFJ","ESFP","INTJ"), INTJ = c("ESFP","ISFJ","ENTJ"),
  ENTP = c("ISFP","ESFJ","INTP"), INTP = c("ESFJ","ISFP","ENTP"),
  ENFJ = c("ISTJ","ESTP","INFJ"), INFJ = c("ESTP","ISTJ","ENFJ"),
  ENFP = c("ISTP","ESTJ","INFP"), INFP = c("ESTJ","ISTP","ENFP")
)

MBTI_QUEST <- list(
  ESTJ = c("Préférerais-tu INFP : créatif, introspectif et idéaliste ?",
           "Préférerais-tu ENFP : enthousiaste, sociable et imaginatif ?",
           "Préférerais-tu ISTP : calme, pratique et analytique ?"),
  ISTJ = c("Préférerais-tu ENFJ : chaleureux, organisé et charismatique ?",
           "Préférerais-tu INFJ : réfléchi, intuitif et empathique ?",
           "Préférerais-tu ESTP : énergique, pratique et spontané ?"),
  ESFJ = c("Préférerais-tu INTP : logique, discret et créatif ?",
           "Préférerais-tu ENTP : inventif, sociable et curieux ?",
           "Préférerais-tu ISFP : sensible, artistique et attentionné ?"),
  ISFJ = c("Préférerais-tu ENTJ : déterminé, organisé et ambitieux ?",
           "Préférerais-tu INTJ : stratégique, calme et visionnaire ?",
           "Préférerais-tu ESFP : spontané, joyeux et sociable ?"),
  ESTP = c("Préférerais-tu INFJ : réfléchi, intuitif et empathique ?",
           "Préférerais-tu ENFJ : sociable, chaleureux et charismatique ?",
           "Préférerais-tu ISTJ : organisé, pratique et fiable ?"),
  ISTP = c("Préférerais-tu ENFP : enthousiaste, curieux et imaginatif ?",
           "Préférerais-tu INFP : introspectif, créatif et idéaliste ?",
           "Préférerais-tu ESTJ : pratique, organisé et direct ?"),
  ESFP = c("Préférerais-tu INTJ : stratégique, réfléchi et visionnaire ?",
           "Préférerais-tu ENTJ : ambitieux, organisé et motivé ?",
           "Préférerais-tu ISFJ : attentionné, calme et fiable ?"),
  ISFP = c("Préférerais-tu ENTP : inventif, sociable et curieux ?",
           "Préférerais-tu INTP : analytique, créatif et discret ?",
           "Préférerais-tu ESFJ : chaleureux, sociable et attentionné ?"),
  ENTJ = c("Préférerais-tu ISFJ : attentif, fiable et discret ?",
           "Préférerais-tu ESFP : joyeux, sociable et spontané ?",
           "Préférerais-tu INTJ : réfléchi, stratégique et visionnaire ?"),
  INTJ = c("Préférerais-tu ESFP : joyeux, sociable et spontané ?",
           "Préférerais-tu ISFJ : fiable, attentif et calme ?",
           "Préférerais-tu ENTJ : ambitieux, organisé et déterminé ?"),
  ENTP = c("Préférerais-tu ISFP : sensible, artistique et attentif ?",
           "Préférerais-tu ESFJ : sociable, chaleureux et attentif ?",
           "Préférerais-tu INTP : logique, discret et inventif ?"),
  INTP = c("Préférerais-tu ESFJ : sociable, chaleureux et attentif ?",
           "Préférerais-tu ISFP : artistique, sensible et discret ?",
           "Préférerais-tu ENTP : curieux, inventif et sociable ?"),
  ENFJ = c("Préférerais-tu ISTJ : organisé, fiable et réfléchi ?",
           "Préférerais-tu ESTP : spontané, pratique et direct ?",
           "Préférerais-tu INFJ : intuitif, réfléchi et empathique ?"),
  INFJ = c("Préférerais-tu ESTP : pratique, énergique et spontané ?",
           "Préférerais-tu ISTJ : fiable, réfléchi et organisé ?",
           "Préférerais-tu ENFJ : sociable, chaleureux et charismatique ?"),
  ENFP = c("Préférerais-tu ISTP : calme, pratique et analytique ?",
           "Préférerais-tu ESTJ : organisé, direct et efficace ?",
           "Préférerais-tu INFP : créatif, introspectif et idéaliste ?"),
  INFP = c("Préférerais-tu ESTJ : organisé, direct et efficace ?",
           "Préférerais-tu ISTP : calme, pratique et analytique ?",
           "Préférerais-tu ENFP : enthousiaste, sociable et imaginatif ?")
)

# --- UI ---
ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(tags$style(HTML("
    body{background:linear-gradient(180deg,#ffe6f2 0%,#fff 100%);color:#b30059}
    .container-fluid{max-width:1000px}
    h1,h3,label{text-align:center}
    .card{background:#ffffffcc;border-radius:18px;padding:20px 24px;
          box-shadow:0 10px 25px rgba(255,102,178,.25);border:1px solid #ffd1e6}
    .love-btn{background:#ff66b2;color:#fff;font-weight:700;border-radius:16px;
              padding:12px 20px;border:none;font-size:18px}
    .love-btn:hover{background:#ff3399}
    .score-chip{display:inline-block;padding:6px 12px;border-radius:999px;background:#ffe6f2;
                border:1px solid #ffb3d9;font-weight:700;color:#b30059}
    .hint{color:#a04c74;font-size:12px;text-align:center}
  "))),
  br(), h1(" Test de Compatibilité — Questionnaire MBTI (Shiny) "),
# p(class="hint","Réponds, clique, et je crée les fichiers (mbti_result.txt, mbti_star_result.txt, user_info.txt)."),
  
  br(),
  div(class="card",
      h3("👤 Infos personnelles"),
      fluidRow(
        column(6, textInput("nom","Nom")),
        column(6, textInput("prenom","Prénom"))
      ),
      fluidRow(
        column(4, numericInput("age","Âge", value = NA, min = 1, max = 120)),
        column(4, selectInput("genre","Genre (H/F)", choices = c("","H","F"))),
        column(4, selectInput("orient","Orientation",
                              choices = c("","Hétéro","Bi","Gay","Lesbienne","Asexuelle","Pan","Autre")))
      )
  ),
  
  br(),
  div(class="card",
      h3("🧠 Questions MBTI (16)"),
      uiOutput("q_ui"),
      br(),
      uiOutput("tie_ui"),
      div(style="text-align:center", actionButton("go"," Voir le résultat", class="love-btn"))
  ),
  
  br(),
  div(class="card",
      h3(" Résultat & choix compatible"),
      div(style="text-align:center",
          uiOutput("score_ui"),
          uiOutput("mbti_ui"),
          plotlyOutput("heart", height = "420px")
      ),
      br(),
      uiOutput("compat_ui"),
      div(style="text-align:center", actionButton("save","💾 Enregistrer les fichiers", class="love-btn"))
  ),
  br(), br()
)

# --- Serveur ---
server <- function(input, output, session){

  # --- Questions ---
  questions <- list(
    list("Quand tu es fatigué(e), tu préfères :", c("Sortir voir des amis","Rester seul(e)"), c('E','I')),
    list("En soirée, tu :", c("Adores parler à plein de monde","Préfères discuter avec une ou deux personnes"), c('E','I')),
    list("Quand tu rencontres quelqu’un de nouveau :", c("Tu engages facilement la conversation","Tu attends qu’on te parle"), c('E','I')),
    list("Au travail ou en groupe :", c("Tu t’exprimes spontanément","Tu réfléchis avant de parler"), c('E','I')),
    list("Tu te fies plutôt à :", c("Ton expérience passée","Ton intuition"), c('S','N')),
    list("Tu as tendance à :", c("Remarquer les détails","Imaginer les possibilités"), c('S','N')),
    list("Tu préfères :", c("Ce qui est tangible et réel","Ce qui est théorique et abstrait"), c('S','N')),
    list("On te décrit comme :", c("Pragmatique","Visionnaire"), c('S','N')),
    list("Quand un ami a un problème :", c("Tu proposes une solution","Tu offres du soutien émotionnel"), c('T','F')),
    list("On te dit souvent :", c("Franc(he) et rationnel(le)","Empathique et attentionné(e)"), c('T','F')),
    list("Quand tu décides :", c("Tu utilises la logique","Tu écoutes ton cœur"), c('T','F')),
    list("Dans les débats :", c("Tu défends la vérité","Tu protèges les sentiments des autres"), c('T','F')),
    list("Quand tu planifies :", c("Tu veux tout prévoir à l’avance","Tu préfères t’adapter au moment venu"), c('J','P')),
    list("Tes journées sont :", c("Structurées et organisées","Souples et improvisées"), c('J','P')),
    list("Tu préfères :", c("Finir les choses avant d’en commencer d’autres","Avoir plusieurs projets ouverts"), c('J','P')),
    list("Les règles :", c("Sont faites pour être respectées","Sont faites pour être adaptées"), c('J','P'))
  )

  # --- Génération des questions ---
  output$q_ui <- renderUI({
    tagList(
      lapply(seq_along(questions), function(i){
        q <- questions[[i]]
        radioButtons(paste0("q",i), sprintf("%d) %s", i, q[[1]]),
                     choices=setNames(c("1","2"), q[[2]]),
                     inline=TRUE, selected=character(0))
      })
    )
  })

  # --- Départage dynamique ---
  output$tie_ui <- renderUI({
    vals <- sapply(1:16, function(i) input[[paste0("q",i)]])
    if (any(is.null(vals) | vals=="")) return(NULL)
    scores <- c(E=0,I=0,S=0,N=0,T=0,F=0,J=0,P=0)
    for(i in 1:16){
      q <- questions[[i]]
      dim1 <- q[[3]][1]; dim2 <- q[[3]][2]
      if (vals[i]=="1") scores[as.character(dim1)] <- scores[as.character(dim1)]+1
      if (vals[i]=="2") scores[as.character(dim2)] <- scores[as.character(dim2)]+1
    }
    tie_EI <- scores["E"]==scores["I"]
    tie_SN <- scores["S"]==scores["N"]
    tie_TF <- scores["T"]==scores["F"]
    tie_JP <- scores["J"]==scores["P"]
    if (!any(c(tie_EI,tie_SN,tie_TF,tie_JP))) return(NULL)
    tagList(
      h4("⚖️ Départage (égalité détectée)"),
      fluidRow(
        if (tie_EI) column(6, radioButtons("tie_EI","Énergie (E/I) — Tu trouves ton énergie surtout…",
          choices=c("E = en parlant aux autres","I = en étant seul·e"),inline=TRUE,selected=character(0))),
        if (tie_SN) column(6, radioButtons("tie_SN","Perception (S/N) — Tu fais plus confiance…",
          choices=c("S = à ce que tu observes","N = à ton intuition"),inline=TRUE,selected=character(0)))
      ),
      fluidRow(
        if (tie_TF) column(6, radioButtons("tie_TF","Décision (T/F) — Tu décides plutôt…",
          choices=c("T = avec logique/faits","F = avec émotions/valeurs"),inline=TRUE,selected=character(0))),
        if (tie_JP) column(6, radioButtons("tie_JP","Style (J/P) — Tu préfères…",
          choices=c("J = planifier/organiser","P = improviser/flexible"),inline=TRUE,selected=character(0)))
      ),
      p(class="hint","(Ces choix ne sont requis que pour les dimensions en parfaite égalité.)")
    )
  })

  # --- Calcul MBTI ---
  calc_mbti <- eventReactive(input$go,{
    vals <- sapply(1:16,function(i) input[[paste0("q",i)]])
    validate(need(all(!is.null(vals)&nzchar(vals)),"Réponds à toutes les questions "))
    scores <- c(E=0,I=0,S=0,N=0,T=0,F=0,J=0,P=0)
    for(i in 1:16){
      q<-questions[[i]]
      d1<-q[[3]][1]; d2<-q[[3]][2]
      if(vals[i]=="1") scores[d1]<-scores[d1]+1
      if(vals[i]=="2") scores[d2]<-scores[d2]+1
    }
    decide<-function(a,b,tie_id){
      if(scores[a]>scores[b])return(a)
      if(scores[b]>scores[a])return(b)
      tie_val<-switch(tie_id,input$tie_EI,input$tie_SN,input$tie_TF,input$tie_JP)
      validate(need(!is.null(tie_val)&&nzchar(tie_val),paste0("Égalité ",a,"/",b," — choisis dans 'Départage'.")))
      substr(tie_val,1,1)
    }
    l1<-decide("E","I","tie_EI")
    l2<-decide("S","N","tie_SN")
    l3<-decide("T","F","tie_TF")
    l4<-decide("J","P","tie_JP")
    mbti<-paste0(l1,l2,l3,l4)
    list(mbti=mbti)
  })

  # --- Résultat ---
  output$score_ui<-renderUI({
    res<-calc_mbti();req(res)
    tags$div(class="score-chip",HTML(paste0("Ton type MBTI : <b>",res$mbti,"</b>")))
  })

  output$heart<-renderPlotly({
    res<-calc_mbti();req(res)
    pulse<-seq(0.9,1.15,length.out=24)
    frames<-lapply(seq_along(pulse),function(k){
      t<-seq(0,2*pi,length.out=600)
      x<-16*sin(t)^3; y<-13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t)
      x<-x*0.06*pulse[k]; y<-y*0.06*pulse[k]
      list(data=list(list(x=x,y=y,type="scatter",mode="lines",
                          fill="toself",line=list(width=2),hoverinfo="none")),
           name=paste0("f",k))
    })
    fig<-plot_ly();fig<-fig%>%animation_opts(frame=80,transition=0,redraw=FALSE)
    fig$x$data<-frames[[1]]$data;fig$x$frames<-frames
    fig%>%layout(showlegend=FALSE,xaxis=list(visible=FALSE),yaxis=list(visible=FALSE),
      annotations=list(list(text=res$mbti,x=0,y=0,showarrow=FALSE,
      font=list(size=28,color="#b30059"))))
  })

  # --- Compatibilité + Sauvegarde ---
  output$compat_ui<-renderUI({
    res<-calc_mbti();req(res)
    opts<-MBTI_COMP[[res$mbti]]
    tagList(
      h4("⭐ Choisis ton type compatible préféré"),
      radioButtons("compat_choice",NULL,
                   choices=setNames(c("0","1","2","3"),
                     c(paste0("🎲 Hasard : ",paste(opts,collapse=", ")),
                       paste0("1) ",opts[1]),paste0("2) ",opts[2]),paste0("3) ",opts[3]))))
    )
  })

  observeEvent(input$save,{
    res<-calc_mbti();req(res)
    opts<-MBTI_COMP[[res$mbti]]
    chosen<-if(input$compat_choice=="0")sample(opts,1)else opts[as.integer(input$compat_choice)]
    writeLines(res$mbti,"mbti_result.txt")
    writeLines(chosen,"mbti_star_result.txt")
    info<-c(
      paste("prenom",input$prenom),
      paste("nom",input$nom),
      paste("genre",input$genre),
      paste("age",input$age),
      paste("orientation",input$orient)
    )
    writeLines(info,"user_info.txt")
    showModal(modalDialog(
      title="✅ Fichiers créés",
      HTML(paste0("<b>mbti_result.txt</b> = ",res$mbti,"<br/>",
                  "<b>mbti_star_result.txt</b> = ",chosen,"<br/>",
                  "<b>user_info.txt</b> enregistré ")),
      easyClose=TRUE,footer=modalButton("OK")
    ))
  })
}

shinyApp(ui,server)

