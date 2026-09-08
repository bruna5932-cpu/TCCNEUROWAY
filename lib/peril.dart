import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  String nome = 'Carregando...';
  String email = 'Carregando...';
  String cidade = 'Carregando...';

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  // ============================================================
  // BUSCAR DADOS DO USUÁRIO
  // ============================================================

  Future<void> _buscarDados() async {
    try {
      // Usuário atualmente logado
      final User? usuario =
          FirebaseAuth.instance.currentUser;

      // ==========================================================
      // VERIFICA SE EXISTE USUÁRIO LOGADO
      // ==========================================================

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          nome = 'Usuário não identificado';
          email = 'Faça login novamente';
          cidade = 'Não informado';
          carregando = false;
        });

        return;
      }

      // E-mail vindo do Authentication
      final String? emailAuth = usuario.email;

      // UID vindo do Authentication
      final String uid = usuario.uid;

      debugPrint('========================================');
      debugPrint('PERFIL');
      debugPrint('UID: $uid');
      debugPrint('E-MAIL AUTHENTICATION: $emailAuth');
      debugPrint('========================================');

      DocumentSnapshot<Map<String, dynamic>>? documento;

      // ==========================================================
      // PRIMEIRA TENTATIVA:
      // PROCURAR PELO E-MAIL
      // ==========================================================

      if (emailAuth != null && emailAuth.isNotEmpty) {
        debugPrint(
          'Procurando usuário pelo e-mail...',
        );

        final QuerySnapshot<Map<String, dynamic>>
            resultado =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .where(
                  'email',
                  isEqualTo: emailAuth,
                )
                .limit(1)
                .get();

        if (resultado.docs.isNotEmpty) {
          documento = resultado.docs.first;

          debugPrint(
            'Usuário encontrado pelo e-mail!',
          );

          debugPrint(
            'ID do documento: ${documento.id}',
          );
        }
      }

      // ==========================================================
      // SEGUNDA TENTATIVA:
      // PROCURAR PELO UID
      // ==========================================================

      if (documento == null) {
        debugPrint(
          'Usuário não encontrado pelo e-mail.',
        );

        debugPrint(
          'Tentando procurar pelo UID...',
        );

        final DocumentSnapshot<Map<String, dynamic>>
            documentoUid =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();

        if (documentoUid.exists) {
          documento = documentoUid;

          debugPrint(
            'Usuário encontrado pelo UID!',
          );
        }
      }

      // ==========================================================
      // DOCUMENTO ENCONTRADO
      // ==========================================================

      if (documento != null && documento.exists) {
        final Map<String, dynamic> dados =
            documento.data() ?? {};

        debugPrint('========================================');
        debugPrint('DADOS DO FIRESTORE');
        debugPrint('Nome: ${dados['nome']}');
        debugPrint('E-mail: ${dados['email']}');
        debugPrint('Cidade: ${dados['cidade']}');
        debugPrint('========================================');

        if (!mounted) return;

        setState(() {
          // NOME
          final nomeBanco =
              dados['nome']?.toString().trim() ?? '';

          nome = nomeBanco.isNotEmpty
              ? nomeBanco
              : 'Nome não informado';

          // E-MAIL
          final emailBanco =
              dados['email']?.toString().trim() ?? '';

          if (emailBanco.isNotEmpty) {
            email = emailBanco;
          } else if (emailAuth != null &&
              emailAuth.isNotEmpty) {
            email = emailAuth;
          } else {
            email = 'E-mail não informado';
          }

          // CIDADE
          final cidadeBanco =
              dados['cidade']?.toString().trim() ?? '';

          cidade = cidadeBanco.isNotEmpty
              ? cidadeBanco
              : 'Cidade não informada';

          carregando = false;
        });

        return;
      }

      // ==========================================================
      // NÃO ENCONTROU NO FIRESTORE
      // ==========================================================

      debugPrint(
        'NENHUM DOCUMENTO ENCONTRADO.',
      );

      if (!mounted) return;

      setState(() {
        nome = 'Nome não encontrado';

        email = emailAuth ??
            'E-mail não encontrado';

        cidade = 'Cidade não encontrada';

        carregando = false;
      });
    }

    // ============================================================
    // ERRO DO FIREBASE
    // ============================================================

    on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('ERRO FIREBASE NO PERFIL');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('========================================');

      if (!mounted) return;

      // Mesmo se o Firestore der erro,
      // mostramos o e-mail do Authentication.

      final User? usuario =
          FirebaseAuth.instance.currentUser;

      setState(() {
        nome = 'Erro ao carregar nome';

        email = usuario?.email ??
            'E-mail não disponível';

        cidade = 'Erro ao carregar cidade';

        carregando = false;
      });
    }

    // ============================================================
    // ERRO GERAL
    // ============================================================

    catch (e) {
      debugPrint(
        'ERRO GERAL NO PERFIL: $e',
      );

      if (!mounted) return;

      final User? usuario =
          FirebaseAuth.instance.currentUser;

      setState(() {
        nome = 'Erro ao carregar';

        email = usuario?.email ??
            'E-mail não disponível';

        cidade = 'Erro ao carregar';

        carregando = false;
      });
    }
  }

  // ============================================================
  // SAIR
  // ============================================================

  Future<void> _sair() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LOGIN(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Erro ao sair: $e',
      );

      if (!mounted) return;

      _mostrarMensagem(
        'Erro ao sair da conta.',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        top: false,

        child: Column(
          children: [

            // ==================================================
            // PARTE PRINCIPAL
            // ==================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),

                children: [

                  // ==================================================
                  // FOTO + NOME + E-MAIL
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [

                      const CircleAvatar(
                        radius: 50,

                        backgroundColor:
                            Color(0xFF6C757D),

                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // NOME
                            Text(
                              nome,

                              style:
                                  const TextStyle(
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black,
                              ),

                              maxLines: 2,

                              overflow:
                                  TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 5),

                            // E-MAIL
                            Text(
                              email,

                              style:
                                  const TextStyle(
                                fontSize: 16,
                                color:
                                    Color(0xFF495057),
                              ),

                              maxLines: 2,

                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // CIDADE
                  // ==================================================

                  _buildProfileOption(
                    icon:
                        Icons.location_on_outlined,

                    label: cidade,

                    onTap: () {
                      if (!carregando) {
                        _mostrarMensagem(
                          'Cidade: $cidade',
                        );
                      }
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // FAVORITOS
                  // ==================================================

                  _buildProfileOption(
                    icon:
                        Icons.favorite_border,

                    label: 'Favoritos',

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Scaffold(
                            backgroundColor:
                                Colors.white,
                            body: Favoritos(),
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // AGENDAMENTOS
                  // ==================================================

                  _buildProfileOption(
                    icon:
                        Icons.calendar_today_outlined,

                    label: 'Agendamentos',

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Scaffold(
                            backgroundColor:
                                Colors.white,
                            body: Agendamentos(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // PARTE INFERIOR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  // ==================================================
                  // EDITAR
                  // ==================================================

                  TextButton.icon(
                    onPressed: () {
                      _mostrarMensagem(
                        'Botão Editar clicado',
                      );
                    },

                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.black,
                      size: 28,
                    ),

                    label: const Text(
                      'Editar',

                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),

                    style:
                        TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),

                  // ==================================================
                  // SAIR
                  // ==================================================

                  InkWell(
                    onTap: _sair,

                    splashColor:
                        Colors.green.withOpacity(
                      0.3,
                    ),

                    borderRadius:
                        BorderRadius.circular(10),

                    child: const Padding(
                      padding:
                          EdgeInsets.all(8),

                      child: Row(
                        children: [

                          Text(
                            'Sair',

                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(width: 8),

                          Icon(
                            Icons.exit_to_app,
                            color: Colors.black,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ITEM DO PERFIL
  // ============================================================

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),

      title: Text(
        label,

        style:
            const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),

        maxLines: 1,

        overflow:
            TextOverflow.ellipsis,
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
        size: 16,
      ),

      onTap: onTap,
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _mostrarMensagem(
    String mensagem,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),

        duration:
            const Duration(seconds: 2),
      ),
    );
  }
}

// ================================================================
// HEADER WAVE CLIPPER
// ================================================================

class HeaderWaveClipper
    extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(
      0,
      size.height * 0.75,
    );

    final firstControlPoint =
        Offset(
      size.width * 0.25,
      size.height * 0.60,
    );

    final firstEndPoint =
        Offset(
      size.width * 0.5,
      size.height * 0.80,
    );

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint =
        Offset(
      size.width * 0.75,
      size.height * 1.0,
    );

    final secondEndPoint =
        Offset(
      size.width,
      size.height * 0.75,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(
      size.width,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}