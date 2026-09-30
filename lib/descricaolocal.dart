import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neuroway/agendarvisita.dart';
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

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _favoritoSubscription;

  int _minhaAvaliacao = 0;
  bool _carregandoAvaliacao = true;
  bool _salvandoAvaliacao = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _minhaAvaliacaoSubscription;

  String _idFavorito() {
    return 'empresa_${widget.empresaId}';
  }

  String _idAvaliacao() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return '';
    }

    return '${widget.empresaId}_${usuario.uid}';
  }

  @override
  void initState() {
    super.initState();
    _acompanharFavorito();
    _acompanharMinhaAvaliacao();
  }

  // FAVORITOS

  void _acompanharFavorito() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final referencia = FirebaseFirestore.instance
        .collection('favoritos')
        .doc('${usuario.uid}_${_idFavorito()}');

    _favoritoSubscription = referencia.snapshots().listen(
      (documento) {
        if (!mounted) return;

        setState(() {
          _isFavorited = documento.exists;
        });
      },
      onError: (erro) {
        debugPrint('Erro ao acompanhar favorito: $erro');
      },
    );
  }

  Future<void> _alternarFavorito(
    Map<String, dynamic> dados,
  ) async {
    if (_alterandoFavorito) return;

    final usuario = FirebaseAuth.instance.currentUser;

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
      final referencia = FirebaseFirestore.instance
          .collection('favoritos')
          .doc('${usuario.uid}_${_idFavorito()}');

      if (_isFavorited) {
        await referencia.delete();

        if (mounted) {
          setState(() {
            _isFavorited = false;
          });
        }
      } else {
        final String nome =
            (dados['nome'] ?? 'Empresa').toString();

        final String categoria =
            (dados['categoria'] ?? '').toString();

        final String descricao =
            (dados['descricao'] ?? '').toString();

        final String endereco =
            (dados['endereco'] ?? '').toString();

        String foto = '';

        final fotos = dados['fotos'];

        if (fotos is List && fotos.isNotEmpty) {
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
          'criadoEm': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isFavorited = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao alterar favorito: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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

  // AVALIAÇÃO

  void _acompanharMinhaAvaliacao() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      if (mounted) {
        setState(() {
          _carregandoAvaliacao = false;
        });
      }
      return;
    }

    final referencia = FirebaseFirestore.instance
        .collection('avaliacoes_empresas')
        .doc(_idAvaliacao());

    _minhaAvaliacaoSubscription = referencia.snapshots().listen(
      (documento) {
        if (!mounted) return;

        int nota = 0;

        if (documento.exists) {
          final dados = documento.data();

          if (dados != null) {
            final valor = dados['nota'];

            if (valor is num) {
              nota = valor.toInt();
            }
          }
        }

        setState(() {
          _minhaAvaliacao = nota;
          _carregandoAvaliacao = false;
        });
      },
      onError: (erro) {
        debugPrint('Erro ao acompanhar avaliação: $erro');

        if (mounted) {
          setState(() {
            _carregandoAvaliacao = false;
          });
        }
      },
    );
  }

  Future<void> _salvarAvaliacao(int novaNota) async {
    if (_salvandoAvaliacao) return;
    if (novaNota < 1 || novaNota > 5) return;

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faça login para avaliar a empresa.',
          ),
        ),
      );
      return;
    }

    final avaliacaoAnterior = _minhaAvaliacao;

    setState(() {
      _salvandoAvaliacao = true;
      _minhaAvaliacao = novaNota;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final empresaRef = firestore
          .collection('empresas')
          .doc(widget.empresaId);

      final avaliacaoRef = firestore
          .collection('avaliacoes_empresas')
          .doc('${widget.empresaId}_${usuario.uid}');

      await firestore.runTransaction(
        (transaction) async {
          final empresaSnapshot =
              await transaction.get(empresaRef);

          final avaliacaoSnapshot =
              await transaction.get(avaliacaoRef);

          double soma = 0;
          int quantidade = 0;

          if (empresaSnapshot.exists) {
            final dadosEmpresa = empresaSnapshot.data();

            if (dadosEmpresa != null) {
              final somaFirestore =
                  dadosEmpresa['somaAvaliacoes'];

              final quantidadeFirestore =
                  dadosEmpresa['quantidadeAvaliacoes'];

              if (somaFirestore is num) {
                soma = somaFirestore.toDouble();
              }

              if (quantidadeFirestore is num) {
                quantidade =
                    quantidadeFirestore.toInt();
              }
            }
          }

          int notaAnterior = 0;

          if (avaliacaoSnapshot.exists) {
            final dadosAvaliacao =
                avaliacaoSnapshot.data();

            if (dadosAvaliacao != null) {
              final valor = dadosAvaliacao['nota'];

              if (valor is num) {
                notaAnterior = valor.toInt();
              }
            }
          }

          if (notaAnterior > 0) {
            soma = soma - notaAnterior + novaNota;
          } else {
            soma += novaNota;
            quantidade++;
          }

          if (quantidade < 0) {
            quantidade = 0;
          }

          final double media =
              quantidade > 0 ? soma / quantidade : 0;

          transaction.set(
            avaliacaoRef,
            {
              'empresaId': widget.empresaId,
              'usuarioId': usuario.uid,
              'nota': novaNota,
              'atualizadoEm':
                  FieldValue.serverTimestamp(),
              if (!avaliacaoSnapshot.exists)
                'criadoEm':
                    FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

          transaction.set(
            empresaRef,
            {
              'somaAvaliacoes': soma,
              'quantidadeAvaliacoes': quantidade,
              'mediaAvaliacao': media,
            },
            SetOptions(merge: true),
          );
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            avaliacaoAnterior == 0
                ? 'Avaliação enviada com sucesso!'
                : 'Avaliação atualizada com sucesso!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar avaliação: $e');

      if (mounted) {
        setState(() {
          _minhaAvaliacao = avaliacaoAnterior;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível salvar sua avaliação.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _salvandoAvaliacao = false;
        });
      }
    }
  }

  void _abrirAvaliacao() {
    int notaSelecionada = _minhaAvaliacao;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Avalie esta empresa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notaSelecionada == 0
                        ? 'Escolha de 1 a 5 estrelas'
                        : 'Sua avaliação: $notaSelecionada de 5',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final numero = index + 1;

                        return IconButton(
                          onPressed: _salvandoAvaliacao
                              ? null
                              : () {
                                  setModalState(() {
                                    notaSelecionada =
                                        numero;
                                  });
                                },
                          icon: Icon(
                            numero <= notaSelecionada
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 42,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          notaSelecionada == 0 ||
                                  _salvandoAvaliacao
                              ? null
                              : () async {
                                  Navigator.pop(context);

                                  await _salvarAvaliacao(
                                    notaSelecionada,
                                  );
                                },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF76A085),
                        disabledBackgroundColor:
                            Colors.grey[300],
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _minhaAvaliacao == 0
                            ? 'Enviar avaliação'
                            : 'Atualizar avaliação',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // AGENDAMENTO
  void _abrirAgendarVisita(
    String nome,
    List<Map<String, dynamic>> profissionais,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendarVisita(
          empresaId: widget.empresaId,
          empresaNome: nome,
          profissionais: profissionais,
        ),
      ),
    );
  }
  // NAVEGAÇÃO
  void _selecionarNavegacao(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Menuprincipal(
          initialIndex: index,
        ),
      ),
      (route) => false,
    );
  }
  // Converter foto Base64
Uint8List? _decodificarFoto(
  String? fotoBase64,
) {
  if (fotoBase64 == null ||
      fotoBase64.trim().isEmpty) {
    return null;
  }

  try {
    return base64Decode(
      fotoBase64.trim(),
    );
  } catch (e) {
    debugPrint(
      'Erro ao carregar foto: $e',
    );

    return null;
  }
}
// CARREGAMENTO
Widget _buildMensagemCarregamento(
  Widget child,
) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(
        top: 180,
      ),
      child: SizedBox(
        height: 400,
        child: Center(
          child: child,
        ),
      ),
    ),
  );
}

