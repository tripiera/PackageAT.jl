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
Grâce à Bonito.jl, le test MBTI a pu être transformé en une application web interactive, plus intuitive que la version console. L’utilisateur peut saisir ses informations, répondre aux questions par clics, visualiser son type MBTI et choisir un profil compatible de manière totalement graphique. Nous avons essayé de faire la partie 5 ci-dessous avec bonito.jl mais sans succès .


## 5. Trouver la star compatible avec l'utilisateur

Dans cette partie, nous utilisons toute la mécanique définie précédemment (types Julia, dictionnaires MBTI, fonctions de compatibilité, etc.) pour construire un **pipeline complet** qui part des réponses de l'utilisateur et aboutit au nom de la star la plus compatible.

L'objectif de ce module est donc :
- de lancer le questionnaire MBTI en console,
- de récupérer le type MBTI de l'utilisateur et le type qu'il préfère chez les stars,
- de charger les données des célébrités depuis le fichier CSV nettoyé,
- de calculer un score de compatibilité pour chaque star,
- puis d'afficher la meilleure correspondance de manière lisible (texte + graphique).

Tout cela est orchestré dans un script unique, `runcompatibilite0.jl`, dont voici la structure principale.

```julia (editor=true, logging=false, output=true)
#########################################################
# Amine
# runcompatibilite0.jl – Lancer le test de compatibilité
# VERSION STABLE – Questionnaire MBTI + compatibilité stars
#########################################################

# Chemin racine du projet (pour inclure correctement les modules et CSV)
root = joinpath(dirname(@__FILE__), "..")

# On charge directement les modules internes
include(joinpath(root, "src/types_projet.jl"))
include(joinpath(root, "src/compatibilité.jl"))
include(joinpath(root, "src/calcul_compatibilite.jl"))
include(joinpath(root, "graphique/graphique_coeur.jl"))

println("=== TEST DE COMPATIBILITÉ ===\n")

#########################################################
# Étape 1 : Questionnaire MBTI
#########################################################

user_mbti, mbti_compatible, utili = ask_mbti_questions()

mbti_user = chomp(read(joinpath(root, "mbti_result.txt"), String))
mbti_star = chomp(read(joinpath(root, "mbti_star_result.txt"), String))

println("\n Ton type MBTI : $mbti_user")
println(" Type préféré chez les stars : $mbti_star")

#########################################################
# Étape 2 : Information utilisateur
#########################################################

user = utili
println("\n Utilisateur chargé : $(user.firstname) $(user.lastname), $(user.age) ans, $(user.orientation), genre $(user.genre)")

#########################################################
# Étape 3 : Chargement du CSV
#########################################################

println("\n Chargement des célébrités...")
csv_path = joinpath(root, "data", "base_stars_clean.csv")

if !isfile(csv_path)
    error(" ERREUR : Le fichier CSV n'existe pas : $csv_path")
end

stars = charger_stars(csv_path)

#########################################################
# Étape 4 : Calcul compatibilité
#########################################################

println("\n Calcul en cours...\n")
resultats = trouver_meilleures_compatibilites(user, stars)

#########################################################
# Étape 5 : Résultat final
#########################################################

if isempty(resultats)
    println("\n Aucun match trouvé selon ton orientation et ton genre ")
else
    top_star, top_score = resultats[1]

    println("\n Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    println("  Score total : $(top_score)%")

    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")

    println("\n Fin du programme ")
end
```

Ce script est le point d'entrée principal côté Julia : il assemble toutes les briques fonctionnelles du projet et produit un résultat complet, du questionnaire utilisateur jusqu'à l'affichage graphique de la star sélectionnée.

---

## 5.1 Le calcul de compatibilité (MBTI, orientation, âge)

Pour que le score reflète au mieux la « plausibilité » d'une compatibilité, nous avons défini une fonction de score structurée en trois composantes principales :
- une composante **MBTI** (personnalité),
- une composante **orientation / genre** (attirance mutuelle),
- une composante **âge** (proximité générationnelle).

Tout ce calcul est regroupé dans le fichier `calcul_compatibilite.jl`.

### 5.1.1 Compatibilité de personnalité (MBTI)

La première partie du score prend en compte les compatibilités théoriques entre types MBTI.  
On utilise pour cela un dictionnaire global `MBTI_COMPATIBILITIES` (défini dans `types_projet.jl`) qui associe à chaque type les trois types les plus compatibles.

