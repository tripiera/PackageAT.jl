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
