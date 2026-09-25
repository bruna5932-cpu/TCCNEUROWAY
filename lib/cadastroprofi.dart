
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
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

  File? _fotoSelecionada;

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

  // ============================================================
  // SELECIONAR FOTO
  // ============================================================

  Future<void> _selecionarFoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem != null) {
        setState(() {
          _fotoSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao selecionar imagem: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMATAR TELEFONE
  // ============================================================

  String _formatarTelefone(String valor) {
    String numeros = valor.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }

    if (numeros.length <= 2) {
      return '($numeros';
    }

    if (numeros.length <= 7) {
      return '(${numeros.substring(0, 2)}) '
          '${numeros.substring(2)}';
    }

    if (numeros.length <= 11) {
      return '(${numeros.substring(0, 2)}) '
          '${numeros.substring(2, 7)}-'
          '${numeros.substring(7)}';
    }

    return valor;
  }

  // ============================================================
  // CADASTRAR PROFISSIONAL
  // ============================================================

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final descricao = _descricaoController.text.trim();
    final profissao = _profissaoController.text.trim();
    final experiencia = _experienciaController.text.trim();
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    if (nome.isEmpty ||
        email.isEmpty ||
        telefone.isEmpty ||
        profissao.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos obrigatórios.',
          ),
        ),
      );

      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A senha deve ter pelo menos 6 caracteres.',
          ),
        ),
      );

      return;
    }

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      // --------------------------------------------------------
      // CRIAR USUÁRIO NO FIREBASE AUTH
      // --------------------------------------------------------

      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final usuarioCriado = credencial.user;

      if (usuarioCriado == null) {
        throw Exception(
          'Não foi possível criar o usuário.',
        );
      }

      String? fotoUrl;

      // --------------------------------------------------------
      // ENVIAR FOTO PARA O FIREBASE STORAGE
      // --------------------------------------------------------

      if (_fotoSelecionada != null) {
        final referencia = FirebaseStorage.instance
            .ref()
            .child('profissionais')
            .child('${usuarioCriado.uid}.jpg');

        await referencia.putFile(
          _fotoSelecionada!,
        );

        fotoUrl = await referencia.getDownloadURL();
      }

      // --------------------------------------------------------
      // SALVAR PROFISSIONAL NO FIRESTORE
      // --------------------------------------------------------

      await FirebaseFirestore.instance
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
        'tipo': 'profissional',
        'fotoUrl': fotoUrl ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // --------------------------------------------------------
      // DEVOLVER DADOS PARA A TELA DE CADASTRO DA EMPRESA
      // --------------------------------------------------------

      Navigator.pop(
        context,
        {
          'nome': nome,
          'especialidade': profissao,
          'uid': usuarioCriado.uid,
          'fotoUrl': fotoUrl ?? '',
        },
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao cadastrar profissional.';

      if (e.code == 'email-already-in-use') {
        mensagem = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'invalid-email') {
        mensagem = 'Digite um e-mail válido.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A senha é muito fraca.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao cadastrar: $e',
          ),
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

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.black,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIÇÃO
  // ============================================================

  Widget _campoDescricao() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: _descricaoController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Descrição',
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.black,
          ),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context).size.height;

    final double molduraHeight =
        screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // QUEBRA-CABEÇA SUPERIOR
              // ==================================================

              // QUEBRA-CABEÇA SUPERIOR
              SizedBox(
                height: molduraHeight,
                width: double.infinity,
                child: Image.asset(
                  'imagem/quebrasuperior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // MESMO ESPAÇO NAS DUAS TELAS
              const SizedBox(
                height: 10,
              ),

              // CABEÇALHO
              Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 16,
                ),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                            size: 22,
                          ),
                          onPressed: _carregando
                              ? null
                              : () {
                                  Navigator.maybePop(context);
                                },
                        ),
                      ),

                      Center(
                        child: Image.asset(
                          'imagem/Cadastro_profissionais.png',
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // ==================================================
              // CONTEÚDO
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // FOTO
                    Center(
                      child: GestureDetector(
                        onTap: _carregando
                            ? null
                            : _selecionarFoto,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: _fotoSelecionada != null
                                ? Image.file(
                                    _fotoSelecionada!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Center(
                      child: TextButton(
                        onPressed: _carregando
                            ? null
                            : _selecionarFoto,
                        child: const Text(
                          'Adicionar foto',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // NOME
                    _campoTexto(
                      label: 'Nome',
                      controller: _nomeController,
                      keyboardType: TextInputType.name,
                    ),

                    // E-MAIL
                    _campoTexto(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                    ),

                    // TELEFONE
                    _campoTexto(
                      label: 'Telefone',
                      controller: _telefoneController,
                      keyboardType:
                          TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          11,
                        ),
                      ],
                    ),

                    // PROFISSÃO
                    _campoTexto(
                      label: 'Profissão / Especialidade',
                      controller: _profissaoController,
                      keyboardType: TextInputType.text,
                    ),

                    // EXPERIÊNCIA
                    _campoTexto(
                      label: 'Experiência',
                      controller:
                          _experienciaController,
                      keyboardType: TextInputType.text,
                    ),

                    // DESCRIÇÃO
                    _campoDescricao(),

                    // SENHA
                    _campoTexto(
                      label: 'Senha',
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarSenha
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarSenha =
                                !_mostrarSenha;
                          });
                        },
                      ),
                    ),

                    // CONFIRMAR SENHA
                    _campoTexto(
                      label: 'Confirmar senha',
                      controller:
                          _confirmarSenhaController,
                      obscureText:
                          !_mostrarConfirmarSenha,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarConfirmarSenha
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarConfirmarSenha =
                                !_mostrarConfirmarSenha;
                          });
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // BOTÃO CADASTRAR
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _carregando
                                ? null
                                : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF76A085),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cadastrar profissional',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // QUEBRA-CABEÇA INFERIOR
              // ==================================================

              SizedBox(
                height: molduraHeight,
                width: double.infinity,
                child: Image.asset(
                  'imagem/quebrainferior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