```julia (editor=true, logging=false, output=true)
function score_mbti(user_mbti::String, star_mbti::String)
    u = normalize_mbti(user_mbti)
    s = normalize_mbti(star_mbti)

    if haskey(MBTI_COMPATIBILITIES, u)
        compatibles = MBTI_COMPATIBILITIES[u]
        return s == compatibles[1] ? 50 :
               s == compatibles[2] ? 35 :
               s == compatibles[3] ? 20 :
               s == u              ? 10 : 0
    else
        return 0
    end
end
```

Nous attribuons :
- 50 points pour le type le plus compatible,
- 35 pour le deuxième,
- 20 pour le troisième,
- 10 si la star a le même type que l'utilisateur,
- 0 sinon.

Ce choix traduit l'idée que certaines personnalités se complètent particulièrement bien, mais qu'avoir le même profil peut également fonctionner, même si ce n'est pas optimal.

### 5.1.2 Compatibilité orientation / genre

Ensuite, nous modélisons l'attirance possible entre l'utilisateur et la star en prenant en compte le **genre** et l’**orientation sexuelle** des deux.

Deux fonctions servent à tester si la relation est possible dans les deux sens :
- est-ce que l'utilisateur peut être attiré par la star ?
- est-ce que la star peut être attirée par l'utilisateur ?

```julia (editor=true, logging=false, output=true)
function user_attire_par_star(user::Utilisateur, star::Star)
    return user.orientation == "Pan" ||
           (user.orientation == "Hétéro"    && user.genre != star.genre) ||
           (user.orientation == "Gay"       && user.genre == "H" && star.genre == "H") ||
           (user.orientation == "Lesbienne" && user.genre == "F" && star.genre == "F") ||
           (user.orientation == "Bi")
end

function star_attiree_par_user(star::Star, user::Utilisateur)
    return star.orientation == "Pan" ||
           (star.orientation == "Hétéro"    && star.genre != user.genre) ||
           (star.orientation == "Gay"       && star.genre == "H" && user.genre == "H") ||
           (star.orientation == "Lesbienne" && star.genre == "F" && user.genre == "F") ||
           (star.orientation == "Bi")
end
```

Si l'une de ces deux conditions n'est pas respectée, la star est directement exclue.  
Sinon, on calcule un score d'orientation :

```julia (editor=true, logging=false, output=true)
function score_orientation(user::Utilisateur, star::Star)
    if !user_attire_par_star(user, star) || !star_attiree_par_user(star, user)
        return 0
    elseif user.orientation == "Hétéro" && star.orientation == "Hétéro"
        return 30
    else
        return 25
    end
end
```

L'idée est que :
- une compatibilité parfaitement « symétrique » (hétéro/hétéro avec genres opposés) est valorisée au maximum (30 points),
- les autres formes de compatibilité (bi, gay, lesbienne, pan) obtiennent un score légèrement plus faible mais restent possibles (25 points).

### 5.1.3 Compatibilité d’âge

La troisième composante du score concerne la différence d'âge.  
Nous supposons qu’une petite différence d’âge facilite la compatibilité et nous appliquons un barème simple par tranches :

```julia (editor=true, logging=false, output=true)
function score_age(user_age::Int, star_age::Int)
    diff = abs(user_age - star_age)
    return diff <= 5  ? 20 :
           diff <= 10 ? 10 :
           diff <= 15 ? 5  : 0
end
```

- moins de 5 ans d’écart : 20 points,
- entre 5 et 10 ans : 10 points,
- entre 10 et 15 ans : 5 points,
- au-delà : 0 point.

Cela permet de favoriser les couples de même génération, sans rendre les autres cas strictement impossibles (mais avec un score plus faible).

### 5.1.4 Score global de compatibilité

Enfin, le score global est obtenu simplement en additionnant les trois contributions, avec un plafond à 100 :

```julia (editor=true, logging=false, output=true)
function calculer_compatibilite(user::Utilisateur, star::Star)
    s_mbti   = score_mbti(user.mbti, star.mbti)
    s_orient = score_orientation(user, star)
    s_age    = score_age(user.age, star.age)
    return min(s_mbti + s_orient + s_age, 100)
end
```

Ce score est ensuite utilisé pour comparer les différentes stars entre elles et choisir la meilleure correspondance pour l'utilisateur.

---

## 5.2 Application du calcul de compatibilité à toute la base de données

Une fois que les critères de compatibilité ont été définis (MBTI, âge, genre, orientation), la dernière étape consiste à appliquer ces règles à l’ensemble des célébrités présentes dans notre base de données.  
Cette partie du programme charge le fichier CSV nettoyé, instancie chaque star sous forme d’objet `Star`, puis calcule un score global pour chaque célébrité.

