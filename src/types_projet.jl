
#anaide
abstract type Personne end # ils ont en communs firstname, lastname, age et mbti

mutable struct Star <: Personne
    firstname::String
    lastname::String
    age::Int
    genre::String
    metier::String
    orientation::String
    mbti::String
end


mutable struct Utilisateur <: Personne
    firstname::String
    lastname::String
    genre::String
    age::Int
    orientation::String
    mbti::String
end



#il faut rajouter un peit message pour les compa_autre-signes : pourquoi on est compatible avec cet mbti pour après l'affichage
#faire bcp de type pour stoker
mutable struct MBTI
    type::String                            
    description::String                     
    compatibles::Vector{String}            
    message_compatibilite::Dict{String,String} 
end


const MBTI_COMPATIBILITIES = Dict(
    "ESTJ" => ["INFP", "ENFP", "ISTP"],
    "ISTJ" => ["ENFJ", "INFJ", "ESTP"],
    "ESFJ" => ["INTP", "ENTP", "ISFP"],
    "ISFJ" => ["ENTJ", "INTJ", "ESFP"],
    "ESTP" => ["INFJ", "ENFJ", "ISTJ"],
    "ISTP" => ["ENFP", "INFP", "ESTJ"],
    "ESFP" => ["INTJ", "ENTJ", "ISFJ"],
    "ISFP" => ["ENTP", "INTP", "ESFJ"],
    "ENTJ" => ["ISFJ", "ESFP", "INTJ"],
    "INTJ" => ["ESFP", "ISFJ", "ENTJ"],
    "ENTP" => ["ISFP", "ESFJ", "INTP"],
    "INTP" => ["ESFJ", "ISFP", "ENTP"],
    "ENFJ" => ["ISTJ", "ESTP", "INFJ"],
    "INFJ" => ["ESTP", "ISTJ", "ENFJ"],
    "ENFP" => ["ISTP", "ESTJ", "INFP"],
    "INFP" => ["ESTJ", "ISTP", "ENFP"]
)




### compabilité des mbti:
## source: https://hitostat.com/fr/articles/16-personalities-compatibility

estj = MBTI(
    "ESTJ",
    "Les ESTJ sont travailleur,productif et impatient.",
    MBTI_COMPATIBILITIES["ESTJ"],
    Dict(
        "INFP" => "Ils peuvent devenir des partenaires idéaux en utilisant leurs forces respectives pour compenser leurs faiblesses.",
        "ENFP" => "La présence de chacun stimule l'autre et encourage l'action proactive, créant une relation où l'ennui est rare.",
        "ISTP" => "Ils peuvent approfondir leur compréhension de soi et trouver des opportunités d'amélioration personnelle à travers leurs actions respectives. C'est une relation empathique."
    )
)

istj = MBTI(
    "ISTJ",
    "Les ISTJ sont patients, responsables et introvertis.",
    MBTI_COMPATIBILITIES["ISTJ"],
    Dict(
        "ENFP" => "Ils se complètent mutuellement et peuvent surmonter les situations difficiles ensemble en se soutenant.",
        "INFJ" => "Ils apportent des perspectives et des idées différentes, facilitant de nouvelles découvertes et des solutions créatives.",
        "ESTP" => "Ils comprennent leurs propres schémas de comportement en observant les réactions de l'autre, favorisant ainsi la croissance personnelle."
    )
)

esfj = MBTI(
    "ESFJ",
    "Les ESFJ sont gentils, populaires et un peu girouette",
    MBTI_COMPATIBILITIES["ESFJ"],
    Dict(
        "INTP" => "Grâce à une compréhension intuitive et une communication fluide, les malentendus et les frictions sont rares, favorisant une relation harmonieuse.",
        "ENTP" => "Ils se stimulent mutuellement, encourageant des actions positives. L'engagement dans de nouveaux défis crée une dynamique constante.",
        "ISFP" => "Ils reflètent les uns les autres, aidant à reconnaître leurs forces et faiblesses. L'empathie et la confiance émergent naturellement."
    )
)

isfj = MBTI(
    "ISFJ",
    "Les ISFJ sont loyaux, réguliers et peu flexibles",
    MBTI_COMPATIBILITIES["ISFJ"],
    Dict(
        "ENTJ" => "Dans la vie quotidienne, au travail et en amour, ils répondent aux besoins émotionnels de chacun, maintenant une relation stable.",
        "INTJ" => "Avec l'un apportant une pensée logique et planifiée et l'autre une pensée intuitive et flexible, un équilibre est possible.",
        "ESFP" => "Partageant des valeurs et des comportements similaires, la communication est fluide et les intentions sont facilement comprises."
    )
)

