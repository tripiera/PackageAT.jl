#########################################################
# Amine
# runcompabiliteRshiny.jl – Questionnaire Shiny + calcul compatibilité
# VERSION PORTABLE – chemins relatifs
#########################################################

using CSV, DataFrames
using PlotlyJS   # si tu veux afficher le cœur

# -----------------------------
# Inclure tes modules internes
# -----------------------------
root = @__DIR__  # dossier du script

include(joinpath(root, "..", "src", "types_projet.jl"))
include(joinpath(root, "..", "src", "compatibilité.jl"))
include(joinpath(root, "..", "src", "calcul_compatibilite.jl"))
include(joinpath(root, "..", "graphique", "graphique_coeur.jl"))


# -----------------------------
# Étape 1 : Lancer Shiny (processus séparé)
# -----------------------------
app_path = root  # si app.R est dans le même dossier que ce script
run(`Rscript -e "shiny::runApp('$(app_path)', launch.browser=TRUE)"`, wait=false)

println("Quand tu auras fini le test et cliqué sur 'Enregistrer', appuie sur Entrée ici ⏎")
readline()  # pause manuelle

# -----------------------------
# Étape 2 : Lecture des résultats MBTI
# -----------------------------
mbti_file       = joinpath(root, "mbti_result.txt")
mbti_star_file  = joinpath(root, "mbti_star_result.txt")

if isfile(mbti_file) && isfile(mbti_star_file)
    mbti_user = chomp(read(mbti_file, String))
    mbti_star = chomp(read(mbti_star_file, String))
    println("Ton type MBTI : $mbti_user")
    println("Type préféré chez les stars : $mbti_star")
else
    println(" Les fichiers 'mbti_result.txt' et/ou 'mbti_star_result.txt' sont introuvables.")
    println("Lance d'abord le questionnaire Shiny (app.R) et enregistre les résultats.")
    exit()
end

# -----------------------------
# Étape 3 : Création de l'utilisateur (depuis Shiny)
# -----------------------------
println("\nCréation de l'utilisateur (infos depuis Shiny)")

user_info_file = joinpath(root, "user_info.txt")
user_info = Dict{String,String}()

if isfile(user_info_file)
    for line in eachline(user_info_file)
        parts = split(line)
        if length(parts) == 2
            user_info[parts[1]] = parts[2]
        end
    end
    prenom      = get(user_info, "prenom", "Inconnu")
    nom         = get(user_info, "nom", "Inconnu")
    genre       = get(user_info, "genre", "H")
    age         = parse(Int, get(user_info, "age", "25"))
    orientation = get(user_info, "orientation", "Hétéro")
else
    println(" Fichier user_info.txt introuvable — valeurs par défaut utilisées.")
    prenom, nom, genre, age, orientation = "PrenomExemple", "NomExemple", "H", 25, "Hétéro"
end

utili = Utilisateur(prenom, nom, genre, age, orientation, mbti_user)
user  = utili

println("Utilisateur chargé : $(user.firstname) $(user.lastname), $(user.age) ans, $(user.orientation)")
println("Type MBTI : $(user.mbti)\n")

# -----------------------------
# Étape 4 : Charger la base de stars et calculer compatibilité
# -----------------------------
stars_file = joinpath(root, "..", "data", "base_stars_clean.csv")
println("Chargement des célébrités depuis $stars_file ...")
stars = charger_stars(stars_file)

println("\nCalcul des compatibilités...\n")
resultats = trouver_meilleures_compatibilites(user, stars)

# -----------------------------
# Étape 5 : Afficher les résultats
# -----------------------------
if isempty(resultats)
    println(" Aucune célébrité ne correspond à tes critères de compatibilité.")
    println("Essaie d’élargir tes préférences (âge, genre, orientation...).")
else
    top_star, top_score = resultats[1]
    println("\n Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    println("Score total : $(top_score)%")
    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")
    println("\n Fin du programme ")
end
