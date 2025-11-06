using Bonito

app = App() do session
    # Widgets
    name = TextField("", Dict(:placeholder => "Nom"))
    firstname = TextField("", Dict(:placeholder => "Prénom"))
    age = TextField("", Dict(:placeholder => "Âge (en chiffres)"))
    genre = Dropdown(["H" => "Homme", "F" => "Femme"], label="Genre")
    submit_btn = Button("Valider")
    output = DOM.div("")  # Zone pour le message

    # Callback sur le bouton
    on(submit_btn) do _
        # Simple validation pour l'âge
        if isnumeric(age[])
            output[] = "Bonjour $(firstname[]) $(name[]), âge $(age[]) ans, genre $(genre[]) !"
        else
            output[] = "Erreur : L'âge doit être un nombre."
        end
    end

    # Retourne la mise en page
    return DOM.div(
        md"## Formulaire utilisateur",
        name,
        firstname,
        age,
        genre,
        submit_btn,
        output
    )
end

# Serveur
server = Bonito.Server(app, "127.0.0.1", 8080)
route!(server, "/" => app)