estp = MBTI(
    "ESTP",
    "Les ESTP sont optimistes, actifs et agités",
    MBTI_COMPATIBILITIES["ESTP"],
    Dict(
        "INFJ" => "Ils se comprennent intuitivement sur le plan émotionnel et intellectuel, ce qui réduit les malentendus et crée un sentiment de sécurité.",
        "ENFJ" => "Les deux ont une énergie élevée, parfois source de conflits, mais une communication appropriée permet de résoudre les désaccords.",
        "ISTJ" => "Ils se redécouvrent à travers l'autre. Partager des expériences communes solidifie leur relation."
    )
)

istp = MBTI(
    "ISTP",
    "Les ISTP sont optimistes, doux et têtus",
    MBTI_COMPATIBILITIES["ISTP"],
    Dict(
        "ENFP" => "Leurs façons de penser s'accordent, générant de nouvelles idées et solutions créatives.",
        "INFP" => "Partager de nouvelles expériences et aventures enrichit leur relation et crée un partenariat stimulant.",
        "ESTJ" => "Se voir mutuellement de manière claire renforce la compréhension et construit une confiance naturelle."
    )
)


esfp = MBTI(
    "ESFP",
    "Les ESFP sont dynamiques, sociables et dépensiers  ",
    MBTI_COMPATIBILITIES["ESFP"],
    Dict(
        "INTJ" => "Ils peuvent devenir des partenaires très équilibrés en mettant en valeur les forces de l'autre et en compensant leurs faiblesses.",
        "ENTJ" => "La présence de l'autre est une source de stimulation, les encourageant à agir de manière proactive. C'est une relation rarement ennuyeuse.",
        "ISFJ" => "Ils peuvent comprendre leurs propres actions à travers les réactions de l'autre, obtenant ainsi des opportunités de croissance. La coopération est nécessaire."
    )
)

isfp = MBTI(
    "ISFP",
    "Les ISFP sont spontanés, introspectifs et insaisissables ",
    MBTI_COMPATIBILITIES["ISFP"],
    Dict(
        "ENTP" => "Une confiance naturelle s'établit, la communication est fluide et chacun peut tirer le meilleur parti des forces de l'autre.",
        "INTP" => "Ils apportent des perspectives et des idées différentes, favorisant les découvertes et les solutions créatives.",
        "ESFJ" => "Ils partagent des valeurs similaires, ce qui facilite l'empathie et la communication, approfondissant la compréhension de soi."
    )
)

entj = MBTI(
    "ENTJ",
    "Les ENTJ sont compétitieurs, confiants et narcissiques ",
    MBTI_COMPATIBILITIES["ENTJ"],
    Dict(
        "ISFJ" => "En intégrant le point de vue de l'autre, vous découvrirez de nouvelles perspectives et opportunités de croissance, fournissant mutuellement un environnement optimal.",
        "ESFP" => "Vous augmentez mutuellement votre énergie, vous incitant à agir activement. En relevant de nouveaux défis, vous restez constamment dynamique.",
        "INTJ" => "Grâce à l'autre, vous réévaluez vos actions, offrant des opportunités de croissance. Les retours d'information sont essentiels."
    )
)

intj = MBTI(
    "INTJ",
    "Les INTJ sont perspicace, inspirés et capricieux ",
    MBTI_COMPATIBILITIES["INTJ"],
    Dict(
        "ESFP" => "En intégrant les perspectives de l'autre, de nouvelles idées et solutions émergent, favorisant la croissance.",
        "ISFJ" => "L'un apporte une pensée logique et planifiée, tandis que l'autre apporte une réflexion intuitive et flexible, conduisant à des résultats efficaces.",
        "ENTJ" => "Avec des comportements similaires, ils construisent naturellement une relation de confiance et de compréhension."
    )
)

entp = MBTI(
    "ENTP",
    "Les ENTP sont innovants, vifs d'esprit et impulsifs ",
    MBTI_COMPATIBILITIES["ENTP"],
    Dict(
        "ISFP" => "Une coopération naturelle et une compréhension mutuelle se développent, établissant une relation de confiance profonde. Une relation idéale pour les deux parties.",
        "ESFJ" => "Les deux possèdent une énergie élevée, ce qui peut parfois provoquer des conflits ou des frictions, mais cela offre aussi des opportunités de croissance et de renforcement des liens.",
        "INTP" => "Observer les réactions de l'autre aide à comprendre ses propres schémas de comportement, facilitant ainsi la croissance personnelle."
    )
)

