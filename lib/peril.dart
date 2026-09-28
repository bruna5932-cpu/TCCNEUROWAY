
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final Color verde = const Color(0xFF98B9A6);

  String nome = 'Carregando...';
  String email = 'Não informado';
  String cidade = 'Não informado';
  String fotoPerfilUrl = '';

  bool carregando = true;
  bool enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          nome = 'Usuário não identificado';
          carregando = false;
        });

        return;
      }

      final firestore = FirebaseFirestore.instance;

      DocumentSnapshot<Map<String, dynamic>>? documentoUsuario;

      final documentoPorUid = await firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (documentoPorUid.exists) {
        documentoUsuario = documentoPorUid;
      } else {
        final resultado = await firestore
            .collection('usuarios')
            .where(
              'email',
              isEqualTo: usuario.email,
            )
            .limit(1)
            .get();

        if (resultado.docs.isNotEmpty) {
          documentoUsuario = resultado.docs.first;
        }
      }

      final dados = documentoUsuario?.data() ?? {};

      final nomeBanco = dados['nome']?.toString().trim() ?? '';
      final emailBanco = dados['email']?.toString().trim() ?? '';
      final cidadeBanco = dados['cidade']?.toString().trim() ?? '';

      final dynamic fotoValor = dados['fotoPerfilUrl'];

      final String fotoBanco =
          fotoValor == null ? '' : fotoValor.toString().trim();

      if (!mounted) return;

      setState(() {
        nome = nomeBanco.isNotEmpty ? nomeBanco : 'Usuário';
        email = emailBanco.isNotEmpty
            ? emailBanco
            : (usuario.email ?? 'Não informado');
        cidade = cidadeBanco.isNotEmpty
            ? cidadeBanco
            : 'Não informado';
        fotoPerfilUrl = fotoBanco;
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');

      if (!mounted) return;

      setState(() {
        nome = 'Erro ao carregar perfil';
        carregando = false;
      });
    }
  }

  Future<void> _alterarFoto() async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem == null) return;

      if (mounted) {
        setState(() {
          enviandoFoto = true;
        });
      }

      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _mostrarMensagem('Usuário não identificado.');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('usuarios/${usuario.uid}/foto_perfil.jpg');

      await storageRef.putFile(File(imagem.path));

      final url = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set(
        {
          'fotoPerfilUrl': url,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        fotoPerfilUrl = url;
      });

      _mostrarMensagem('Foto atualizada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao alterar foto: $e');

      if (mounted) {
        _mostrarMensagem('Não foi possível alterar a foto.');
      }
    } finally {
      if (mounted) {
        setState(() {
          enviandoFoto = false;
        });
      }
    }
  }

  void _mostrarEdicaoCidade() {
    final controller = TextEditingController(
      text: cidade == 'Não informado' ? '' : cidade,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Expanded(
                  child: Text('Cidade'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    setDialogState(() {
                      editando = true;
                    });
                  },
                ),
              ],
            ),
            content: TextField(
              controller: controller,
              enabled: editando,
              keyboardType: TextInputType.streetAddress,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Fechar'),
              ),
              if (editando)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final valor = controller.text.trim();

                    if (valor.isEmpty) {
                      _mostrarMensagem('Preencha a cidade.');
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _salvarCidade(valor);
                  },
                  child: const Text('Salvar'),
                ),
            ],
          );
        },
      ),
    ).then((_) => controller.dispose());
  }

  Future<void> _salvarCidade(String valor) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _mostrarMensagem('Usuário não identificado.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set(
        {
          'cidade': valor,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        cidade = valor;
      });

      _mostrarMensagem('Cidade atualizada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao salvar cidade: $e');

      if (mounted) {
        _mostrarMensagem('Não foi possível atualizar a cidade.');
      }
    }
  }

  void _abrirFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: Colors.white,
          body: Favoritos(),
        ),
      ),
    );
  }

  void _abrirAgendamentos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: Colors.white,
          body: Agendamentos(),
        ),
      ),
    );
  }

  Future<void> _sair() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LOGIN(),
        ),
        (route) => false,
      );
    } catch (e) {
      _mostrarMensagem('Erro ao sair da conta.');
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: carregando
            ? Center(
                child: CircularProgressIndicator(
                  color: verde,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _alterarFoto,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor:
                                        const Color(0xFFF1F1F1),
                                    backgroundImage:
                                        fotoPerfilUrl.isNotEmpty
                                            ? NetworkImage(fotoPerfilUrl)
                                            : null,
                                    child: fotoPerfilUrl.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 55,
                                            color: Colors.black54,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: verde,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF495057),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextButton(
                                    onPressed: enviandoFoto
                                        ? null
                                        : _alterarFoto,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 36),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    child: Text(
                                      enviandoFoto
                                          ? 'Enviando foto...'
                                          : 'Alterar foto',
                                      style: TextStyle(
                                        color: verde,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _opcao(
                          Icons.location_city_outlined,
                          'Cidade: $cidade',
                          _mostrarEdicaoCidade,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.favorite_border,
                          'Favoritos',
                          _abrirFavoritos,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.calendar_today_outlined,
                          'Agendamentos',
                          _abrirAgendamentos,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _sair,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _divisor() {
    return const Divider(height: 1);
  }

  Widget _opcao(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.black,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}