// ESTRELAS
Widget _buildEstrelasMedia(
  double media, {
  double tamanho = 18,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (index) {
        final numero = index + 1;

        IconData icone;

        if (media >= numero) {
          icone = Icons.star;
        } else if (media >= numero - 0.5) {
          icone = Icons.star_half;
        } else {
          icone = Icons.star_border;
        }

        return Icon(
          icone,
          color: Colors.amber,
          size: tamanho,
        );
      },
    ),
  );
}
  // CONTEÚDO
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          _buildBottomNavigationBar(),
      body: _buildLocalConteudo(),
    );
  }

  Widget _buildLocalConteudo() {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final screenWidth =
        MediaQuery.of(context).size.width;

    final molduraHeight =
        screenHeight * 0.15;

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _buildMensagemCarregamento(
            const CircularProgressIndicator(
              color: Color(0xFF76A085),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildMensagemCarregamento(
            Text(
              'Erro ao carregar os dados.',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return _buildMensagemCarregamento(
            Text(
              'Empresa não encontrada.',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          );
        }

        final dados = snapshot.data!.data()!;
        // Foto principal do local
        final String fotoLocalBase64 =
            dados['fotoPerfilBase64']
                ?.toString()
                .trim() ??
            '';

        final Uint8List? fotoLocalBytes =
            _decodificarFoto(
          fotoLocalBase64,
        );
        final String nome =
            (dados['nome'] ?? 'Empresa').toString();

        final String categoria =
            (dados['categoria'] ?? '').toString();

        final String descricao =
            (dados['descricao'] ?? '').toString();

        final String endereco =
            (dados['endereco'] ?? '').toString();

        final String telefone =
            (dados['telefone'] ?? '').toString();

        final String necessitaAgendamento =
            (dados['necessitaAgendamento'] ?? 'NÃO')
                .toString();

        final dynamic valorMedia =
            dados['mediaAvaliacao'];

        final dynamic valorQuantidade =
            dados['quantidadeAvaliacoes'];

        final double media =
            valorMedia is num
                ? valorMedia.toDouble()
                : 0;

        final int quantidade =
            valorQuantidade is num
                ? valorQuantidade.toInt()
                : 0;

        final Map<String, dynamic> redesSociais =
            dados['redesSociais'] is Map
                ? Map<String, dynamic>.from(
                    dados['redesSociais'],
                  )
                : {};

        final String instagram =
            (redesSociais['instagram'] ?? '').toString();

        final String facebook =
            (redesSociais['facebook'] ?? '').toString();

        final String tiktok =
            (redesSociais['tiktok'] ?? '').toString();

        final String website =
            (redesSociais['website'] ?? '').toString();

        final Map<String, dynamic> formasPagamento =
            dados['formasPagamento'] is Map
                ? Map<String, dynamic>.from(
                    dados['formasPagamento'],
                  )
                : {};

        final bool cartao =
            formasPagamento['cartao'] == true;

        final bool pix =
            formasPagamento['pix'] == true;

        final bool outros =
            formasPagamento['outros'] == true;

        final List<String> fotos = [];

        final fotosFirestore =
            dados['fotos'];

        if (fotosFirestore is List) {
          for (final foto in fotosFirestore) {
            if (foto is String &&
                foto.trim().isNotEmpty) {
              fotos.add(foto);
            }
          }
        }

        final List<Map<String, dynamic>>
            profissionais = [];

        final profissionaisFirestore =
            dados['profissionais'];

        if (profissionaisFirestore is List) {
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

        final Map<String, dynamic> horarios =
            dados['horarios'] is Map
                ? Map<String, dynamic>.from(
                    dados['horarios'],
                  )
                : {};

        final bool possuiPagamento =
            cartao || pix || outros;

        final bool possuiRedesSociais =
            instagram.trim().isNotEmpty ||
                facebook.trim().isNotEmpty ||
                tiktok.trim().isNotEmpty ||
                website.trim().isNotEmpty;

        return SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // QUEBRA-CABEÇA SUPERIOR
              SizedBox(
                height: molduraHeight,
                width: double.infinity,
                child: Image.asset(
                  'imagem/quebrasuperior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment:
                      Alignment.topCenter,
                ),
              ),

              const SizedBox(height: 8),
              // CABEÇALHO
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(
                          context,
                        )) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Menuprincipal(),
                            ),
                          );
                        }
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nome,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              screenWidth * 0.06,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(),
                      icon: _alterandoFavorito
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
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
                  ],
                ),
              ),

              if (categoria.trim().isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 56,
                    right: 16,
                    top: 2,
                  ),
                  child: Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              // AVALIAÇÃO
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: InkWell(
                  onTap: _abrirAvaliacao,
                  borderRadius:
                      BorderRadius.circular(10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        _buildEstrelasMedia(
                          media,
                          tamanho: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          media > 0
                              ? media.toStringAsFixed(
                                  1,
                                )
                              : 'Sem avaliações',
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        if (quantidade > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '($quantidade)',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          _minhaAvaliacao > 0
                              ? 'Editar avaliação'
                              : 'Avaliar',
                          style:
                              const TextStyle(
                            color:
                                Color(0xFF76A085),
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // FOTO DO LOCAL
              _buildFotos(
                fotoLocalBytes,
                fotos,
              ),
              const SizedBox(height: 20),
              // DESCRIÇÃO
              if (descricao.trim().isNotEmpty)
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
                      const SizedBox(height: 8),
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
const SizedBox(height: 24),

// PROFISSIONAIS
Padding(
  padding: const EdgeInsets.symmetric(
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
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      _buildProfissionais(
        profissionais,
      ),
    ],
  ),
),

const SizedBox(height: 24),

              // LOCALIZAÇÃO
              if (endereco.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF76A085),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Localização',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                endereco,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
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

              // TELEFONE
              if (telefone.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 14,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color(0xFF76A085),
                          size: 23,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Telefone',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                telefone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
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

              // HORÁRIOS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: _buildHorarios(
                  horarios,
                ),
              ),

              // PAGAMENTO
              if (possuiPagamento) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: _buildFormasPagamento(
                    cartao: cartao,
                    pix: pix,
                    outros: outros,
                  ),
                ),
              ],

              // REDES SOCIAIS
              if (possuiRedesSociais) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
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

              // AGENDAMENTO
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: _buildInformacaoAgendamento(
                  necessitaAgendamento:
                      necessitaAgendamento,
                  nome: nome,
                  profissionais: profissionais,
                ),
              ),

              // COMENTÁRIOS
              const SizedBox(height: 24),

              CompanyCommentsSection(
                empresaId: widget.empresaId,
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // Foto do local
  Widget _buildFotos(
    Uint8List? fotoLocalBytes,
    List<String> fotos,
  ) {
    final int quantidade =
        fotos.length + (fotoLocalBytes != null ? 1 : 0);

    if (quantidade == 0) {
      return SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            itemCount: quantidade,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (fotoLocalBytes != null &&
                  index == 0) {
                return Image.memory(
                  fotoLocalBytes,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
                );
              }

              final int fotoIndex =
                  fotoLocalBytes != null
                      ? index - 1
                      : index;

              return _buildFoto(
                fotos[fotoIndex],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoto(
    String foto,
  ) {
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
          child: CircularProgressIndicator(
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

  // PROFISSIONAIS
  Widget _buildProfissionais(
    List<Map<String, dynamic>> profissionais,
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
        scrollDirection: Axis.horizontal,
        itemCount: profissionais.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 24);
        },
        itemBuilder: (context, index) {
          final profissional = profissionais[index];

          final String nome =
              (profissional['nome'] ?? '').toString();

          final String especialidade =
              (profissional['especialidade'] ??
                      profissional['profissao'] ??
                      '')
                  .toString();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Descricaoprofi(
                    profissional: profissional,
                    empresaId: widget.empresaId,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 145,
              child: _buildProfessionalAvatar(
                profissional,
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
    Map<String, dynamic> profissional,
    String nome,
    String especialidade,
  ) {
    final String uid =
        profissional['uid']
                ?.toString()
                .trim() ??
            '';

    return Row(
      children: [
        _buildFotoProfissional(
          uid,
          profissional,
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
                  fontWeight: FontWeight.bold,
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
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFotoProfissional(
    String uid,
    Map<String, dynamic> profissional,
  ) {
    return FutureBuilder<Uint8List?>(
      future: _buscarFotoProfissional(
        uid,
        profissional,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.grey[300],
            child: const SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF76A085),
              ),
            ),
          );
        }

        final fotoBytes = snapshot.data;

        if (fotoBytes != null) {
          return CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.grey[300],
            backgroundImage:
                MemoryImage(fotoBytes),
          );
        }

        return _avatarSemFoto();
      },
    );
  }

  Future<Uint8List?> _buscarFotoProfissional(
    String uid,
    Map<String, dynamic> profissional,
  ) async {
    final String fotoEmpresa =
        profissional['fotoPerfilBase64']
                ?.toString()
                .trim() ??
            '';

    if (fotoEmpresa.isNotEmpty) {
      final bytes =
          _decodificarFoto(fotoEmpresa);

      if (bytes != null) {
        return bytes;
      }
    }

    String emailProfissional =
        profissional['email']
                ?.toString()
                .trim() ??
            '';

    try {
      if (uid.isNotEmpty) {
        final documentoProfissional =
            await FirebaseFirestore.instance
                .collection('profissionais')
                .doc(uid)
                .get();

        if (documentoProfissional.exists) {
          final dados =
              documentoProfissional.data();

          final String foto =
              dados?['fotoPerfilBase64']
                      ?.toString()
                      .trim() ??
                  '';

          if (foto.isNotEmpty) {
            final bytes =
                _decodificarFoto(foto);

            if (bytes != null) {
              return bytes;
            }
          }

          if (emailProfissional.isEmpty) {
            emailProfissional =
                dados?['email']
                        ?.toString()
                        .trim() ??
                    '';
          }
        }
      }

      if (uid.isNotEmpty) {
        final documentoUsuario =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();

        if (documentoUsuario.exists) {
          final dados =
              documentoUsuario.data();

          final String foto =
              dados?['fotoPerfilBase64']
                      ?.toString()
                      .trim() ??
                  '';

          if (foto.isNotEmpty) {
            final bytes =
                _decodificarFoto(foto);

            if (bytes != null) {
              return bytes;
            }
          }
        }
      }

      if (emailProfissional.isNotEmpty) {
        final resultado =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .where(
                  'email',
                  isEqualTo:
                      emailProfissional,
                )
                .limit(1)
                .get();

        if (resultado.docs.isNotEmpty) {
          final dados =
              resultado.docs.first.data();

          final String foto =
              dados['fotoPerfilBase64']
                      ?.toString()
                      .trim() ??
                  '';

          if (foto.isNotEmpty) {
            final bytes =
                _decodificarFoto(foto);

            if (bytes != null) {
              return bytes;
            }
          }
        }
      }
    } catch (e) {
      debugPrint(
        'Erro ao buscar foto do profissional: $e',
      );
    }

    return null;
  }

  Widget _avatarSemFoto() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // HORÁRIOS
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

    final List<Widget> linhas = [];

    for (final dia in dias) {
      final dadosDia = horarios[dia];

      if (dadosDia is Map) {
        final Map<String, dynamic> horario =
            Map<String, dynamic>.from(
          dadosDia,
        );

        final bool aberto =
            horario['aberto'] == true;

        final String abertura =
            (horario['abertura'] ?? '')
                .toString()
                .trim();

        final String fechamento =
            (horario['fechamento'] ?? '')
                .toString()
                .trim();

        String textoHorario;

        if (!aberto) {
          textoHorario = 'Fechado';
        } else if (abertura.isNotEmpty &&
            fechamento.isNotEmpty) {
          textoHorario =
              '$abertura às $fechamento';
        } else if (abertura.isNotEmpty) {
          textoHorario =
              'A partir das $abertura';
        } else if (fechamento.isNotEmpty) {
          textoHorario =
              'Até às $fechamento';
        } else {
          textoHorario =
              'Horário não informado';
        }

        linhas.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 5,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 75,
                  child: Text(
                    '$dia:',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    textoHorario,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        linhas.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 5,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 75,
                  child: Text(
                    '$dia:',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Horário não informado',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.access_time,
            color: Color(0xFF76A085),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Horários',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...linhas,
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFormasPagamento({
    required bool cartao,
    required bool pix,
    required bool outros,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
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
                color:
                    Color(0xFF76A085),
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
          if (cartao)
            _buildPagamentoLinha(
              Icons.credit_card,
              'Cartão',
            ),
          if (pix)
            _buildPagamentoLinha(
              Icons.pix,
              'Pix',
            ),
          if (outros)
            _buildPagamentoLinha(
              Icons.payments,
              'Outros',
            ),
        ],
      ),
    );
  }

  Widget _buildPagamentoLinha(
    IconData icone,
    String titulo,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(
            icone,
            size: 19,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // REDES SOCIAIS
  Widget _buildRedesSociais({
    required String instagram,
    required String facebook,
    required String tiktok,
    required String website,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
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
                color:
                    Color(0xFF76A085),
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
          const EdgeInsets.only(top: 7),
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
                color:
                    Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // AGENDAMENTO
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
      padding:
          const EdgeInsets.all(14),
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
              color:
                  Colors.grey[700],
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
                        BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Text(
                        'Agende seu horário',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
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
  // BARRA INFERIOR
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration:
          const BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child:
          BottomNavigationBar(
        currentIndex: 0,
        type:
            BottomNavigationBarType.fixed,
        backgroundColor:
            Colors.white,
        selectedItemColor:
            Colors.black,
        unselectedItemColor:
            Color(0xFF9E9E9E),
        showSelectedLabels:
            false,
        showUnselectedLabels:
            false,
        elevation: 0,
        onTap:
            _selecionarNavegacao,
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
  // DISPOSE
  @override
  void dispose() {
    _favoritoSubscription?.cancel();
    _minhaAvaliacaoSubscription?.cancel();
    super.dispose();
  }
}
// COMENTÁRIOS DA EMPRESA
class CompanyCommentsSection extends StatelessWidget {
  final String empresaId;

  const CompanyCommentsSection({
    super.key,
    required this.empresaId,
  });

  CollectionReference<Map<String, dynamic>>
      _comentariosRef() {
    return FirebaseFirestore.instance
        .collection('empresas')
        .doc(empresaId)
        .collection('comentarios');
  }
  // PUBLICAR COMENTÁRIO
  Future<void> _abrirComentario(
    BuildContext context,
  ) async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faça login para publicar um comentário.',
          ),
        ),
      );
      return;
    }

    final controller =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Faça um comentário',
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText:
                  'Digite seu comentário...',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF98B9A6,
                ),
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () async {
                final texto =
                    controller.text.trim();

                if (texto.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Digite um comentário.',
                      ),
                    ),
                  );

                  return;
                }

                if (empresaId.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Erro: empresa não identificada.',
                      ),
                    ),
                  );

                  return;
                }

                String nome = 'Usuário';

                if (usuario.displayName != null &&
                    usuario.displayName!
                        .trim()
                        .isNotEmpty) {
                  nome =
                      usuario.displayName!
                          .trim();
                } else if (usuario.email !=
                    null) {
                  nome = usuario.email!
                      .split('@')
                      .first;
                }

                try {
                  final ref =
                      _comentariosRef();

                  await ref.add({
                    'empresaId':
                        empresaId,
                    'usuarioId':
                        usuario.uid,
                    'nome': nome,
                    'comentario': texto,
                    'likes': 0,
                    'dislikes': 0,
                    'criadoEm':
                        FieldValue
                            .serverTimestamp(),
                  });

                  if (dialogContext
                      .mounted) {
                    Navigator.pop(
                      dialogContext,
                    );
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Comentário publicado com sucesso!',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(
                    'Erro ao publicar comentário: $e',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro ao publicar comentário: $e',
                        ),
                      ),
                    );
                  }
                }
              },
              child:
                  const Text('Publicar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }
  // REAÇÕES
  Future<void> _alterarReacao(
    DocumentSnapshot<Map<String, dynamic>>
        comentario,
    String novaReacao,
  ) async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    if (novaReacao != 'like' &&
        novaReacao != 'dislike') {
      return;
    }

    try {
      final comentarioRef =
          comentario.reference;

      final reacaoRef = comentarioRef
          .collection('reacoes')
          .doc(usuario.uid);

      await FirebaseFirestore.instance
          .runTransaction(
        (transaction) async {
          final comentarioSnapshot =
              await transaction.get(
            comentarioRef,
          );

          final reacaoSnapshot =
              await transaction.get(
            reacaoRef,
          );

          if (!comentarioSnapshot.exists) {
            return;
          }

          final dados =
              comentarioSnapshot.data();

          if (dados == null) {
            return;
          }

          String? reacaoAnterior;

          if (reacaoSnapshot.exists) {
            final dadosReacao = reacaoSnapshot.data();

            if (dadosReacao != null) {
              reacaoAnterior = dadosReacao['tipo']?.toString();
            }
          }
          int likes =
              dados['likes'] is num
                  ? (dados['likes'] as num)
                      .toInt()
                  : 0;

          int dislikes =
              dados['dislikes'] is num
                  ? (dados['dislikes'] as num)
                      .toInt()
                  : 0;

          if (reacaoAnterior ==
              novaReacao) {
            if (novaReacao == 'like') {
              likes =
                  likes > 0
                      ? likes - 1
                      : 0;
            } else {
              dislikes =
                  dislikes > 0
                      ? dislikes - 1
                      : 0;
            }

            transaction.update(
              comentarioRef,
              {
                'likes': likes,
                'dislikes': dislikes,
              },
            );

            transaction.delete(
              reacaoRef,
            );

            return;
          }

          if (reacaoAnterior ==
              'like') {
            likes =
                likes > 0
                    ? likes - 1
                    : 0;
          } else if (reacaoAnterior ==
              'dislike') {
            dislikes =
                dislikes > 0
                    ? dislikes - 1
                    : 0;
          }

          if (novaReacao == 'like') {
            likes++;
          } else {
            dislikes++;
          }

          transaction.update(
            comentarioRef,
            {
              'likes': likes,
              'dislikes': dislikes,
            },
          );

          transaction.set(
            reacaoRef,
            {
              'usuarioId':
                  usuario.uid,
              'tipo': novaReacao,
              'atualizadoEm':
                  FieldValue
                      .serverTimestamp(),
            },
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Erro ao alterar reação: $e',
      );
    }
  }
  // EXCLUIR COMENTÁRIO
  Future<void> _excluirComentario(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>>
        comentario,
  ) async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final dados =
        comentario.data();

    if (dados == null) {
      return;
    }

    final usuarioId =
        dados['usuarioId']
                ?.toString() ??
            '';

    if (usuarioId != usuario.uid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Você só pode excluir seus próprios comentários.',
          ),
        ),
      );

      return;
    }

    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir comentário?',
          ),
          content: const Text(
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child:
                  const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              style:
                  TextButton.styleFrom(
                foregroundColor:
                    Colors.red,
              ),
              child:
                  const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await comentario.reference.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Comentário excluído com sucesso.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Erro ao excluir comentário: $e',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível excluir o comentário: $e',
            ),
          ),
        );
      }
    }
  }
  // LISTA DE COMENTÁRIOS
  @override
  Widget build(
    BuildContext context,
  ) {
    final ref = _comentariosRef();

    final usuario =
        FirebaseAuth.instance.currentUser;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comentários',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.grey[700],
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: ref.snapshots(),
            builder:
                (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          Color(0xFF98B9A6),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Text(
                    'Erro ao carregar comentários:\n${snapshot.error}',
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              final comentarios =
                  snapshot.data?.docs ?? [];

              if (comentarios.isEmpty) {
                return const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Text(
                    'Ainda não há comentários para esta empresa.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              comentarios.sort(
                (a, b) {
                  final dataA =
                      a.data()['criadoEm'];

                  final dataB =
                      b.data()['criadoEm'];

                  if (dataA is Timestamp &&
                      dataB is Timestamp) {
                    return dataB.compareTo(
                      dataA,
                    );
                  }

                  return 0;
                },
              );

              return Column(
                children:
                    comentarios.map(
                  (comentario) {
                    final dados =
                        comentario.data();

                    final nome =
                        (dados['nome'] ??
                                'Usuário')
                            .toString();

                    final texto =
                        (dados['comentario'] ??
                                '')
                            .toString();

                    final likes =
                        dados['likes']
                                is num
                            ? (dados['likes']
                                    as num)
                                .toInt()
                            : 0;

                    final dislikes =
                        dados['dislikes']
                                is num
                            ? (dados[
                                        'dislikes']
                                    as num)
                                .toInt()
                            : 0;

                    final donoComentario =
                        usuario != null &&
                        dados['usuarioId']
                                ?.toString() ==
                            usuario.uid;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child:
                          _CompanyReactionBuilder(
                        comentario:
                            comentario,
                        usuarioId:
                            usuario?.uid,
                        builder:
                            (reacaoAtual) {
                          return CompanyCommentCard(
                            author:
                                nome,
                            content:
                                texto,
                            likes:
                                likes,
                            dislikes:
                                dislikes,
                            reacaoAtual:
                                reacaoAtual,
                            podeExcluir:
                                donoComentario,
                            onLike: () {
                              _alterarReacao(
                                comentario,
                                'like',
                              );
                            },
                            onDislike: () {
                              _alterarReacao(
                                comentario,
                                'dislike',
                              );
                            },
                            onDelete: () {
                              _excluirComentario(
                                context,
                                comentario,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),

          const SizedBox(
            height: 4,
          ),

          OutlinedButton(
            onPressed: () =>
                _abrirComentario(
              context,
            ),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  Colors.black,
              side:
                  const BorderSide(
                color: Colors.grey,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child:
                const Text(
              'Faça um comentário!',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// REACTION BUILDER DA EMPRESA
class _CompanyReactionBuilder
    extends StatelessWidget {
  final DocumentSnapshot<
      Map<String, dynamic>> comentario;

  final String? usuarioId;

  final Widget Function(
    String? reacaoAtual,
  ) builder;

  const _CompanyReactionBuilder({
    required this.comentario,
    required this.usuarioId,
    required this.builder,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (usuarioId == null ||
        usuarioId!.isEmpty) {
      return builder(null);
    }

    final reacaoRef = comentario
        .reference
        .collection('reacoes')
        .doc(usuarioId);

    return StreamBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      stream: reacaoRef.snapshots(),
      builder:
          (context, snapshot) {
        String? reacaoAtual;

        if (snapshot.hasData &&
            snapshot.data!.exists) {
          reacaoAtual =
              snapshot.data!
                  .data()?['tipo']
                  ?.toString();

          if (reacaoAtual != 'like' &&
              reacaoAtual !=
                  'dislike') {
            reacaoAtual = null;
          }
        }

        return builder(
          reacaoAtual,
        );
      },
    );
  }
}
// CARD DE COMENTÁRIO DA EMPRESA
class CompanyCommentCard
    extends StatelessWidget {
  final String author;
  final String content;
  final int likes;
  final int dislikes;
  final String? reacaoAtual;
  final bool podeExcluir;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onDelete;

  const CompanyCommentCard({
    super.key,
    required this.author,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.reacaoAtual,
    required this.podeExcluir,
    required this.onLike,
    required this.onDislike,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final likeSelecionado =
        reacaoAtual == 'like';

    final dislikeSelecionado =
        reacaoAtual == 'dislike';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  author,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              if (podeExcluir)
                IconButton(
                  onPressed: onDelete,
                  tooltip:
                      'Excluir comentário',
                  padding:
                      EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
                    color: Colors.red,
                    size: 21,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            content,
            style:
                const TextStyle(
              fontSize: 13,
              height: 1.3,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              InkWell(
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
                onTap: onLike,
                child: Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        likeSelecionado
                            ? Icons
                                .thumb_up
                            : Icons
                                .thumb_up_outlined,
                        size: 17,
                        color: likeSelecionado
                            ? const Color(
                                0xFF4F7D63,
                              )
                            : Colors
                                .grey[700],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '$likes',
                        style:
                            TextStyle(
                          fontSize: 11,
                          fontWeight:
                              likeSelecionado
                                  ? FontWeight
                                      .bold
                                  : FontWeight
                                      .normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              InkWell(
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
                onTap: onDislike,
                child: Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        dislikeSelecionado
                            ? Icons
                                .thumb_down
                            : Icons
                                .thumb_down_outlined,
                        size: 17,
                        color: dislikeSelecionado
                            ? Colors
                                .redAccent
                            : Colors
                                .grey[700],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '$dislikes',
                        style:
                            TextStyle(
                          fontSize: 11,
                          fontWeight:
                              dislikeSelecionado
                                  ? FontWeight
                                      .bold
                                  : FontWeight
                                      .normal,
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