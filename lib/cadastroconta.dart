
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroway/menuprincipal.dart';

class CriarConta extends StatefulWidget {
  const CriarConta({super.key});

  @override
  CriarContaState createState() => CriarContaState();
}

class CriarContaState extends State<CriarConta> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Controla a visualização das senhas
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  // Mensagem de erro das senhas
  String? _erroSenha;

  // Controla o carregamento
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

  // ============================================================
  // FUNÇÃO DE CADASTRO
  // ============================================================
  Future<void> _realizarCadastro() async {
    final String nome = _userController.text.trim();
    final String cidade = _cityController.text.trim();
    final String email = _emailController.text.trim();
    final String senha = _passwordController.text;
    final String confirmarSenha = _confirmPasswordController.text;

    // ------------------------------------------------------------
    // VERIFICA SE TODOS OS CAMPOS FORAM PREENCHIDOS
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // VERIFICA SE AS SENHAS SÃO IGUAIS
    // ------------------------------------------------------------
    if (senha != confirmarSenha) {
      setState(() {
        _erroSenha = 'As senhas não coincidem';
      });

      return;
    }

    // ------------------------------------------------------------
    // INICIA O CARREGAMENTO
    // ------------------------------------------------------------
    setState(() {
      _carregando = true;
    });

    try {
      // ==========================================================
      // 1. CRIA A CONTA NO FIREBASE AUTHENTICATION
      // ==========================================================
      debugPrint('======================================');
      debugPrint('INICIANDO CADASTRO');
      debugPrint('E-mail: $email');
      debugPrint('======================================');

      final UserCredential credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuario = credencial.user;

      // Verifica se o usuário foi realmente criado
      if (usuario == null) {
        throw Exception(
          'O Firebase não retornou o usuário após o cadastro.',
        );
      }

      final String uid = usuario.uid;

      debugPrint('======================================');
      debugPrint('USUÁRIO CRIADO NO AUTHENTICATION');
      debugPrint('UID: $uid');
      debugPrint('======================================');

      // ==========================================================
      // 2. SALVA OS DADOS NO FIRESTORE
      // ==========================================================
      debugPrint('======================================');
      debugPrint('SALVANDO DADOS NO FIRESTORE');
      debugPrint('Coleção: usuarios');
      debugPrint('Documento: $uid');
      debugPrint('======================================');

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set({
        'nome': nome,
        'cidade': cidade,
        'email': email,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      debugPrint('======================================');
      debugPrint('DADOS SALVOS COM SUCESSO NO FIRESTORE');
      debugPrint('======================================');

      if (!mounted) return;

      // Remove o erro de senha caso exista
      setState(() {
        _erroSenha = null;
        _carregando = false;
      });

      // ==========================================================
      // 3. MOSTRA MENSAGEM DE SUCESSO
      // ==========================================================
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

      // ==========================================================
      // 4. VAI PARA O MENU PRINCIPAL
      // ==========================================================
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Menuprincipal(),
        ),
        (route) => false,
      );
    }

    // ============================================================
    // ERROS DO FIREBASE AUTHENTICATION
    // ============================================================
    on FirebaseAuthException catch (e) {
      debugPrint('======================================');
      debugPrint('ERRO NO FIREBASE AUTHENTICATION');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('======================================');

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
    }

    // ============================================================
    // ERROS DO FIRESTORE
    // ============================================================
    on FirebaseException catch (e) {
      debugPrint('======================================');
      debugPrint('ERRO NO FIRESTORE');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Plugin: ${e.plugin}');
      debugPrint('======================================');

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
    }

    // ============================================================
    // OUTROS ERROS
    // ============================================================
    catch (e) {
      debugPrint('======================================');
      debugPrint('ERRO DESCONHECIDO');
      debugPrint('$e');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro inesperado:\n$e',
          ),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ========================================================
          // CONTEÚDO PRINCIPAL
          // ========================================================
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight,
                  bottom: molduraHeight,
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - molduraHeight * 2,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ==================================================
                          // TÍTULO + BOTÃO VOLTAR
                          // ==================================================
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
                                  "imagem/criarconta.png",
                                  width: 224,
                                  height: 147,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Text(
                                      "Criar Conta",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // CAMPOS
                          // ==================================================
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                            ),
                            child: Column(
                              children: [
                                // ------------------------------------------------
                                // NOME
                                // ------------------------------------------------
                                _buildTextField(
                                  "Nome de Usuário",
                                  _userController,
                                ),

                                const SizedBox(height: 15),

                                // ------------------------------------------------
                                // CIDADE
                                // ------------------------------------------------
                                _buildTextField(
                                  "Cidade",
                                  _cityController,
                                ),

                                const SizedBox(height: 15),

                                // ------------------------------------------------
                                // E-MAIL
                                // ------------------------------------------------
                                _buildTextField(
                                  "E-mail",
                                  _emailController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 15),

                                // ------------------------------------------------
                                // SENHA
                                // ------------------------------------------------
                                _buildTextField(
                                  "Senha",
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
                                            _confirmPasswordController.text) {
                                          _erroSenha =
                                              "As senhas não coincidem";
                                        } else {
                                          _erroSenha = null;
                                        }
                                      });
                                    }
                                  },
                                ),

                                const SizedBox(height: 15),

                                // ------------------------------------------------
                                // CONFIRMAR SENHA
                                // ------------------------------------------------
                                _buildTextField(
                                  "Confirmar Senha",
                                  _confirmPasswordController,
                                  isPassword: true,
                                  isVisible:
                                      _confirmarSenhaVisivel,
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
                                            "As senhas não coincidem";
                                      } else {
                                        _erroSenha = null;
                                      }
                                    });
                                  },
                                ),

                                // ==================================================
                                // MENSAGEM DE ERRO DA SENHA
                                // ==================================================
                                if (_erroSenha != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      left: 15,
                                    ),
                                    child: Align(
                                      alignment:
                                          Alignment.centerLeft,
                                      child: Text(
                                        _erroSenha!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 30),

                                // ==================================================
                                // BOTÃO CADASTRAR
                                // ==================================================
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
                                    disabledForegroundColor:
                                        Colors.black,
                                    padding:
                                        const EdgeInsets.symmetric(
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
                                          "Cadastrar",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

          // ============================================================
          // MOLDURA INFERIOR
          // ============================================================
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

  // ============================================================
  // FUNÇÃO PARA CRIAR OS CAMPOS DE TEXTO
  // ============================================================
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5D8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,

        // Esconde ou mostra a senha
        obscureText: isPassword && !isVisible,

        // Tipo do teclado
        keyboardType: keyboardType,

        // Detecta alterações
        onChanged: onChanged,

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),

          border: InputBorder.none,

          // ========================================================
          // OLHINHO DA SENHA
          // ========================================================
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility
                        : Icons.visibility_outlined,
                    color: Colors.black,
                  ),
                  onPressed: onVisibilityChanged,
                )
              : null,
        ),
      ),
    );
  }
}

