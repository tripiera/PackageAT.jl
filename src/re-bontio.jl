using Bonito
using Markdown
using DataFrames
using CSV
include("types_projet.jl")

function ask_mbti_questions_bonito()
    # observables
    q_index = Observable(1)
    scores = Dict('E'=>0, 'I'=>0, 'S'=>0, 'N'=>0, 'T'=>0, 'F'=>0, 'J'=>0, 'P'=>0)
    question_text = Observable("")
    bouton1_label = Observable("")
    bouton2_label = Observable("")
    result_text = Observable("")
    bouton_suivant_disabled = Observable(true)

    # questions
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

    # fonction d'affichage de la question actuelle
    function maj_question(i)
        if i > length(questions)
            # fin du questionnaire
            l1 = if scores['E'] ≥ scores['I'] 'E' else 'I' end
            l2 = if scores['S'] ≥ scores['N'] 'S' else 'N' end
            l3 = if scores['T'] ≥ scores['F'] 'T' else 'F' end
            l4 = if scores['J'] ≥ scores['P'] 'J' else 'P' end
            mbti = string(l1,l2,l3,l4)
            set!(result_text, "Ton type MBTI est : **$(mbti)** 🎯")
            set!(question_text, "Merci d’avoir complété le questionnaire !")
            set!(bouton1_label, "")
            set!(bouton2_label, "")
            set!(bouton_suivant_disabled, true)
            return
        end

        q = questions[i]
        set!(question_text, q[1])
        set!(bouton1_label, q[2])
        set!(bouton2_label, q[3])
        set!(bouton_suivant_disabled, true)
    end

    # callback sur les boutons
    function clic_bouton1()
        i = q_index[]
        if i <= length(questions)
            dim1, dim2 = questions[i][4], questions[i][5]
            scores[dim1] += 1
            set!(bouton_suivant_disabled, false)
        end
    end

    function clic_bouton2()
        i = q_index[]
        if i <= length(questions)
            dim1, dim2 = questions[i][4], questions[i][5]
            scores[dim2] += 1
            set!(bouton_suivant_disabled, false)
        end
    end

    function clic_suivant()
        q_index[] += 1
        maj_question(q_index[])
    end

    # layout
    app = App() do
        Div(class="p-8 space-y-6",
            H1("Questionnaire MBTI"),
            Div(
                H3(bind=question_text),
                Div(
                    Button(bind=bouton1_label, onclick=clic_bouton1),
                    Button(bind=bouton2_label, onclick=clic_bouton2),
                ),
                Button("Question suivante", disabled=bouton_suivant_disabled, onclick=clic_suivant),
            ),
            Div(InnerHTML(bind=result_text))
        )
    end

    maj_question(1)
    return app
end

run(ask_mbti_questions_bonito(), port=8000)
