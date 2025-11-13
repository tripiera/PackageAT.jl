#########################################################
# Amine
# runcompabiliteRshiny.jl
# VERSION  — lance le questionnaire Shiny et lit les infos réelles
##########################################################

using CSV, DataFrames

# === Importation des modules nécessaires ===
include("../src/compatibilité.jl")             # contient types, structures, etc.
include("../src/types_projet.jl")              # structures et dictionnaires
include("../src/calcul_compatibilite.jl")  # fonctions de calcul des compatibilités
include("../graphique/graphique_coeur.jl")       # affichage graphique du cœur

println("===  Lancement automatique du questionnaire Shiny ===")

#  Lance Shiny dans un processus séparé
cd("C:/Users/Admin/Documents/PackageAT.jl")
run(`"C:\\PROGRA~1\\R\\R-44~1.3\\bin\\x64\\Rscript.exe" -e "shiny::runApp('C:/Users/Admin/Documents/PackageAT.jl', launch.browser=TRUE)"`, wait = false)

println(" Quand tu auras fini le test et cliqué sur 'Enregistrer', appuie sur Entrée ici ⏎")
readline()  # attend que tu appuies sur Entrée manuellement

println(" Lecture des fichiers générés...\n")

##########################################################
# 1️ Lecture des fichiers générés par Shiny
##########################################################
if isfile("mbti_result.txt") && isfile("mbti_star_result.txt")
    mbti_user = chomp(read("mbti_result.txt", String))
    mbti_star = chomp(read("mbti_star_result.txt", String))
    println(" Ton type MBTI : $mbti_user")
    println(" Type préféré chez les stars : $mbti_star")
else
    println(" Les fichiers 'mbti_result.txt' et/ou 'mbti_star_result.txt' sont introuvables.")
    println(" Lance d'abord le questionnaire Shiny (app.R) et enregistre les résultats.")
    exit()
end

##########################################################
# 2️ Création de l'objet utilisateur (lecture réelle depuis Shiny)
##########################################################
println("\n Création de l'utilisateur (infos depuis Shiny)")

user_info = Dict{String,String}()
if isfile("user_info.txt")
    for line in eachline("user_info.txt")
        parts = split(line)
        if length(parts) == 2
            user_info[parts[1]] = parts[2]
        end
    end
    prenom = get(user_info, "prenom", "Inconnu")
    nom = get(user_info, "nom", "Inconnu")
    genre = get(user_info, "genre", "H")
    age = parse(Int, get(user_info, "age", "25"))
    orientation = get(user_info, "orientation", "Hétéro")
else
    println(" Fichier user_info.txt introuvable — valeurs par défaut utilisées.")
    prenom = "PrenomExemple"
    nom = "NomExemple"
    genre = "H"
    age = 25
    orientation = "Hétéro"
end

utili = Utilisateur(prenom, nom, genre, age, orientation, mbti_user)
user = utili

println(" Utilisateur chargé : $(user.firstname) $(user.lastname), $(user.age) ans, $(user.orientation)")
println(" Type MBTI : $(user.mbti)\n")

##########################################################
# 3️ Charger la base de célébrités et calculer compatibilité
##########################################################
println(" Chargement des célébrités...")
stars = charger_stars("base_stars_clean.csv")

println("\n Calcul des compatibilités...\n")
resultats = trouver_meilleures_compatibilites(user, stars)

##########################################################
# 4️ Vérifier et afficher le résultat
##########################################################
if isempty(resultats)
    println(" Aucune célébrité ne correspond à tes critères de compatibilité.")
    println(" Essaie d’élargir tes préférences (âge, genre, orientation...).")
    println("\n     💔 ")
    println("  Aucun match trouvé...")
    println("     💔 ")
else
    top_star, top_score = resultats[1]
    println("\n Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    println(" Score total : $(top_score)%")

    ##########################################################
    # 5️ Affichage graphique du cœur
    ##########################################################
    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")
    println("\n💞 Fin du programme 💞")
end
