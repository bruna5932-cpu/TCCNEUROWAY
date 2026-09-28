import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neuroway/cadastroconta.dart';
import 'package:neuroway/cadastroempresa.dart';
import 'package:neuroway/menuprincipal.dart';

class LOGIN extends StatefulWidget {
  const LOGIN({super.key});

  @override
  State<LOGIN> createState() => LOGINState();
}

class LOGINState extends State<LOGIN> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _mostrarSenha = false;
  bool _carregando = false;

  String? _erroLogin;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNÇÃO DE LOGIN
  Future<void> _realizarLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    setState(() {
      _erroLogin = null;
    });

    if (email.isEmpty) {
      setState(() {
        _erroLogin = 'Digite seu e-mail.';
      });
      return;
    }

    if (senha.isEmpty) {
      setState(() {
        _erroLogin = 'Digite sua senha.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _erroLogin = 'Digite um e-mail válido.';
      });
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {

      // FIREBASE AUTHENTICATION
      final UserCredential resultado =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuario = resultado.user;

      if (usuario == null) {
        throw Exception(
          'Não foi possível identificar o usuário.',
        );
      }

      debugPrint(
        'Login realizado com sucesso. UID: ${usuario.uid}',
      );

      // FIRESTORE
      try {
        final DocumentSnapshot<Map<String, dynamic>> documento =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(usuario.uid)
                .get();

        if (documento.exists) {
          debugPrint(
            'Usuário encontrado no Firestore.',
          );

          debugPrint(
            'Dados: ${documento.data()}',
          );
        } else {
          debugPrint(
            'Usuário autenticado, mas não possui documento '
            'na coleção usuarios.',
          );
        }
      } on FirebaseException catch (e) {
        debugPrint(
          'Erro ao consultar Firestore: '
          '${e.code} - ${e.message}',
        );
      }

      // LOGIN CONCLUÍDO
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Menuprincipal(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Erro Firebase Authentication: '
        '${e.code} - ${e.message}',
      );

      String mensagem;

      switch (e.code) {
        case 'invalid-credential':
          mensagem = 'E-mail ou senha incorretos.';
          break;

        case 'invalid-email':
          mensagem = 'O e-mail informado é inválido.';
          break;

        case 'user-disabled':
          mensagem = 'Esta conta foi desativada.';
          break;

        case 'user-not-found':
          mensagem = 'Não existe uma conta com este e-mail.';
          break;

        case 'wrong-password':
          mensagem = 'Senha incorreta.';
          break;

        case 'too-many-requests':
          mensagem =
              'Muitas tentativas de login. '
              'Tente novamente mais tarde.';
          break;

        case 'network-request-failed':
          mensagem =
              'Erro de conexão. Verifique sua internet.';
          break;

        case 'configuration-not-found':
          mensagem =
              'A configuração do Firebase não foi encontrada. '
              'Verifique o Firebase Authentication e o '
              'firebase_options.dart.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O login por e-mail e senha não está habilitado '
              'no Firebase Authentication.';
          break;

        default:
          mensagem =
              'Não foi possível realizar o login.\n'
              'Código: ${e.code}';
      }

      if (!mounted) return;

      setState(() {
        _erroLogin = mensagem;
      });
    } on FirebaseException catch (e) {
      debugPrint(
        'Erro Firebase: ${e.code} - ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _erroLogin =
            'Erro do Firebase:\n'
            'Código: ${e.code}\n'
            '${e.message ?? ''}';
      });
    } catch (e) {
      debugPrint(
        'Erro inesperado durante o login: $e',
      );

      if (!mounted) return;

      setState(() {
        _erroLogin =
            'Ocorreu um erro inesperado. '
            'Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // TELA
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final molduraHeight = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [

          // CONTEÚDO ROLÁVEL
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.manual,

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),

                child: Padding(
                  padding: EdgeInsets.only(
                    top: molduraHeight * 1.2,
                    bottom: molduraHeight * 0.6,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),

                      // CABEÇALHO COM SETA E LOGO
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        child: SizedBox(
                          width: double.infinity,

                          height: screenHeight * 0.075,

                          child: Stack(
                            alignment: Alignment.center,

                            children: [
                              // SETA PARA VOLTAR

                              Align(
                                alignment: Alignment.centerLeft,

                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black,
                                    size: 22,
                                  ),

                                  onPressed: () {
                                    Navigator.maybePop(context);
                                  },
                                ),
                              ),

                              // LOGO CENTRALIZADA

                              Center(
                                child: SizedBox(
                                  width: screenWidth * 0.45,
                                  height: screenHeight * 0.055,

                                  child: Image.asset(
                                    'imagem/login.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.015,
                      ),

                      // CAMPOS
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                        ),

                        child: Column(
                          children: [
                            // E-MAIL

                            _buildTextField(
                              "E-mail",
                              _emailController,
                            ),

                            SizedBox(
                              height: screenHeight * 0.02,
                            ),

                            // SENHA

                            _buildTextField(
                              "Senha",
                              _passwordController,
                              isPassword: true,
                            ),

                            // MENSAGEM DE ERRO
                            if (_erroLogin != null) ...[
                              SizedBox(
                                height: screenHeight * 0.015,
                              ),

                              Container(
                                width: double.infinity,

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),

                                child: Text(
                                  _erroLogin!,
                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize:
                                        screenWidth * 0.035,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.04,
                      ),

                      // BOTÕES LOGIN E CADASTRAR
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          // BOTÃO LOGIN

                          ElevatedButton(
                            onPressed: _carregando
                                ? null
                                : _realizarLogin,

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF98B9A6),

                              disabledBackgroundColor:
                                  const Color(0xFFB8C9BF),

                              foregroundColor: Colors.black,

                              padding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    screenWidth * 0.07,
                                vertical:
                                    screenHeight * 0.015,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),

                              elevation: 2,
                            ),

                            child: _carregando
                                ? SizedBox(
                                    width:
                                        screenWidth * 0.045,
                                    height:
                                        screenWidth * 0.045,

                                    child:
                                        const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    "Login",

                                    style: TextStyle(
                                      fontSize:
                                          screenWidth * 0.045,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                          ),

                          SizedBox(
                            width: screenWidth * 0.04,
                          ),

                          // BOTÃO CADASTRAR

                          ElevatedButton(
                            onPressed: _carregando
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CriarConta(),
                                      ),
                                    );
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF98B9A6),

                              disabledBackgroundColor:
                                  const Color(0xFFB8C9BF),

                              foregroundColor: Colors.black,

                              padding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    screenWidth * 0.07,
                                vertical:
                                    screenHeight * 0.015,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),

                              elevation: 2,
                            ),

                            child: Text(
                              "Cadastrar",

                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.045,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: screenHeight * 0.05,
                      ),

                      // CADASTRO DE EMPRESA
                      Center(
                        child: GestureDetector(
                          onTap: _carregando
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CadastroEmpresa(),
                                    ),
                                  );
                                },

                          child: Text(
                            'Quero cadastrar\n'
                            'minha empresa',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.055,

                              fontWeight:
                                  FontWeight.bold,

                              color: Colors.black,

                              decoration:
                                  TextDecoration.underline,

                              decorationThickness: 2.0,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                    ],
                  ),
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
  }) {
    return TextFormField(
      controller: controller,

      obscureText: isPassword && !_mostrarSenha,

      keyboardType: hint == "E-mail"
          ? TextInputType.emailAddress
          : TextInputType.text,

      textInputAction: isPassword
          ? TextInputAction.done
          : TextInputAction.next,

      onFieldSubmitted: isPassword
          ? (_) {
              if (!_carregando) {
                _realizarLogin();
              }
            }
          : null,

      decoration: InputDecoration(
        labelText: hint,

        labelStyle: const TextStyle(
          color: Colors.black,
        ),

        floatingLabelStyle: const TextStyle(
          color: Colors.black,
        ),

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.grey,
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

        // OLHINHO DA SENHA

        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _mostrarSenha = !_mostrarSenha;
                  });
                },

                icon: Icon(
                  _mostrarSenha
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,

                  color: Colors.black,
                ),
              )
            : null,
      ),
    );
  }
}