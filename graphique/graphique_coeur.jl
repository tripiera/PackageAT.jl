using PlotlyJS

function afficher_coeur(score::Int, nom::String)
    # Cœur
    t = range(-π, π, length=400)
    x = 16 .* sin.(t).^3
    y = 13 .* cos.(t) .- 5 .* cos.(2t) .- 2 .* cos.(3t) .- cos.(4t)

    # Couleur selon score
    couleur = score < 40 ? "#777777" :
              score < 60 ? "#FFB6C1" :
              score < 80 ? "#FF69B4" : "#FF1493"

    trace = scatter(x=x, y=y, mode="lines", fill="toself",
                    fillcolor=couleur, line=attr(color="white", width=3), hoverinfo="none")

    # —— Texte au MILIEU du cœur, avec gros espace entre les 2 lignes ——
    y_center = 1.2                     # centre vertical du cœur 
    name_size  = clamp(40 - max(length(nom)-14, 0), 22, 40)  # réduit si nom long
    score_size = 28

    text_html = """
<span style='font-size:$(name_size)px; font-weight:700; color:white;'>$(nom)</span>
<br><br>
<span style='font-size:$(score_size)px; color:white;'>Compatibilité : $(score)%</span>
"""

    ann = attr(
        x=0, y=y_center, text=text_html,
        showarrow=false, xanchor="center", yanchor="middle", align="center"
    )

    layout = Layout(
        title=" Résultat de compatibilité ",
        plot_bgcolor="black", paper_bgcolor="black",
        xaxis=attr(visible=false, scaleanchor="y", scaleratio=1),
        yaxis=attr(visible=false),
        showlegend=false, annotations=[ann],
        margin=attr(l=0, r=0, t=40, b=0)
    )

    display(plot([trace], layout))
end
