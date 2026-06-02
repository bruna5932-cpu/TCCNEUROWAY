import 'package:flutter/material.dart';

class BarberiaScreen extends StatefulWidget {
  const BarberiaScreen({super.key});

  @override
  State<BarberiaScreen> createState() => _BarberiaScreenState();
}

class _BarberiaScreenState extends State<BarberiaScreen> {
  int _currentIndex = 0;
  bool _isFavorited = false; 

  @override
  Widget build(BuildContext context) {
    // 1. LISTA DE PÁGINAS DA SUA REFEIÇÃO DE NAVEGAÇÃO
    // Substitua os 'Center' pelas suas páginas reais (Ex: FavoritosPage(), AgendaPage(), etc.)
    final List<Widget> _pages = [
      _buildInicioTab(), // Índice 0: Sua página atual da Barbearia
      const Center(child: Text('Sua Página de Favoritos Aqui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), // Índice 1
      const Center(child: Text('Sua Página de Agenda Aqui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),    // Índice 2
      const Center(child: Text('Sua Página de Perfil Aqui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),    // Índice 3
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // 2. O BODY AGORA MUDA DE ACORDO COm O ÍNDICE SELECIONADO
      body: _pages[_currentIndex],

      // 3. Sua Barra de Navegação Inferior (já atualizando o estado do index)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Alterna entre as páginas da lista acima
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey.shade200,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 28), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month, size: 28), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Perfil'),
        ],
      ),
    );
  }

  // 4. SEU CONTEÚDO ORIGINAL ISOLADO AQUI (Aba Início / Barbearia)
  Widget _buildInicioTab() {
    return Column(
      children: [
        // O TOPO COM A SUA IMAGEM NETWORK
        Image.network(
          "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/0kaf4f8w_expires_30_days.png",
          height: 149,
          width: double.infinity,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 149,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.broken_image, size: 40),
              ),
            );
          },
        ),

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
                            onPressed: () {},
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
    );
  }
} 