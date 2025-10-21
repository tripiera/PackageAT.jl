using DataFrames
using CSV

# base de donnees générée par chat gpt contenant : 
# Nom;Profession;Âge;Genre;Orientation;MBTI;Sociabilité;Créativité;Organisation;Rationalité;Empathie;Ambition
# nettoyage de la base : je me rend compte à ce stade que MBTI suffit donc je vais enlever Sociabilité;Créativité;Organisation;Rationalité;Empathie;Ambition
# j'ai regardée sur ce site: https://readmedium.com/read-csv-to-data-frame-in-julia-programming-lang-77f3d0081c14


df = CSV.read("base_star.csv", DataFrame)
select!(df, Not([:Sociabilité, :Créativité, :Organisation, :Rationalité, :Empathie, :Ambition]))
CSV.write("base_stars_clean.csv", df)
