import 'package:flutter/material.dart';
import 'package:neuroway/login.dart';

// Certifique-se de importar a tela de LOGIN se ela estiver em outro arquivo
// import 'login.dart'; 

class INICIO extends StatefulWidget {
  const INICIO({super.key});
  @override
  INICIOState createState() => INICIOState();
}

class INICIOState extends State<INICIO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 26, left: 25, right: 25),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IntrinsicHeight(
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 419),
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/hasu6z32_expires_30_days.png"),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(bottom: 40), // Reduzi um pouco a margem para o botão não sumir da tela
                                                  width: double.infinity,
                                                  child: const Text(
                                                    "O caminho mais próximo de você.",
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontSize: 24,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                // --- NOVO BOTÃO DE LOGIN SUBSTUINDO A IMAGEM ANTERIOR ---
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center, // Alterado para center para o botão ficar no meio
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            // Certifique-se de que a classe LOGIN() existe no seu projeto
                                                            MaterialPageRoute(builder: (context) => const LOGIN()), 
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF98B9A6),
                                                          foregroundColor: Colors.black,
                                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          elevation: 2,
                                                        ),
                                                        child: const Text(
                                                          "Login",
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // -------------------------------------------------------
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 149,
                                    child: SizedBox(
                                      height: 149,
                                      width: double.infinity,
                                      child: Image.network(
                                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/3bnn2jd1_expires_30_days.png",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ] // Correção visual da árvore de elementos do Stack
                              ),
                            ),
                          ),
                          IntrinsicHeight(
                            child: Container(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 54),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 150,
                                          width: double.infinity,
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/mmm5zn7a_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: IntrinsicHeight(
                                      child: Container(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 117,
                                              height: 63,
                                              child: Image.network(
                                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/fhca1cac_expires_30_days.png",
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}