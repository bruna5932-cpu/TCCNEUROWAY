import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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

  // Foto

  Future<void> _adicionarFoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (imagem == null) {
        return;
      }

      setState(() {
        _fotoSelecionada = File(imagem.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível selecionar a foto: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Upload da foto

  Future<String?> _enviarFotoParaStorage(String uid) async {
    if (_fotoSelecionada == null) {
      return null;
    }

    try {
      final String caminho = 'profissionais/$uid.jpg';

      final Reference referencia = _storage.ref().child(caminho);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      await referencia.putFile(
        _fotoSelecionada!,
        metadata,
      );

      final String url = await referencia.getDownloadURL();

      return url;
    } on FirebaseException catch (e) {
      debugPrint(
        'Erro Firebase Storage ao enviar foto: '
        '${e.code} - ${e.message}',
      );

      if (e.code == 'object-not-found') {
        throw Exception(
          'O arquivo da foto não foi encontrado no Firebase Storage. '
          'Verifique se o Storage está ativado no projeto Firebase.',
        );
      }

      if (e.code == 'unauthorized' ||
          e.code == 'permission-denied') {
        throw Exception(
          'O Firebase Storage não permitiu enviar a foto. '
          'Verifique as regras do Storage.',
        );
      }

      if (e.code == 'canceled') {
        throw Exception(
          'O envio da foto foi cancelado.',
        );
      }

      if (e.code == 'retry-limit-exceeded') {
        throw Exception(
          'O envio da foto demorou demais. '
          'Verifique sua conexão com a internet.',
        );
      }

      throw Exception(
        'Erro ao enviar a foto: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint(
        'Erro inesperado ao enviar foto: $e',
      );

      throw Exception(
        'Não foi possível enviar a foto.',
      );
    }
  }

  // Cadastro

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

    User? usuarioCriado;

    try {
      final UserCredential credencial =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      usuarioCriado = credencial.user;

      if (usuarioCriado == null) {
        throw Exception(
          'Não foi possível criar a conta do profissional.',
        );
      }

      await usuarioCriado.updateDisplayName(nome);

      String? fotoUrl;

      if (_fotoSelecionada != null) {
        fotoUrl = await _enviarFotoParaStorage(
          usuarioCriado.uid,
        );
      }

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
        'fotoUrl': fotoUrl ?? '',
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
          mensagem = 'A senha deve ter pelo menos 6 caracteres.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O cadastro por e-mail e senha não está habilitado no Firebase.';
          break;

        case 'network-request-failed':
          mensagem = 'Erro de conexão. Verifique sua internet.';
          break;

        case 'configuration-not-found':
          mensagem =
              'A configuração do Firebase não foi encontrada. '
              'Verifique o firebase_options.dart e o projeto Firebase.';
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
        case 'unauthorized':
          mensagem =
              'O Firebase não permitiu acessar o Storage ou Firestore. '
              'Verifique as regras de segurança.';
          break;

        case 'object-not-found':
          mensagem =
              'O arquivo da foto não foi encontrado no Firebase Storage. '
              'Verifique se o Storage está configurado corretamente.';
          break;

        case 'unavailable':
          mensagem =
              'O Firebase está indisponível. '
              'Verifique sua conexão com a internet.';
          break;

        case 'canceled':
          mensagem = 'O envio da foto foi cancelado.';
          break;

        default:
          mensagem =
              'Erro do Firebase: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
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
          duration: const Duration(seconds: 6),
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

  // Dispose

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

  // Tela

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.15;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quebra-cabeça superior

                SizedBox(
                  height: molduraHeight,
                  child: Image.asset(
                    'imagem/quebrasuperior.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),

                const SizedBox(height: 8),

                // Título

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      InkWell(
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

                      const SizedBox(width: 4),

                      const Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Cadastro',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'de profissionais',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 38),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Campos

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome

                      _buildTextField(
                        label: 'Nome:',
                        controller: _nomeController,
                      ),

                      // E-mail

                      _buildTextField(
                        label: 'E-mail:',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validarEmail,
                      ),

                      // Telefone

                      _buildTextField(
                        label: 'Telefone:',
                        controller: _telefoneController,
                        hintText: '(00) 00000-0000',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          TelefoneInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }

                          final numeros = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );

                          if (numeros.length != 11) {
                            return 'Digite um telefone válido';
                          }

                          return null;
                        },
                      ),

                      // Descrição

                      _buildDescricaoField(),

                      // Profissão

                      _buildTextField(
                        label: 'Profissão:',
                        controller: _profissaoController,
                      ),

                      // Experiência

                      _buildTextField(
                        label: 'Tempo de experiência:',
                        controller: _experienciaController,
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
                              _mostrarSenha = !_mostrarSenha;
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
                          if (value == null || value.isEmpty) {
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
                        controller: _confirmarSenhaController,
                        obscureText: !_mostrarConfirmarSenha,
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
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }

                          if (value != _senhaController.text) {
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
                                backgroundColor: Colors.grey[600],
                                backgroundImage:
                                    _fotoSelecionada != null
                                        ? FileImage(_fotoSelecionada!)
                                        : null,
                                child: _fotoSelecionada == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(height: 8),

                            InkWell(
                              onTap: _adicionarFoto,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Adicionar foto ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),

                            if (_fotoSelecionada != null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Foto selecionada',
                                  style: TextStyle(
                                    color: Color(0xFF65A56E),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Botão

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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: _carregando
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
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

                // Quebra-cabeça inferior

                SizedBox(
                  height: molduraHeight,
                  child: Image.asset(
                    'imagem/quebrainferior.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Descrição

  Widget _buildDescricaoField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descrição:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _descricaoController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 5,
            style: const TextStyle(
              fontSize: 16,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }

              return null;
            },
            decoration: InputDecoration(
              hintText:
                  'Digite uma descrição sobre o profissional...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              inputFormatters: inputFormatters,
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
                  fontSize: 16,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                suffixIcon: suffixIcon,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                errorBorder: const UnderlineInputBorder(
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

// Máscara de telefone

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numeros = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }

    String formatado = '';

    if (numeros.isNotEmpty) {
      if (numeros.length <= 2) {
        formatado = '($numeros';
      } else {
        formatado = '(${numeros.substring(0, 2)}) ';

        if (numeros.length <= 7) {
          formatado += numeros.substring(2);
        } else {
          formatado += '${numeros.substring(2, 7)}-';
          formatado += numeros.substring(7);
        }
      }
    }

    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(
        offset: formatado.length,
      ),
    );
  }
}