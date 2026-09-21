import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroway/cadastroempresa.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _imagePicker = ImagePicker();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _experienciaController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _carregando = false;
  bool _enviandoFoto = false;

  XFile? _fotoSelecionada;

  // ============================================================
  // ADICIONAR FOTO
  // ============================================================

  Future<void> _adicionarFoto() async {
    if (_enviandoFoto || _carregando) {
      return;
    }

    FocusScope.of(context).unfocus();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar foto de perfil',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF98B9A6),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Escolher da galeria',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Escolha uma foto já salva no celular',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _selecionarDaGaleria();
                  },
                ),

                const SizedBox(height: 5),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF98B9A6),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Tirar uma foto',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Use a câmera do celular',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _tirarFoto();
                  },
                ),

                if (_fotoSelecionada != null) ...[
                  const SizedBox(height: 5),

                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      'Remover foto',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        _fotoSelecionada = null;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GALERIA
  // ============================================================

  Future<void> _selecionarDaGaleria() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (foto == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _fotoSelecionada = foto;
      });
    } catch (e) {
      debugPrint(
        'Erro ao selecionar foto da galeria: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível selecionar a foto: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CÂMERA
  // ============================================================

  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (foto == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _fotoSelecionada = foto;
      });
    } catch (e) {
      debugPrint(
        'Erro ao tirar foto: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir a câmera: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // ENVIAR FOTO PARA O FIREBASE STORAGE
  // ============================================================

  Future<String> _enviarFotoParaFirebase(
    String profissionalUid,
  ) async {
    final foto = _fotoSelecionada;

    if (foto == null) {
      return '';
    }

    setState(() {
      _enviandoFoto = true;
    });

    try {
      final Uint8List bytes = await foto.readAsBytes();

      final Reference referencia = _storage
          .ref()
          .child('profissionais')
          .child(profissionalUid)
          .child('foto_perfil.jpg');

      final UploadTask uploadTask = referencia.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      await uploadTask;

      final String url =
          await referencia.getDownloadURL();

      return url;
    } finally {
      if (mounted) {
        setState(() {
          _enviandoFoto = false;
        });
      }
    }
  }

  // ============================================================
  // CADASTRAR PROFISSIONAL
  // ============================================================

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_carregando) {
      return;
    }

    final String nome =
        _nomeController.text.trim();

    final String email =
        _emailController.text.trim();

    final String telefone =
        _telefoneController.text.trim();

    final String descricao =
        _descricaoController.text.trim();

    final String profissao =
        _profissaoController.text.trim();

    final String experiencia =
        _experienciaController.text.trim();

    final String senha =
        _senhaController.text;

    final String confirmarSenha =
        _confirmarSenhaController.text;

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      // --------------------------------------------------------
      // CRIAR CONTA
      // --------------------------------------------------------

      final UserCredential credencial =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuarioCriado =
          credencial.user;

      if (usuarioCriado == null) {
        throw Exception(
          'Não foi possível criar a conta do profissional.',
        );
      }

      // --------------------------------------------------------
      // NOME NO FIREBASE AUTH
      // --------------------------------------------------------

      await usuarioCriado.updateDisplayName(
        nome,
      );

      // --------------------------------------------------------
      // ENVIAR FOTO
      // --------------------------------------------------------

      String fotoUrl = '';

      if (_fotoSelecionada != null) {
        fotoUrl = await _enviarFotoParaFirebase(
          usuarioCriado.uid,
        );
      }

      // --------------------------------------------------------
      // SALVAR PROFISSIONAL NO FIRESTORE
      // --------------------------------------------------------

      await _firestore
          .collection('profissionais')
          .doc(usuarioCriado.uid)
          .set({
        'uid': usuarioCriado.uid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'descricao': descricao,
        'profissao': profissao,
        'experiencia': experiencia,
        'foto': fotoUrl,
        'fotoUrl': fotoUrl,
        'tipo': 'profissional',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profissional cadastrado com sucesso!',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // DEVOLVE OS DADOS PARA CADASTROEMPRESA
      // --------------------------------------------------------

      Navigator.pop(
        context,
        {
          'nome': nome,
          'especialidade': profissao,
          'profissao': profissao,
          'experiencia': experiencia,
          'uid': usuarioCriado.uid,
          'foto': fotoUrl,
          'fotoUrl': fotoUrl,
          'descricao': descricao,
          'telefone': telefone,
          'email': email,
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem =
              'Este e-mail já está cadastrado.';
          break;

        case 'invalid-email':
          mensagem =
              'O e-mail informado é inválido.';
          break;

        case 'weak-password':
          mensagem =
              'A senha deve ter pelo menos 6 caracteres.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O cadastro por e-mail e senha não está habilitado no Firebase.';
          break;

        case 'network-request-failed':
          mensagem =
              'Erro de conexão. Verifique sua internet.';
          break;

        case 'configuration-not-found':
          mensagem =
              'A configuração do Firebase não foi encontrada. Verifique o firebase_options.dart e o projeto Firebase.';
          break;

        default:
          mensagem =
              'Erro ao cadastrar: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem;

      switch (e.code) {
        case 'permission-denied':
          mensagem =
              'O Firebase não permitiu salvar os dados. Verifique as regras do Firestore.';
          break;

        case 'unauthorized':
          mensagem =
              'O Firebase Storage não permitiu enviar a foto. Verifique as regras do Storage.';
          break;

        case 'object-not-found':
          mensagem =
              'Não foi possível encontrar o arquivo no Firebase Storage.';
          break;

        case 'canceled':
          mensagem =
              'O envio da foto foi cancelado.';
          break;

        case 'unavailable':
          mensagem =
              'O Firebase está indisponível. Verifique sua conexão.';
          break;

        default:
          mensagem =
              'Erro no Firebase: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _profissaoController.dispose();
    _experienciaController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final molduraHeight =
        screenHeight * 0.25;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ====================================================
          // CONTEÚDO
          // ====================================================

          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight * 0.75,
                  bottom: molduraHeight * 0.75,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior
                            .onDrag,
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // ==================================================
                            // TÍTULO
                            // ==================================================

                            const Text(
                              'Cadastro',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const Text(
                              'de profissionais',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ==================================================
                            // NOME
                            // ==================================================

                            _buildTextField(
                              label: 'Nome:',
                              controller:
                                  _nomeController,
                            ),

                            // ==================================================
                            // E-MAIL
                            // ==================================================

                            _buildTextField(
                              label: 'E-mail:',
                              controller:
                                  _emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                              validator:
                                  _validarEmail,
                            ),

                            // ==================================================
                            // TELEFONE
                            // ==================================================

                            _buildTextField(
                              label: 'Telefone:',
                              controller:
                                  _telefoneController,
                              hintText:
                                  '(12) 99999-9999',
                              keyboardType:
                                  TextInputType.phone,
                            ),

                            // ==================================================
                            // DESCRIÇÃO
                            // ==================================================

                            _buildTextField(
                              label: 'Descrição:',
                              controller:
                                  _descricaoController,
                              maxLines: 3,
                            ),

                            // ==================================================
                            // PROFISSÃO
                            // ==================================================

                            _buildTextField(
                              label: 'Profissão:',
                              controller:
                                  _profissaoController,
                            ),

                            // ==================================================
                            // EXPERIÊNCIA
                            // ==================================================

                            _buildTextField(
                              label:
                                  'Tempo de experiência:',
                              controller:
                                  _experienciaController,
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // SENHA
                            // ==================================================

                            _buildTextField(
                              label: 'Senha:',
                              controller:
                                  _senhaController,
                              obscureText:
                                  !_mostrarSenha,
                              suffixIcon:
                                  IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarSenha =
                                        !_mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility
                                      : Icons
                                          .visibility_off,
                                  color:
                                      Colors.grey[700],
                                  size: 21,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Campo obrigatório';
                                }

                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }

                                return null;
                              },
                            ),

                            // ==================================================
                            // CONFIRMAR SENHA
                            // ==================================================

                            _buildTextField(
                              label:
                                  'Confirmar senha:',
                              controller:
                                  _confirmarSenhaController,
                              obscureText:
                                  !_mostrarConfirmarSenha,
                              suffixIcon:
                                  IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarConfirmarSenha =
                                        !_mostrarConfirmarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarConfirmarSenha
                                      ? Icons.visibility
                                      : Icons
                                          .visibility_off,
                                  color:
                                      Colors.grey[700],
                                  size: 21,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Campo obrigatório';
                                }

                                if (value !=
                                    _senhaController
                                        .text) {
                                  return 'As senhas não coincidem';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // FOTO DE PERFIL
                            // ==================================================

                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap:
                                        _adicionarFoto,
                                    child:
                                        Container(
                                      width: 110,
                                      height: 110,
                                      decoration:
                                          BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        color:
                                            Colors.grey[600],
                                        border:
                                            Border.all(
                                          color:
                                              Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors
                                                .black
                                                .withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 6,
                                            offset:
                                                const Offset(
                                              0,
                                              3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child:
                                          ClipOval(
                                        child:
                                            _fotoSelecionada !=
                                                    null
                                                ? FutureBuilder<
                                                    Uint8List>(
                                                    future:
                                                        _fotoSelecionada!
                                                            .readAsBytes(),
                                                    builder:
                                                        (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                Colors.white,
                                                          ),
                                                        );
                                                      }

                                                      if (!snapshot
                                                          .hasData) {
                                                        return const Icon(
                                                          Icons
                                                              .person,
                                                          size:
                                                              65,
                                                          color:
                                                              Colors.white,
                                                        );
                                                      }

                                                      return Image
                                                          .memory(
                                                        snapshot
                                                            .data!,
                                                        width:
                                                            110,
                                                        height:
                                                            110,
                                                        fit: BoxFit
                                                            .cover,
                                                      );
                                                    },
                                                  )
                                                : const Icon(
                                                    Icons.person,
                                                    size: 65,
                                                    color:
                                                        Colors.white,
                                                  ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  InkWell(
                                    onTap:
                                        _adicionarFoto,
                                    child:
                                        const Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Adicionar foto',
                                          style:
                                              TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(
                                            width: 5),
                                        Icon(
                                          Icons
                                              .add_a_photo_outlined,
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (_fotoSelecionada !=
                                      null)
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(
                                        top: 6,
                                      ),
                                      child: Text(
                                        'Foto selecionada',
                                        style:
                                            TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            // ==================================================
                            // BOTÃO CADASTRAR
                            // ==================================================

                            ElevatedButton(
                              onPressed:
                                  _carregando
                                      ? null
                                      : _cadastrar,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF98B9A6,
                                ),
                                foregroundColor:
                                    Colors.black,
                                disabledBackgroundColor:
                                    Colors.grey[400],
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                elevation: 2,
                              ),
                              child: _carregando
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2.5,
                                        color:
                                            Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Cadastrar',
                                      style:
                                          TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // MOLDURA SUPERIOR
          // ============================================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: molduraHeight,
                child: Image.asset(
                  'imagem/quebrasuperior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // ============================================================
          // MOLDURA INFERIOR
          // ============================================================

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: molduraHeight,
                child: Image.asset(
                  'imagem/quebrainferior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ============================================================
          // BOTÃO VOLTAR
          // ============================================================

          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CadastroEmpresa(),
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALIDAÇÃO DO E-MAIL
  // ============================================================

  String? _validarEmail(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final email = value.trim();

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(email)) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines:
                  obscureText ? 1 : maxLines,
              obscureText: obscureText,
              style: const TextStyle(
                fontSize: 16,
              ),
              validator: validator ??
                  (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }

                    return null;
                  },
              decoration:
                  InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 4,
                ),
                suffixIcon:
                    suffixIcon,
                suffixIconConstraints:
                    const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                enabledBorder:
                    const UnderlineInputBorder(
                  borderSide:
                      BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder:
                    const UnderlineInputBorder(
                  borderSide:
                      BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                errorBorder:
                    const UnderlineInputBorder(
                  borderSide:
                      BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder:
                    const UnderlineInputBorder(
                  borderSide:
                      BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                errorStyle:
                    const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}