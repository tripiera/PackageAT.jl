using Bonito
using Markdown

include("types_projet.jl")  # Utilisateur, MBTI_COMPATIBILITIES, MBTI_QUESTIONS

const QUESTIONS = [
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

function ask_mbti_questions_bonito()
    app = App() do session

        # --- Inputs ---
        name = TextField("", Dict(:placeholder=>"Nom"))
        firstname = TextField("", Dict(:placeholder=>"Prénom"))
        age = TextField("", Dict(:placeholder=>"Âge"))
        genre = Dropdown(["H"=>"Homme", "F"=>"Femme"], label="Genre")
        orientation = Dropdown(["1"=>"Hétéro", "2"=>"Bi", "3"=>"Gay", "4"=>"Lesbienne", "5"=>"Asexuelle", "6"=>"Pan", "7"=>"Autre"], label="Orientation")
        start_btn = Button("Commencer le test MBTI")
        info = Observable{Markdown.MD}(md"")

        # --- Question UI ---
        question_div = Observable{Markdown.MD}(md"")
        opt1_label = Observable{Markdown.MD}(md"")
        opt2_label = Observable{Markdown.MD}(md"")
        opt1_btn = Button("1")
        opt2_btn = Button("2")
        progress = Observable{Markdown.MD}(md"")

        # --- Résultat MBTI ---
        result = Observable{Markdown.MD}(md"")
        descr_compat = Observable{Markdown.MD}(md"")

        # --- Compatibilité ---
        compat_btns = [
            Button("Choix 1"),
            Button("Choix 2"),
            Button("Choix 3")
        ]

        # --- état ---
        qidx = Ref(0)
        scores = Dict('E'=>0,'I'=>0,'S'=>0,'N'=>0,'T'=>0,'F'=>0,'J'=>0,'P'=>0)
        tie_letters = Dict{Symbol,Char}()
        phase = Ref(:intro)  # :intro, :questions, :tie, :compat, :choix_compat, :done

        # --- Fonctions utilitaires ---
        function reset!()
            for k in keys(scores); scores[k]=0; end
            empty!(tie_letters)
            qidx[] = 0
            phase[] = :intro
            set_markdown!(question_div, md"")
            set_markdown!(opt1_label, md"")
            set_markdown!(opt2_label, md"")
            set_markdown!(progress, md"")
            set_markdown!(result, md"")
            set_markdown!(descr_compat, md"")
        end

        function update_question_ui!()
            if qidx[] >= 1 && qidx[] <= length(QUESTIONS)
                (q,a1,a2,d1,d2) = QUESTIONS[qidx[]]
                set_markdown!(question_div, md"**Question $(qidx[]) / $(length(QUESTIONS))** — $q")
                set_markdown!(opt1_label, md"$a1")
                set_markdown!(opt2_label, md"$a2")
                set_markdown!(progress, md"Progression : $(qidx[]) / $(length(QUESTIONS))")
            else
                set_markdown!(question_div, md"")
                set_markdown!(opt1_label, md"")
                set_markdown!(opt2_label, md"")
                set_markdown!(progress, md"")
            end
        end

        function handle_end_or_tie!()
            # Départage égalités
            tie_letters[:L1] = scores['E'] != scores['I'] ? (scores['E']>scores['I'] ? 'E' : 'I') : nothing
            tie_letters[:L2] = scores['S'] != scores['N'] ? (scores['S']>scores['N'] ? 'S' : 'N') : nothing
            tie_letters[:L3] = scores['T'] != scores['F'] ? (scores['T']>scores['F'] ? 'T' : 'F') : nothing
            tie_letters[:L4] = scores['J'] != scores['P'] ? (scores['J']>scores['P'] ? 'J' : 'P') : nothing

            # Gérer égalités
            if tie_letters[:L1] === nothing; phase[] = :tie_EI; set_markdown!(question_div, md"Egalité E/I — Choisis 1 ou 2"); return; end
            if tie_letters[:L2] === nothing; phase[] = :tie_SN; set_markdown!(question_div, md"Egalité S/N — Choisis 1 ou 2"); return; end
            if tie_letters[:L3] === nothing; phase[] = :tie_TF; set_markdown!(question_div, md"Egalité T/F — Choisis 1 ou 2"); return; end
            if tie_letters[:L4] === nothing; phase[] = :tie_JP; set_markdown!(question_div, md"Egalité J/P — Choisis 1 ou 2"); return; end

            # Tout défini -> affichage MBTI
            phase[] = :compat
            mbti = string(tie_letters[:L1], tie_letters[:L2], tie_letters[:L3], tie_letters[:L4])
            session[:mbti] = mbti
            set_markdown!(result, md"### Ton MBTI : **$mbti**")
            if haskey(MBTI_QUESTIONS, mbti)
                s = "**Descriptions (aide au choix) :**\n"
                for (i,d) in enumerate(MBTI_QUESTIONS[mbti])
                    s *= "\n- $(i)) $d"
                end
                set_markdown!(descr_compat, md"$s")
            else
                set_markdown!(descr_compat, md"Descriptions non disponibles.")
            end
        end

        function choose_opt(which::Int)
            if phase[] == :questions
                (q,a1,a2,d1,d2) = QUESTIONS[qidx[]]
                scores[which==1 ? d1 : d2] += 1
                qidx[] += 1
                if qidx[] <= length(QUESTIONS)
                    update_question_ui!()
                else
                    handle_end_or_tie!()
                end
            elseif phase[] in [:tie_EI, :tie_SN, :tie_TF, :tie_JP]
                if phase[] == :tie_EI; tie_letters[:L1] = which==1 ? 'E' : 'I'
                elseif phase[] == :tie_SN; tie_letters[:L2] = which==1 ? 'S' : 'N'
                elseif phase[] == :tie_TF; tie_letters[:L3] = which==1 ? 'T' : 'F'
                elseif phase[] == :tie_JP; tie_letters[:L4] = which==1 ? 'J' : 'P'
                end
                handle_end_or_tie!()
            elseif phase[] == :choix_compat
                mbti = session[:mbti]
                compatibles = MBTI_COMPATIBILITIES[mbti]
                chosen = compatibles[which]
                set_markdown!(result, md"### Ton MBTI : $mbti\n**MBTI compatible choisi :** $chosen")
                phase[] = :done
            end
        end

        # --- Liens boutons ---
        on(opt1_btn) do _; choose_opt(1); end
        on(opt2_btn) do _; choose_opt(2); end
        for (i, btn) in enumerate(compat_btns)
            on(btn) do _; choose_opt(i); end
        end

        on(start_btn) do _
            if isempty(name[]) || isempty(firstname[]); set_markdown!(info, md"Erreur: nom et prénom requis."); return; end
            if isnothing(tryparse(Int, age[])); set_markdown!(info, md"Erreur: âge doit être un chiffre."); return; end
            qidx[] = 1
            phase[] = :questions
            update_question_ui!()
            set_markdown!(info, md"Bonjour **$(firstname[]) $(name[])**, commence le questionnaire.")
        end

        # --- Layout ---
        return DOM.div(
            md"# Test MBTI",
            DOM.div(md"## Informations", name, firstname, age, genre, orientation, start_btn, info),
            DOM.div(md"## Questionnaire", question_div, DOM.div(opt1_btn,opt1_label), DOM.div(opt2_btn,opt2_label), progress),
            DOM.div(md"## Résultat", result, descr_compat, DOM.div(compat_btns...))
        )
    end

    return app
end

app = ask_mbti_questions_bonito()

# Ouvre dans le navigateur
Bonito.HTTPServer.serve(app; host="127.0.0.1", port=8000)
