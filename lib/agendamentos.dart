import 'package:flutter/material.dart';
import 'package:neuroway/menuprincipal.dart';

class Agendamentos extends StatefulWidget {
  const Agendamentos({super.key});

  @override
  State<Agendamentos> createState() => _AgendamentosState();
}

class _AgendamentosState extends State<Agendamentos> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    // Retiramos o Scaffold e o bottomNavigationBar para não duplicar com o MenuPrincipal
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: molduraHeight * 0.75),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOPO (Seta voltar e Título)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Menuprincipal()),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Expanded(
                              child: Text(
                                "Agendamentos",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // CARD AGENDAMENTO
                        GestureDetector(
                          onTap: () {
                            debugPrint("Card clicado");
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 3,
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // LADO ESQUERDO (Data e Hora)
                                  const Expanded(
                                    flex: 4,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 70,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                          "09/05 - Terça",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "12:30",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divisória Dinâmica
                                  const VerticalDivider(
                                    color: Colors.black54,
                                    thickness: 2,
                                    width: 20,
                                  ),

                                  // LADO DIREITO (Informações e Botão)
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Barbearia",
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Barbearia desde 2015 com atendimento especializado há 7 anos.",
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.3,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Ambiente calmo, organizado e silencioso, trazendo conforto aos nossos clientes.",
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.3,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    "Av. Andrômeda, 1292 - Jardim Satélite",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              debugPrint("Cancelar agendamento");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                            ),
                                            child: const Text(
                                              "Cancelar",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
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
                ],
              ),
            ),
          ),
        ),

        // --- Moldura superior ---
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
      ],
    );
  }
}