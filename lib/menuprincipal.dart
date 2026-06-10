import 'package:flutter/material.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/descricaolocal.dart';
import 'package:neuroway/localizacao.dart';
import 'package:neuroway/favoritos.dart'; 
import 'package:neuroway/peril.dart'; // Importação do seu arquivo de perfil

class Menuprincipal extends StatefulWidget {
  const Menuprincipal({super.key});

  @override
  State<Menuprincipal> createState() => _MenuprincipalState();
}

class _MenuprincipalState extends State<Menuprincipal> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // Controla o ícone ativo na barra inferior

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Conteúdo da sua aba Home
  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const PuzzleHeader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SearchBarWidget(controller: _searchController),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const BarbeariaCard();
                },
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lista de subpáginas. (Garante que nenhuma delas tenha bottomNavigationBar própria)
    final List<Widget> _paginas = [
      _buildHomeContent(), // Index 0: Home
      const Favoritos(),   // Index 1: Tela de Favoritos
      const Agendamentos(), // Index 2: Tela de Agendamentos
      const Perfil(),    // Index 3: Tela de Perfil
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _paginas,
      ),
      // ESTA é a única barra que vai aparecer no app inteiro
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
              _currentIndex = index; // Alterna suavemente entre as telas
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
}

// --- WIDGETS AUXILIARES DE SUPORTE (Mantidos idênticos ao original) ---

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  const SearchBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFD0D3D8), width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18, fontWeight: FontWeight.w400),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(height: 24, width: 1, color: const Color(0xFFB0B3B8)),
          const SizedBox(width: 12),
          const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 24),
          const SizedBox(width: 6),
          const Text('SJC', style: TextStyle(color: Color(0xFF7D828A), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [ 
          Image.network(
            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/0kaf4f8w_expires_30_days.png",
            height: 149,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ],
      ),
    );
  }
}

class BarbeariaCard extends StatelessWidget {
  const BarbeariaCard({super.key});

  @override 
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E2E5), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  height: 90,
                  color: Colors.grey[400],
                  child: const Icon(Icons.store, color: Colors.white, size: 40), 
                ),  
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DescricaoLocalScreen()),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Barbearia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                          Icon(Icons.favorite_border, color: Colors.grey[400], size: 22),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Barbearia desde 2015 com atendimento especializado há 7 anos.\nAmbiente calmo, organizado e silencioso, trazendo conforto aos nossos clientes.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.black87, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocalizacaoScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 14),
                    SizedBox(width: 2),
                    Text('Av. Andrômeda, 1232 - Jardim Satélite', style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}