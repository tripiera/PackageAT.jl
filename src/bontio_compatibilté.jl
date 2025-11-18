using Bonito
using Markdown
include("types_projet.jl")  # MBTI_QUESTIONS, MBTI_COMPATIBILITIES

const QUESTIONS = [
    ("Quand tu es fatigué(e), tu préfères :", "Sortir voir des amis", "Rester seul(e)", 'E', 'I'),
    ("En soirée, tu :", "Adores parler à plein de monde", "Tu préfères discuter avec une ou deux personnes", 'E', 'I'),
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

function ask_mbti_bonito()
    app = App() do session
        # --- Infos utilisateur ---
        name = TextField("", Dict(:placeholder=>"Nom"))
        firstname = TextField("", Dict(:placeholder=>"Prénom"))
        age = TextField("", Dict(:placeholder=>"Âge"))
        genre = Dropdown(["H"=>"Homme", "F"=>"Femme"], label="Genre")
        orientation = Dropdown(["1"=>"Hétéro", "2"=>"Bi", "3"=>"Gay", "4"=>"Lesbienne", "5"=>"Asexuelle", "6"=>"Pan", "7"=>"Autre"], label="Orientation")
        start_btn = Button("Commencer le test MBTI")
        info_output = Observable{String}("")

        # --- Zone de questionnaire ---
        question_text = Observable{String}("")
        opt1_text = Observable{String}("")
        opt2_text = Observable{String}("")
        progress_text = Observable{String}("")
        result_text = Observable{String}("")
        descr_text = Observable{String}("")

        # --- Boutons ---
        opt1_btn = Button("1")
        opt2_btn = Button("2")
        compat_btns_dynamic = Observable{Vector{Button{String}}}(Vector{Button{String}}())

        # --- État ---
        qidx = Ref(0)
        scores = Dict('E'=>0,'I'=>0,'S'=>0,'N'=>0,'T'=>0,'F'=>0,'J'=>0,'P'=>0)
        tie_letters = Dict{Symbol,Union{Char,Nothing}}(:L1=>nothing, :L2=>nothing, :L3=>nothing, :L4=>nothing)
        phase = Ref(:intro)  # :intro, :questions, :tie_*, :choix_compat, :done

        # --- Fonctions ---
        function update_question!()
            if qidx[] >= 1 && qidx[] <= length(QUESTIONS)
                (q,a1,a2,d1,d2) = QUESTIONS[qidx[]]
                question_text[] = "Question $(qidx[]) / $(length(QUESTIONS)) — $q"
                opt1_text[] = "1. $a1"
                opt2_text[] = "2. $a2"
                progress_text[] = "Progression : $(qidx[]) / $(length(QUESTIONS))"
            else
                handle_end_or_tie!()
            end
        end

        function handle_end_or_tie!()
            # Calcul des lettres MBTI
            tie_letters[:L1] = scores['E'] != scores['I'] ? (scores['E']>scores['I'] ? 'E' : 'I') : nothing
            tie_letters[:L2] = scores['S'] != scores['N'] ? (scores['S']>scores['N'] ? 'S' : 'N') : nothing
            tie_letters[:L3] = scores['T'] != scores['F'] ? (scores['T']>scores['F'] ? 'T' : 'F') : nothing
            tie_letters[:L4] = scores['J'] != scores['P'] ? (scores['J']>scores['P'] ? 'J' : 'P') : nothing

            # Gestion des égalités
            if tie_letters[:L1] === nothing; phase[] = :tie_EI; question_text[] = "Égalité E/I — Choisis 1 ou 2"; return end
            if tie_letters[:L2] === nothing; phase[] = :tie_SN; question_text[] = "Égalité S/N — Choisis 1 ou 2"; return end
            if tie_letters[:L3] === nothing; phase[] = :tie_TF; question_text[] = "Égalité T/F — Choisis 1 ou 2"; return end
            if tie_letters[:L4] === nothing; phase[] = :tie_JP; question_text[] = "Égalité J/P — Choisis 1 ou 2"; return end

            # Tout défini : on passe directement à la phase MBTI + compatibilité
            phase[] = :choix_compat
            mbti = string(tie_letters[:L1], tie_letters[:L2], tie_letters[:L3], tie_letters[:L4])
            session[:mbti] = mbti
            result_text[] = "Votre type MBTI : $mbti"

            # Affichage des questions de préférence MBTI
            if haskey(MBTI_QUESTIONS, mbti)
                descr_text[] = join(["- " * q for q in MBTI_QUESTIONS[mbti]], "\n")
                # Création boutons dynamiques
                compat_btns_dynamic[] = [Button(q) for q in MBTI_QUESTIONS[mbti]]
                for (i, btn) in enumerate(compat_btns_dynamic[])
                    local idx = i
                    on(btn) do _
                        chosen = MBTI_QUESTIONS[mbti][idx]
                        result_text[] = "Votre type MBTI : $mbti\nType compatible choisi : $chosen"
                        phase[] = :done
                    end
                end
            else
                descr_text[] = "Description non disponible."
                compat_btns_dynamic[] = []
            end
        end

        function choose_opt(which::Int)
            if phase[] == :questions
                (q,a1,a2,d1,d2) = QUESTIONS[qidx[]]
                scores[which==1 ? d1 : d2] += 1
                qidx[] += 1
                update_question!()
            elseif phase[] in [:tie_EI, :tie_SN, :tie_TF, :tie_JP]
                # Résolution égalité
                if phase[] == :tie_EI; tie_letters[:L1] = which==1 ? 'E' : 'I'
                elseif phase[] == :tie_SN; tie_letters[:L2] = which==1 ? 'S' : 'N'
                elseif phase[] == :tie_TF; tie_letters[:L3] = which==1 ? 'T' : 'F'
                elseif phase[] == :tie_JP; tie_letters[:L4] = which==1 ? 'J' : 'P'
                end
                handle_end_or_tie!()
            end
        end

        # --- Callbacks ---
        on(opt1_btn) do _; choose_opt(1); end
        on(opt2_btn) do _; choose_opt(2); end
        on(start_btn) do _
            if isempty(name[]) || isempty(firstname[]); info_output[] = "Erreur : nom et prénom requis."; return end
            if isnothing(tryparse(Int, age[])); info_output[] = "Erreur : âge doit être un chiffre."; return end
            qidx[] = 1
            phase[] = :questions
            update_question!()
            info_output[] = "Bonjour $(firstname[]) $(name[]), commence le questionnaire."
        end

        # --- Layout ---
        return DOM.div(
            DOM.div("## Informations", name, firstname, age, genre, orientation, start_btn, info_output),
            DOM.div("## Questionnaire",
                DOM.div(question_text),
                DOM.div(opt1_btn,opt1_text),
                DOM.div(opt2_btn,opt2_text),
                DOM.div(progress_text)
            ),
            DOM.div("## Résultat",
                DOM.div(result_text),
                DOM.div(Markdown.MD(descr_text[])),
                DOM.div(compat_btns_dynamic[])
            )
        )
    end

    return app
end

# --- Lancer le serveur ---
app = ask_mbti_bonito()
server = Bonito.Server(app, "127.0.0.1", 8080)
route!(server, "/" => app)
