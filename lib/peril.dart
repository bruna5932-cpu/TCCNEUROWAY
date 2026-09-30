import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

String fotoPerfilBase64 = '';
Uint8List? fotoPerfilBytes;

  bool carregando = true;
  bool enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  // Buscar dados
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
            .where('email', isEqualTo: usuario.email)
            .limit(1)
            .get();

        if (resultado.docs.isNotEmpty) {
          documentoUsuario = resultado.docs.first;
        }
      }

      final dados = documentoUsuario?.data() ?? {};

      final nomeBanco =
          dados['nome']?.toString().trim() ?? '';

      final emailBanco =
          dados['email']?.toString().trim() ?? '';

      final cidadeBanco =
          dados['cidade']?.toString().trim() ?? '';

      // Buscar foto em Base64
      final fotoBase64 =
          dados['fotoPerfilBase64']?.toString() ?? '';

      Uint8List? bytesFoto;

      if (fotoBase64.isNotEmpty) {
        try {
          bytesFoto = base64Decode(
            fotoBase64,
          );
        } catch (e) {
          debugPrint(
            'Erro ao carregar foto: $e',
          );

          bytesFoto = null;
        }
      }

      if (!mounted) return;

      final emailAuth =
          usuario.email?.trim() ?? '';

      setState(() {
        nome = nomeBanco.isNotEmpty
            ? nomeBanco
            : 'Usuário';

        email = emailAuth.isNotEmpty
            ? emailAuth
            : (emailBanco.isNotEmpty
                ? emailBanco
                : 'Não informado');

        cidade = cidadeBanco.isNotEmpty
            ? cidadeBanco
            : 'Não informado';

        fotoPerfilBase64 = fotoBase64;
        fotoPerfilBytes = bytesFoto;

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

  // Confirmar senha
  Future<String?> _pedirSenha() async {
    final controller = TextEditingController();

    final senhaConfirmada = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool carregandoSenha = false;
        bool ocultarSenha = true;
        String? erroSenha;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> confirmarSenha() async {
              final senha = controller.text.trim();

              if (senha.isEmpty) {
                setDialogState(() {
                  erroSenha = 'Digite sua senha.';
                });
                return;
              }

              setDialogState(() {
                carregandoSenha = true;
                erroSenha = null;
              });

              try {
                final usuario = FirebaseAuth.instance.currentUser;

                if (usuario == null) {
                  setDialogState(() {
                    carregandoSenha = false;
                    erroSenha = 'Usuário não identificado.';
                  });
                  return;
                }

                final emailAtual = usuario.email;

                if (emailAtual == null || emailAtual.isEmpty) {
                  setDialogState(() {
                    carregandoSenha = false;
                    erroSenha = 'Não foi possível confirmar sua senha.';
                  });
                  return;
                }

                final credencial = EmailAuthProvider.credential(
                  email: emailAtual,
                  password: senha,
                );

                await usuario.reauthenticateWithCredential(credencial);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext, senha);
              } on FirebaseAuthException catch (e) {
                debugPrint('Erro ao validar senha: ${e.code}');

                if (!dialogContext.mounted) return;

                String mensagem;

                switch (e.code) {
                  case 'wrong-password':
                  case 'invalid-credential':
                  case 'invalid-login-credentials':
                    mensagem = 'Senha inválida. Digite a senha correta.';
                    break;

                  default:
                    mensagem = 'Não foi possível confirmar a senha.';
                }

                setDialogState(() {
                  carregandoSenha = false;
                  erroSenha = mensagem;
                });
              } catch (e) {
                debugPrint('Erro ao validar senha: $e');

                if (!dialogContext.mounted) return;

                setDialogState(() {
                  carregandoSenha = false;
                  erroSenha = 'Não foi possível confirmar a senha.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Confirme sua senha'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para salvar esta alteração, digite a senha da sua conta.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: ocultarSenha,
                    enabled: !carregandoSenha,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!carregandoSenha) {
                        confirmarSenha();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      errorText: erroSenha,
                      suffixIcon: IconButton(
                        onPressed: carregandoSenha
                            ? null
                            : () {
                                setDialogState(() {
                                  ocultarSenha = !ocultarSenha;
                                });
                              },
                        icon: Icon(
                          ocultarSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: carregandoSenha
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: carregandoSenha ? null : confirmarSenha,
                  child: carregandoSenha
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return senhaConfirmada;
  }

  // Alterar foto
  Future<void> _alterarFoto() async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 45,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (imagem == null) return;

      if (mounted) {
        setState(() {
          enviandoFoto = true;
        });
      }

      final bytes = await imagem.readAsBytes();

      if (bytes.isEmpty) {
        _mostrarMensagem(
          'Não foi possível carregar a foto.',
        );
        return;
      }

      if (bytes.length > 450000) {
        _mostrarMensagem(
          'A foto é muito grande. Escolha uma imagem menor.',
        );
        return;
      }

      final fotoBase64 = base64Encode(
        bytes,
      );

      if (fotoBase64.length > 650000) {
        _mostrarMensagem(
          'A foto é muito grande. Escolha uma imagem menor.',
        );
        return;
      }

      final usuario =
          FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _mostrarMensagem(
          'Usuário não identificado.',
        );
        return;
      }

      // Salvar foto no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set(
        {
          'fotoPerfilBase64': fotoBase64,
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        fotoPerfilBase64 = fotoBase64;
        fotoPerfilBytes = bytes;
      });

      _mostrarMensagem(
        'Foto atualizada com sucesso.',
      );
    } catch (e) {
      debugPrint(
        'Erro ao alterar foto: $e',
      );

      if (mounted) {
        _mostrarMensagem(
          'Não foi possível alterar a foto.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          enviandoFoto = false;
        });
      }
    }
  }

  // Editar nome
  void _mostrarEdicaoNome() {
    final controller = TextEditingController(
      text: nome == 'Usuário' || nome == 'Não informado' ? '' : nome,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nome'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Digite seu nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final valor = controller.text.trim();

                if (valor.isEmpty) {
                  _mostrarMensagem('Preencha o nome.');
                  return;
                }

                if (valor == nome) {
                  Navigator.pop(dialogContext);
                  return;
                }

                Navigator.pop(dialogContext);
                await _salvarNome(valor);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  // Salvar nome
  Future<void> _salvarNome(String valor) async {
    final senha = await _pedirSenha();

    if (senha == null) return;

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
        {'nome': valor},
        SetOptions(merge: true),
      );

      await usuario.updateDisplayName(valor);

      if (!mounted) return;

      setState(() {
        nome = valor;
      });

      _mostrarMensagem('Nome atualizado com sucesso.');
    } catch (e) {
      debugPrint('Erro ao salvar nome: $e');

      if (mounted) {
        _mostrarMensagem('Não foi possível atualizar o nome.');
      }
    }
  }

  // Editar e-mail
  void _mostrarEdicaoEmail() {
    final controller = TextEditingController(
      text: email == 'Não informado' ? '' : email,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('E-mail'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              hintText: 'Digite seu novo e-mail',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final valor = controller.text.trim().toLowerCase();

                if (valor.isEmpty) {
                  _mostrarMensagem('Preencha o e-mail.');
                  return;
                }

                if (!_emailValido(valor)) {
                  _mostrarMensagem('Digite um e-mail válido.');
                  return;
                }

                if (valor == email.toLowerCase()) {
                  _mostrarMensagem('Esse já é o seu e-mail.');
                  return;
                }

                Navigator.pop(dialogContext);
                await _salvarEmail(valor);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  // Validar e-mail
  bool _emailValido(String valor) {
    final regex = RegExp(
      r'^[A-Za-z0-9.!#$%&'
      r"'"
      r'*+/=?^_`{|}~-]+@[A-Za-z0-9]'
      r'(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
      r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
    );

    return regex.hasMatch(valor);
  }

  // Salvar e-mail
  Future<void> _salvarEmail(String valor) async {
    final senha = await _pedirSenha();

    if (senha == null) return;

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      _mostrarMensagem('Usuário não identificado.');
      return;
    }

    final uid = usuario.uid;

    try {
      await _alterarEmailNoFirebase(novoEmail: valor);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: valor,
        password: senha,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set(
        {'email': valor},
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        email = valor;
      });

      _mostrarMensagem('E-mail atualizado com sucesso.');
    } on _ErroAlteracaoEmail catch (e) {
      debugPrint('Erro ao alterar e-mail: ${e.codigo}');

      if (!mounted) return;

      switch (e.codigo) {
        case 'EMAIL_EXISTS':
          _mostrarMensagem(
            'Esse e-mail já está sendo usado por outra conta.',
          );
          break;

        case 'INVALID_EMAIL':
          _mostrarMensagem('O e-mail informado é inválido.');
          break;

        default:
          _mostrarMensagem('Não foi possível alterar o e-mail.');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro Auth ao alterar e-mail: ${e.code}');

      if (!mounted) return;

      switch (e.code) {
        case 'email-already-in-use':
          _mostrarMensagem(
            'Esse e-mail já está sendo usado por outra conta.',
          );
          break;

        case 'invalid-email':
          _mostrarMensagem('O e-mail informado é inválido.');
          break;

        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          _mostrarMensagem('Senha inválida.');
          break;

        default:
          _mostrarMensagem('Não foi possível atualizar o e-mail.');
      }
    } catch (e) {
      debugPrint('Erro ao salvar e-mail: $e');

      if (mounted) {
        _mostrarMensagem('Não foi possível atualizar o e-mail.');
      }
    }
  }

  // Alterar e-mail no Firebase
  Future<void> _alterarEmailNoFirebase({
    required String novoEmail,
  }) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw const _ErroAlteracaoEmail('ERRO_ALTERAR_EMAIL');
    }

    final idToken = await usuario.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw const _ErroAlteracaoEmail('ERRO_ALTERAR_EMAIL');
    }

    final apiKey = Firebase.app().options.apiKey;

    final uri = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:update',
      {'key': apiKey},
    );

    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);

      request.headers.contentType = ContentType.json;

      request.write(
        jsonEncode({
          'idToken': idToken,
          'email': novoEmail,
          'returnSecureToken': true,
        }),
      );

      final response = await request.close();
      final respostaTexto = await utf8.decoder.bind(response).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      String codigo = 'ERRO_ALTERAR_EMAIL';

      try {
        final resposta = jsonDecode(respostaTexto);
        final mensagem = resposta['error']?['message'];

        if (mensagem != null) {
          codigo = mensagem.toString().split(' ').first;
        }
      } catch (_) {
        codigo = 'ERRO_ALTERAR_EMAIL';
      }

      throw _ErroAlteracaoEmail(codigo);
    } finally {
      client.close(force: true);
    }
  }

  // Editar cidade
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
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
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

                    if (valor == cidade) {
                      Navigator.pop(dialogContext);
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

  // Salvar cidade
  Future<void> _salvarCidade(String valor) async {
    final senha = await _pedirSenha();

    if (senha == null) return;

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
        {'cidade': valor},
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

  // Abrir alteração de senha
  void _mostrarAlterarSenha() {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();

    bool ocultarSenhaAtual = true;
    bool ocultarNovaSenha = true;
    bool carregando = false;
    String? erro;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> salvar() async {
              final senhaAtual = senhaAtualController.text.trim();
              final novaSenha = novaSenhaController.text.trim();

              if (senhaAtual.isEmpty) {
                setDialogState(() {
                  erro = 'Digite sua senha atual.';
                });
                return;
              }

              if (novaSenha.isEmpty) {
                setDialogState(() {
                  erro = 'Digite a nova senha.';
                });
                return;
              }

              if (senhaAtual == novaSenha) {
                setDialogState(() {
                  erro = 'A nova senha deve ser diferente da senha atual.';
                });
                return;
              }

              setDialogState(() {
                carregando = true;
                erro = null;
              });

              final resultado = await _alterarSenha(
                senhaAtual: senhaAtual,
                novaSenha: novaSenha,
              );

              if (!dialogContext.mounted) return;

              if (resultado == 'sucesso') {
                Navigator.pop(dialogContext);
                return;
              }

              setDialogState(() {
                carregando = false;

                if (resultado == 'senhaIncorreta') {
                  erro = 'Senha atual incorreta.';
                } else {
                  erro = 'Não foi possível alterar a senha.';
                }
              });
            }

            return AlertDialog(
              title: const Text('Alterar senha'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: senhaAtualController,
                    autofocus: true,
                    obscureText: ocultarSenhaAtual,
                    enabled: !carregando,
                    decoration: InputDecoration(
                      labelText: 'Senha atual',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: carregando
                            ? null
                            : () {
                                setDialogState(() {
                                  ocultarSenhaAtual =
                                      !ocultarSenhaAtual;
                                });
                              },
                        icon: Icon(
                          ocultarSenhaAtual
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: novaSenhaController,
                    obscureText: ocultarNovaSenha,
                    enabled: !carregando,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!carregando) {
                        salvar();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: carregando
                            ? null
                            : () {
                                setDialogState(() {
                                  ocultarNovaSenha =
                                      !ocultarNovaSenha;
                                });
                              },
                        icon: Icon(
                          ocultarNovaSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  if (erro != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        erro!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: carregando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: carregando ? null : salvar,
                  child: carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      senhaAtualController.dispose();
      novaSenhaController.dispose();
    });
  }

  // Salvar nova senha
  Future<String> _alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        return 'erro';
      }

      final emailAtual = usuario.email;

      if (emailAtual == null || emailAtual.isEmpty) {
        return 'erro';
      }

      final credencial = EmailAuthProvider.credential(
        email: emailAtual,
        password: senhaAtual,
      );

      await usuario.reauthenticateWithCredential(credencial);

      await usuario.updatePassword(novaSenha);

      if (mounted) {
        _mostrarMensagem('Senha alterada com sucesso.');
      }

      return 'sucesso';
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao alterar senha: ${e.code}');

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'senhaIncorreta';

        default:
          return 'erro';
      }
    } catch (e) {
      debugPrint('Erro ao alterar senha: $e');
      return 'erro';
    }
  }

  // Favoritos
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

  // Agendamentos
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

  // Sair
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

  // Mensagem
  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Tela
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Foto
                            GestureDetector(
                              onTap: enviandoFoto
                                  ? null
                                  : _alterarFoto,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor:
                                        const Color(0xFFF1F1F1),
                                    backgroundImage:
                                        fotoPerfilBytes != null
                                            ? MemoryImage(
                                                fotoPerfilBytes!,
                                              )
                                            : null,
                                    child: fotoPerfilBytes == null
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

                            // Nome e e-mail
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Nome
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          nome,
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: _mostrarEdicaoNome,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 17,
                                            color: Color(0xFF495057),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  // E-mail
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF495057),
                                          ),
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: _mostrarEdicaoEmail,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: Color(0xFF495057),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Alterar foto
                                  TextButton(
                                    onPressed:
                                        enviandoFoto ? null : _alterarFoto,
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

                        // Cidade
                        _opcao(
                          Icons.location_city_outlined,
                          'Cidade: $cidade',
                          _mostrarEdicaoCidade,
                        ),

                        _divisor(),

                        // Alterar senha
                        _opcao(
                          Icons.lock_outline,
                          'Alterar senha',
                          _mostrarAlterarSenha,
                        ),

                        _divisor(),

                        // Favoritos
                        _opcao(
                          Icons.favorite_border,
                          'Favoritos',
                          _abrirFavoritos,
                        ),

                        _divisor(),

                        // Agendamentos
                        _opcao(
                          Icons.calendar_today_outlined,
                          'Agendamentos',
                          _abrirAgendamentos,
                        ),
                      ],
                    ),
                  ),

                  // Sair
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _sair,
                        borderRadius: BorderRadius.circular(8),
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

  // Divisor
  Widget _divisor() {
    return const Divider(height: 1);
  }

  // Opção
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

// Erro ao alterar e-mail
class _ErroAlteracaoEmail implements Exception {
  final String codigo;

  const _ErroAlteracaoEmail(this.codigo);
}