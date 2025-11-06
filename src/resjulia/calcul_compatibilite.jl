#############################################################
# calcul_compatibilite.jl
#############################################################

using CSV
using DataFrames
include("../types_projet.jl")

# ============================================================
# Helpers de normalisation
# ============================================================

normalize_genre(x) = begin
    s = lowercase(strip(String(x)))
    s in ["h", "homme", "male", "m"] && return "H"
    s in ["f", "femme", "female"] && return "F"
    return "?"
end

normalize_orientation(x) = begin
    s = lowercase(strip(String(x)))
    s in ["hetero", "hétéro", "heterosexuel", "hétérosexuel",
          "heterosexuelle", "hétérosexuelle"] && return "Hétéro"
    s in ["gay", "gai", "homosexuel", "homosexuelle"] && return "Gay"
    s in ["lesbienne"] && return "Lesbienne"
    s in ["bi", "bisexuel", "bisexuelle", "bisexual"] && return "Bi"
    s in ["pan", "pansexuel", "pansexuelle", "pansexual"] && return "Pan"
    s in ["asexuel", "asexuelle", "asexual"] && return "Asexuelle"
    return "Autre"
end

normalize_mbti(x) = uppercase(strip(String(x)))

# ============================================================
# Charger les célébrités
# ============================================================

function charger_stars(fichier_csv::String)
    df = CSV.read(fichier_csv, DataFrame)
    stars = Star[]

    for row in eachrow(df)
        nom_parts = split(String(row.Nom), " ")
        firstname = nom_parts[1]
        lastname = join(nom_parts[2:end], " ")

        push!(stars, Star(
            firstname,
            lastname,
            Int(row."Âge"),
            normalize_genre(row.Genre),
            String(row.Profession),
            normalize_orientation(row.Orientation),
            normalize_mbti(row.MBTI)
        ))
    end
    return stars
end

# ============================================================
# Compatibilité MBTI
# ============================================================

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

# ============================================================
# Compatibilité orientation / genre
# ============================================================

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

function score_orientation(user::Utilisateur, star::Star)
    if !user_attire_par_star(user, star) || !star_attiree_par_user(star, user)
        return 0
    elseif user.orientation == "Hétéro" && star.orientation == "Hétéro"
        return 30
    else
        return 25
    end
end

# ============================================================
# Compatibilité d’âge
# ============================================================

function score_age(user_age::Int, star_age::Int)
    diff = abs(user_age - star_age)
    return diff <= 5  ? 20 :
           diff <= 10 ? 10 :
           diff <= 15 ? 5  : 0
end

# ============================================================
# Calcul global
# ============================================================

function calculer_compatibilite(user::Utilisateur, star::Star)
    s_mbti = score_mbti(user.mbti, star.mbti)
    s_orient = score_orientation(user, star)
    s_age = score_age(user.age, star.age)
    return min(s_mbti + s_orient + s_age, 100)
end

# ============================================================
# Trouver les meilleures correspondances
# ============================================================

function trouver_meilleures_compatibilites(user::Utilisateur, stars::Vector{Star}; top::Int=5)
    # 🔍 Filtrer selon genre/orientation avant tout calcul
    filtered_stars = filter(stars) do s
        user_attire_par_star(user, s) && star_attiree_par_user(s, user)
    end

    println("Filtrage : $(length(filtered_stars)) célébrités retenues sur $(length(stars)) totales.")

    # Calculer compatibilité uniquement sur ce sous-ensemble
    scores = [(s, calculer_compatibilite(user, s)) for s in filtered_stars]
    sorted = sort(scores, by=x->x[2], rev=true)

    return sorted[1:min(top, length(sorted))]
end