### 5.2.1 Chargement du CSV des stars

Nous utilisons la fonction `charger_stars` (définie dans `calcul_compatibilite.jl`) pour transformer chaque ligne du fichier `base_stars_clean.csv` en un objet `Star` complet :

```julia (editor=true, logging=false, output=true)
stars = charger_stars(joinpath(root, "data", "base_stars_clean.csv"))
```

Cette fonction :
- lit chaque ligne du fichier CSV avec `CSV.read`,
- normalise le genre, l’orientation et le MBTI,
- sépare prénom et nom,
- crée un objet `Star` avec toutes les informations utiles.

Ce prétraitement garantit que toutes les stars sont au même format que l’utilisateur, ce qui permet un calcul cohérent.

### 5.2.2 Filtrage initial : orientation et genre

Avant même de calculer un score, le programme applique un filtre logique :  
une star est retenue uniquement si l’utilisateur peut être attiré par elle et si la star peut être attirée par l’utilisateur.

Ce double filtrage est réalisé par :

```julia (editor=true, logging=false, output=true)
filtered_stars = filter(stars) do s
    user_attire_par_star(user, s) && star_attiree_par_user(s, user)
end
```

Si l’un des deux tests échoue, la star ne participe pas au calcul.  
Cela évite d’obtenir des correspondances impossibles (par exemple un utilisateur hétérosexuel avec une star homosexuelle qui n’est attirée que par les personnes de son propre genre).

### 5.2.3 Calcul de compatibilité pour chaque célébrité

Pour chaque star retenue, nous appliquons ensuite le score global défini à la section précédente :

```julia (editor=true, logging=false, output=true)
scores = [(s, calculer_compatibilite(user, s)) for s in filtered_stars]
```

Chaque élément de cette liste contient :
- l’objet `Star`,
- le score numérique associé.

### 5.2.4 Sélection des meilleures correspondances

Une fois tous les scores calculés, ils sont triés du plus élevé au plus bas :

```julia (editor=true, logging=false, output=true)
sorted = sort(scores, by = x -> x[2], rev = true)
```

Dans la pratique, nous encapsulons cela dans une fonction utilitaire qui renvoie directement les `top` meilleures stars :

```julia (editor=true, logging=false, output=true)
function trouver_meilleures_compatibilites(user::Utilisateur, stars::Vector{Star}; top::Int=5)
    filtered_stars = filter(stars) do s
        user_attire_par_star(user, s) && star_attiree_par_user(s, user)
    end

    println("Filtrage : $(length(filtered_stars)) célébrités retenues sur $(length(stars)) totales.")

    scores = [(s, calculer_compatibilite(user, s)) for s in filtered_stars]
    sorted = sort(scores, by = x -> x[2], rev = true)

    return sorted[1:min(top, length(sorted))]
end
```

Dans `runcompatibilite0.jl`, nous utilisons simplement :

```julia (editor=true, logging=false, output=true)
resultats = trouver_meilleures_compatibilites(user, stars)
top_star, top_score = resultats[1]
```

Nous obtenons ainsi directement la célébrité la plus compatible.

### 5.2.5 Affichage final : nom, score et graphique

Pour rendre le résultat plus visuel, nous utilisons une fonction graphique `afficher_coeur` définie dans `graphique_coeur.jl`.  
Cette fonction affiche un cœur dont la couleur varie en fonction du pourcentage de compatibilité, avec le nom de la star au centre.

```julia (editor=true, logging=false, output=true)
afficher_coeur(top_score, string(top_star.firstname, " ", top_star.lastname))
```

L’utilisateur obtient ainsi :
- le nom complet de sa star compatible,
- le pourcentage total de compatibilité,
- un graphique final affichant un cœur coloré en fonction du niveau de match.

Cette étape conclut l’ensemble du pipeline, depuis le questionnaire MBTI jusqu’à l’identification de la célébrité la plus compatible avec l’utilisateur.

# 6. Interface Graphique – Affichage du Cœur (graphique_coeur.jl)

Dans cette section, nous présentons la partie du projet qui concerne **l’affichage graphique final**, développée par Amine.  
Cette étape intervient **après le calcul du score de compatibilité**, et permet d’afficher un **cœur dynamique**, coloré en fonction du score obtenu entre l’utilisateur et la star choisie.

