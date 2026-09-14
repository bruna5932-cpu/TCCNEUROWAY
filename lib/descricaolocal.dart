import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/peril.dart';
import 'descricaoprofi.dart';

class DescricaoLocalScreen extends StatefulWidget {
  final String empresaId;

  const DescricaoLocalScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<DescricaoLocalScreen> createState() =>
      _DescricaoLocalScreenState();
}

class _DescricaoLocalScreenState
    extends State<DescricaoLocalScreen> {
  bool _isFavorited = false;
  bool _alterandoFavorito = false;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  String _idFavorito() {
    return 'empresa_${widget.empresaId}';
  }

  Future<void> _verificarFavorito() async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    try {
      final referencia =
          FirebaseFirestore.instance
              .collection('favoritos')
              .doc(
                '${usuario.uid}_${_idFavorito()}',
              );

      final documento =
          await referencia.get();

      if (mounted) {
        setState(() {
          _isFavorited =
              documento.exists;
        });
      }
    } catch (e) {
      debugPrint(
        'Erro ao verificar favorito da empresa: $e',
      );
    }
  }

  Future<void> _alternarFavorito(
    Map<String, dynamic> dados,
  ) async {
    if (_alterandoFavorito) {
      return;
    }

    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Faça login para adicionar favoritos.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _alterandoFavorito = true;
    });

    try {
      final referencia =
          FirebaseFirestore.instance
              .collection('favoritos')
              .doc(
                '${usuario.uid}_${_idFavorito()}',
              );

      if (_isFavorited) {
        await referencia.delete();

        if (mounted) {
          setState(() {
            _isFavorited = false;
          });
        }
      } else {
        final nome =
            (dados['nome'] ??
                    'Empresa')
                .toString();

        final categoria =
            (dados['categoria'] ??
                    '')
                .toString();

        final descricao =
            (dados['descricao'] ??
                    '')
                .toString();

        final endereco =
            (dados['endereco'] ??
                    '')
                .toString();

        final fotosFirestore =
            dados['fotos'];

        String foto = '';

        if (fotosFirestore is List &&
            fotosFirestore.isNotEmpty) {
          final primeiraFoto =
              fotosFirestore.first;

          if (primeiraFoto is String) {
            foto = primeiraFoto;
          }
        }

        await referencia.set({
          'usuarioId': usuario.uid,
          'tipo': 'empresa',
          'itemId': widget.empresaId,
          'empresaId':
              widget.empresaId,
          'nome': nome,
          'categoria':
              categoria,
          'descricao':
              descricao,
          'endereco':
              endereco,
          'foto': foto,
          'criadoEm':
              FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isFavorited = true;
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Erro ao alterar favorito da empresa: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível alterar o favorito: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _alterandoFavorito = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      _buildLocalConteudo(),
      const Favoritos(),
      const Agendamentos(),
      const Perfil(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: paginas,
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildLocalConteudo() {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final molduraHeight =
        screenHeight * 0.15;

    return StreamBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Stack(
            children: [
              const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFF76A085),
                ),
              ),
              _buildMolduraSuperior(
                molduraHeight,
              ),
              _buildBotaoVoltar(),
            ],
          );
        }

        if (snapshot.hasError) {
          return Stack(
            children: [
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(30),
                  child: Text(
                    'Não foi possível carregar os dados da empresa.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              _buildMolduraSuperior(
                molduraHeight,
              ),
              _buildBotaoVoltar(),
            ],
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return Stack(
            children: [
              const Center(
                child: Text(
                  'Empresa não encontrada.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildMolduraSuperior(
                molduraHeight,
              ),
              _buildBotaoVoltar(),
            ],
          );
        }

        final dados =
            snapshot.data!.data()!;

        final String nome =
            (dados['nome'] ??
                    'Empresa')
                .toString();

        final String categoria =
            (dados['categoria'] ??
                    '')
                .toString();

        final String descricao =
            (dados['descricao'] ??
                    'Nenhuma descrição cadastrada.')
                .toString();

        final String endereco =
            (dados['endereco'] ??
                    'Endereço não informado.')
                .toString();

        final String necessitaAgendamento =
            (dados[
                        'necessitaAgendamento'] ??
                    'NÃO')
                .toString();

        final dynamic fotosFirestore =
            dados['fotos'];

        final List<String> fotos = [];

        if (fotosFirestore is List) {
          for (final foto
              in fotosFirestore) {
            if (foto is String &&
                foto.trim().isNotEmpty) {
              fotos.add(foto);
            }
          }
        }

        final dynamic profissionaisFirestore =
            dados['profissionais'];

        final List<
                Map<String, dynamic>>
            profissionais = [];

        if (profissionaisFirestore
            is List) {
          for (final profissional
              in profissionaisFirestore) {
            if (profissional is Map) {
              profissionais.add(
                Map<String, dynamic>.from(
                  profissional,
                ),
              );
            }
          }
        }

        final dynamic horariosFirestore =
            dados['horarios'];

        final Map<String, dynamic>
            horarios = {};

        if (horariosFirestore is Map) {
          horarios.addAll(
            Map<String, dynamic>.from(
              horariosFirestore,
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height:
                        molduraHeight * 0.75,
                  ),

                  const SizedBox(
                      height: 16),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center,
                      children: [
                        Expanded(
                          child: Text(
                            nome,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 6),

                        IconButton(
                          padding:
                              EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(),
                          icon: _alterandoFavorito
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.grey,
                                  ),
                                )
                              : Icon(
                                  _isFavorited
                                      ? Icons
                                          .favorite
                                      : Icons
                                          .favorite_border,
                                  color: _isFavorited
                                      ? Colors.red
                                      : Colors.black,
                                  size: 26,
                                ),
                          onPressed:
                              _alterandoFavorito
                                  ? null
                                  : () {
                                      _alternarFavorito(
                                        dados,
                                      );
                                    },
                        ),

                        const SizedBox(
                            width: 6),

                        const Row(
                          children: [
                            Icon(
                              Icons.star,
                              color:
                                  Colors.amber,
                              size: 16,
                            ),
                            Icon(
                              Icons.star,
                              color:
                                  Colors.amber,
                              size: 16,
                            ),
                            Icon(
                              Icons.star,
                              color:
                                  Colors.amber,
                              size: 16,
                            ),
                            Icon(
                              Icons.star,
                              color:
                                  Colors.amber,
                              size: 16,
                            ),
                            Icon(
                              Icons.star_half,
                              color:
                                  Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (categoria
                      .isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        left: 16,
                        right: 16,
                        top: 3,
                      ),
                      child: Text(
                        categoria,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors
                              .grey[600],
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 16),

                  _buildFotos(fotos),

                  const SizedBox(
                      height: 16),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Descrição',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                            height: 4),
                        Text(
                          descricao,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors
                                .grey[700],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Divider(
                      thickness: 1,
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Profissionais',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                            height: 12),
                        _buildProfissionais(
                          profissionais,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  if (profissionais
                      .isNotEmpty)
                    Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          _buildDot(
                            isActive:
                                true,
                          ),
                          _buildDot(
                            isActive:
                                false,
                          ),
                          _buildDot(
                            isActive:
                                false,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                      height: 16),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color:
                              Colors.red,
                          size: 20,
                        ),
                        const SizedBox(
                            width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'Localização',
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                  height: 2),
                              Text(
                                endereco,
                                style:
                                    TextStyle(
                                  fontSize:
                                      13,
                                  color: Colors
                                      .grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 16),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color:
                              Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(
                            width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'Horário de funcionamento',
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                  height: 4),
                              _buildHorarios(
                                horarios,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  if (necessitaAgendamento
                          .toUpperCase() ==
                      'SIM')
                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),
                      child: Align(
                        alignment:
                            Alignment
                                .centerRight,
                        child: InkWell(
                          onTap: () {},
                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(8),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                const Text(
                                  'Agende seu horário',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    decoration:
                                        TextDecoration
                                            .underline,
                                  ),
                                ),
                                const SizedBox(
                                    width: 8),
                                Image.asset(
                                  'assets/whatsApp.png',
                                  height: 28,
                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Icon(
                                      Icons.chat,
                                      color:
                                          Colors.green,
                                      size: 28,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 24),
                ],
              ),
            ),

            _buildMolduraSuperior(
              molduraHeight,
            ),

            _buildBotaoVoltar(),
          ],
        );
      },
    );
  }

  Widget _buildMolduraSuperior(
      double molduraHeight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: molduraHeight,
        child: Image.asset(
          'imagem/quebrasuperior.png',
          width: double.infinity,
          fit: BoxFit.cover,
          alignment:
              Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return Positioned(
      top: 40,
      left: 10,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 32,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildFotos(
      List<String> fotos) {
    if (fotos.isEmpty) {
      return SizedBox(
        height: 180,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.only(
          left: 16,
        ),
        itemCount: fotos.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(
          width: 12,
        ),
        itemBuilder:
            (context, index) {
          return _buildImageCard(
            fotos[index],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(
      String imageUrl) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 200,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 180,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 45,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfissionais(
      List<Map<String, dynamic>>
          profissionais) {
    if (profissionais.isEmpty) {
      return const Text(
        'Nenhum profissional cadastrado.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount:
            profissionais.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(
          width: 24,
        ),
        itemBuilder:
            (context, index) {
          final profissional =
              profissionais[index];

          final String nome =
              (profissional['nome'] ??
                      '')
                  .toString();

          final String especialidade =
              (profissional[
                          'especialidade'] ??
                      profissional[
                          'profissao'] ??
                      '')
                  .toString();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          Descricaoprofi(
                    profissional:
                        profissional,
                    empresaId:
                        widget.empresaId,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 145,
              child:
                  _buildProfessionalAvatar(
                nome,
                especialidade,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalAvatar(
    String name,
    String experience,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              Colors.grey[300],
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 30,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                name.isEmpty
                    ? 'Profissional'
                    : name,
                style:
                    const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                ),
                overflow:
                    TextOverflow.ellipsis,
              ),
              if (experience
                  .isNotEmpty)
                Text(
                  experience,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors
                        .grey[600],
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorarios(
      Map<String, dynamic>
          horarios) {
    final dias = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
      'Feriados',
    ];

    final List<Widget> linhas = [];

    for (final dia in dias) {
      final horario =
          (horarios[dia] ?? '')
              .toString()
              .trim();

      if (horario.isNotEmpty) {
        linhas.add(
          Text(
            '$dia: $horario',
            style: TextStyle(
              fontSize: 13,
              color:
                  Colors.grey[700],
              height: 1.3,
            ),
          ),
        );
      }
    }

    if (linhas.isEmpty) {
      return Text(
        'Horário não informado.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: linhas,
    );
  }

  Widget _buildDot({
    required bool isActive,
  }) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 3,
      ),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.grey[700]
            : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}