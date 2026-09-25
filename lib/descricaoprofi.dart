import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/peril.dart';
import 'package:neuroway/menuprincipal.dart';

class Descricaoprofi extends StatefulWidget {
  final bool abrirPerfilNaHome;
  final Map<String, dynamic>? profissional;
  final String? empresaId;

  const Descricaoprofi({
    super.key,
    this.abrirPerfilNaHome = false,
    this.profissional,
    this.empresaId,
  });

  @override
  State<Descricaoprofi> createState() => _DescricaoprofiState();
}

class _DescricaoprofiState extends State<Descricaoprofi> {
  int _currentIndex = 0;

  Map<String, dynamic>? _profissional;

  bool _carregandoProfissional = true;
  bool _isFavorited = false;
  bool _alterandoFavorito = false;

  @override
  void initState() {
    super.initState();
    _buscarProfissional();
  }

  // Buscar profissional
  Future<void> _buscarProfissional() async {
    try {
      final profissionalInicial = widget.profissional;

      String? profissionalUid;

      if (profissionalInicial != null) {
        profissionalUid =
            profissionalInicial['uid']?.toString() ??
            profissionalInicial['id']?.toString() ??
            profissionalInicial['profissionalUid']?.toString();
      }

      Map<String, dynamic>? dadosProfissional;

      if (profissionalUid != null && profissionalUid.isNotEmpty) {
        final documento =
            await FirebaseFirestore.instance
                .collection('profissionais')
                .doc(profissionalUid)
                .get();

        if (documento.exists && documento.data() != null) {
          dadosProfissional = documento.data();
        }
      }

      if (dadosProfissional == null &&
          widget.empresaId != null &&
          widget.empresaId!.isNotEmpty &&
          profissionalUid != null &&
          profissionalUid.isNotEmpty) {
        final documentoEmpresa =
            await FirebaseFirestore.instance
                .collection('empresas')
                .doc(widget.empresaId)
                .get();

        final dadosEmpresa = documentoEmpresa.data();

        final profissionais = dadosEmpresa?['profissionais'];

        if (profissionais is List) {
          for (final item in profissionais) {
            if (item is Map) {
              final mapa = Map<String, dynamic>.from(item);

              final uidItem = mapa['uid']?.toString();

              if (uidItem == profissionalUid) {
                dadosProfissional = mapa;
                break;
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _profissional = dadosProfissional ?? profissionalInicial;
          _carregandoProfissional = false;
        });
      }

      await _verificarFavorito();
    } catch (e) {
      debugPrint('Erro ao buscar profissional: $e');

      if (mounted) {
        setState(() {
          _profissional = widget.profissional;
          _carregandoProfissional = false;
        });
      }

      await _verificarFavorito();
    }
  }

  // Dados do profissional
  String _obterNomeProfissional() {
    final profissional = _profissional ?? {};

    return (profissional['nome'] ??
            profissional['name'] ??
            'Profissional')
        .toString();
  }

  String _obterEspecialidade() {
    final profissional = _profissional ?? {};

    return (profissional['especialidade'] ??
            profissional['profissao'] ??
            profissional['profissão'] ??
            profissional['categoria'] ??
            '')
        .toString();
  }

  String _obterUidProfissional() {
    final profissional = _profissional ?? {};

    return (profissional['uid'] ??
            profissional['id'] ??
            profissional['profissionalUid'] ??
            '')
        .toString();
  }

  // Foto do profissional
  String _obterFotoProfissional() {
    final profissional = _profissional ?? {};

    final foto =
        profissional['foto'] ??
        profissional['fotoUrl'] ??
        profissional['imagem'] ??
        profissional['fotoPerfil'] ??
        '';

    return foto.toString().trim();
  }

  String _obterDescricaoProfissional() {
    final profissional = _profissional ?? {};

    return (profissional['descricao'] ??
            profissional['descricaoProfissional'] ??
            profissional['bio'] ??
            profissional['sobre'] ??
            'Profissional cadastrado no estabelecimento.')
        .toString();
  }

  String _obterExperienciaProfissional() {
    final profissional = _profissional ?? {};

    return (profissional['experiencia'] ??
            profissional['tempoExperiencia'] ??
            profissional['tempoDeExperiencia'] ??
            profissional['tempo_experiencia'] ??
            '')
        .toString();
  }

  // Favoritos
  String _obterIdFavorito() {
    final uid = _obterUidProfissional();

    if (uid.isNotEmpty) {
      return 'profissional_$uid';
    }

    final empresa = widget.empresaId ?? 'sem_empresa';

    final nome = _obterNomeProfissional();

    final texto =
        '${empresa}_$nome'
            .replaceAll('/', '_')
            .replaceAll(' ', '_');

    return 'profissional_$texto';
  }

  DocumentReference<Map<String, dynamic>> _referenciaFavorito() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não está logado.');
    }

    return FirebaseFirestore.instance
        .collection('favoritos')
        .doc('${usuario.uid}_${_obterIdFavorito()}');
  }