intp = MBTI(
    "INTP",
    "Les INTP sont equitables,raisonnables et incaccessibles ",
    MBTI_COMPATIBILITIES["INTP"],
    Dict(
        "ESFJ" => "Ils forment une équipe équilibrée et puissante en mettant en valeur les forces de chacun et en compensant les faiblesses de l'autre.",
        "ISFP" => "Partager de nouvelles expériences et aventures renforce leur relation et crée un partenariat stimulant pour les deux.",
        "ENTP" => "Ils reflètent l'image de l'autre, aidant à reconnaître leurs propres forces et faiblesses. L'empathie et la confiance naissent naturellement."
    )
)

enfj = MBTI(
    "ENFJ",
    "Les ENFJ sont prudents, tolérants, et crédules",
    MBTI_COMPATIBILITIES["ENFJ"],
    Dict(
        "ISTJ" => "Ils construisent une relation de collaboration solide et progressent harmonieusement vers des objectifs communs. Ils se complètent mutuellement dans leurs points faibles.",
        "ESTP" => "Ils se stimulent mutuellement, encourageant une action proactive. C'est une relation peu ennuyeuse.",
        "INFJ" => "Ayant des valeurs et des comportements similaires, la communication est fluide et les intentions de chacun sont facilement comprises."
    )
)

infj = MBTI(
    "INFJ",
    "Les INFJ sont calmes, passionnés et passifs",
    MBTI_COMPATIBILITIES["INFJ"],
    Dict(
        "ESTP" => "Grâce à une compréhension intuitive, les échanges d'idées se font sans malentendus, assurant une communication efficace.",
        "ISTJ" => "L'apport de perspectives et d'idées différentes stimule les découvertes et les solutions créatives.",
        "ENFJ" => "Une relation qui offre des opportunités d'amélioration personnelle par le biais de la réflexion à travers l'autre. Ils partagent des expériences communes."
    )
)

enfp = MBTI(
    "ENFP",
    "Les ENFP sont genils, créatifs et se lassent vite",
    MBTI_COMPATIBILITIES["ENFP"],
    Dict(
        "ISTP" => "Leurs pensées s'harmonisent bien, permettant une approche efficace où planification et créativité fusionnent.",
        "ESTJ" => "Ils stimulent mutuellement leur énergie, favorisant une action proactive. Les nouveaux défis apportent une vitalité constante.",
        "INFP" => "Ils se reflètent mutuellement, approfondissant la compréhension de soi et établissant une confiance naturelle. Facile à empathiser."
    )
)

infp = MBTI(
    "INFP",
    "Les INFP sont imaginatifs,humbles et idéalistes",
    MBTI_COMPATIBILITIES["INFP"],
    Dict(
        "ESTJ" => "Les faiblesses de chacun sont compensées par les forces de l'autre, créant une confiance et une compréhension naturelles. Une coopération facile permet de construire un partenariat solide.",
        "ISTP" => "L'un apporte une pensée logique et planifiée, tandis que l'autre apporte une pensée intuitive et flexible, produisant de bons résultats.",
        "ENFP" => "Comprendre ses propres actions à travers les réactions de l'autre permet de grandir. La coopération est clé."
    )
)


