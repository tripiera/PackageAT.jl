module PackageAT

using Markdown 
using Bonito
using DataFrames
using CSV

export ask_mbti_questions, Star, Utilisateur, MBTI


include(joinpath(@__DIR__, "types_projet.jl"))
include(joinpath(@__DIR__, "compatibilité.jl"))
include(joinpath(@__DIR__, "1bonito_compa.jl"))
include(joinpath(@__DIR__, "final_bonito.jl"))
include(joinpath(@__DIR__, "trouver_match.jl"))
include(joinpath(@__DIR__, "calcul_compatibilite.jl"))



end
