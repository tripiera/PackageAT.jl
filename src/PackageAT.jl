module PackageAT

using DataFrames
using CSV
export ask_mbti_questions
include("types_projet.jl")
include("compatibilité.jl")
include("1bonito_compa.jl")
include("final_bonito.jl")
include("trouver_match.jl")
include("calcul_compatibilite.jl")

# Write your package code here.

end
