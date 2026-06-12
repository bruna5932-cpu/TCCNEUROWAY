import 'package:flutter/material.dart';
import 'menuprincipal.dart';
import 'favoritos.dart';
import 'agendamentos.dart';
import 'peril.dart';

class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key});

  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  int _currentIndex = 0;
  bool _isFavorited = false; 

  @override
  Widget build(BuildContext context) {
    // 1. LISTA DE PÁGINAS DA SUA REFEIÇÃO DE NAVEGAÇÃO
    // Substitua os 'Center' pelas suas páginas reais (Ex: FavoritosPage(), AgendaPage(), etc.)
    final List<Widget> _pages = [
      _buildInicioTab(), // Índice 0: Sua página atual da Barbearia
      const Favoritos(), // Índice 1
      const Agendamentos(),    // Índice 2
      const Perfil(),    // Índice 3
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // 2. O BODY AGORA MUDA DE ACORDO COm O ÍNDICE SELECIONADO
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF9E9E9E),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Isso muda a tela dinamicamente
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 28),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month, size: 28),
              label: 'Agenda',
              activeIcon: Icon(Icons.calendar_month, size: 28),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // 4. SEU CONTEÚDO ORIGINAL ISOLADO AQUI (Aba Início / Barbearia)
  Widget _buildInicioTab() {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    return Stack(
      children: [
        Column(
          children: [
            // Espaço reservado para a moldura superior não cobrir o conteúdo
            SizedBox(height: molduraHeight * 0.75),

            // Conteúdo Rolável protegido pelo SafeArea
            Expanded(
              child: SafeArea(
                top: false, 
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Título "Barbearia" com botão voltar e coração
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.arrow_back_ios, size: 28),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Barbearia',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              _isFavorited ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorited ? Colors.red : Colors.black,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorited = !_isFavorited;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Link do Endereço
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Av. Andrômeda, 1234 - Jardim Satélite, São José dos Campos - SP, 12230-001',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Container do Mapa
                      Container(
                        height: 380,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            const Center(
                              child: Icon(Icons.location_on, color: Colors.red, size: 45),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.white.withOpacity(0.8),
                                child: const Row(
                                  children: [
                                    Icon(Icons.map, size: 14, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text('Google Maps', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botão "Agende seu horário!"
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Agende seu horário!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
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