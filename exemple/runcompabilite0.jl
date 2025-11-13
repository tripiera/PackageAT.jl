#########################################################
#Amine
# runcompabilite0.jerminal julia 
# VERSION STABLE – VERSION: questionnaire sur le t 
##########################################################

using CSV, DataFrames

# === Importation des modules nécessaires ===
include("../src/compatibilité.jl")             # contient ask_mbti_questions()
include("../src/types_projet.jl")              # structures et dictionnaires
include("../src/calcul_compatibilite.jl")  # fonctions de calcul des compatibilités
include("../graphique/graphique_coeur.jl")       # affichage graphique du cœur

println("===  TEST DE COMPATIBILITÉ ===\n")

##########################################################
# Étape : Lancer le test MBTI + récupérer utilisateur
##########################################################
# On récupère maintenant : 
# - le type MBTI de l’utilisateur
# - le type MBTI préféré (parmi les compatibles)
# - l’objet utilisateur complet (utili)
##########################################################

user_mbti, mbti_compatible, utili = ask_mbti_questions()

# Lecture des fichiers texte (résultats sauvegardés)
mbti_user = chomp(read("mbti_result.txt", String))
mbti_star = chomp(read("mbti_star_result.txt", String))

println("\n Ton type MBTI : $mbti_user")
println(" Type préféré chez les stars : $mbti_star")

##########################################################
#  Étape : Créer l'objet utilisateur
##########################################################
# On récupère directement l'objet Utilisateur (utili)
##########################################################

user = utili
println("\n Utilisateur chargé : $(user.firstname) $(user.lastname), $(user.age) ans, $(user.orientation)")

##########################################################
# Étape : Charger les célébrités et calculer compatibilité
##########################################################

println("\n Chargement des célébrités...")
stars = charger_stars("../data/base_stars_clean.csv")

println("\n Calcul en cours...\n")
resultats = trouver_meilleures_compatibilites(user, stars)

##########################################################
#  Étape : Vérifier les résultats et afficher
##########################################################

if isempty(resultats)
    println(" Aucune célébrité ne correspond à tes critères de compatibilité.")
    println(" Essaie d’élargir tes préférences (âge, genre, orientation...).")

    println("\n     💔 ")
    println("  Aucun match trouvé...")
    println("     💔 ")
else
    #  Prend la star la plus compatible
    top_star, top_score = resultats[1]

    println("\n Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    println(" Score total : $(top_score)%")

    ##########################################################
    #  Étape : Affichage graphique
    ##########################################################
    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")

    println("\n💞 Fin du programme 💞")
end
