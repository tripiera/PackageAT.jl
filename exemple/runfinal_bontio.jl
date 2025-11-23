using PackageAT  

app = ask_mbti_bonito2()
server = Bonito.Server(app, "127.0.0.1", 8080)
route!(server, "/" => app)