Contrairement à Bonito.jl (utilisé pour l’interface), **cette partie graphique est indépendante** et repose sur **PlotlyJS**, via un fichier séparé : `graphique_coeur.jl`.

---

## 6.1 Objectif de la visualisation

L’objectif est de produire une **visualisation forte et personnalisée** :

- Un **cœur mathématique** tracé grâce à une équation paramétrique  
- Une **couleur dépendante du score**  
- Le **nom de la star** inscrit au centre  
- Le **score de compatibilité** affiché directement  
- Une esthétique moderne, simple et représentative

Cette visualisation apparaît à la fin de `runcompatibilite0.jl`.

---

## 6.2 Code du fichier `graphique_coeur.jl`

```julia
using PlotlyJS

function afficher_coeur(score::Int, nom::String)
    # Courbe du cœur paramétrique
    t = range(-π, π, length=400)
    x = 16 .* sin.(t).^3
    y = 13 .* cos.(t) .- 5 .* cos.(2t) .- 2 .* cos.(3t) .- cos.(4t)

    # Couleur du cœur selon score
    couleur = score < 40 ? "#777777" :
              score < 60 ? "#FFB6C1" :
              score < 80 ? "#FF69B4" : "#FF1493"

    trace = scatter(
        x = x,
        y = y,
        mode = "lines",
        fill = "toself",
        fillcolor = couleur,
        line = attr(color="white", width=3),
        hoverinfo = "none"
    )

    # Texte au centre du cœur
    y_center = 1.2
    name_size  = clamp(40 - max(length(nom)-14, 0), 22, 40)
    score_size = 28

    text_html = "<span style='font-size:$(name_size)px; font-weight:700; color:white;'>$(nom)</span><br><br>" *
                "<span style='font-size:$(score_size)px; color:white;'>Compatibilité : $(score)%</span>"

    ann = attr(
        x = 0,
        y = y_center,
        text = text_html,
        showarrow = false,
        xanchor = "center",
        yanchor = "middle",
        align = "center"
    )

    layout = Layout(
        title = "Résultat de compatibilité",
        plot_bgcolor = "black",
        paper_bgcolor = "black",
        xaxis = attr(visible=false, scaleanchor="y", scaleratio=1),
        yaxis = attr(visible=false),
        showlegend = false,
        annotations = [ann],
        margin = attr(l=0, r=0, t=40, b=0)
    )

    display(plot([trace], layout))
end
```

---

## 6.3 Intégration dans `runcompatibilite0.jl`

Une fois que l’algorithme identifie la star la plus compatible, on appelle :

```julia
afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")
```

Ce qui génère automatiquement :

- Le cœur coloré  
- Le nom de la star  
- Le pourcentage affiché au centre  

---

## 6.4 Résumé de la section

| Élément | Rôle |
|--------|------|
| `graphique_coeur.jl` | Produit la visualisation finale |
| PlotlyJS | Permet le rendu graphique interactif |
| Cœur paramétrique | Symbolise la compatibilité |
| Texte et couleurs dynamiques | Personnalisation du résultat |
| Intégration dans runcompatibilite0.jl | Affichage final du programme |


# 7. Intégration de R Shiny avec le système de compatibilité 

## 7.1 Objectif de la partie Shiny

L’objectif de cette section est d’expliquer comment une application **R Shiny** vient compléter le projet Julia.
Shiny sert ici d’interface alternative pour remplir le questionnaire MBTI et enregistrer les choix de l’utilisateur
dans des fichiers texte, que le programme Julia peut ensuite lire pour calculer les compatibilités avec les stars.
Cette version vise une expérience utilisateur plus interactive et plus proche d’une application web.

---

## 7.2 Fonctionnement général de Shiny dans le projet

L’application Shiny est organisée autour de trois éléments fondamentaux :

1. **Un mini questionnaire MBTI**, affiché dans une page web.
2. **Un bouton permettant d’enregistrer les résultats** dans des fichiers texte :
   - `mbti_result.txt` : type MBTI final de l’utilisateur  
   - `mbti_star_result.txt` : type MBTI compatible qu’il préfère  
   - `user_info.txt` : informations personnelles (nom, prénom, âge, orientation, genre)
3. **Une exécution ultérieure dans Julia**, qui lit ces fichiers et calcule les compatibilités.

Ainsi, Shiny ne calcule pas de compatibilité :  
**Shiny collecte – Julia calcule.**

---

## 7.3 Code de lancement côté Julia : `runcompabiliteRshiny.jl`

