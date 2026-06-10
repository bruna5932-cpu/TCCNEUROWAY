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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Imagem de Topo
              Image.asset(
                'imagem/quebrasuperior.png', // Se o seu caminho usar assets, mude para 'assets/imagem/quebrasuperior.png'
                width: double.infinity,
                height: 150, 
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) {
                  // Caso a imagem falhe, isso mostrará um aviso visual em vez de sumir
                  return const SizedBox(
                    height: 150,
                    child: Center(child: Text('Erro ao carregar imagem superior', style: TextStyle(color: Colors.red))),
                  );
                },
              ),

              const SizedBox(height: 20),
              
              // Área Central
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Image.asset(
                      "imagem/neurologo.png",
                      height: 250, 
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 25), 
                    
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
              
              const SizedBox(height: 40),
              
              // Área de Cadastro / Continuar sem conta
              Column(
                children: [
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Imagem Inferior
                  Image.asset(
                    "imagem/quebrainferior.png",
                    width: double.infinity,
                    height: 300, 
                    fit: BoxFit.fill, 
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: Text('Erro ao carregar imagem inferior', style: TextStyle(color: Colors.red))),
                      );
                    },
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