  Future<void> _verificarFavorito() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      if (mounted) {
        setState(() {
          _isFavorited = false;
        });
      }

      return;
    }

    try {
      final documento = await _referenciaFavorito().get();

      if (mounted) {
        setState(() {
          _isFavorited = documento.exists;
        });
      }
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
    }
  }

  Future<void> _alternarFavorito() async {
    if (_alterandoFavorito) {
      return;
    }

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

    final profissionalUid = _obterUidProfissional();

    final nome = _obterNomeProfissional();

    if (nome.isEmpty) {
      return;
    }

    setState(() {
      _alterandoFavorito = true;
    });

    try {
      final referencia = _referenciaFavorito();

      if (_isFavorited) {
        await referencia.delete();

        if (mounted) {
          setState(() {
            _isFavorited = false;
          });
        }
      } else {
        await referencia.set({
          'usuarioId': usuario.uid,
          'tipo': 'profissional',
          'itemId': profissionalUid.isNotEmpty
              ? profissionalUid
              : _obterIdFavorito(),
          'profissionalUid': profissionalUid,
          'empresaId': widget.empresaId ?? '',
          'nome': nome,
          'especialidade': _obterEspecialidade(),
          'profissao': _obterEspecialidade(),
          'descricao': _obterDescricaoProfissional(),
          'experiencia': _obterExperienciaProfissional(),
          'foto': _obterFotoProfissional(),
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

  // Navegação
  List<Widget> get _paginas => [
        _buildPerfilConteudo(),
        const Favoritos(),
        const Agendamentos(),
        const Perfil(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _paginas,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Perfil
  Widget _buildPerfilConteudo() {
    if (_carregandoProfissional) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF98B9A6),
        ),
      );
    }

    final nome = _obterNomeProfissional();

    final especialidade = _obterEspecialidade();

    final descricao = _obterDescricaoProfissional();

    final profissao = _obterEspecialidade();

    final experiencia = _obterExperienciaProfissional();

    final foto = _obterFotoProfissional();

    final profissionalUid = _obterUidProfissional();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeaderSection(
            nome: nome,
            especialidade: especialidade,
            foto: foto,
            isFavorited: _isFavorited,
            carregandoFavorito: _alterandoFavorito,
            onFavorite: _alternarFavorito,
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              descricao,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profissao.trim().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 19,
                        color: Color(0xFF4F7D63),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Profissão: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: profissao,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                if (profissao.trim().isNotEmpty &&
                    experiencia.trim().isNotEmpty)
                  const SizedBox(
                    height: 8,
                  ),

                if (experiencia.trim().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 19,
                        color: Color(0xFF4F7D63),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Tempo de experiência: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: experiencia,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Divider(
              color: Colors.black45,
              thickness: 1,
            ),
          ),

          CommentsSection(
            profissionalUid: profissionalUid,
            empresaId: widget.empresaId,
          ),

          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// Bottom navigation
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0xFF9E9E9E),
        showSelectedLabels: false,
        showUnselectedLabels: false,
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

// Header do profissional
class ProfileHeaderSection extends StatelessWidget {
  final String nome;
  final String especialidade;
  final String foto;
  final bool isFavorited;
  final bool carregandoFavorito;
  final VoidCallback onFavorite;

  const ProfileHeaderSection({
    super.key,
    required this.nome,
    required this.especialidade,
    required this.foto,
    required this.isFavorited,
    required this.carregandoFavorito,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 45,
          left: 10,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        Positioned(
          top: 95,
          right: 15,
          child: IconButton(
            icon: carregandoFavorito
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  )
                : Icon(
                    isFavorited
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorited
                        ? Colors.red
                        : Colors.black,
                    size: 28,
                  ),
            onPressed: carregandoFavorito
                ? null
                : onFavorite,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            top: 45,
            left: 45,
            right: 45,
            bottom: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: foto.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          foto,
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),

                    if (especialidade.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ),
                        child: Text(
                          especialidade,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Comentários
class CommentsSection extends StatelessWidget {
  final String profissionalUid;
  final String? empresaId;

  const CommentsSection({
    super.key,
    required this.profissionalUid,
    required this.empresaId,
  });

  CollectionReference<Map<String, dynamic>>? _comentariosRef() {
    if (empresaId == null ||
        empresaId!.isEmpty ||
        profissionalUid.isEmpty) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('empresas')
        .doc(empresaId)
        .collection('comentarios');
  }

  Future<void> _abrirComentario(BuildContext context) async {
    final usuario = FirebaseAuth.instance.currentUser;

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

    final controller = TextEditingController();

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
              hintText: 'Digite seu comentário...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF98B9A6,
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final texto = controller.text.trim();

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

                if (empresaId == null ||
                    empresaId!.isEmpty) {
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

                if (profissionalUid.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Erro: profissional não identificado.',
                      ),
                    ),
                  );

                  return;
                }

                String nome = 'Usuário';

                if (usuario.displayName != null &&
                    usuario.displayName!.trim().isNotEmpty) {
                  nome = usuario.displayName!.trim();
                } else if (usuario.email != null) {
                  nome = usuario.email!.split('@').first;
                }

                try {
                  final ref =
                      FirebaseFirestore.instance
                          .collection('empresas')
                          .doc(empresaId)
                          .collection('comentarios');

                  await ref.add({
                    'profissionalUid': profissionalUid,
                    'usuarioId': usuario.uid,
                    'nome': nome,
                    'comentario': texto,
                    'likes': 0,
                    'dislikes': 0,
                    'criadoEm': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
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
              child: const Text('Publicar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  // Reações
  Future<void> _alterarReacao(
    DocumentSnapshot<Map<String, dynamic>> comentario,
    String novaReacao,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    if (novaReacao != 'like' &&
        novaReacao != 'dislike') {
      return;
    }

    try {
      final comentarioRef = comentario.reference;

      final reacaoRef = comentarioRef
          .collection('reacoes')
          .doc(usuario.uid);

      await FirebaseFirestore.instance.runTransaction(
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

          final dados = comentarioSnapshot.data();

          if (dados == null) {
            return;
          }

          final reacaoAnterior = reacaoSnapshot.exists
              ? (reacaoSnapshot.data()?['tipo']?.toString())
              : null;

          int likes = dados['likes'] is num
              ? (dados['likes'] as num).toInt()
              : 0;

          int dislikes = dados['dislikes'] is num
              ? (dados['dislikes'] as num).toInt()
              : 0;

          if (reacaoAnterior == novaReacao) {
            if (novaReacao == 'like') {
              likes = likes > 0 ? likes - 1 : 0;
            } else {
              dislikes = dislikes > 0 ? dislikes - 1 : 0;
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

          if (reacaoAnterior == 'like') {
            likes = likes > 0 ? likes - 1 : 0;
          } else if (reacaoAnterior == 'dislike') {
            dislikes = dislikes > 0 ? dislikes - 1 : 0;
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
              'usuarioId': usuario.uid,
              'tipo': novaReacao,
              'atualizadoEm': FieldValue.serverTimestamp(),
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

  // Excluir comentário
  Future<void> _excluirComentario(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> comentario,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final dados = comentario.data();

    if (dados == null) {
      return;
    }

    final usuarioId =
        dados['usuarioId']?.toString() ?? '';

    if (usuarioId != usuario.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você só pode excluir seus próprios comentários.',
          ),
        ),
      );

      return;
    }

    final confirmar = await showDialog<bool>(
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
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
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
        ScaffoldMessenger.of(context).showSnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível excluir o comentário: $e',
            ),
          ),
        );
      }
    }
  }

  // Lista de comentários
  @override
  Widget build(BuildContext context) {
    final ref = _comentariosRef();

    final usuario = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comentários',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

          if (ref == null)
            const Text(
              'Não foi possível carregar os comentários.',
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          else
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ref
                  .where(
                    'profissionalUid',
                    isEqualTo: profissionalUid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF98B9A6),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      'Erro ao carregar comentários:\n${snapshot.error}',
                      style: const TextStyle(
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
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      'Ainda não há comentários para este profissional.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                comentarios.sort(
                  (a, b) {
                    final dataA = a.data()['criadoEm'];

                    final dataB = b.data()['criadoEm'];

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
                  children: comentarios.map(
                    (comentario) {
                      final dados = comentario.data();

                      final nome =
                          (dados['nome'] ?? 'Usuário').toString();

                      final texto =
                          (dados['comentario'] ?? '').toString();

                      final likes = dados['likes'] is num
                          ? (dados['likes'] as num).toInt()
                          : 0;

                      final dislikes = dados['dislikes'] is num
                          ? (dados['dislikes'] as num).toInt()
                          : 0;

                      final donoComentario =
                          usuario != null &&
                          dados['usuarioId']?.toString() ==
                              usuario.uid;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _ReactionBuilder(
                          comentario: comentario,
                          usuarioId: usuario?.uid,
                          builder: (reacaoAtual) {
                            return CommentCard(
                              author: nome,
                              content: texto,
                              likes: likes,
                              dislikes: dislikes,
                              reacaoAtual: reacaoAtual,
                              podeExcluir: donoComentario,
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
            onPressed: () => _abrirComentario(
              context,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(
                color: Colors.grey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: const Text(
              'Faça um comentário!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reaction builder
class _ReactionBuilder extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> comentario;

  final String? usuarioId;

  final Widget Function(
    String? reacaoAtual,
  ) builder;

  const _ReactionBuilder({
    required this.comentario,
    required this.usuarioId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (usuarioId == null ||
        usuarioId!.isEmpty) {
      return builder(null);
    }

    final reacaoRef = comentario.reference
        .collection('reacoes')
        .doc(usuarioId);

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: reacaoRef.snapshots(),
      builder: (context, snapshot) {
        String? reacaoAtual;

        if (snapshot.hasData &&
            snapshot.data!.exists) {
          reacaoAtual =
              snapshot.data!.data()?['tipo']?.toString();

          if (reacaoAtual != 'like' &&
              reacaoAtual != 'dislike') {
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

// Card de comentário
class CommentCard extends StatelessWidget {
  final String author;
  final String content;
  final int likes;
  final int dislikes;
  final String? reacaoAtual;
  final bool podeExcluir;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onDelete;

  const CommentCard({
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
  Widget build(BuildContext context) {
    final likeSelecionado =
        reacaoAtual == 'like';

    final dislikeSelecionado =
        reacaoAtual == 'dislike';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              if (podeExcluir)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Excluir comentário',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
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
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                onTap: onLike,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        likeSelecionado
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 17,
                        color: likeSelecionado
                            ? const Color(0xFF4F7D63)
                            : Colors.grey[700],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '$likes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: likeSelecionado
                              ? FontWeight.bold
                              : FontWeight.normal,
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
                borderRadius: BorderRadius.circular(
                  8,
                ),
                onTap: onDislike,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        dislikeSelecionado
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        size: 17,
                        color: dislikeSelecionado
                            ? Colors.redAccent
                            : Colors.grey[700],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '$dislikes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: dislikeSelecionado
                              ? FontWeight.bold
                              : FontWeight.normal,
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