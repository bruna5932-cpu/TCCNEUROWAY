import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Adicionar foto
  Future<void> _adicionarFoto() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A função de adicionar foto ainda não foi configurada.',
        ),
      ),
    );
  }

  // Cadastrar profissional
  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_carregando) {
      return;
    }

    final String nome = _nomeController.text.trim();
    final String email = _emailController.text.trim();
    final String telefone = _telefoneController.text.trim();
    final String descricao = _descricaoController.text.trim();
    final String profissao = _profissaoController.text.trim();
    final String experiencia = _experienciaController.text.trim();
    final String senha = _senhaController.text;
    final String confirmarSenha = _confirmarSenhaController.text;

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      // Criar conta do profissional
      final UserCredential credencial =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuarioCriado = credencial.user;

      if (usuarioCriado == null) {
        throw Exception(
          'Não foi possível criar a conta do profissional.',
        );
      }

      // Salvar nome no Authentication
      await usuarioCriado.updateDisplayName(nome);

      // Salvar profissional no Firestore
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

      // Volta para empresa enviando os dados do profissional
      Navigator.pop(
        context,
        {
          'nome': nome,
          'especialidade': profissao,
          'uid': usuarioCriado.uid,
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;

        case 'invalid-email':
          mensagem = 'O e-mail informado é inválido.';
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

        case 'unavailable':
          mensagem =
              'O Firestore está indisponível. Verifique sua conexão.';
          break;

        default:
          mensagem =
              'Erro ao salvar os dados: ${e.message ?? e.code}';
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
          content: Text('Ocorreu um erro: $e'),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo
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
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // Título
                            const Text(
                              'Cadastro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const Text(
                              'de profissionais',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Nome
                            _buildTextField(
                              label: 'Nome:',
                              controller: _nomeController,
                            ),

                            // E-mail
                            _buildTextField(
                              label: 'E-mail:',
                              controller: _emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                              validator: _validarEmail,
                            ),

                            // Telefone
                            _buildTextField(
                              label: 'Telefone:',
                              controller: _telefoneController,
                              hintText: '(12) 99999-9999',
                              keyboardType:
                                  TextInputType.phone,
                            ),

                            // Descrição
                            _buildTextField(
                              label: 'Descrição:',
                              controller: _descricaoController,
                              maxLines: 3,
                            ),

                            // Profissão
                            _buildTextField(
                              label: 'Profissão:',
                              controller: _profissaoController,
                            ),

                            // Experiência
                            _buildTextField(
                              label: 'Tempo de experiência:',
                              controller:
                                  _experienciaController,
                            ),

                            const SizedBox(height: 8),

                            // Senha
                            _buildTextField(
                              label: 'Senha:',
                              controller: _senhaController,
                              obscureText: !_mostrarSenha,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarSenha =
                                        !_mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[700],
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

                            // Confirmar senha
                            _buildTextField(
                              label: 'Confirmar senha:',
                              controller:
                                  _confirmarSenhaController,
                              obscureText:
                                  !_mostrarConfirmarSenha,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarConfirmarSenha =
                                        !_mostrarConfirmarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarConfirmarSenha
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[700],
                                  size: 21,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Campo obrigatório';
                                }

                                if (value !=
                                    _senhaController.text) {
                                  return 'As senhas não coincidem';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Foto
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _adicionarFoto,
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor:
                                          Colors.grey[600],
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _adicionarFoto,
                                    child: const Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Adicionar foto ',
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons
                                              .add_a_photo_outlined,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            // Botão cadastrar
                            ElevatedButton(
                              onPressed: _carregando
                                  ? null
                                  : _cadastrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF98B9A6),
                                foregroundColor: Colors.black,
                                disabledBackgroundColor:
                                    Colors.grey[400],
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: _carregando
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
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

          // Moldura superior
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

          // Moldura inferior
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

          // Botão voltar
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

  // Validação do e-mail
  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
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

  // Campo de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: obscureText ? 1 : maxLines,
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
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                suffixIcon: suffixIcon,
                suffixIconConstraints:
                    const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                enabledBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                errorBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                errorStyle: const TextStyle(
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