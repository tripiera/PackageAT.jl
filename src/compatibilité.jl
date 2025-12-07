using DataFrames
using CSV
include("types_projet.jl")
#anaide
#pour créer ma fonction de compatibilité

# récupérations des données utilisateurs via machine pour le questionnaire
# nom, prénom, age, orientation sexuelle, mbti
# parmis les 3 types compatibles ,lequel choisir???

function ask_mbti_questions()
    ###info pour utilisateurs 
    println("Quel est ton nom?")
    print("> ")
    reponse1 = readline()
    
    println("Quel est ton prénom?")
    print("> ")
    reponse2 = readline()
    
    println("Quel est ton âge? ( en chiffre )")
    print("> ")
    reponse3 = readline()
    # je vais convertir l'age(int) en string car comme j'utilise readline() qui est pour les string
    # lorsque je définie utilisateur à la ligne 217 ca ne fonctionne pas. 
    while isnothing(tryparse(Int, reponse3))
        println("Tape en chiffre.")
        print("> ")
        reponse3 = readline()
    end
    reponse3 = parse(Int, reponse3)


    
    println("Es-tu une femme ou un homme (tape H ou F) ?")
    reponse4 = ""
    while !(reponse4 in ["H", "F"])
        print("> ")
        reponse4 = readline()
        if !(reponse4 in ["H", "F"])
            println("Réponse invalide, tape H ou F.")
        end
    end
    
    println("est-tu Hétérosexuel(1), Bisexuel(2), Gay(3), Lesbienne(4), Asexuelle(5), Pansexuel(6) ou Autre (7)?")
    print("> ")
    reponse5 = ""
    while !(reponse5 in ["1","2","3","4","5","6","7"])
        print("> ")
        reponse5 = readline()
        if !(reponse5 in ["1","2","3","4","5","6","7"])
            println("Réponse invalide, tape un chiffre entre 1 et 7.")
        end
    end


    if reponse5 =="1"
        reponse5= "Hétéro"
    elseif reponse5 == "2"
        reponse5= "Bi"
    elseif reponse5 == "3"
        reponse5 = "Gay"
    elseif reponse5 == "4"
        reponse5= "Lesbienne"
    elseif reponse5 == "5"
        reponse5 ="Asexuelle"
    elseif reponse5 =="6"
        reponse5 = "Pan"
    elseif reponse5 == "7"
        reponse5 = "Autre"
    
    end  





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

    utili = Utilisateur(reponse2,reponse1,reponse4,reponse3,reponse5, mbti  )
    println("\nFiche utilisateur :")
    println("Nom : $(utili.lastname)")
    println("Prénom : $(utili.firstname)")
    println("Genre : $(utili.genre)")
    println("Âge : $(utili.age)")
    println("Orientation : $(utili.orientation)")
    println("Type MBTI : $(utili.mbti)")

    
    #######
    project_root = dirname(@__DIR__)
    filepath = joinpath(project_root, "exemple", "resultcompabilite_typesmbti")
    mkpath(filepath)

    filename  = joinpath(filepath, "mbti_result.txt")
    


    open(filename, "w") do f
        write(f, mbti)
    end
    println(" Votre résultat MBTI ($mbti) a été enregistré dans '$filename'.")

    ####maintenant qu'on a notre mbti  je vais regarder avec qui il est compatible.
    ####  j'ai deja definie avec qui chaque mbti est compatible dans mon dictionnaire qui se trouve dans types_projet.jl
    #### chaqque mbti est compatible avec 3 autres.
    #### je vais donc rajouter une question à l'utilisateur si il a des préferences en fonction des mbti compatibles
    compatibles = MBTI_COMPATIBILITIES[mbti]
    questions_descriptives = MBTI_QUESTIONS[mbti]

    for (i, q) in enumerate(questions_descriptives)
        println("$i) $q")
    end

    println("Tape le numéro correspondant à ton choix (1, 2 ou 3), ou 0 pour laisser le hasard choisir.")
    choice = ""
    while !(choice in ["0","1","2","3"])
        print("> ")
        choice = readline()
    end

     
    if choice == "0"
        choice_compatibility=compatibles[rand(1:3)]
    else
        choice_compatibility= compatibles[parse(Int, choice)]  # exemple : choice = readline()      # l'utilisateur tape "2"
                                                                #num = parse(Int, choice) # convertit "2" en 2
    end
    println("\nTu pourrais envisager une personne de type MBTI : $choice_compatibility")


   
    filename2 = joinpath(filepath, "mbti_star_result.txt")

    open(filename2, "w") do f
        write(f, choice_compatibility)
    end
    println(" Votre résultat MBTI compatible avec vous ( $choice_compatibility) a été enregistré dans '$filename2'.")

    return mbti, choice_compatibility
    
end



