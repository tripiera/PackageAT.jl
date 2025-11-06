using Bonito
using DataFrames
using CSV
include("types_projet.jl")

function ask_mbti_questions_bonito()
    # Création de la page bonito
    page = Page()

    ###infos utilisateur
    name = Textbox(placeholder="Nom")
    firstname = Textbox(placeholder="Prénom")
    age = Textbox(placeholder="Âge (en chiffres)")
    genre = Dropdown(["H" => "Homme", "F" => "Femme"], label="Genre")
    orientation = Dropdown([
        "1" => "Hétérosexuel",
        "2" => "Bisexuel",
        "3" => "Gay",
        "4" => "Lesbienne",
        "5" => "Asexuel",
        "6" => "Pansexuel",
        "7" => "Autre"
    ], label="Orientation sexuelle")

    submit_info = Button("Valider les informations")
    info_box = vbox(
        md"### Informations personnelles",
        name,
        firstname,
        age,
        genre,
        orientation,
        submit_info
    )

    #questionaire
    questions = [
        ("Quand tu es fatigué(e), tu préfères :", "Sortir voir des amis", "Rester seul(e)", 'E', 'I'),
        ("En soirée, tu :", "Adores parler à plein de monde", "Préfères discuter avec une ou deux personnes", 'E', 'I'),
        ("Quand tu rencontres quelqu’un de nouveau :", "Tu engages facilement la conversation", "Tu attends qu’on te parle", 'E', 'I'),
        ("Au travail ou en groupe :", "Tu t’exprimes spontanément", "Tu réfléchis avant de parler", 'E', 'I'),
        ("Tu te fies plutôt à :", "Ton expérience passée", "Ton intuition", 'S', 'N'),
        ("Tu as tendance à :", "Remarquer les détails", "Imaginer les possibilités", 'S', 'N'),
        ("Tu préfères :", "Ce qui est tangible et réel", "Ce qui est théorique et abstrait", 'S', 'N'),
        ("On te décrit comme :", "Pragmatique", "Visionnaire", 'S', 'N'),
        ("Quand un ami a un problème :", "Tu proposes une solution", "Tu offres du soutien émotionnel", 'T', 'F'),
        ("On te dit souvent :", "Franc(he) et rationnel(le)", "Empathique et attentionné(e)", 'T', 'F'),
        ("Quand tu décides :", "Tu utilises la logique", "Tu écoutes ton cœur", 'T', 'F'),
        ("Dans les débats :", "Tu défends la vérité", "Tu protèges les sentiments des autres", 'T', 'F'),
        ("Quand tu planifies :", "Tu veux tout prévoir à l’avance", "Tu préfères t’adapter au moment venu", 'J', 'P'),
        ("Tes journées sont :", "Structurées et organisées", "Souples et improvisées", 'J', 'P'),
        ("Tu préfères :", "Finir les choses avant d’en commencer d’autres", "Avoir plusieurs projets ouverts", 'J', 'P'),
        ("Les règles :", "Sont faites pour être respectées", "Sont faites pour être adaptées", 'J', 'P')
    ]

    # init
    scores = Dict('E'=>0, 'I'=>0, 'S'=>0, 'N'=>0, 'T'=>0, 'F'=>0, 'J'=>0, 'P'=>0)
    q_index = Observable(1)
    result_label = Label("")

    question_label = Label("")
    bouton1 = Button("")
    bouton2 = Button("")
    bouton_suivant = Button("Question suivante", enabled=false)

    # fonction qui permet de  mettre à jour l’interface dynamiquement en fonction des clics sur les boutons
    #car Bonito ne bloque pas le programme en attendant que l’utilisateur tape quelque chose ,comme readline() le fait dans le terminal.
    function miseajour_question(i)
        if i > length(questions) #si on a déjà posé toutes les questions :affichage resultat
            bouton_suivant.enabled = false
            question_label.text = "Chargement du résultat..."
            res_affich()
            return
        end
        q = questions[i]
        question_label.text = q[1] #question
       bouton1.label =  q[2] #response 1 
        bouton2.label = q[3] # reponse 2
        bouton_suivant.enabled = false
    end

    function res_affich()
        
        function cas_egalite(sym1, sym2, qtext, o1, o2)
            if scores[sym1] > scores[sym2]
                return sym1
            elseif scores[sym2] > scores[sym1]
                return sym2
            else
                # affichage de la question de départage
                question_label.text = qtext
                bouton1.label = o1
                bouton2.label = o2
                bouton_suivant.enabled = false
                # bloque ici jusqu'à clic utilisateur
                wait(bouton1)
                return (bouton1.clicked[] > bouton2.clicked[]) ? sym1 : sym2
            end
        end

        l1 = cas_egalite('E','I',"Égalité entre E et I :","Parler aux autres (E)","Être seul(e) (I)")
        l2 = cas_egalite('S','N',"Égalité entre S et N :","Observer (S)","Imaginer (N)")
        l3 = cas_egalite('T','F',"Égalité entre T et F :","Logique (T)","Émotions (F)")
        l4 = cas_egalite('J','P',"Égalité entre J et P :","Planifier (J)","Improviser (P)")

        mbti = string(l1,l2,l3,l4)
        result_label.text = "Ton type MBTI est : **$mbti** 🎯"

        #si on a une preference parmis l'un des 3 types
        compatibles = MBTI_COMPATIBILITIES[mbti]
        descr = MBTI_QUESTIONS[mbti]
        compat_options = [Radio(o) for o in descr]
        bouton_random = Button("Choisir au hasard")
        compat_section = vbox(
            md"### Types compatibles",
            compat_options...,
            bouton_random
        )
        append!(page, compat_section)
    end

    # gestion des clics
    on(bouton1) do _  #execute le code à l’intérieur chaque fois que l’utilisateur interagit avecbouton1
        i = q_index[]  #q_index = un obersvable  j'ai pu apprendre que un observable= "boite à valeurs"
        dim1, dim2 = questions[i][4], questions[i][5] #Chaque question a deux dimensions
        scores[dim1] += 1#si l’utilisateur a cliqué sur le bouton 1, on incrémente le score de la première dimension
        bouton_suivant.enabled = true
    end
    on(bouton2) do _
        i = q_index[]
        dim1, dim2 = questions[i][4], questions[i][5]
        scores[dim2] += 1 #comme on a fait dim 1 on fait dim2
        bouton_suivant.enabled = true #suivant
    end
    on(bouton_suivant) do _
        q_index[] += 1  #question suivante
        miseajour_question(q_index[]) #met à jour le texte et les boutons pour la prochaine question
    end

    miseajour_question(1)
    #maintenant que tout est defini : on ajoute tous les éléments dans la page web
    append!(page, [
        info_box,
        vbox(
            md"# Questionnaire MBTI",
            question_label,
            hbox(bouton1, bouton2),
            bouton_suivant,
            result_label
        )
    ])

    return page
end

# Pour lancer le questionnaire :
Bonito.serve(ask_mbti_questions_bonito)
