import 'package:flutter/material.dart';
import 'package:neuroway/login.dart'; // ← importe o login.dart
import 'package:neuroway/menuprincipal.dart'; // ← importe o menuprincipal.dart

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  InicioState createState() => InicioState();
}

class InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Conteúdo central — logo + botão
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo neurologo.png
                  Container(
                    width: screenWidth * 0.45,
                    height: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF98B9A6),
                        width: 3,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      'imagem/neurologo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Botão Login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegação direta para o Login
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LOGIN(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98B9A6),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Botão Continuar sem login
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Navegação direta para o Menu Principal, sem login
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Menuprincipal(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF98B9A6),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: Color(0xFF98B9A6), width: 1.5),
                        ),
                      ),
                      child: Text(
                        'Continuar sem login',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Moldura superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: molduraHeight,
              child: Image.asset(
                'imagem/quebrasuperior.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Moldura inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: molduraHeight,
              child: Image.asset(
                'imagem/quebrainferior.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}