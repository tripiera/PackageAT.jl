using CSV
using DataFrames
include("types_projet.jl")
include("calcul_compatibilite.jl")

"""
    trouver_meilleurs_matchs(user::Utilisateur, chemin_csv::String, mbti_objs::Dict; top::Int=3)

Charge le CSV des célébrités, calcule la compatibilité pour chacune,
et renvoie les `top` stars les plus compatibles avec l'utilisateur.
"""
function trouver_meilleurs_matchs(user::Utilisateur, chemin_csv::String, mbti_objs::Dict; top::Int=3)
    # Charger le CSV
    df = CSV.read(chemin_csv, DataFrame)

    resultats = DataFrame(Star = String[], Score = Float64[], Message = String[])

    for row in eachrow(df)
        star = Star(
            split(row.Nom, " ")[1],
            join(split(row.Nom, " ")[2:end], " "),
            row.Âge,
            row.Profession,
            row.Orientation,
            row.MBTI
        )

        score, msg = calculer_compatibilite(user, star, mbti_objs)
        push!(resultats, (string(row.Nom), score, msg))
    end

    # Trier du plus compatible au moins compatible
    sort!(resultats, :Score, rev=true)

    println("\n💘 Top $(top) des célébrités compatibles :")
    for i in 1:top
        println("$(i). $(resultats[i, :Star]) → $(resultats[i, :Score])%")
    end

    return resultats[1:top, :]
end
