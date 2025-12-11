# New Book

# Rapport projet Julia

## Le projet

Le but de ce projet était de créer une interface graphique qui nous renvoie la star avec laquelle on est compatible en julia.  Pour cela nous nous sommes basés sur les 16 types mbti : ils caractérisent notre personnalité selon un questionnaire. Il est devenu très populaire et répendu dans le monde, c'est pourquoi on connait le type mbti de la majorité des stars.  On a essayé de recréer un mini test mbti car le vrai dure vraiment très longtemps.

## Le plan

  * créer notre base de données de star avec leur mbti
  * définir les types utiles à notre code
  * récupérer les données de l'utilisateur ( nom, prénom, âge, type de mbti,... )
  * trouver le mbti compatible avec l'utilisateur
  * trouver la star associé au mbti compatible avec l'utilisateur selon certains critères
  * affichage graphique

## 1 La base de donnée des stars

Nous avons décidé de créer notre base de données sous format csv. Nous avons premièrement essayé de remplir nos données à la main mais c'était trop coûteux en temps donc nous avons demandé à chatgpt de nous remplir suffisament de lignes pour avoir une homogénéité de star (sexualités et personnalités nombreuses et diffférentes) . Nous obtenons une 50taine de stars . Après avoir nettoyé cette base et gardé uniquement les variables suivantes : Nom,Profession,Âge,Genre,Orientation et MBTI , nous avons pu commencer à coder notre algorythme. cf dossier data

## 2 Les types