Ce fichier démarre l’application Shiny, attend que l’utilisateur termine le questionnaire, puis exécute le calcul Julia.

```julia
using CSV, DataFrames
using PlotlyJS   # si tu veux afficher le cœur

root = @__DIR__

include(joinpath(root, "..", "src", "types_projet.jl"))
include(joinpath(root, "..", "src", "compatibilité.jl"))
include(joinpath(root, "..", "src", "calcul_compatibilite.jl"))
include(joinpath(root, "..", "graphique", "graphique_coeur.jl"))

# 1. Lancement de Shiny
run(`Rscript -e "shiny::runApp('$(root)', launch.browser=TRUE)"`, wait=false)

println("Quand tu as terminé le questionnaire dans Shiny, appuie sur Entrée ici.")
readline()

# 2. Lecture des fichiers exportés par Shiny
mbti_user = chomp(read(joinpath(root, "mbti_result.txt"), String))
mbti_star = chomp(read(joinpath(root, "mbti_star_result.txt"), String))
println("Type MBTI → $mbti_user")
println("Type préféré → $mbti_star")

# 3. Lecture des infos utilisateur
user_info = Dict{String,String}()
for line in eachline(joinpath(root, "user_info.txt"))
    parts = split(line)
    if length(parts) == 2
        user_info[parts[1]] = parts[2]
    end
end

utili = Utilisateur(
    get(user_info, "prenom", "Inconnu"),
    get(user_info, "nom", "Inconnu"),
    get(user_info, "genre", "H"),
    parse(Int, get(user_info, "age", "25")),
    get(user_info, "orientation", "Hétéro"),
    mbti_user
)

println("Utilisateur chargé : $(utili.firstname) $(utili.lastname) – $(utili.age) ans")

# 4. Calcul compatibilités
stars = charger_stars(joinpath(root, "..", "data", "base_stars_clean.csv"))
resultats = trouver_meilleures_compatibilites(utili, stars)

if !isempty(resultats)
    top_star, top_score = resultats[1]
    println("Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")
end
```

Ce script assure la **liaison totale** entre R Shiny et Julia.

---

## 7.4 Structure simplifiée de l’application Shiny

Le fichier `app.R` contient trois parties :

### **UI — Interface utilisateur**

- Formulaire : nom, prénom, âge, genre, orientation  
- Questionnaire MBTI  
- Bouton **Enregistrer mes résultats**

### **Server — Logique serveur**

- Calcul du MBTI depuis les réponses  
- Choix du type compatible  
- Écriture dans trois fichiers texte :
  - `mbti_result.txt`
  - `mbti_star_result.txt`
  - `user_info.txt`

### **RunApp — Lancement**

```r
shinyApp(ui = ui, server = server)
```

---

## 7.5 Pourquoi intégrer Shiny ?

L’ajout de Shiny apporte plusieurs avantages :

- Une **interface web moderne** et intuitive  
- Aucune saisie au clavier dans le terminal  
- Possibilité d’utiliser l’application **sans connaître Julia**  
- Une séparation claire entre :
  - **Collecte des réponses → Shiny**
  - **Analyse et compatibilité → Julia**

Cette section permet de montrer que le groupe a su réaliser une **solution hybride multiparadigme** :  
un front-end Shiny et un back-end Julia.

---

## 7.6 Conclusion de la partie Shiny

La version Shiny du questionnaire améliore fortement l’expérience utilisateur et offre un point d’entrée attrayant
au programme de compatibilité. Une fois les réponses enregistrées, Julia prend la suite pour exécuter une analyse
beaucoup plus précise grâce à la base de données des célébrités et aux règles de compatibilité MBTI.

Les deux outils se complètent parfaitement :
- **Shiny** → Interface interactive  
- **Julia** → Calculs avancés et analyse approfondie

Cette section démontre la capacité du projet à intégrer plusieurs technologies pour construire une application complète.


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



## GENESIS — Simulation du vivant

Cette première version du projet **GENESIS** est une application **Shiny** volontairement simple, conçue comme un prototype fonctionnel pour explorer la **vie artificielle** et l’**émergence** de dynamiques collectives à partir de règles locales minimales.

### Choix technologiques (sans JavaScript)

L’application a été développée en **R** avec :
- **shiny** : structure de l’interface et gestion de la réactivité (entrées utilisateur, sorties graphiques, boucles d’animation)
- **ggplot2** : tracé de la courbe d’évolution de la population
- **bslib** : thème Bootstrap personnalisé (couleurs, typographie)

