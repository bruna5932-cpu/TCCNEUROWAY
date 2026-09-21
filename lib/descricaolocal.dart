import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neuroway/agendarvisita.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/peril.dart';
import 'package:neuroway/menuprincipal.dart';
import 'package:neuroway/descricaoprofi.dart';

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

  StreamSubscription<
          DocumentSnapshot<Map<String, dynamic>>>?
      _favoritoSubscription;

  @override
  void initState() {
    super.initState();
    _acompanharFavorito();
  }

  String _idFavorito() {
    return 'empresa_${widget.empresaId}';
  }

  void _acompanharFavorito() {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final referencia =
        FirebaseFirestore.instance
            .collection('favoritos')
            .doc(
              '${usuario.uid}_${_idFavorito()}',
            );

    _favoritoSubscription =
        referencia.snapshots().listen(
      (documento) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isFavorited =
              documento.exists;
        });
      },
      onError: (erro) {
        debugPrint(
          'Erro ao acompanhar favorito: $erro',
        );
      },
    );
  }

  @override
  void dispose() {
    _favoritoSubscription?.cancel();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
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
          'itemId': widget.empresaId,
          'empresaId': widget.empresaId,
          'nome': nome,
          'categoria': categoria,
          'descricao': descricao,
          'endereco': endereco,
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
        'Erro ao alterar favorito: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível alterar o favorito.',
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

  void _abrirAgendarVisita(
    String nome,
    List<Map<String, dynamic>> profissionais,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgendarVisita(
          empresaId: widget.empresaId,
          empresaNome: nome,
          profissionais: profissionais,
        ),
      ),
    );
  }

  void _abrirAgendamentos() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const Agendamentos(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // A barra inferior continua fixa.
      bottomNavigationBar:
          _buildBottomNavigationBar(),

      body: SafeArea(
        top: false,
        child: _buildLocalConteudo(),
      ),
    );
  }

  // ============================================================
  // CONTEÚDO PRINCIPAL
  // ============================================================

  Widget _buildLocalConteudo() {
    return Stack(
      children: [
        // ======================================================
        // PARTE ROLÁVEL
        // ======================================================
        Positioned.fill(
          child: StreamBuilder<
              DocumentSnapshot<
                  Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('empresas')
                .doc(widget.empresaId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 140,
                    ),
                    child: SizedBox(
                      height: 400,
                      child: const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              Color(0xFF76A085),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 140,
                    ),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'Erro ao carregar os dados.',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  !snapshot.data!.exists) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 140,
                    ),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'Empresa não encontrada.',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final dados =
                  snapshot.data!.data()!;

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

              final String telefone =
                  (dados['telefone'] ?? '')
                      .toString();

              final String necessitaAgendamento =
                  (dados['necessitaAgendamento'] ??
                          'NÃO')
                      .toString();

              // ------------------------------------------------
              // REDES SOCIAIS
              // ------------------------------------------------

              final Map<String, dynamic>
                  redesSociais =
                  dados['redesSociais']
                          is Map
                      ? Map<String, dynamic>.from(
                          dados['redesSociais'],
                        )
                      : {};

              final String instagram =
                  (redesSociais['instagram'] ??
                          '')
                      .toString();

              final String facebook =
                  (redesSociais['facebook'] ??
                          '')
                      .toString();

              final String tiktok =
                  (redesSociais['tiktok'] ??
                          '')
                      .toString();

              final String website =
                  (redesSociais['website'] ??
                          '')
                      .toString();

              // ------------------------------------------------
              // FORMAS DE PAGAMENTO
              // ------------------------------------------------

              final Map<String, dynamic>
                  formasPagamento =
                  dados['formasPagamento']
                          is Map
                      ? Map<String, dynamic>.from(
                          dados['formasPagamento'],
                        )
                      : {};

              final String cartao =
                  (formasPagamento['cartao'] ??
                          '')
                      .toString();

              final String pix =
                  (formasPagamento['pix'] ?? '')
                      .toString();

              final String outros =
                  (formasPagamento['outros'] ??
                          '')
                      .toString();

              // ------------------------------------------------
              // FOTOS
              // ------------------------------------------------

              final List<String> fotos = [];

              final fotosFirestore =
                  dados['fotos'];

              if (fotosFirestore is List) {
                for (final foto
                    in fotosFirestore) {
                  if (foto is String &&
                      foto.trim().isNotEmpty) {
                    fotos.add(foto);
                  }
                }
              }

              // ------------------------------------------------
              // PROFISSIONAIS
              // ------------------------------------------------

              final List<
                      Map<String, dynamic>>
                  profissionais = [];

              final profissionaisFirestore =
                  dados['profissionais'];

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

              // ------------------------------------------------
              // HORÁRIOS
              // ------------------------------------------------

              final Map<String, dynamic>
                  horarios =
                  dados['horarios'] is Map
                      ? Map<String, dynamic>.from(
                          dados['horarios'],
                        )
                      : {};

              final bool possuiPagamento =
                  cartao.trim().isNotEmpty ||
                      pix.trim().isNotEmpty ||
                      outros.trim().isNotEmpty;

              final bool possuiRedesSociais =
                  instagram.trim().isNotEmpty ||
                      facebook.trim().isNotEmpty ||
                      tiktok.trim().isNotEmpty ||
                      website.trim().isNotEmpty;

              // =================================================
              // TODO ESTE CONTEÚDO É ROLÁVEL
              // =================================================

              return SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 140,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // =================================================
                    // NOME + FAVORITO + ESTRELAS
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              nome,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          IconButton(
                            padding:
                                EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(),
                            icon:
                                _alterandoFavorito
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
                                        color:
                                            _isFavorited
                                                ? Colors
                                                    .red
                                                : Colors
                                                    .black,
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

                          const SizedBox(width: 6),

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

                    // =================================================
                    // CATEGORIA
                    // =================================================

                    if (categoria.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 3,
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.grey[600],
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // =================================================
                    // FOTOS
                    // =================================================

                    _buildFotos(fotos),

                    const SizedBox(height: 20),

                    // =================================================
                    // DESCRIÇÃO
                    // =================================================

                    if (descricao
                        .trim()
                        .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sobre o local',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              descricao,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // =================================================
                    // PROFISSIONAIS
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profissionais',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildProfissionais(
                            profissionais,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // PONTOS
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        _buildDot(
                          isActive: true,
                        ),
                        _buildDot(
                          isActive: false,
                        ),
                        _buildDot(
                          isActive: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // LOCALIZAÇÃO
                    // =================================================

                    if (endereco.trim().isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                              color:
                                  Colors.grey.shade300,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(
                                  0xFF76A085,
                                ),
                                size: 24,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
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
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      endereco,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors
                                            .grey[700],
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // =================================================
                    // TELEFONE
                    // =================================================

                    if (telefone.trim().isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 14,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                              color:
                                  Colors.grey.shade300,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Color(
                                  0xFF76A085,
                                ),
                                size: 23,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    const Text(
                                      'Telefone',
                                      style:
                                          TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      telefone,
                                      style: TextStyle(
                                        fontSize: 13,
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
                      ),

                    const SizedBox(height: 20),

                    // =================================================
                    // HORÁRIOS
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Horários',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildHorarios(
                            horarios,
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // FORMAS DE PAGAMENTO
                    // =================================================

                    if (possuiPagamento) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child:
                            _buildFormasPagamento(
                          cartao: cartao,
                          pix: pix,
                          outros: outros,
                        ),
                      ),
                    ],

                    // =================================================
                    // REDES SOCIAIS
                    // =================================================

                    if (possuiRedesSociais) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: _buildRedesSociais(
                          instagram: instagram,
                          facebook: facebook,
                          tiktok: tiktok,
                          website: website,
                        ),
                      ),
                    ],

                    // =================================================
                    // AGENDAMENTO
                    // =================================================

                    const SizedBox(height: 24),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child:
                          _buildInformacaoAgendamento(
                        necessitaAgendamento:
                            necessitaAgendamento,
                        nome: nome,
                        profissionais:
                            profissionais,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),

        // ==========================================================
        // QUEBRA-CABEÇA FIXO
        // ==========================================================
        _buildMolduraSuperior(),

        // ==========================================================
        // SETA FIXA
        // ==========================================================
        _buildBotaoVoltar(),
      ],
    );
  }

  // ============================================================
  // QUEBRA-CABEÇA FIXO NO TOPO
  // ============================================================

  Widget _buildMolduraSuperior() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Image.asset(
          'imagem/quebrasuperior.png',
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }

  // ============================================================
  // SETA FIXA
  // MESMA CONFIGURAÇÃO DO FAVORITOS
  // ============================================================

  Widget _buildBotaoVoltar() {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 26,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const Menuprincipal(),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  // ============================================================
  // FOTOS
  // ============================================================

  Widget _buildFotos(List<String> fotos) {
    if (fotos.isEmpty) {
      return SizedBox(
        height: 200,
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
      height: 200,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(16),
          child: PageView.builder(
            scrollDirection:
                Axis.horizontal,
            itemCount: fotos.length,
            physics:
                const BouncingScrollPhysics(),
            itemBuilder:
                (context, index) {
              return _buildFoto(
                fotos[index],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoto(String foto) {
    return Image.network(
      foto,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder:
          (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return const Center(
          child:
              CircularProgressIndicator(
            color: Color(0xFF76A085),
          ),
        );
      },
      errorBuilder:
          (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 50,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFISSIONAIS
  // ============================================================

  Widget _buildProfissionais(
    List<Map<String, dynamic>>
        profissionais,
  ) {
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
        itemCount: profissionais.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 24),
        itemBuilder:
            (context, index) {
          final profissional =
              profissionais[index];

          final String nome =
              (profissional['nome'] ?? '')
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
                  builder: (context) =>
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
    String nome,
    String especialidade,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              Colors.grey[300],
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                nome.isNotEmpty
                    ? nome
                    : 'Profissional',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                especialidade.isNotEmpty
                    ? especialidade
                    : 'Profissional',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HORÁRIOS
  // ============================================================

  Widget _buildHorarios(
    Map<String, dynamic> horarios,
  ) {
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

    final List<Widget> linhas =
        [];

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
              color: Colors.grey[700],
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

  // ============================================================
  // FORMAS DE PAGAMENTO
  // ============================================================

  Widget _buildFormasPagamento({
    required String cartao,
    required String pix,
    required String outros,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 21,
                color: Color(0xFF76A085),
              ),
              SizedBox(width: 8),
              Text(
                'Formas de pagamento',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (cartao.trim().isNotEmpty)
            _buildPagamentoLinha(
              Icons.credit_card,
              'Cartão',
              cartao,
            ),

          if (pix.trim().isNotEmpty)
            _buildPagamentoLinha(
              Icons.pix,
              'Pix',
              pix,
            ),

          if (outros.trim().isNotEmpty)
            _buildPagamentoLinha(
              Icons.payments,
              'Outros',
              outros,
            ),
        ],
      ),
    );
  }

  Widget _buildPagamentoLinha(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 19,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$titulo: $valor',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REDES SOCIAIS
  // ============================================================

  Widget _buildRedesSociais({
    required String instagram,
    required String facebook,
    required String tiktok,
    required String website,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.share,
                size: 21,
                color: Color(0xFF76A085),
              ),
              SizedBox(width: 8),
              Text(
                'Redes sociais',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (instagram.trim().isNotEmpty)
            _buildRedeSocialLinha(
              Icons.camera_alt_outlined,
              'Instagram',
              instagram,
            ),

          if (facebook.trim().isNotEmpty)
            _buildRedeSocialLinha(
              Icons.facebook,
              'Facebook',
              facebook,
            ),

          if (tiktok.trim().isNotEmpty)
            _buildRedeSocialLinha(
              Icons.music_note,
              'TikTok',
              tiktok,
            ),

          if (website.trim().isNotEmpty)
            _buildRedeSocialLinha(
              Icons.language,
              'Website',
              website,
            ),
        ],
      ),
    );
  }

  Widget _buildRedeSocialLinha(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 19,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$titulo: $valor',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AGENDAMENTO
  // ============================================================

  Widget _buildInformacaoAgendamento({
    required String necessitaAgendamento,
    required String nome,
    required List<Map<String, dynamic>>
        profissionais,
  }) {
    final String status =
        necessitaAgendamento.toUpperCase();

    String texto;

    if (status == 'SIM') {
      texto =
          'Esta empresa necessita de agendamento.';
    } else if (status == 'OPCIONAL') {
      texto =
          'O agendamento é opcional nesta empresa.';
    } else {
      texto =
          'Esta empresa não necessita de agendamento.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'SIM'
                    ? Icons.calendar_month
                    : status == 'OPCIONAL'
                        ? Icons.event_available
                        : Icons.event_busy,
                size: 21,
                color:
                    const Color(0xFF76A085),
              ),
              const SizedBox(width: 8),
              const Text(
                'Agendamento',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),

          if (status == 'SIM') ...[
            const SizedBox(height: 10),

            Align(
              alignment:
                  Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  _abrirAgendarVisita(
                    nome,
                    profissionais,
                  );
                },
                borderRadius:
                    BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFF76A085),
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Text(
                        'Agende seu horário',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        'assets/whatsApp.png',
                        height: 24,
                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.chat,
                            color:
                                Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PONTOS
  // ============================================================

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

  // ============================================================
  // BARRA INFERIOR
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type:
            BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor:
            Color(0xFF9E9E9E),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Menuprincipal(),
              ),
            );
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Favoritos(),
              ),
            );
          }

          if (index == 2) {
            _abrirAgendamentos();
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Perfil(),
              ),
            );
          }
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
    );
  }
}