import 'package:flutter/material.dart';
import 'package:neuroway/menuprincipal.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({Key? key}) : super(key: key);

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  final List<bool> _isFavorite = [true, true, true];
  final TextEditingController _searchController = TextEditingController();
  String _cidadeSelecionada = 'SJC';
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _allItems = [
      {'index': 0, 'title': 'Barbearia', 'isAvatar': false, 'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500'},
      {'index': 1, 'title': 'Marcos Silva', 'isAvatar': true, 'imageUrl': ''},
      {'index': 2, 'title': 'Barbearia Premium', 'isAvatar': false, 'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500'},
    ];
    _filteredItems = _allItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return (item['title'] as String).toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _abrirSelecaoCidade() {
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
                children: _cidades.map((cidade) {
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: molduraHeight * 1.1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Menuprincipal()),
                          (route) => false,
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F4),
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(color: const Color(0xFFD0D3D8), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearch,
                                decoration: const InputDecoration(
                                  hintText: "Buscar nos favoritos",
                                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            Container(height: 24, width: 1, color: const Color(0xFFB0B3B8)),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _abrirSelecaoCidade,
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 24),
                                  const SizedBox(width: 6),
                                  Text(
                                    _cidadeSelecionada,
                                    style: const TextStyle(color: Color(0xFF7D828A), fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Color(0xFF9E9E9E), size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum resultado encontrado.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: _filteredItems.map((item) {
                          return _buildBarberCard(
                            index: item['index'],
                            title: item['title'],
                            isAvatar: item['isAvatar'],
                            imageUrl: item['imageUrl'],
                          );
                        }).toList(),
                      ),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _buildBarberCard({
    required int index,
    required String title,
    required bool isAvatar,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE0E2E5), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                if (isAvatar)
                  Container(
                    width: 90,
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 55, color: Colors.white),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isFavorite[index] ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite[index] ? Colors.red : Colors.black45,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite[index] = !_isFavorite[index];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Barbearia desde 2015 com atendimento especializado há 7 anos.\nAmbiente calmo, organizado e silencioso, trazendo conforto aos nossos clientes.",
                    style: TextStyle(fontSize: 10, color: Colors.black87, height: 1.2),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.red, size: 14),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          "Av. Andrômeda, 1232 - Jardim Satélite",
                          style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}