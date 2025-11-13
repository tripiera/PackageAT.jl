#########################################################
# Amine
# runcompatibilite0.jl – Lancer le test de compatibilité
# VERSION STABLE – Questionnaire MBTI + compatibilité stars
#########################################################

using PackageAT

println("=== TEST DE COMPATIBILITÉ ===\n")

# Étape 1 : Lancer le test MBTI
user_mbti, mbti_compatible, utili = ask_mbti_questions()

mbti_user = chomp(read("mbti_result.txt", String))
mbti_star = chomp(read("mbti_star_result.txt", String))

println("\n Ton type MBTI : $mbti_user")
println(" Type préféré chez les stars : $mbti_star")

# Étape 2 : Créer l'utilisateur
user = utili
println("\n Utilisateur chargé : $(user.firstname) $(user.lastname), $(user.age) ans, $(user.orientation)")

# Étape 3 : Charger les célébrités et calculer la compatibilité
println("\n Chargement des célébrités...")
stars = charger_stars("../data/base_stars_clean.csv")

println("\n Calcul en cours...\n")
resultats = trouver_meilleures_compatibilites(user, stars)

# Étape 4 : Affichage du résultat
if isempty(resultats)
    println("💔 Aucun match trouvé. Essaie d’élargir tes préférences 💔")
else
    top_star, top_score = resultats[1]
    println("\n Star la plus compatible : $(top_star.firstname) $(top_star.lastname)")
    println(" Score total : $(top_score)%")
    afficher_coeur(top_score, "$(top_star.firstname) $(top_star.lastname)")
    println("\n💞 Fin du programme 💞")
end
