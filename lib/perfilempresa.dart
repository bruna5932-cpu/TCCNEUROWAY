import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';
import 'package:neuroway/cadastroprofi.dart';

class PerfilEmpresa extends StatefulWidget {
  const PerfilEmpresa({super.key});

  @override
  State<PerfilEmpresa> createState() => _PerfilEmpresaState();
}

class _PerfilEmpresaState extends State<PerfilEmpresa> {
  final Color verde = const Color(0xFF98B9A6);

  String? empresaUid;

  String nome = 'Carregando...';
  String email = 'Não informado';
  String cnpj = 'Não informado';
  String categoria = 'Não informado';
  String numero = 'Não informado';
  String descricao = 'Não informado';
  String endereco = 'Não informado';
  String fotoPerfilBase64 = '';
  Uint8List? fotoPerfilBytes;

  String instagram = 'Não informado';
  String facebook = 'Não informado';
  String tiktok = 'Não informado';
  String website = 'Não informado';

  String necessitaAgendamento = 'Não informado';

  String pagamentoCartao = 'Não informado';
  String pagamentoPix = 'Não informado';
  String pagamentoOutros = 'Não informado';

  final List<String> dias = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
    'feriados',
  ];

  final Map<String, String> nomesDias = {
    'segunda': 'Segunda-feira',
    'terca': 'Terça-feira',
    'quarta': 'Quarta-feira',
    'quinta': 'Quinta-feira',
    'sexta': 'Sexta-feira',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
    'feriados': 'Feriados',
  };

  Map<String, Map<String, dynamic>> horarios = {};
  List<Map<String, dynamic>> profissionais = [];
  List<dynamic> fotos = [];

  bool carregando = true;
  bool salvando = false;
  bool enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _buscarDadosEmpresa();
  }

  String _valor(dynamic valor) {
    if (valor == null || valor.toString().trim().isEmpty) {
      return 'Não informado';
    }

    return valor.toString().trim();
  }

  // Referência da empresa
  Future<DocumentReference<Map<String, dynamic>>?>
      _obterReferenciaEmpresa() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return null;

    final firestore = FirebaseFirestore.instance;
    final referencia = firestore.collection('empresas').doc(usuario.uid);
    final documento = await referencia.get();

    if (documento.exists) {
      empresaUid = usuario.uid;
      return referencia;
    }

    final resultado = await firestore
        .collection('empresas')
        .where('uid', isEqualTo: usuario.uid)
        .limit(1)
        .get();

    if (resultado.docs.isNotEmpty) {
      empresaUid = resultado.docs.first.id;
      return resultado.docs.first.reference;
    }

    return null;
  }

  // Buscar dados
  Future<void> _buscarDadosEmpresa() async {
    try {
      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        if (!mounted) return;

        setState(() {
          nome = 'Empresa não encontrada';
          carregando = false;
        });

        return;
      }

      final documento = await referencia.get();
      final dados = documento.data() ?? {};

      final Map<String, dynamic> horariosBanco =
          dados['horarios'] is Map
              ? Map<String, dynamic>.from(dados['horarios'])
              : {};

      final Map<String, Map<String, dynamic>> horariosConvertidos = {};

      for (final dia in dias) {
        final valor = horariosBanco[dia];

        if (valor is Map) {
          horariosConvertidos[dia] =
              Map<String, dynamic>.from(valor);
        } else {
          final texto = valor?.toString() ?? '';

          if (texto.isNotEmpty &&
              texto != 'Não informado' &&
              texto.toLowerCase() != 'fechado') {
            final partes = texto.split('-');

            horariosConvertidos[dia] = {
              'aberto': true,
              'abertura': partes.isNotEmpty ? partes[0].trim() : '',
              'fechamento': partes.length > 1 ? partes[1].trim() : '',
            };
          } else {
            horariosConvertidos[dia] = {
              'aberto': false,
              'abertura': '',
              'fechamento': '',
            };
          }
        }
      }

      final redes = dados['redesSociais'] is Map
          ? Map<String, dynamic>.from(dados['redesSociais'])
          : {};

      final pagamentos = dados['formasPagamento'] is Map
          ? Map<String, dynamic>.from(dados['formasPagamento'])
          : {};

      final profissionaisBanco = <Map<String, dynamic>>[];

      if (dados['profissionais'] is List) {
        for (final item in dados['profissionais']) {
          if (item is Map) {
            profissionaisBanco.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      if (!mounted) return;

final emailAuth =
    FirebaseAuth.instance.currentUser?.email?.trim() ?? '';

final emailBanco =
    dados['email']?.toString().trim() ?? '';

// Foto
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

setState(() {
      nome = _valor(dados['nome']);

      email = emailAuth.isNotEmpty
          ? emailAuth
          : (emailBanco.isNotEmpty
              ? emailBanco
              : 'Não informado');

      cnpj = _valor(dados['cnpj']);
      categoria = _valor(dados['categoria']);
      numero = _valor(
        dados['telefone'] ?? dados['numero'],
      );
      descricao = _valor(dados['descricao']);
      endereco = _valor(dados['endereco']);

      fotoPerfilBase64 = fotoBase64;
      fotoPerfilBytes = bytesFoto;

      horarios = horariosConvertidos;

      instagram = _valor(redes['instagram']);
      facebook = _valor(redes['facebook']);
      tiktok = _valor(redes['tiktok']);
      website = _valor(redes['website']);

      necessitaAgendamento =
          _valor(dados['necessitaAgendamento']);

      pagamentoCartao =
          _valor(pagamentos['cartao']);

      pagamentoPix =
          _valor(pagamentos['pix']);

      pagamentoOutros =
          _valor(pagamentos['outros']);

      profissionais = profissionaisBanco;

      fotos = dados['fotos'] is List
          ? List<dynamic>.from(dados['fotos'])
          : [];

      carregando = false;
    });
    } catch (e) {
      debugPrint('Erro ao carregar empresa: $e');

      if (!mounted) return;

      setState(() {
        nome = 'Erro ao carregar empresa';
        carregando = false;
      });
    }
  }

  // Salvar informação
  Future<void> _salvarCampo(String campo, dynamic valor) async {
    try {
      if (mounted) {
        setState(() {
          salvando = true;
        });
      }

      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        _mostrarMensagem('Empresa não encontrada.');
        return;
      }

      await referencia.update({campo: valor});

      if (!mounted) return;

      _mostrarMensagem('Informação atualizada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao salvar $campo: $e');

      if (mounted) {
        _mostrarMensagem('Erro ao atualizar informação.');
      }
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Future<void> _salvarMapa(
    String campo,
    Map<String, dynamic> dados,
  ) async {
    await _salvarCampo(campo, dados);
  }

  Future<void> _salvarLista(
    String campo,
    List<dynamic> dados,
  ) async {
    await _salvarCampo(campo, dados);
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
                    erroSenha =
                        'Não foi possível confirmar sua senha.';
                  });
                  return;
                }

                final credencial = EmailAuthProvider.credential(
                  email: emailAtual,
                  password: senha,
                );

                await usuario.reauthenticateWithCredential(
                  credencial,
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext, senha);
              } on FirebaseAuthException catch (e) {
                debugPrint('Erro ao validar senha: ${e.code}');

                if (!dialogContext.mounted) return;

                final senhaIncorreta =
                    e.code == 'wrong-password' ||
                    e.code == 'invalid-credential' ||
                    e.code == 'invalid-login-credentials';

                setDialogState(() {
                  carregandoSenha = false;
                  erroSenha = senhaIncorreta
                      ? 'Senha inválida. Digite a senha correta.'
                      : 'Não foi possível confirmar a senha.';
                });
              } catch (e) {
                debugPrint('Erro ao validar senha: $e');

                if (!dialogContext.mounted) return;

                setDialogState(() {
                  carregandoSenha = false;
                  erroSenha =
                      'Não foi possível confirmar a senha.';
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
                  onPressed:
                      carregandoSenha ? null : confirmarSenha,
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

  // Editar nome
  void _mostrarEdicaoNome() {
    final controller = TextEditingController(
      text: nome == 'Não informado' ? '' : nome,
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
              hintText: 'Digite o nome da empresa',
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

      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        _mostrarMensagem('Empresa não encontrada.');
        return;
      }

      await referencia.update({
        'nome': valor,
      });

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
              hintText: 'Digite o novo e-mail',
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
                final valor =
                    controller.text.trim().toLowerCase();

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

    try {
      await _alterarEmailNoFirebase(
        novoEmail: valor,
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: valor,
        password: senha,
      );

      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        _mostrarMensagem('Empresa não encontrada.');
        return;
      }

      await referencia.update({
        'email': valor,
      });

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
          _mostrarMensagem(
            'O e-mail informado é inválido.',
          );
          break;

        default:
          _mostrarMensagem(
            'Não foi possível alterar o e-mail.',
          );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Erro Auth ao alterar e-mail: ${e.code}',
      );

      if (!mounted) return;

      switch (e.code) {
        case 'email-already-in-use':
          _mostrarMensagem(
            'Esse e-mail já está sendo usado por outra conta.',
          );
          break;

        case 'invalid-email':
          _mostrarMensagem(
            'O e-mail informado é inválido.',
          );
          break;

        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          _mostrarMensagem('Senha inválida.');
          break;

        default:
          _mostrarMensagem(
            'Não foi possível atualizar o e-mail.',
          );
      }
    } catch (e) {
      debugPrint('Erro ao salvar e-mail: $e');

      if (mounted) {
        _mostrarMensagem(
          'Não foi possível atualizar o e-mail.',
        );
      }
    }
  }

  // Alterar e-mail
  Future<void> _alterarEmailNoFirebase({
    required String novoEmail,
  }) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw const _ErroAlteracaoEmail(
        'ERRO_ALTERAR_EMAIL',
      );
    }

    final idToken =
        await usuario.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw const _ErroAlteracaoEmail(
        'ERRO_ALTERAR_EMAIL',
      );
    }

    final apiKey =
        Firebase.app().options.apiKey;

    final uri = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:update',
      {
        'key': apiKey,
      },
    );

    final client = HttpClient();

    try {
      final request =
          await client.postUrl(uri);

      request.headers.contentType =
          ContentType.json;

      request.write(
        jsonEncode({
          'idToken': idToken,
          'email': novoEmail,
          'returnSecureToken': true,
        }),
      );

      final response =
          await request.close();

      final respostaTexto =
          await utf8.decoder.bind(response).join();

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return;
      }

      String codigo = 'ERRO_ALTERAR_EMAIL';

      try {
        final resposta =
            jsonDecode(respostaTexto);

        final mensagem =
            resposta['error']?['message'];

        if (mensagem != null) {
          codigo =
              mensagem.toString().split(' ').first;
        }
      } catch (_) {
        codigo = 'ERRO_ALTERAR_EMAIL';
      }

      throw _ErroAlteracaoEmail(codigo);
    } finally {
      client.close(force: true);
    }
  }

  // Alterar senha
  void _mostrarAlterarSenha() {
    final senhaAtualController =
        TextEditingController();

    final novaSenhaController =
        TextEditingController();

    bool ocultarSenhaAtual = true;
    bool ocultarNovaSenha = true;
    bool carregandoSenha = false;
    String? erro;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> salvar() async {
              final senhaAtual =
                  senhaAtualController.text.trim();

              final novaSenha =
                  novaSenhaController.text.trim();

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
                  erro =
                      'A nova senha deve ser diferente da senha atual.';
                });
                return;
              }

              setDialogState(() {
                carregandoSenha = true;
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
                carregandoSenha = false;

                erro = resultado == 'senhaIncorreta'
                    ? 'Senha atual incorreta.'
                    : 'Não foi possível alterar a senha.';
              });
            }

            return AlertDialog(
              title: const Text('Alterar senha'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        senhaAtualController,
                    autofocus: true,
                    obscureText:
                        ocultarSenhaAtual,
                    enabled:
                        !carregandoSenha,
                    decoration: InputDecoration(
                      labelText: 'Senha atual',
                      border:
                          const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: carregandoSenha
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
                    controller:
                        novaSenhaController,
                    obscureText:
                        ocultarNovaSenha,
                    enabled:
                        !carregandoSenha,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!carregandoSenha) {
                        salvar();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      border:
                          const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: carregandoSenha
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
                      alignment:
                          Alignment.centerLeft,
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
                  onPressed: carregandoSenha
                      ? null
                      : () =>
                          Navigator.pop(
                            dialogContext,
                          ),
                  child:
                      const Text('Cancelar'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed:
                      carregandoSenha ? null : salvar,
                  child: carregandoSenha
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
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

  // Salvar senha
  Future<String> _alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    try {
      final usuario =
          FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        return 'erro';
      }

      final emailAtual = usuario.email;

      if (emailAtual == null ||
          emailAtual.isEmpty) {
        return 'erro';
      }

      final credencial =
          EmailAuthProvider.credential(
        email: emailAtual,
        password: senhaAtual,
      );

      await usuario.reauthenticateWithCredential(
        credencial,
      );

      await usuario.updatePassword(
        novaSenha,
      );

      if (mounted) {
        _mostrarMensagem(
          'Senha alterada com sucesso.',
        );
      }

      return 'sucesso';
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Erro ao alterar senha: ${e.code}',
      );

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'senhaIncorreta';

        default:
          return 'erro';
      }
    } catch (e) {
      debugPrint(
        'Erro ao alterar senha: $e',
      );

      return 'erro';
    }
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

    final base64Foto = base64Encode(bytes);

    if (base64Foto.length > 650000) {
      _mostrarMensagem(
        'A foto é muito grande. Escolha uma imagem menor.',
      );
      return;
    }

    final referenciaEmpresa =
        await _obterReferenciaEmpresa();

    if (referenciaEmpresa == null) {
      _mostrarMensagem(
        'Empresa não encontrada.',
      );
      return;
    }

    // Salvar foto no Firestore
    await referenciaEmpresa.set(
      {
        'fotoPerfilBase64': base64Foto,
      },
      SetOptions(
        merge: true,
      ),
    );

    if (!mounted) return;

    setState(() {
      fotoPerfilBase64 = base64Foto;
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
      _mostrarMensagem(
        'Erro ao sair da conta.',
      );
    }
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
                          children: [
                            // Foto
                            GestureDetector(
                              onTap: _alterarFoto,
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
                                            Icons.business,
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
                                  // Nome
                                  Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          nome,
                                          style:
                                              const TextStyle(
                                            fontSize: 25,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap:
                                            _mostrarEdicaoNome,
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.all(3),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 17,
                                            color:
                                                Color(0xFF495057),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  // E-mail
                                  Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
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
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap:
                                            _mostrarEdicaoEmail,
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.all(3),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color:
                                                Color(0xFF495057),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Alterar foto
                                  TextButton(
                                    onPressed: enviandoFoto
                                        ? null
                                        : _alterarFoto,
                                    child: Text(
                                      enviandoFoto
                                          ? 'Enviando foto...'
                                          : 'Alterar foto',
                                      style:
                                          TextStyle(color: verde),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Alterar senha
                        _opcao(
                          Icons.lock_outline,
                          'Alterar senha',
                          _mostrarAlterarSenha,
                        ),

                        _divisor(),

                        // CNPJ
                        _opcao(
                          Icons.badge_outlined,
                          'CNPJ: $cnpj',
                          _mostrarCnpj,
                        ),

                        _divisor(),

                        // Telefone
                        _opcao(
                          Icons.phone_outlined,
                          'Telefone: $numero',
                          _mostrarTelefone,
                        ),

                        _divisor(),

                        // Endereço
                        _opcao(
                          Icons.location_on_outlined,
                          endereco,
                          _mostrarEndereco,
                        ),

                        _divisor(),

                        // Horários
                        _opcao(
                          Icons.access_time_outlined,
                          'Horários de funcionamento',
                          _mostrarHorarios,
                        ),

                        _divisor(),

                        // Descrição
                        _opcao(
                          Icons.description_outlined,
                          'Descrição',
                          _mostrarDescricao,
                        ),

                        _divisor(),

                        // Redes sociais
                        _opcao(
                          Icons.public,
                          'Redes sociais',
                          _mostrarRedesSociais,
                        ),

                        _divisor(),

                        // Agendamento
                        _opcao(
                          Icons.calendar_month_outlined,
                          'Agendamento: $necessitaAgendamento',
                          _mostrarAgendamento,
                        ),

                        _divisor(),

                        // Profissionais
                        _opcao(
                          Icons.people_outline,
                          'Profissionais (${profissionais.length})',
                          _mostrarProfissionais,
                        ),

                        _divisor(),

                        // Fotos
                        _opcao(
                          Icons.photo_library_outlined,
                          'Fotos (${fotos.length})',
                          _mostrarFotos,
                        ),

                        _divisor(),

                        // Pagamentos
                        _opcao(
                          Icons.payment_outlined,
                          'Formas de pagamento',
                          _mostrarPagamentos,
                        ),

                        _divisor(),

                        // Favoritos
                        _opcao(
                          Icons.favorite_border,
                          'Favoritos',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const Scaffold(
                                  backgroundColor:
                                      Colors.white,
                                  body: Favoritos(),
                                ),
                              ),
                            );
                          },
                        ),

                        _divisor(),

                        // Agendamentos
                        _opcao(
                          Icons.calendar_today_outlined,
                          'Agendamentos',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const Scaffold(
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

                  // Sair
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

  // Componentes
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

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Máscaras
  String _somenteNumeros(String texto) {
    return texto.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
  }

  String _mascaraCnpj(String texto) {
    final numeros = _somenteNumeros(texto);
    final b = StringBuffer();

    for (int i = 0; i < numeros.length && i < 14; i++) {
      if (i == 2 || i == 5) {
        b.write('.');
      }

      if (i == 8) {
        b.write('/');
      }

      if (i == 12) {
        b.write('-');
      }

      b.write(numeros[i]);
    }

    return b.toString();
  }

  String _mascaraTelefone(String texto) {
    final numeros = _somenteNumeros(texto);

    if (numeros.isEmpty) return '';

    final b = StringBuffer();

    if (numeros.isNotEmpty) {
      b.write('(');
      b.write(
        numeros.substring(
          0,
          numeros.length >= 2 ? 2 : 1,
        ),
      );
    }

    if (numeros.length >= 3) {
      b.write(') ');

      final limite =
          numeros.length > 7 ? 7 : numeros.length;

      b.write(
        numeros.substring(
          2,
          limite,
        ),
      );
    }

    if (numeros.length > 7) {
      b.write('-');

      b.write(
        numeros.substring(
          7,
          numeros.length > 11
              ? 11
              : numeros.length,
        ),
      );
    }

    return b.toString();
  }

  // CNPJ
  void _mostrarCnpj() {
    _mostrarEdicaoSimples(
      titulo: 'CNPJ',
      valorInicial: cnpj,
      campo: 'cnpj',
      mascara: _mascaraCnpj,
      limite: 18,
      teclado: TextInputType.number,
      onAtualizado: (valor) {
        setState(() {
          cnpj = valor;
        });
      },
    );
  }

  // Telefone
  void _mostrarTelefone() {
    _mostrarEdicaoSimples(
      titulo: 'Telefone',
      valorInicial: numero,
      campo: 'telefone',
      mascara: _mascaraTelefone,
      limite: 15,
      teclado: TextInputType.phone,
      onAtualizado: (valor) {
        setState(() {
          numero = valor;
        });
      },
    );
  }

  // Endereço
  void _mostrarEndereco() {
    _mostrarEdicaoSimples(
      titulo: 'Endereço',
      valorInicial: endereco,
      campo: 'endereco',
      teclado: TextInputType.streetAddress,
      onAtualizado: (valor) {
        setState(() {
          endereco = valor;
        });
      },
    );
  }

  // Editar campo
  void _mostrarEdicaoSimples({
    required String titulo,
    required String valorInicial,
    required String campo,
    required TextInputType teclado,
    required Function(String) onAtualizado,
    String Function(String)? mascara,
    int? limite,
  }) {
    final controller = TextEditingController(
      text: valorInicial == 'Não informado'
          ? ''
          : valorInicial,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(titulo),
              ),
              IconButton(
                icon:
                    const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(
                    () => editando = true,
                  );
                },
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            enabled: editando,
            keyboardType: teclado,
            maxLength: limite,
            inputFormatters: mascara == null
                ? []
                : [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        final texto =
                            mascara(newValue.text);

                        return TextEditingValue(
                          text: texto,
                          selection:
                              TextSelection.collapsed(
                            offset: texto.length,
                          ),
                        );
                      },
                    ),
                  ],
            maxLines:
                titulo == 'Endereço' ? 3 : 1,
            decoration: InputDecoration(
              labelText: titulo,
              border:
                  const OutlineInputBorder(),
              counterText: '',
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
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  final valor =
                      controller.text.trim();

                  if (valor.isEmpty) {
                    _mostrarMensagem(
                      'Preencha o campo.',
                    );
                    return;
                  }

                  if (titulo == 'CNPJ' &&
                      _somenteNumeros(valor)
                              .length !=
                          14) {
                    _mostrarMensagem(
                      'Digite um CNPJ válido.',
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                  );

                  await _salvarCampo(
                    campo,
                    valor,
                  );

                  if (mounted) {
                    onAtualizado(valor);
                  }
                },
                child:
                    const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then(
      (_) => controller.dispose(),
    );
  }

  // Horários
  void _mostrarHorarios() {
    final aberto = <String, bool>{};

    final aberturas =
        <String, TextEditingController>{};

    final fechamentos =
        <String, TextEditingController>{};

    for (final dia in dias) {
      final dados = horarios[dia] ?? {};

      aberto[dia] =
          dados['aberto'] == true;

      aberturas[dia] =
          TextEditingController(
        text:
            dados['abertura']?.toString() ??
                '',
      );

      fechamentos[dia] =
          TextEditingController(
        text: dados['fechamento']
                ?.toString() ??
            '',
      );
    }

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Horários de funcionamento',
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () {
                  setDialogState(
                    () => editando = true,
                  );
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: dias.map((dia) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        activeColor: verde,
                        title: Text(
                          nomesDias[dia]!,
                          style:
                              const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        value: aberto[dia],
                        onChanged: editando
                            ? (valor) {
                                setDialogState(
                                  () {
                                    aberto[dia] =
                                        valor ??
                                            false;
                                  },
                                );
                              }
                            : null,
                      ),
                      if (aberto[dia] == true)
                        Row(
                          children: [
                            Expanded(
                              child: _campoHora(
                                'Abertura',
                                aberturas[dia]!,
                                editando,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: _campoHora(
                                'Fechamento',
                                fechamentos[
                                    dia]!,
                                editando,
                              ),
                            ),
                          ],
                        )
                      else
                        const Padding(
                          padding:
                              EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: Text(
                            'Fechado',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
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
                  const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  final novosHorarios =
                      <String, dynamic>{};

                  for (final dia in dias) {
                    final abertura =
                        aberturas[dia]!
                            .text
                            .trim();

                    final fechamento =
                        fechamentos[dia]!
                            .text
                            .trim();

                    if (aberto[dia] == true) {
                      if (!_horaValida(
                            abertura,
                          ) ||
                          !_horaValida(
                            fechamento,
                          )) {
                        _mostrarMensagem(
                          'Confira os horários de ${nomesDias[dia]}.',
                        );
                        return;
                      }
                    }

                    novosHorarios[dia] = {
                      'aberto':
                          aberto[dia] == true,
                      'abertura':
                          aberto[dia] == true
                              ? abertura
                              : '',
                      'fechamento':
                          aberto[dia] == true
                              ? fechamento
                              : '',
                    };
                  }

                  Navigator.pop(
                    dialogContext,
                  );

                  await _salvarMapa(
                    'horarios',
                    novosHorarios,
                  );

                  if (mounted) {
                    setState(() {
                      horarios = {
                        for (final dia
                            in dias)
                          dia: Map<String,
                              dynamic>.from(
                            novosHorarios[
                                dia],
                          ),
                      };
                    });
                  }
                },
                child:
                    const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c
          in aberturas.values) {
        c.dispose();
      }

      for (final c
          in fechamentos.values) {
        c.dispose();
      }
    });
  }

  bool _horaValida(String valor) {
    return RegExp(
      r'^([01]\d|2[0-3]):[0-5]\d$',
    ).hasMatch(valor);
  }

  Widget _campoHora(
    String label,
    TextEditingController controller,
    bool editando,
  ) {
    return TextField(
      controller: controller,
      enabled: editando,
      keyboardType:
          TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9:]'),
        ),
        LengthLimitingTextInputFormatter(
          5,
        ),
        _MascaraHora(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:mm',
        border:
            const OutlineInputBorder(),
      ),
    );
  }

  // Descrição
  void _mostrarDescricao() {
    final controller =
        TextEditingController(
      text: descricao == 'Não informado'
          ? ''
          : descricao,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text('Descrição'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () {
                  setDialogState(
                    () => editando = true,
                  );
                },
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            enabled: editando,
            maxLines: 7,
            decoration:
                const InputDecoration(
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
                  const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  final valor =
                      controller.text.trim();

                  if (valor.isEmpty) return;

                  Navigator.pop(
                    dialogContext,
                  );

                  await _salvarCampo(
                    'descricao',
                    valor,
                  );

                  if (mounted) {
                    setState(() {
                      descricao = valor;
                    });
                  }
                },
                child:
                    const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then(
      (_) => controller.dispose(),
    );
  }

  // Redes sociais
  void _mostrarRedesSociais() {
    final controllers = {
      'instagram':
          TextEditingController(
        text: instagram ==
                'Não informado'
            ? ''
            : instagram,
      ),
      'facebook':
          TextEditingController(
        text: facebook ==
                'Não informado'
            ? ''
            : facebook,
      ),
      'tiktok':
          TextEditingController(
        text:
            tiktok == 'Não informado'
                ? ''
                : tiktok,
      ),
      'website':
          TextEditingController(
        text:
            website == 'Não informado'
                ? ''
                : website,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child:
                    Text('Redes sociais'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () {
                  setDialogState(
                    () => editando = true,
                  );
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children:
                  controllers.entries.map(
                (entry) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: TextField(
                      controller:
                          entry.value,
                      enabled: editando,
                      decoration:
                          InputDecoration(
                        labelText:
                            entry.key,
                        border:
                            const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ).toList(),
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
                  const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  final novasRedes = {
                    for (final entry
                        in controllers.entries)
                      entry.key:
                          entry.value.text
                              .trim(),
                  };

                  Navigator.pop(
                    dialogContext,
                  );

                  await _salvarMapa(
                    'redesSociais',
                    novasRedes,
                  );

                  if (mounted) {
                    setState(() {
                      instagram = _valor(
                        novasRedes[
                            'instagram'],
                      );

                      facebook = _valor(
                        novasRedes[
                            'facebook'],
                      );

                      tiktok = _valor(
                        novasRedes[
                            'tiktok'],
                      );

                      website = _valor(
                        novasRedes[
                            'website'],
                      );
                    });
                  }
                },
                child:
                    const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c
          in controllers.values) {
        c.dispose();
      }
    });
  }

  // Agendamento
  void _mostrarAgendamento() {
    String valorAtual =
        necessitaAgendamento;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title:
              const Text('Agendamento'),
          content:
              DropdownButtonFormField<String>(
            value: valorAtual == 'SIM' ||
                    valorAtual == 'NÃO'
                ? valorAtual
                : null,
            decoration:
                const InputDecoration(
              labelText:
                  'Necessita agendamento?',
              border:
                  OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'SIM',
                child: Text('SIM'),
              ),
              DropdownMenuItem(
                value: 'NÃO',
                child: Text('NÃO'),
              ),
            ],
            onChanged: (valor) {
              setDialogState(() {
                valorAtual =
                    valor ?? valorAtual;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Fechar'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                await _salvarCampo(
                  'necessitaAgendamento',
                  valorAtual,
                );

                if (mounted) {
                  setState(() {
                    necessitaAgendamento =
                        valorAtual;
                  });
                }
              },
              child:
                  const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // Profissionais
  void _mostrarProfissionais() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Text(
            'Profissionais (${profissionais.length})',
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: profissionais.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum profissional cadastrado.',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              profissionais.length,
                          itemBuilder:
                              (context, index) {
                            final profissional =
                                profissionais[
                                    index];

                            final nomeProfissional =
                                _valor(
                              profissional[
                                  'nome'],
                            );

                            final especialidade =
                                _valor(
                              profissional[
                                      'especialidade'] ??
                                  profissional[
                                      'profissao'],
                            );

                            final fotoUrl =
                                profissional[
                                            'fotoUrl']
                                        ?.toString() ??
                                    '';

                            return Card(
                              child: ListTile(
                                leading:
                                    CircleAvatar(
                                  backgroundColor:
                                      verde,
                                  backgroundImage:
                                      fotoUrl
                                              .isNotEmpty
                                          ? NetworkImage(
                                              fotoUrl,
                                            )
                                          : null,
                                  child: fotoUrl
                                          .isEmpty
                                      ? const Icon(
                                          Icons
                                              .person,
                                          color: Colors
                                              .white,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  nomeProfissional,
                                ),
                                subtitle: Text(
                                  especialidade,
                                ),
                                trailing:
                                    IconButton(
                                  icon:
                                      const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                        Colors.red,
                                  ),
                                  onPressed:
                                      () async {
                                    final confirmar =
                                        await showDialog<
                                            bool>(
                                      context:
                                          dialogContext,
                                      builder:
                                          (ctx) =>
                                              AlertDialog(
                                        title:
                                            const Text(
                                          'Excluir profissional',
                                        ),
                                        content:
                                            const Text(
                                          'Tem certeza que deseja excluir esse profissional?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.pop(
                                              ctx,
                                              false,
                                            ),
                                            child:
                                                const Text(
                                              'Cancelar',
                                            ),
                                          ),
                                          ElevatedButton(
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red,
                                              foregroundColor:
                                                  Colors.white,
                                            ),
                                            onPressed:
                                                () =>
                                                    Navigator.pop(
                                              ctx,
                                              true,
                                            ),
                                            child:
                                                const Text(
                                              'Excluir',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar ==
                                        true) {
                                      setDialogState(
                                        () {
                                          profissionais
                                              .removeAt(
                                            index,
                                          );
                                        },
                                      );

                                      await _salvarLista(
                                        'profissionais',
                                        profissionais,
                                      );

                                      if (mounted) {
                                        setState(
                                          () {},
                                        );
                                      }

                                      _mostrarMensagem(
                                        'Profissional excluído com sucesso.',
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child:
                      ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final uidEmpresa =
                          empresaUid ??
                              FirebaseAuth
                                  .instance
                                  .currentUser
                                  ?.uid;

                      if (uidEmpresa ==
                              null ||
                          uidEmpresa
                              .trim()
                              .isEmpty) {
                        _mostrarMensagem(
                          'Não foi possível identificar a empresa.',
                        );
                        return;
                      }

                      final novo =
                          await Navigator.push<
                              Map<String,
                                  dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CadastroPage(
                            empresaUid:
                                uidEmpresa,
                          ),
                        ),
                      );

                      if (novo != null &&
                          mounted) {
                        final novoProfissional =
                            Map<String,
                                dynamic>.from(
                          novo,
                        );

                        final uidNovo =
                            novoProfissional[
                                        'uid']
                                    ?.toString() ??
                                '';

                        final existe =
                            profissionais.any(
                          (profissional) =>
                              profissional[
                                          'uid']
                                      ?.toString() ==
                                  uidNovo,
                        );

                        if (!existe) {
                          setDialogState(
                            () {
                              profissionais.add(
                                novoProfissional,
                              );
                            },
                          );
                        }

                        setState(() {});

                        _mostrarMensagem(
                          'Profissional adicionado com sucesso.',
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1,
                    ),
                    label: const Text(
                      'Adicionar profissional',
                    ),
                  ),
                ),
              ],
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
                  const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  // Fotos
  void _mostrarFotos() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Text(
            'Fotos (${fotos.length})',
          ),
          content: fotos.isEmpty
              ? const Text(
                  'Nenhuma foto cadastrada.',
                )
              : SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: fotos.length,
                    itemBuilder:
                        (context, index) {
                      final foto =
                          fotos[index]
                              .toString();

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                              child: Image.network(
                                foto,
                                fit:
                                    BoxFit.cover,
                                errorBuilder:
                                    (
                                  _,
                                  __,
                                  ___,
                                ) =>
                                        Container(
                                  color: Colors
                                      .grey
                                      .shade300,
                                  child:
                                      const Icon(
                                    Icons
                                        .broken_image,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed:
                                  () async {
                                setDialogState(
                                  () {
                                    fotos.removeAt(
                                      index,
                                    );
                                  },
                                );

                                await _salvarLista(
                                  'fotos',
                                  fotos,
                                );

                                if (mounted) {
                                  setState(
                                    () {},
                                  );
                                }
                              },
                              icon:
                                  const Icon(
                                Icons.delete,
                                color:
                                    Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                  const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  // Pagamentos
  void _mostrarPagamentos() {
    final controllers = {
      'cartao':
          TextEditingController(
        text: pagamentoCartao ==
                'Não informado'
            ? ''
            : pagamentoCartao,
      ),
      'pix': TextEditingController(
        text: pagamentoPix ==
                'Não informado'
            ? ''
            : pagamentoPix,
      ),
      'outros':
          TextEditingController(
        text: pagamentoOutros ==
                'Não informado'
            ? ''
            : pagamentoOutros,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder: (context, setDialogState) =>
            AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Formas de pagamento',
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () {
                  setDialogState(
                    () => editando = true,
                  );
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children:
                controllers.entries.map(
              (entry) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: TextField(
                    controller:
                        entry.value,
                    enabled: editando,
                    decoration:
                        InputDecoration(
                      labelText:
                          entry.key,
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  final pagamentos = {
                    for (final entry
                        in controllers.entries)
                      entry.key:
                          entry.value.text
                              .trim(),
                  };

                  Navigator.pop(
                    dialogContext,
                  );

                  await _salvarMapa(
                    'formasPagamento',
                    pagamentos,
                  );

                  if (mounted) {
                    setState(() {
                      pagamentoCartao =
                          _valor(
                        pagamentos[
                            'cartao'],
                      );

                      pagamentoPix =
                          _valor(
                        pagamentos[
                            'pix'],
                      );

                      pagamentoOutros =
                          _valor(
                        pagamentos[
                            'outros'],
                      );
                    });
                  }
                },
                child:
                    const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c
          in controllers.values) {
        c.dispose();
      }
    });
  }
}

// Máscara de horário
class _MascaraHora
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros =
        newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final limitado =
        numeros.length > 4
            ? numeros.substring(0, 4)
            : numeros;

    String resultado = limitado;

    if (limitado.length > 2) {
      resultado =
          '${limitado.substring(0, 2)}:${limitado.substring(2)}';
    }

    return TextEditingValue(
      text: resultado,
      selection:
          TextSelection.collapsed(
        offset: resultado.length,
      ),
    );
  }
}

// Erro ao alterar e-mail
class _ErroAlteracaoEmail
    implements Exception {
  final String codigo;

  const _ErroAlteracaoEmail(
    this.codigo,
  );
}