cf types_projets.jl .Pour mener à bien ce projet nous avons crée les types suivant :

  * Personne (type abstrait) sert de base commune à toutes les personnes du programme (que ce soit l'utilisateur ou les stars).Il regroupe les caractéristiques générales partagées par tous : prénom, nom, âge et type MBTI.Ce type sert uniquement de parent pour d’autres types.
  * Star (sous-type de Personne) représente une célébrité.Ce type hérite de Personne et contient en plus :le genre,le métier et l’orientation.
  * Utilisateur (sous-type de Personne) représente un utilisateur normal comme vous et nous de l’application. Il hérite aussi de Personne et contient :le prénom,le nom,le genre,l’âge, l’orientation et le MBTI.
  * MBTI (type de personnalité) permet de stocker toutes les informations sur un type de personnalité.Il contient :le nom du type (ex : "INTJ"),une description du caractère du type, une liste des types compatibles avec lui et un dictionnaire de messages personnalisés expliquant pourquoi chaque compatibilité fonctionne.
  * MBTI_COMPATIBILITIES est un dictionnaire global qui associe chaque type MBTI à une liste de types compatibles.Il sert de base pour définir automatiquement les compatibilités dans chaque objet MBTI. Chaque MBTI est compatible avec 3 autres.
  * Les objets estj, intj, enfp, etc... représentent un profil MBTI complet, construit à partir du type MBTI.Ils contiennent :leur nom,leur description,leurs compatibilités, et un message personnalisé pour chaque compatibilité.
  * MBTI_QUESTIONS (dictionnaire) contient les questions posées à l’utilisateur selon son type MBTI, pour affiner les préférences de compatibilité.Chaque type possède 3 questions personnalisées pour déterminer lequel des 3 MBTI lui correspond le mieux.
  * MBTI_TYPES est le dictionnaire final qui centralise tous les types MBTI. Il permet d’accéder facilement à un profil MBTI complet à partir de son nom (ex : "INTJ").

## 3 Le questionnaire

Maintenant que tous les types sont définis, nous allons pouvoir coder le questionnaire. Dans un premier temps, avant de passer à un questionnaire sur une interface graphique (avec bonito), nous avons décidé d'afficher le questionnaire dans le terminale pour que l'utilisateur y réponde dessus. cf compabilité.jl . Les questions du questionnaire se basent toutes sur le site suivant qui donne les charactéristiques de chaque mbti ainsi que leur compabilité avec les autres types : https://hitostat.com/fr/articles/16-personalities-compatibility .  Pour récupérer les données de l'utilisateur nous faisons cela:

```julia (editor=true, logging=false, output=true)
println("Quel est ton nom?")
print("> ")
reponse1 = readline()

println("Quel est ton prénom?")
print("> ")
reponse2 = readline()

println("Quel est ton âge? ( en chiffre )")
print("> ")
reponse3 = readline()
# je vais convertir l'age(int) en string car comme j'utilise readline() qui est pour les string
# lorsque je définie utilisateur à la ligne 217 ca ne fonctionne pas. 
while isnothing(tryparse(Int, reponse3))
    println("Tape en chiffre.")
    print("> ")
    reponse3 = readline()
end
reponse3 = parse(Int, reponse3)

println("Es-tu une femme ou un homme (tape H ou F) ?")
reponse4 = ""
while !(reponse4 in ["H", "F"])
    print("> ")
    reponse4 = readline()
    if !(reponse4 in ["H", "F"])
        println("Réponse invalide, tape H ou F.")
    end
end

println("est-tu Hétérosexuel(1), Bisexuel(2), Gay(3), Lesbienne(4), Asexuelle(5), Pansexuel(6) ou Autre (7)?")
print("> ")
reponse5 = ""
while !(reponse5 in ["1","2","3","4","5","6","7"])
    print("> ")
    reponse5 = readline()
    if !(reponse5 in ["1","2","3","4","5","6","7"])
        println("Réponse invalide, tape un chiffre entre 1 et 7.")
    end
end


if reponse5 =="1"
    reponse5= "Hétéro"
elseif reponse5 == "2"
    reponse5= "Bi"
elseif reponse5 == "3"
    reponse5 = "Gay"
elseif reponse5 == "4"
    reponse5= "Lesbienne"
elseif reponse5 == "5"
    reponse5 ="Asexuelle"
elseif reponse5 =="6"
    reponse5 = "Pan"
elseif reponse5 == "7"
    reponse5 = "Autre"

end  
```
Ce code gère les erreurs que l'utilisateur pourrait faire en tappant pour s'assurer que tout ce qu'il tape correspond bien au type des variables de Utilisateur. On obtient à la fin notre fiche complète de l'utilisateur.

Maintenant on s'occupe de savoir à quel type de mbti correspond notre utilisateur. On va lui poser 16 questions qui s'organisent de la manière suivante : 4*4 questions qui déterminent la combinaison de lettres adapté à sont mbti.

En effet, le MBTI est basé sur une combinaison de 4 lettres, chacune représentent une préférence psychologique. En combinant ces 4 dimensions, on obtient les 16 types de personnalité. Les lettres sont les suivantes :

  * Orientation de l’énergie (Lettre 1) :   E (Extraversion) : la personne trouve son énergie dans le monde extérieur et le contact avec les autres.   I (Introversion) : la personne trouve son énergie dans le monde intérieur, la réflexion et le calme.
  * Prise d’informations (Lettre 2) :   S (Sensation) : la personne préfère les faits concrets, ce qui est réel et observable.   N (iNtuition) : la personne préfère les idées, l’imagination et l’abstrait.
  * Prise de décision (Lettre 3) :   T (Thinking) : la personne prend ses décisions selon la logique et l’analyse.   F (Feeling) : la personne prend ses décisions selon ses émotions et ses valeurs.
  * Organisation (Lettre 4) :   J (Jugement) : la personne aime planifier, organiser et contrôler.   P (Perceiving) : la personne préfère rester flexible, spontané et s’adapter.

En combinant ces 4 lettres, on obtient un type de personnalité unique (ex : INTJ, ENFP, ESTJ). Comme il existe 2 possibilités par lettre, il y a au total 16 types MBTI. Voici les 16 questions posées à l'utilisateur:

```julia (editor=true, logging=false, output=true)
questions = [
  ("Quand tu es fatigué(e), tu préfères :", "Sortir voir des amis", "Rester seul(e)", 'E', 'I'),
  ("En soirée, tu :", "Adores parler à plein de monde", "Préfères discuter avec une ou deux personnes", 'E', 'I'),
  ("Quand tu rencontres quelqu’un de nouveau :", "Tu engages facilement la conversation", "Tu attends qu’on te parle", 'E', 'I'),
  ("Au travail ou en groupe :", "Tu t’exprimes spontanément", "Tu réfléchis avant de parler", 'E', 'I'),

  ("Tu te fies plutôt à :", "Ton expérience passée", "Ton intuition", 'S', 'N'),
  ("Tu as tendance à :", "Remarquer les détails", "Imaginer les possibilités", 'S', 'N'),
  ("Tu préfères :", "Ce qui est tangible et réel", "Ce qui est théorique et abstrait", 'S', 'N'),
  ("On te décrit comme :", "Pragmatique", "Visionnaire", 'S', 'N'),

  ("Quand un ami a un problème :", "Tu proposes une solution", "Tu offres du soutien émotionnel", 'T', 'F'),
  ("On te dit souvent :", "Franc(he) et rationnel(le)", "Empathique et attentionné(e)", 'T', 'F'),
  ("Quand tu décides :", "Tu utilises la logique", "Tu écoutes ton cœur", 'T', 'F'),
  ("Dans les débats :", "Tu défends la vérité", "Tu protèges les sentiments des autres", 'T', 'F'),

  ("Quand tu planifies :", "Tu veux tout prévoir à l’avance", "Tu préfères t’adapter au moment venu", 'J', 'P'),
  ("Tes journées sont :", "Structurées et organisées", "Souples et improvisées", 'J', 'P'),
  ("Tu préfères :", "Finir les choses avant d’en commencer d’autres", "Avoir plusieurs projets ouverts", 'J', 'P'),
  ("Les règles :", "Sont faites pour être respectées", "Sont faites pour être adaptées", 'J', 'P')

]
```
Ensuite, un dictionnaire de scores est initialisé pour compter combien de fois chaque lettre apparaît dans les réponses. À chaque réponse, le programme incrémente le score de la lettre correspondante.

```julia (editor=true, logging=false, output=true)
scores = Dict('E'=>0, 'I'=>0, 'S'=>0, 'N'=>0, 'T'=>0, 'F'=>0, 'J'=>0, 'P'=>0)

for (i, (question, opt1, opt2, dim1, dim2)) in enumerate(questions)
  println("\nQuestion $i : $question")#println = pas besoin de faire \n
  println("1) $opt1")
  println("2) $opt2")
  print("> ")
  choice = ""
  while choice != "1" && choice != "2"
      print("> ")
      choice = readline()
      if choice != "1" && choice != "2"
          println(" Réponse invalide, tape 1 ou 2.")
      end
  end
  if choice == "1"
      scores[dim1] += 1
  else
      scores[dim2] += 1
  end
end
```
Une fois toutes les questions répondues, le programme compare les scores lettre par lettre :E contre I ,S contre N,T contre F et J contre P.

Si une lettre a un score plus élevé, elle est choisie. En cas d’égalité, une question de départage est posée à l’utilisateur pour trancher.

```julia (editor=true, logging=false, output=true)
# E|I
if scores['E'] > scores['I']
    lettre1 = 'E'
elseif scores['I'] > scores['E']
    lettre1 = 'I'
else
    println("\n Égalité entre E et I. Question de départage :")
    println("1) Tu trouves ton énergie en parlant aux autres (E)")
    println("2) Tu trouves ton énergie en étant seul(e) (I)")
    print("> ")
    choice = ""
    while choice != "1" && choice != "2"
        choice = readline()
        if choice != "1" && choice != "2"
            println("Réponse invalide, tape 1 ou 2.")
        end
    end
    lettre1 = (choice == "1") ? 'E' : 'I'
end

```
Les quatre lettres obtenues sont ensuite combinées pour former le type MBTI final (ex : INTJ, ENFP, etc.), qui est affiché à l’écran.

Le programme crée ensuite un objet Utilisateur contenant toutes les informations de la personne (nom, prénom, âge, genre, orientation et MBTI), puis affiche une fiche récapitulative.

Le type MBTI est aussi enregistré dans un fichier texte pour le sauvegarder.

Après cela, le programme récupère les trois types MBTI compatibles avec celui de l’utilisateur grâce au dictionnaire de compatibilités. On pose ensuite trois nouvelles questions de préférences, basées sur ces compatibilités. L’utilisateur peut soit choisir une option, soit laisser le hasard décider.  Le type compatible choisi est affiché, puis enregistré dans un second fichier texte.

```julia (editor=true, logging=false, output=true)
mbti = string(lettre1, lettre2, lettre3, lettre4)

utili = Utilisateur(reponse2,reponse1,reponse4,reponse3,reponse5, mbti  )

compatibles = MBTI_COMPATIBILITIES[mbti]
questions_descriptives = MBTI_QUESTIONS[mbti]

for (i, q) in enumerate(questions_descriptives)
    println("$i) $q")
end

println("Tape le numéro correspondant à ton choix (1, 2 ou 3), ou 0 pour laisser le hasard choisir.")
choice = ""
while !(choice in ["0","1","2","3"])
    print("> ")
    choice = readline()
end

  
if choice == "0"
    choice_compatibility=compatibles[rand(1:3)]
else
    choice_compatibility= compatibles[parse(Int, choice)]  # exemple : choice = readline()      # l'utilisateur tape "2"
    #num = parse(Int, choice) # convertit "2" en 2
end
println("\nTu pourrais envisager une personne de type MBTI : $choice_compatibility")

```
Enfin, la fonction retourne le MBTI de l’utilisateur ainsi que le MBTI compatible sélectionné.

## 4 Le questionnaire bonito.jl

Maintenant que la logique est comprise nous passons au codage sur bonito.jl qui fait exactement la même chose que la partie 3 mais sur une interface graphique.

Pour l'interface, l'utilisateur commence comme précedemment, par remplir un formulaire d’informations personnelles (nom, prénom, âge, genre, orientation). Ces informations sont saisies à l’aide de champs interactifs :

```julia (editor=true, logging=false, output=true)
name = TextField("", Dict(:placeholder=>"Nom"))
firstname = TextField("", Dict(:placeholder=>"Prénom"))
age = TextField("", Dict(:placeholder=>"Âge"))
genre = Dropdown(["H"=>"Homme", "F"=>"Femme"], label="Genre")
orientation = Dropdown(["1"=>"Hétéro", "2"=>"Bi", "3"=>"Gay"], label="Orientation")
start_btn = Button("Commencer le test MBTI")

```
Une fois le formulaire validé, le questionnaire démarre.

Les questions sont affichées une par une grâce à un système de variables observables, qui permettent de mettre à jour automatiquement l’interface après chaque réponse :

```julia (editor=true, logging=false, output=true)
question_text = Observable{String}("")
opt1_text = Observable{String}("")
opt2_text = Observable{String}("")
progress_text = Observable{String}("")

```
L’utilisateur répond à chaque question à l’aide de boutons cliquables :

```julia (editor=true, logging=false, output=true)
opt1_btn = Button("1")
opt2_btn = Button("2")

```
À la fin du questionnaire, le type MBTI final est affiché directement à l’écran ainsi qu'une description du profil. Après l’affichage du résultat, les trois types MBTI compatibles sont proposés sous forme de boutons dynamiques, permettant à l’utilisateur de cliquer sur celui qu’il préfère :

```julia (editor=true, logging=false, output=true)
compat_btns_dynamic[] = [Button(t) for t in compat_types]

```
le type compatible sélectionné s’affiche immédiatement à l’écran. Enfin, toute l’application est ensuite regroupée dans une seule page web grâce à la structure suivante :

```julia (editor=true, logging=false, output=true)
return DOM.div(
  DOM.div("## Informations", name, firstname, age, genre, orientation, start_btn, info_output),
  DOM.div("## Questionnaire",
      DOM.div(question_text),
      DOM.div(opt1_btn,opt1_text),
      DOM.div(opt2_btn,opt2_text),
      DOM.div(progress_text)
  ),
  DOM.div("## Résultat",
      DOM.div(result_text),
      DOM.div(Markdown.MD(descr_text)),
      # boutons dynamiques
      map(compat_btns_dynamic) do btns
          DOM.div([btn for btn in btns]...)
      end,
      # texte sélectionné après clic
      DOM.div(compatible_text)
  ))
```
Grâce à Bonito.jl, le test MBTI a pu être transformé en une application web interactive, plus intuitive que la version console. L’utilisateur peut saisir ses informations, répondre aux questions par clics, visualiser son type MBTI et choisir un profil compatible de manière totalement graphique.

## 5 Trouver la star compatible avec l'utilisateur

//à completer ici amine // rshiny ahmed

## Supplément : Partie Rshiny

Dans la continuité du projet MBTI réalisé en Julia, une seconde approche a été développée en R Shiny.
Cette version n’utilise pas les types MBTI mais repose sur un fonctionnement analogue :
l’utilisateur répond à un questionnaire et l’application calcule un pourcentage de compatibilité avec plusieurs stars.
L’objectif était d’avoir un équivalent du projet Julia, mais sous forme d’une application web interactive réalisée en R.

## Notice préalable concernant la version R Shiny :

Avant de présenter la partie réalisée en R Shiny, il est important de préciser que l’application Shiny ne reprend pas le questionnaire MBTI ni la logique détaillée dans les sections précédentes du projet Julia.
En effet, la version Julia s’appuie sur une modélisation complète du MBTI, avec 16 questions structurées permettant de déterminer le type de personnalité de l’utilisateur, puis de calculer ses compatibilités selon des règles psychologiques définies.
La version Shiny, quant à elle, adopte une approche différente et volontairement simplifiée, davantage orientée vers une expérience ludique de “speed-dating de stars”.
Les différences essentielles à noter sont :
-Les questions ne sont pas celles du test MBTI : elles portent sur quelques critères simples (humour, sport, musique, voyages) afin de permettre une interaction rapide dans un environnement web.
-La méthode de calcul de compatibilité n’est pas la même : en Shiny, elle repose sur la similarité numérique entre les réponses de l’utilisateur et un profil simplifié des stars, et non sur les types MBTI.
-Certaines adaptations hors du contexte MBTI ont été faites volontairement pour obtenir une interface intuitive, dynamique et adaptée à une démonstration de projet R Shiny.
Ainsi, cette partie ne cherche pas à reproduire la rigueur psychométrique du projet Julia, mais constitue une version alternative, complémentaire et plus ludique, tout en respectant l’objectif général :
proposer une application interactive permettant de déterminer la star la plus compatible avec l’utilisateur.

## Version Shiny simple : Speed-Dating de Stars

La première version du projet a été construite avec shiny (version basique).
L’application repose sur quatre grandes étapes :

1. Création d’une mini base de données de stars :

On définit un petit tableau contenant les caractéristiques de plusieurs célébrités, par exemple :
-leur nom
-un score de 1 à 5 sur plusieurs critères (humour, sport, musique, voyages)
Exemple de structure interne :
Star	                       Humour	   Sport	  Musique	  Voyages
Zendaya	                     5	        3	       4 	        5
Timothée Chalamet	           3	        4 	      5	         4
Taylor Swift	                4	        2	       5	         3
Ryan Gosling	                4	        5	       3	         4

Ces valeurs servent de profil de personnalité simplifié.

2. Questionnaire utilisateur :

L'utilisateur répond à quatre questions grâce à des sliders allant de 1 à 5 :
 “Tu aimes l’humour ?”
 “Tu es sportif(ve) ?”
 “Tu adores la musique ?”
 “Tu aimes voyager ?”
Ces critères sont volontairement simples pour garder l’interface intuitive.


3. Calcul de la compatibilité :

Le score de compatibilité est calculé ainsi :

Compatibilité = 100 - ((distance moyenne entre les réponses et le profil de la star)/4) x 100
Autrement dit :
plus les réponses de l’utilisateur sont proches des valeurs de la star → plus le pourcentage est élevé.


4. Affichage des résultats:

Shiny permet d’afficher :
un tableau récapitulant les compatibilités
un graphique en barres montrant visuellement quelle star correspond le mieux
la star la plus compatible, calculée automatiquement


## Version avancée : ShinyDashboard

La seconde version du projet utilise shinydashboard pour produire une interface professionnelle :
3 onglets principaux :
- Questionnaire :
      .sliders pour répondre aux questions
      .présentation des stars
- Résultats :
      .tableau des pourcentages
      .graphique comparatif
      .message final : “Ta star la plus compatible est : X ”
- À propos :
      .explication du projet et de la logique
  
L’utilisation de shinydashboard permet une séparation claire des tâches, un style plus moderne et une navigation plus fluide.

## Intérêt de cette version R Shiny

Cette version R Shiny complète idéalement le projet Julia :

 Julia (console + Bonito)  :              Shiny (app web)  :                           
 Approche MBTI complète                 | Approche simplifiée par critères          
 Questionnaire structuré (16 questions) | Questionnaire rapide (4 critères)         
 Match basé sur compatibilités MBTI     | Score basé sur similarité numérique       
 Approche plus théorique/personnelle    | Approche ludique, “speed-dating de stars” 
 Version console + Bonito               | Version web + Dashboard                   

## Conclusion de la partie R Shiny

La double implémentation (version simple + version dashboard) a permis :
-de comprendre la structure d’une application Shiny
-de gérer les interactions utilisateur
-de calculer dynamiquement une compatibilité
-d’afficher des résultats visuels et attrayants
-de produire une application web intuitive et utilisable par n’importe quel utilisateur
Cette approche complète donc logiquement le projet MBTI réalisé en Julia en apportant une version “grand public”, accessible, interactive et visuellement plus moderne.