Un point important de cette version est l’absence totale de JavaScript :
- aucune dépendance JavaScript n’a été ajoutée ;
- l’animation visuelle et l’identité graphique reposent uniquement sur du **CSS**, injecté via `tags$style(HTML(...))` ;
- les éléments HTML (en-tête, audio, mise en page) sont intégrés via `tags$*` (Shiny) sans scripts.

### Structure de l’interface (UI)

L’interface est organisée en deux zones :

1. **Panneau de contrôle (sidebar)**  
   - curseurs (`sliderInput`) :
     - population initiale,
     - gravité,
     - taux de mutation ;
   - boutons (`actionButton`) :
     - création du monde,
     - lecture / pause ;
   - affichage d’indicateurs (textes réactifs) :
     - nombre d’êtres vivants,
     - énergie moyenne,
     - nombre de naissances.

2. **Zone principale (main panel)**  
   - une visualisation de la simulation en temps réel (nuage de points) ;
   - une courbe d’évolution de la population (historique des dernières étapes).

L’identité visuelle est centralisée dans :
- un **thème** `bslib::bs_theme(...)` (fond noir, texte cyan, police Orbitron) ;
- un **bloc CSS** intégré (effets néon, mise en forme, animation par `@keyframes` du logo ADN).

### Moteur de simulation (serveur)

Le serveur implémente un moteur d’animation discret, piloté par la réactivité Shiny.

#### Variables réactives

- `world` : data.frame représentant l’état courant du monde (toutes les entités vivantes)
- `running` : booléen de lecture / pause
- `births` : compteur global de naissances
- `history` : historique (fenêtre glissante) de la taille de population
- `tick <- reactiveTimer(150)` : horloge (itération toutes les 150 ms)

#### Création du monde initial

Lors d’un clic sur **Créer le monde**, une population de taille `n` est générée aléatoirement :
- position `(x, y)` uniforme dans \\([0,1]\\),
- vitesses `(vx, vy)` centrées, faible variance,
- énergie initiale dans un intervalle fixé.

Cette étape réinitialise également :
- le compteur de naissances,
- l’historique de population,
- l’état `running` (démarrage immédiat).

#### Mise à jour à chaque itération

À chaque “tick” (si `running == TRUE`) :

1. **Gravité**  
   La gravité agit sur la vitesse verticale :
   - `vy <- vy - grav * cste`

2. **Déplacement**  
   Les positions sont mises à jour, puis ramenées dans \\([0,1]\\) par un modulo :
   - `x <- (x + vx) %% 1`
   - `y <- (y + vy) %% 1`

3. **Énergie et mortalité**  
   L’énergie décroît à chaque étape :
   - `energy <- max(0, energy - cste)`
   Les entités dont l’énergie devient nulle sont supprimées.

4. **Mutation / reproduction stochastique**  
   Avec une probabilité fixée par l’utilisateur (`mutation`), de nouveaux individus sont ajoutés :
   - ajout d’un petit nombre d’entités,
   - paramètres aléatoires proches des distributions initiales,
   - incrément du compteur `births`.

5. **Historique population**  
   La population courante est ajoutée à `history`.
   On conserve une fenêtre glissante (par exemple 100 dernières étapes) pour la courbe.

### Sorties graphiques et interprétation

1. **Visualisation du monde (plot principal)**  
   - chaque entité est un point ;
   - la taille du point est proportionnelle à l’énergie (`cex ~ energy`) ;
   - la couleur dépend de l’énergie (gradient rouge → vert), ce qui met en évidence :
     - les individus proches de la mort,
     - ceux qui conservent une énergie élevée.

2. **Courbe d’évolution de la population**  
   Construite à partir de `history` via **ggplot2**, elle permet d’observer :
   - phases de croissance (mutations fréquentes),
   - phases de décroissance (gravité forte / pertes énergétiques),
   - régimes instables ou quasi stationnaires.

### Contenu multimédia (audio)

Un son d’ambiance peut être joué via une balise HTML :
- `tags$audio(..., autoplay, loop, controls = NA)`
Le fichier audio est placé dans le dossier `www/` de l’application.

### Objectifs de cette version

Cette version Shiny simple vise à :
- valider la faisabilité et la cohérence du modèle de base ;
- proposer une interface minimaliste et paramétrable ;
- montrer comment des règles simples (mouvement, énergie, reproduction aléatoire) peuvent engendrer des dynamiques globales ;
- servir de socle pour des versions futures (ressources, espèces, sélection, interactions, métriques plus fines).





