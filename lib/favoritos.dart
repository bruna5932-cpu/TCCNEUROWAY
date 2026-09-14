import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/peril.dart';
import 'package:neuroway/descricaolocal.dart';
import 'package:neuroway/descricaoprofi.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({super.key});

  @override
  State<Favoritos> createState() =>
      _FavoritosState();
}

class _FavoritosState
    extends State<Favoritos> {
  int _currentIndex = 1;

  final TextEditingController
      _pesquisaController =
      TextEditingController();

  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(
      () {
        setState(() {
          _pesquisa =
              _pesquisaController.text
                  .trim()
                  .toLowerCase();
        });
      },
    );
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<
          Map<String, dynamic>>>
      _favoritosStream() {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return FirebaseFirestore.instance
          .collection('favoritos')
          .where(
            'usuarioId',
            isEqualTo: '__usuario_nao_logado__',
          )
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('favoritos')
        .where(
          'usuarioId',
          isEqualTo: usuario.uid,
        )
        .snapshots();
  }

  Future<void> _removerFavorito(
    DocumentSnapshot<
            Map<String, dynamic>>
        documento,
  ) async {
    try {
      await documento.reference.delete();
    } catch (e) {
      debugPrint(
        'Erro ao remover favorito: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível remover o favorito.',
            ),
          ),
        );
      }
    }
  }

  void _abrirFavorito(
    Map<String, dynamic> dados,
  ) {
    final tipo =
        (dados['tipo'] ?? '').toString();

    if (tipo == 'empresa') {
      final empresaId =
          (dados['empresaId'] ??
                  dados['itemId'] ??
                  '')
              .toString();

      if (empresaId.isEmpty) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DescricaoLocalScreen(
            empresaId: empresaId,
          ),
        ),
      );

      return;
    }

    if (tipo == 'profissional') {
      final profissionalUid =
          (dados['profissionalUid'] ??
                  dados['itemId'] ??
                  '')
              .toString();

      final Map<String, dynamic>
          profissional = {
        'uid': profissionalUid,
        'nome':
            dados['nome'] ?? '',
        'especialidade':
            dados['especialidade'] ??
                dados['profissao'] ??
                '',
        'profissao':
            dados['profissao'] ??
                dados['especialidade'] ??
                '',
        'descricao':
            dados['descricao'] ?? '',
        'foto':
            dados['foto'] ?? '',
      };

      final empresaId =
          (dados['empresaId'] ??
                  '')
              .toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Descricaoprofi(
            profissional:
                profissional,
            empresaId:
                empresaId.isEmpty
                    ? null
                    : empresaId,
          ),
        ),
      );
    }
  }

  List<DocumentSnapshot<
          Map<String, dynamic>>>
      _filtrarFavoritos(
    List<DocumentSnapshot<
            Map<String, dynamic>>>
        documentos,
  ) {
    if (_pesquisa.isEmpty) {
      return documentos;
    }

    return documentos.where(
      (documento) {
        final dados =
            documento.data();

        final nome =
            (dados['nome'] ?? '')
                .toString()
                .toLowerCase();

        final categoria =
            (dados['categoria'] ??
                    '')
                .toString()
                .toLowerCase();

        final especialidade =
            (dados['especialidade'] ??
                    dados['profissao'] ??
                    '')
                .toString()
                .toLowerCase();

        return nome.contains(_pesquisa) ||
            categoria.contains(_pesquisa) ||
            especialidade.contains(
              _pesquisa,
            );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopo(),

                Expanded(
                  child:
                      _buildListaFavoritos(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavigationBarFavoritos(
        currentIndex:
            _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTopo() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Image.asset(
            'imagem/quebrasuperior.png',
            width: double.infinity,
            fit: BoxFit.cover,
            alignment:
                Alignment.topCenter,
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            children: [
              IconButton(
                padding:
                    EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 26,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.maybePop(
                    context,
                  );
                },
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  height: 54,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF5F5F5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                    border: Border.all(
                      color:
                          const Color(
                        0xFFD4D4D4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                          width: 18),

                      Icon(
                        Icons.search,
                        color:
                            Colors.grey[600],
                        size: 26,
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child:
                            TextField(
                          controller:
                              _pesquisaController,
                          decoration:
                              const InputDecoration(
                            hintText:
                                'Buscar nos favoritos',
                            border:
                                InputBorder
                                    .none,
                            isDense: true,
                          ),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 30,
                        color:
                            Colors.grey[300],
                      ),

                      const SizedBox(
                          width: 12),

                      Icon(
                        Icons.location_on,
                        color:
                            Colors.grey[600],
                        size: 24,
                      ),

                      const SizedBox(
                          width: 5),

                      Text(
                        'SJC',
                        style:
                            TextStyle(
                          color:
                              Colors.grey[600],
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_drop_down,
                        color:
                            Colors.grey,
                      ),

                      const SizedBox(
                          width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListaFavoritos() {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(30),
          child: Text(
            'Faça login para visualizar seus favoritos.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream: _favoritosStream(),
      builder:
          (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(
              color:
                  Color(0xFF76A085),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                30,
              ),
              child: Text(
                'Erro ao carregar favoritos:\n${snapshot.error}',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final documentos =
            snapshot.data?.docs ??
                [];

        final favoritos =
            _filtrarFavoritos(
          documentos,
        );

        if (favoritos.isEmpty) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                30,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color:
                        Colors.grey[400],
                  ),
                  const SizedBox(
                      height: 15),
                  Text(
                    _pesquisa.isEmpty
                        ? 'Você ainda não possui favoritos.'
                        : 'Nenhum favorito encontrado.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 20,
          ),
          itemCount:
              favoritos.length,
          itemBuilder:
              (context, index) {
            final documento =
                favoritos[index];

            final Map<String, dynamic> dados =
                documento.data() ?? {};

            return _buildFavoritoCard(
              documento,
              dados,
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritoCard(
    DocumentSnapshot<
            Map<String, dynamic>>
        documento,
    Map<String, dynamic> dados,
  ) {
    final tipo =
        (dados['tipo'] ?? '')
            .toString();

    final nome =
        (dados['nome'] ??
                'Favorito')
            .toString();

    final categoria =
        (dados['categoria'] ??
                '')
            .toString();

    final especialidade =
        (dados['especialidade'] ??
                dados['profissao'] ??
                '')
            .toString();

    final foto =
        (dados['foto'] ?? '')
            .toString();

    final bool profissional =
        tipo == 'profissional';

    return GestureDetector(
      onTap: () {
        _abrirFavorito(
          dados,
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 16,
        ),
        padding:
            const EdgeInsets.all(14),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
                const Color(
              0xFFE0E0E0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.06,
              ),
              blurRadius: 6,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .center,
          children: [
            _buildImagemFavorito(
              foto,
              profissional,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    nome,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black,
                    ),
                  ),

                  const SizedBox(
                      height: 4),

                  Text(
                    profissional
                        ? especialidade
                        : categoria,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey[600],
                    ),
                  ),

                  const SizedBox(
                      height: 7),

                  Row(
                    children:
                        List.generate(
                      5,
                      (index) =>
                          const Icon(
                        Icons.star,
                        color:
                            Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
                width: 8),

            IconButton(
              padding:
                  EdgeInsets.zero,
              constraints:
                  const BoxConstraints(),
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 28,
              ),
              onPressed: () {
                _removerFavorito(
                  documento,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagemFavorito(
    String foto,
    bool profissional,
  ) {
    if (foto.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child: Image.network(
          foto,
          width: 85,
          height: 85,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error,
                  stackTrace) {
            return _buildImagemPadrao(
              profissional,
            );
          },
        ),
      );
    }

    return _buildImagemPadrao(
      profissional,
    );
  }

  Widget _buildImagemPadrao(
    bool profissional,
  ) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color:
            const Color(0xFFE1E1E1),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Center(
        child: Icon(
          profissional
              ? Icons.person
              : Icons.store,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}

class CustomBottomNavigationBarFavoritos
    extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBarFavoritos({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex:
            currentIndex,
        type:
            BottomNavigationBarType.fixed,
        backgroundColor:
            Colors.white,
        selectedItemColor:
            Colors.black,
        unselectedItemColor:
            const Color(
          0xFF9E9E9E,
        ),
        showSelectedLabels:
            false,
        showUnselectedLabels:
            false,
        onTap: onTap,
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
    );
  }
}