const MBTI_QUESTIONS = Dict(
    "ESTJ" => [
        "Préférerais-tu quelqu'un de INFP : créatif, introspectif et idéaliste ?",
        "Préférerais-tu quelqu'un de ENFP : enthousiaste, sociable et imaginatif ?",
        "Préférerais-tu quelqu'un de ISTP : calme, pratique et analytique ?"
    ],
    "ISTJ" => [
        "Préférerais-tu quelqu'un de ENFJ : chaleureux, organisé et charismatique ?",
        "Préférerais-tu quelqu'un de INFJ : réfléchi, intuitif et empathique ?",
        "Préférerais-tu quelqu'un de ESTP : énergique, pratique et spontané ?"
    ],
    "ESFJ" => [
        "Préférerais-tu quelqu'un de INTP : logique, discret et créatif ?",
        "Préférerais-tu quelqu'un de ENTP : inventif, sociable et curieux ?",
        "Préférerais-tu quelqu'un de ISFP : sensible, artistique et attentionné ?"
    ],
    "ISFJ" => [
        "Préférerais-tu quelqu'un de ENTJ : déterminé, organisé et ambitieux ?",
        "Préférerais-tu quelqu'un de INTJ : stratégique, calme et visionnaire ?",
        "Préférerais-tu quelqu'un de ESFP : spontané, joyeux et sociable ?"
    ],
    "ESTP" => [
        "Préférerais-tu quelqu'un de INFJ : réfléchi, intuitif et empathique ?",
        "Préférerais-tu quelqu'un de ENFJ : sociable, chaleureux et charismatique ?",
        "Préférerais-tu quelqu'un de ISTJ : organisé, pratique et fiable ?"
    ],
    "ISTP" => [
        "Préférerais-tu quelqu'un de ENFP : enthousiaste, curieux et imaginatif ?",
        "Préférerais-tu quelqu'un de INFP : introspectif, créatif et idéaliste ?",
        "Préférerais-tu quelqu'un de ESTJ : pratique, organisé et direct ?"
    ],
    "ESFP" => [
        "Préférerais-tu quelqu'un de INTJ : stratégique, réfléchi et visionnaire ?",
        "Préférerais-tu quelqu'un de ENTJ : ambitieux, organisé et motivé ?",
        "Préférerais-tu quelqu'un de ISFJ : attentionné, calme et fiable ?"
    ],
    "ISFP" => [
        "Préférerais-tu quelqu'un de ENTP : inventif, sociable et curieux ?",
        "Préférerais-tu quelqu'un de INTP : analytique, créatif et discret ?",
        "Préférerais-tu quelqu'un de ESFJ : chaleureux, sociable et attentionné ?"
    ],
    "ENTJ" => [
        "Préférerais-tu quelqu'un de ISFJ : attentif, fiable et discret ?",
        "Préférerais-tu quelqu'un de ESFP : joyeux, sociable et spontané ?",
        "Préférerais-tu quelqu'un de INTJ : réfléchi, stratégique et visionnaire ?"
    ],
    "INTJ" => [
        "Préférerais-tu quelqu'un de ESFP : joyeux, sociable et spontané ?",
        "Préférerais-tu quelqu'un de ISFJ : fiable, attentif et calme ?",
        "Préférerais-tu quelqu'un de ENTJ : ambitieux, organisé et déterminé ?"
    ],
    "ENTP" => [
        "Préférerais-tu quelqu'un de ISFP : sensible, artistique et attentif ?",
        "Préférerais-tu quelqu'un de ESFJ : sociable, chaleureux et attentif ?",
        "Préférerais-tu quelqu'un de INTP : logique, discret et inventif ?"
    ],
    "INTP" => [
        "Préférerais-tu quelqu'un de ESFJ : sociable, chaleureux et attentif ?",
        "Préférerais-tu quelqu'un de ISFP : artistique, sensible et discret ?",
        "Préférerais-tu quelqu'un de ENTP : curieux, inventif et sociable ?"
    ],
    "ENFJ" => [
        "Préférerais-tu quelqu'un de ISTJ : organisé, fiable et réfléchi ?",
        "Préférerais-tu quelqu'un de ESTP : spontané, pratique et direct ?",
        "Préférerais-tu quelqu'un de INFJ : intuitif, réfléchi et empathique ?"
    ],
    "INFJ" => [
        "Préférerais-tu quelqu'un de ESTP : pratique, énergique et spontané ?",
        "Préférerais-tu quelqu'un de ISTJ : fiable, réfléchi et organisé ?",
        "Préférerais-tu quelqu'un de ENFJ : sociable, chaleureux et charismatique ?"
    ],
    "ENFP" => [
        "Préférerais-tu quelqu'un de ISTP : calme, pratique et analytique ?",
        "Préférerais-tu quelqu'un de ESTJ : organisé, direct et efficace ?",
        "Préférerais-tu quelqu'un de INFP : créatif, introspectif et idéaliste ?"
    ],
    "INFP" => [
        "Préférerais-tu quelqu'un de ESTJ : organisé, direct et efficace ?",
        "Préférerais-tu quelqu'un de ISTP : calme, pratique et analytique ?",
        "Préférerais-tu quelqu'un de ENFP : enthousiaste, sociable et imaginatif ?"
    ]
)

const MBTI_TYPES = Dict(
    "ESTJ" => estj,
    "ISTJ" => istj,
    "ESFJ" => esfj,
    "ISFJ" => isfj,
    "ESTP" => estp,
    "ISTP" => istp,
    "ESFP" => esfp,
    "ISFP" => isfp,
    "ENTJ" => entj,
    "INTJ" => intj,
    "ENTP" => entp,
    "INTP" => intp,
    "ENFJ" => enfj,
    "INFJ" => infj,
    "ENFP" => enfp,
    "INFP" => infp
)
