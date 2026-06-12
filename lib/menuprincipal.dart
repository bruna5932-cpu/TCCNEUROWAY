import 'package:flutter/material.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/descricaolocal.dart';
import 'package:neuroway/localizacao.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/peril.dart';

class Menuprincipal extends StatefulWidget {
  const Menuprincipal({super.key});

  @override
  State<Menuprincipal> createState() => _MenuprincipalState();
}

class _MenuprincipalState extends State<Menuprincipal> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  String _cidadeSelecionada = 'SJC';

  void _abrirSelecaoCidade() {
    final TextEditingController _cidadeController = TextEditingController();
    final List<Map<String, String>> _cidades = [
      {'nome': 'São José dos Campos', 'sigla': 'SJC'},
      {'nome': 'São Paulo', 'sigla': 'SP'},
      {'nome': 'Campinas', 'sigla': 'CPS'},
      {'nome': 'Taubaté', 'sigla': 'TBT'},
      {'nome': 'Jacareí', 'sigla': 'JCR'},
    ];
    String? _cidadeEscolhida;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Selecione sua cidade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._cidades.map((cidade) {
                    final bool selecionada = _cidadeEscolhida == cidade['sigla'];
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          _cidadeEscolhida = cidade['sigla'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selecionada ? const Color(0xFF98B9A6) : const Color(0xFFF3F3F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selecionada ? const Color(0xFF98B9A6) : const Color(0xFFD0D3D8),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cidade['nome']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: selecionada ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              cidade['sigla']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: selecionada ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: _cidadeEscolhida == null
                      ? null
                      : () {
                          setState(() {
                            _cidadeSelecionada = _cidadeEscolhida!;
                          });
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98B9A6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  child: SearchBarWidget(
                    controller: _searchController,
                    cidade: _cidadeSelecionada,
                    onCidadeTap: _abrirSelecaoCidade,
                  ),
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
    final List<Widget> _paginas = [
      _buildHomeContent(),
      const Favoritos(),
      const Agendamentos(),
      const Perfil(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _paginas,
      ),
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
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 28), label: 'Favoritos'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month, size: 28), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String cidade;
  final VoidCallback onCidadeTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.cidade,
    required this.onCidadeTap,
  });

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
          GestureDetector(
            onTap: onCidadeTap,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 24),
                const SizedBox(width: 6),
                Text(
                  cidade,
                  style: const TextStyle(color: Color(0xFF7D828A), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF9E9E9E), size: 20),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    return SizedBox(
      height: molduraHeight,
      width: double.infinity,
      child: Image.asset(
        'imagem/quebrasuperior.png',
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
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
          ),
        ],
      ),
    );
  }
}