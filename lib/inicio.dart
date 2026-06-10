import 'package:flutter/material.dart';
import 'package:neuroway/menuprincipal.dart';
import 'package:neuroway/login.dart';

class INICIO extends StatefulWidget {
  const INICIO({super.key});
  @override
  INICIOState createState() => INICIOState();
}

class INICIOState extends State<INICIO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // SingleChildScrollView deve ser o pai direto quando o conteúdo pode ser maior que a tela
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Imagem de Topo
              Image.file(
                image: Image.file("assets/quebrasuperior.png"),
                width: double.infinity,
                height: 150,
                fit: BoxFit.fill,
              ),

              const SizedBox(height: 20),
              // Área Central com a Imagem de Fundo e Texto
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Alterado de NetworkImage para AssetImage
                      image: AssetImage("assets/neurologo.png"), 
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Column(
                    // ... resto do seu código igual
                  children: [
                    const SizedBox(height: 350), // Espaçamento para o texto ficar abaixo da arte da imagem
                    const Text(
                      "O caminho mais próximo de você.",
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // Botão de Login
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LOGIN()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98B9A6),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Área de Cadastro de Empresa
              Column(
                children: [
                  // Usamos o InkWell para dar o efeito de clique (ripple)
                  // ou GestureDetector se preferir algo mais simples.
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Menuprincipal()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Continuar sem conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                        ),
                      ),
                    ),
                  ),
                  Image(
                    image: AssetImage("imagem/quebrainferior.png"),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}