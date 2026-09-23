import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/descricaolocal.dart';
import 'package:neuroway/localizacao.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/peril.dart';

class Menuprincipal extends StatefulWidget {
  final int initialIndex;

  const Menuprincipal({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<Menuprincipal> createState() => _MenuprincipalState();
}

class _MenuprincipalState extends State<Menuprincipal> {
  final TextEditingController _searchController =
      TextEditingController();

  late int _currentIndex;

  String _cidadeSelecionada = 'SJC';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    if (_currentIndex < 0 || _currentIndex > 3) {
      _currentIndex = 0;
    }
  }

  void _abrirSelecaoCidade() {
    final List<Map<String, String>> cidades = [
      {
        'nome': 'São José dos Campos',
        'sigla': 'SJC',
      },
      {
        'nome': 'São Paulo',
        'sigla': 'SP',
      },
      {
        'nome': 'Campinas',
        'sigla': 'CPS',
      },
      {
        'nome': 'Taubaté',
        'sigla': 'TBT',
      },
      {
        'nome': 'Jacareí',
        'sigla': 'JCR',
      },
    ];

    String? cidadeEscolhida;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Selecione sua cidade',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: cidades.map((cidade) {
                  final bool selecionada =
                      cidadeEscolhida == cidade['sigla'];

                  return GestureDetector(
                    onTap: () {
                      setStateDialog(() {
                        cidadeEscolhida =
                            cidade['sigla'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selecionada
                            ? const Color(0xFF98B9A6)
                            : const Color(0xFFF3F3F4),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: selecionada
                              ? const Color(0xFF98B9A6)
                              : const Color(0xFFD0D3D8),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cidade['nome']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w500,
                              color: selecionada
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            cidade['sigla']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                              color: selecionada
                                  ? Colors.white70
                                  : Colors.grey,
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: cidadeEscolhida == null
                      ? null
                      : () {
                          setState(() {
                            _cidadeSelecionada =
                                cidadeEscolhida!;
                          });

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF98B9A6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: SearchBarWidget(
                    controller: _searchController,
                    cidade: _cidadeSelecionada,
                    onCidadeTap:
                        _abrirSelecaoCidade,
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('empresas')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 50,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF98B9A6),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'Não foi possível carregar as empresas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 40,
                    ),
                    child: Center(
                      child: Text(
                        'Nenhuma empresa cadastrada.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final empresas =
                  snapshot.data!.docs.where((empresa) {
                final dados = empresa.data();

                final nome =
                    (dados['nome'] ?? '')
                        .toString()
                        .toLowerCase();

                final categoria =
                    (dados['categoria'] ?? '')
                        .toString()
                        .toLowerCase();

                final descricao =
                    (dados['descricao'] ?? '')
                        .toString()
                        .toLowerCase();

                final endereco =
                    (dados['endereco'] ?? '')
                        .toString()
                        .toLowerCase();

                final busca =
                    _searchQuery
                        .toLowerCase()
                        .trim();

                if (busca.isEmpty) {
                  return true;
                }

                return nome.contains(busca) ||
                    categoria.contains(busca) ||
                    descricao.contains(busca) ||
                    endereco.contains(busca);
              }).toList();

              if (empresas.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 40,
                    ),
                    child: Center(
                      child: Text(
                        'Nenhum resultado encontrado.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                sliver: SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final empresa =
                          empresas[index];

                      return BarbeariaCard(
                        empresa: empresa,
                      );
                    },
                    childCount:
                        empresas.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      _buildHomeContent(),
      const Favoritos(),
      const Agendamentos(),
      const Perfil(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      body: IndexedStack(
        index: _currentIndex,
        children: paginas,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor:
              Color(0xFF9E9E9E),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_filled,
                size: 28,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                size: 28,
              ),
              label: 'Favoritos',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_month,
                size: 28,
              ),
              label: 'Agenda',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 28,
              ),
              label: 'Perfil',
            ),
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
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.cidade,
    required this.onCidadeTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius:
            BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFFD0D3D8),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          const Icon(
            Icons.search,
            color: Color(0xFF9E9E9E),
            size: 26,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration:
                  const InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFB0B3B8),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onCidadeTap,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF9E9E9E),
                  size: 24,
                ),

                const SizedBox(width: 6),

                Text(
                  cidade,
                  style: const TextStyle(
                    color: Color(0xFF7D828A),
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
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
    final screenHeight =
        MediaQuery.of(context).size.height;

    final molduraHeight =
        screenHeight * 0.15;

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
  final QueryDocumentSnapshot<
      Map<String, dynamic>> empresa;

  const BarbeariaCard({
    super.key,
    required this.empresa,
  });

  String _idFavorito() {
    return 'empresa_${empresa.id}';
  }

  Future<void> _alternarFavorito() async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final referencia = FirebaseFirestore
        .instance
        .collection('favoritos')
        .doc(
          '${usuario.uid}_${_idFavorito()}',
        );

    final favorito =
        await referencia.get();

    if (favorito.exists) {
      await referencia.delete();
      return;
    }

    final dados = empresa.data();

    final String nome =
        (dados['nome'] ?? 'Empresa')
            .toString();

    final String categoria =
        (dados['categoria'] ?? '')
            .toString();

    final String descricao =
        (dados['descricao'] ?? '')
            .toString();

    final String endereco =
        (dados['endereco'] ?? '')
            .toString();

    String foto = '';

    final fotos = dados['fotos'];

    if (fotos is List &&
        fotos.isNotEmpty) {
      final primeiraFoto = fotos.first;

      if (primeiraFoto is String &&
          primeiraFoto.trim().isNotEmpty) {
        foto = primeiraFoto;
      }
    }

    await referencia.set({
      'usuarioId': usuario.uid,
      'tipo': 'empresa',
      'itemId': empresa.id,
      'empresaId': empresa.id,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'endereco': endereco,
      'foto': foto,
      'criadoEm':
          FieldValue.serverTimestamp(),
    });
  }

  IconData _iconeEstrela(
    double media,
    int numero,
  ) {
    if (media >= numero) {
      return Icons.star;
    }

    if (media >= numero - 0.5) {
      return Icons.star_half;
    }

    return Icons.star_border;
  }

  Widget _buildAvaliacao(
    Map<String, dynamic> dados,
  ) {
    final dynamic mediaRaw =
        dados['mediaAvaliacao'];

    final dynamic quantidadeRaw =
        dados['quantidadeAvaliacoes'];

    double media = 0.0;
    int quantidade = 0;

    if (mediaRaw is num) {
      media = mediaRaw.toDouble();
    } else if (mediaRaw is String) {
      media =
          double.tryParse(mediaRaw) ?? 0.0;
    }

    if (quantidadeRaw is num) {
      quantidade =
          quantidadeRaw.toInt();
    } else if (quantidadeRaw is String) {
      quantidade =
          int.tryParse(quantidadeRaw) ?? 0;
    }

    if (media < 0) {
      media = 0;
    }

    if (media > 5) {
      media = 5;
    }

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) {
              final numero = index + 1;

              return Icon(
                _iconeEstrela(
                  media,
                  numero,
                ),
                color: quantidade > 0
                    ? Colors.amber
                    : Colors.grey[400],
                size: 20,
              );
            },
          ),
        ),

        const SizedBox(width: 5),

        if (quantidade > 0)
          Text(
            '${media.toStringAsFixed(1).replaceAll('.', ',')} '
            '(${quantidade})',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontWeight:
                  FontWeight.w500,
            ),
          )
        else
          const Text(
            'Sem avaliações',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dados = empresa.data();

    final String nome =
        (dados['nome'] ?? 'Empresa')
            .toString();

    final String categoria =
        (dados['categoria'] ?? '')
            .toString();

    final String descricao =
        (dados['descricao'] ??
                'Sem descrição cadastrada.')
            .toString();

    final String endereco =
        (dados['endereco'] ??
                'Endereço não informado.')
            .toString();

    final dynamic fotos =
        dados['fotos'];

    String? fotoUrl;

    if (fotos is List &&
        fotos.isNotEmpty) {
      final primeiraFoto =
          fotos.first;

      if (primeiraFoto is String &&
          primeiraFoto.trim().isNotEmpty) {
        fotoUrl = primeiraFoto;
      }
    }

    final usuario =
        FirebaseAuth.instance.currentUser;

    Widget conteudoCoracao;

    if (usuario == null) {
      conteudoCoracao = const Icon(
        Icons.favorite_border,
        color: Colors.grey,
        size: 24,
      );
    } else {
      conteudoCoracao = StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream: FirebaseFirestore
            .instance
            .collection('favoritos')
            .doc(
              '${usuario.uid}_${_idFavorito()}',
            )
            .snapshots(),
        builder: (context, snapshot) {
          final favorito =
              snapshot.data?.exists ??
                  false;

          return Icon(
            favorito
                ? Icons.favorite
                : Icons.favorite_border,
            color: favorito
                ? Colors.red
                : Colors.grey[400],
            size: 24,
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E2E5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  height: 90,
                  color: Colors.grey[400],
                  child: fotoUrl != null
                      ? Image.network(
                          fotoUrl,
                          width: 110,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 40,
                            );
                          },
                        )
                      : const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DescricaoLocalScreen(
                                    empresaId:
                                        empresa.id,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              nome,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        GestureDetector(
                          onTap:
                              _alternarFavorito,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              4,
                            ),
                            child:
                                conteudoCoracao,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    if (categoria.isNotEmpty)
                      Text(
                        categoria,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              Color(0xFF555555),
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                    const SizedBox(height: 3),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DescricaoLocalScreen(
                              empresaId:
                                  empresa.id,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        descricao,
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildAvaliacao(
                  dados,
                ),
              ),

              Flexible(
                child: GestureDetector(
                  behavior:
                      HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LocalizacaoScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 14,
                      ),

                      const SizedBox(width: 2),

                      Flexible(
                        child: Text(
                          endereco,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}