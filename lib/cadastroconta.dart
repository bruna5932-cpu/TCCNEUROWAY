import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neuroway/menuprincipal.dart';

class CriarConta extends StatefulWidget {
  const CriarConta({super.key});

  @override
  CriarContaState createState() => CriarContaState();
}

class CriarContaState extends State<CriarConta> {
  // Controladores
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Foto de perfil
  File? _fotoPerfil;
  final ImagePicker _seletorImagem = ImagePicker();

  // Controle da tela
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  String? _erroSenha;
  bool _carregando = false;

  @override
  void dispose() {
    _userController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Selecionar foto
  Future<void> _selecionarFoto() async {
    try {
      final XFile? imagem = await _seletorImagem.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        _fotoPerfil = File(imagem.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível selecionar a foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Realizar cadastro
  Future<void> _realizarCadastro() async {
    final String nome = _userController.text.trim();
    final String cidade = _cityController.text.trim();
    final String email = _emailController.text.trim();
    final String senha = _passwordController.text;
    final String confirmarSenha = _confirmPasswordController.text;

    if (nome.isEmpty ||
        cidade.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (senha != confirmarSenha) {
      setState(() {
        _erroSenha = 'As senhas não coincidem';
      });
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final UserCredential credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuario = credencial.user;

      if (usuario == null) {
        throw Exception(
          'O Firebase não retornou o usuário após o cadastro.',
        );
      }

      final String uid = usuario.uid;

      // Salvar usuário
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': nome,
        'cidade': cidade,
        'email': email,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _erroSenha = null;
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Menuprincipal(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Não foi possível criar a conta.';

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;

        case 'invalid-email':
          mensagem = 'Digite um e-mail válido.';
          break;

        case 'weak-password':
          mensagem = 'A senha é muito fraca.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O cadastro com e-mail e senha não está habilitado no Firebase.';
          break;

        case 'network-request-failed':
          mensagem =
              'Não foi possível conectar ao Firebase. Verifique sua internet.';
          break;

        case 'too-many-requests':
          mensagem =
              'Muitas tentativas. Aguarde um pouco e tente novamente.';
          break;

        default:
          mensagem =
              'Erro do Firebase:\nCódigo: ${e.code}\n${e.message ?? ''}';
      }

      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar no Firestore.\n'
            'Código: ${e.code}\n'
            '${e.message ?? ''}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado:\n$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double molduraHeight = screenHeight * 0.15;

    // Altura ocupada pelo teclado
    final double alturaTeclado =
        MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,

      // Impede que o Scaffold mova as molduras quando o teclado abre.
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // CONTEÚDO ROLÁVEL
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight,
                  bottom: molduraHeight,
                ),

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,

                      padding: EdgeInsets.only(
                        bottom: alturaTeclado > 0 ? 20 : 0,
                      ),

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),

                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              // TÍTULO
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),

                                child: Stack(
                                  alignment: Alignment.center,

                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,

                                      child: IconButton(
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

                                    Image.asset(
                                      'imagem/criarconta.png',
                                      width: 224,
                                      height: 147,

                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Text(
                                          'Criar Conta',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // CAMPOS
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),

                                child: Column(
                                  children: [
                                    _buildTextField(
                                      'Nome de Usuário',
                                      _userController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),

                                    const SizedBox(height: 15),

                                    _buildTextField(
                                      'Cidade',
                                      _cityController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),

                                    const SizedBox(height: 15),

                                    _buildTextField(
                                      'E-mail',
                                      _emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                    ),

                                    const SizedBox(height: 15),

                                    _buildTextField(
                                      'Senha',
                                      _passwordController,
                                      isPassword: true,
                                      isVisible: _senhaVisivel,

                                      onVisibilityChanged: () {
                                        setState(() {
                                          _senhaVisivel = !_senhaVisivel;
                                        });
                                      },

                                      onChanged: (value) {
                                        if (_confirmPasswordController
                                            .text.isNotEmpty) {
                                          setState(() {
                                            if (value !=
                                                _confirmPasswordController
                                                    .text) {
                                              _erroSenha =
                                                  'As senhas não coincidem';
                                            } else {
                                              _erroSenha = null;
                                            }
                                          });
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 15),

                                    _buildTextField(
                                      'Confirmar Senha',
                                      _confirmPasswordController,
                                      isPassword: true,
                                      isVisible: _confirmarSenhaVisivel,

                                      onVisibilityChanged: () {
                                        setState(() {
                                          _confirmarSenhaVisivel =
                                              !_confirmarSenhaVisivel;
                                        });
                                      },

                                      onChanged: (value) {
                                        setState(() {
                                          if (value.isEmpty) {
                                            _erroSenha = null;
                                          } else if (value !=
                                              _passwordController.text) {
                                            _erroSenha =
                                                'As senhas não coincidem';
                                          } else {
                                            _erroSenha = null;
                                          }
                                        });
                                      },
                                    ),

                                    if (_erroSenha != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                          left: 15,
                                        ),

                                        child: Align(
                                          alignment: Alignment.centerLeft,

                                          child: Text(
                                            _erroSenha!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 25),

                                    // FOTO
                                    const Text(
                                      'Foto de perfil',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    GestureDetector(
                                      onTap: _carregando
                                          ? null
                                          : _selecionarFoto,

                                      child: Container(
                                        width: 110,
                                        height: 110,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFF1F1F1),
                                          border: Border.all(
                                            color: const Color(0xFF98B9A6),
                                            width: 2,
                                          ),
                                        ),

                                        child: _fotoPerfil != null
                                            ? ClipOval(
                                                child: Image.file(
                                                  _fotoPerfil!,
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,

                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo_outlined,
                                                    size: 35,
                                                    color: Colors.black54,
                                                  ),

                                                  SizedBox(height: 5),

                                                  Text(
                                                    'Adicionar',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    TextButton(
                                      onPressed: _carregando
                                          ? null
                                          : _selecionarFoto,

                                      child: Text(
                                        _fotoPerfil == null
                                            ? 'Selecionar foto'
                                            : 'Alterar foto',

                                        style: const TextStyle(
                                          color: Color(0xFF76A085),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // BOTÃO CADASTRAR
                                    ElevatedButton(
                                      onPressed: _carregando
                                          ? null
                                          : _realizarCadastro,

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF98B9A6),
                                        foregroundColor: Colors.black,
                                        disabledBackgroundColor:
                                            const Color(0xFF98B9A6),
                                        disabledForegroundColor: Colors.black,

                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 45,
                                          vertical: 15,
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),

                                        elevation: 2,
                                      ),

                                      child: _carregando
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,

                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.black,
                                              ),
                                            )
                                          : const Text(
                                              'Cadastrar',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // QUEBRA-CABEÇA SUPERIOR FIXO
          Positioned(
            top: 0,
            left: 0,
            right: 0,

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

          // QUEBRA-CABEÇA INFERIOR FIXO
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

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
        ],
      ),
    );
  }

  // CAMPO DE TEXTO
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      cursorColor: const Color(0xFF7952A3),

      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),

      decoration: InputDecoration(
        labelText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),

        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),
            width: 1,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: onVisibilityChanged,
              )
            : null,
      ),
    );
  }
}