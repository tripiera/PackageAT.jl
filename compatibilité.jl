using DataFrames
using CSV

#pour créer ma fonction de compatibilité

# récupérations des données utilisateurs via machine pour le questionnaire
# nom, prénom, age, orientation sexuelle, mbti(questionnaires ou non)
# parmis les 3 types compatibles ,lequel choisir???

function ask_mbti_questions()
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
#j'initialise toutes lettres avec un compter = 0
#en fonction des réponses aux questions, je vais compter combien de fois chaque lettres apparait et je choisirais celle qui à le compteur le plus élevé
    scores = Dict('E'=>0, 'I'=>0, 'S'=>0, 'N'=>0, 'T'=>0, 'F'=>0, 'J'=>0, 'P'=>0)

    println("Test MBTI - Réponds en tapant 1 ou 2")
    println("---------------------------------------")


    for (i, (question, opt1, opt2, dim1, dim2)) in enumerate(questions)
        println("\nQuestion $i : $question")#println = pas besoin de faire \n
        println("1) $opt1")
        println("2) $opt2")
        print("> ")
        choice = ""
        while choice != "1" && choice != "2"
            print("> ")
            choice = readline()
            if choice != "1" && choice != "2"
                println(" Réponse invalide, tape 1 ou 2.")
            end
        end
        if choice == "1"
            scores[dim1] += 1
        else
            scores[dim2] += 1
        end
    end


# Calcul du type MBTI final avec gestion des égalités/ inégalités
# E|I
    if scores['E'] > scores['I']
        lettre1 = 'E'
    elseif scores['I'] > scores['E']
        lettre1 = 'I'
    else
        println("\n Égalité entre E et I. Question de départage :")
        println("1) Tu trouves ton énergie en parlant aux autres (E)")
        println("2) Tu trouves ton énergie en étant seul(e) (I)")
        print("> ")
        choice = ""
        while choice != "1" && choice != "2"
            choice = readline()
            if choice != "1" && choice != "2"
                println("Réponse invalide, tape 1 ou 2.")
            end
        end
        lettre1 = (choice == "1") ? 'E' : 'I'
    end


#S| N
    if scores['S'] > scores['N']
        lettre2 = 'S'
    elseif scores['N'] > scores['S']
        lettre2 = 'N'
    else
        println("\n Égalité entre S et N. Question de départage :")
        println("1) Tu fais confiance à ce que tu peux observer (S)")
        println("2) Tu fais confiance à ton intuition et ton imagination (N)")
        print("> ")
        choice = ""
        while choice != "1" && choice != "2"
            choice = readline()
            if choice != "1" && choice != "2"
                println("Réponse invalide, tape 1 ou 2.")
            end
        end
        lettre2 = (choice == "1") ? 'S' : 'N'
    end


 # T|F
    if scores['T'] > scores['F']
        lettre3 = 'T'
    elseif scores['F'] > scores['T']
        lettre3 = 'F'
    else
        println("\n Égalité entre T et F. Question de départage :")
        println("1) Tu décides selon la logique et les faits (T)")
        println("2) Tu décides selon les émotions et les valeurs (F)")
        print("> ")
        choice = ""
        while choice != "1" && choice != "2"
            choice = readline()
            if choice != "1" && choice != "2"
                println(" Réponse invalide, tape 1 ou 2.")
            end
        end
        lettre3 = (choice == "1") ? 'T' : 'F'
    end


    # JP
    if scores['J'] > scores['P']
        lettre4 = 'J'
    elseif scores['P'] > scores['J']
        lettre4 = 'P'
    else
        println("\n Égalité entre J et P. Question de départage :")
        println("1) Tu préfères planifier et organiser (J)")
        println("2) Tu préfères improviser et rester flexible (P)")
        print("> ")
        choice = ""
        while choice != "1" && choice != "2"
            choice = readline()
            if choice != "1" && choice != "2"
                println("s Réponse invalide, tape 1 ou 2.")
            end
        end
        lettre4 = (choice == "1") ? 'J' : 'P'
    end


    
    mbti = string(lettre1, lettre2, lettre3, lettre4)
    println("\n Ton type MBTI est  : $mbti ") 

    filename = joinpath(pwd(), "mbti_result.txt")
    open(filename, "w") do f
        write(f, mbti)
    end
    println(" Votre résultat MBTI ($mbti) a été enregistré dans '$filename'.")

    ####maintenant qu'on a notre mbti  je vais regarder avec qui il est compatible.
    ####  j'ai deja definie avec qui chaque mbti est compatible dans mon dictionnaire qui se trouve dans types_projet.jl
    #### chaqque mbti est compatible avec 3 autres.
    #### je vais donc rajouter une question à l'utilisateur si il a des préferences en fonction des mbti compatibles


    


    return mbti
    
end



