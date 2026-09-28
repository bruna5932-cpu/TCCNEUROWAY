import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CadastroPage extends StatefulWidget {
  final String? empresaUid;

  const CadastroPage({
    super.key,
    this.empresaUid,
  });

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

  // Firebase Auth secundário
  Future<FirebaseAuth> _obterAuthSecundario() async {
    const nomeApp = 'neurowayCadastroProfissional';

    for (final app in Firebase.apps) {
      if (app.name == nomeApp) {
        return FirebaseAuth.instanceFor(app: app);
      }
    }

    final appSecundario = await Firebase.initializeApp(
      name: nomeApp,
      options: Firebase.app().options,
    );

    return FirebaseAuth.instanceFor(
      app: appSecundario,
    );
  }

  // Selecionar foto
  Future<void> _selecionarFoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem != null && mounted) {
        setState(() {
          _fotoSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
        ),
      );
    }
  }

  // Cadastrar profissional
  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final descricao = _descricaoController.text.trim();
    final profissao = _profissaoController.text.trim();
    final experiencia = _experienciaController.text.trim();
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    final telefoneNumeros = telefone.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (nome.isEmpty ||
        email.isEmpty ||
        telefone.isEmpty ||
        profissao.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
        ),
      );
      return;
    }

    if (telefoneNumeros.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um telefone completo.'),
        ),
      );
      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres.'),
        ),
      );
      return;
    }

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem.'),
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    FirebaseAuth? authSecundario;

    try {
      // Criar Auth secundário
      authSecundario = await _obterAuthSecundario();

      final credencial =
          await authSecundario.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final usuarioCriado = credencial.user;

      if (usuarioCriado == null) {
        throw Exception('Não foi possível criar o usuário.');
      }

      final profissionalUid = usuarioCriado.uid;
      String fotoUrl = '';

      // Foto do profissional
      if (_fotoSelecionada != null) {
        final referencia = FirebaseStorage.instance
            .ref()
            .child('profissionais')
            .child('$profissionalUid.jpg');

        await referencia.putFile(_fotoSelecionada!);
        fotoUrl = await referencia.getDownloadURL();
      }

      // Dados do profissional
      final Map<String, dynamic> dadosProfissional = {
        'uid': profissionalUid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'descricao': descricao,
        'profissao': profissao,
        'especialidade': profissao,
        'experiencia': experiencia,
        'tipo': 'profissional',
        'fotoUrl': fotoUrl,
        'empresaUid': widget.empresaUid ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
      };

      // Salvar profissional
      await FirebaseFirestore.instance
          .collection('profissionais')
          .doc(profissionalUid)
          .set(dadosProfissional);

      // Adicionar profissional à empresa
      final empresaUid = widget.empresaUid;

      if (empresaUid != null && empresaUid.trim().isNotEmpty) {
        final empresaRef = FirebaseFirestore.instance
            .collection('empresas')
            .doc(empresaUid);

        final empresaDoc = await empresaRef.get();

        if (!empresaDoc.exists) {
          throw Exception(
            'A empresa não foi encontrada no Firestore.',
          );
        }

        final Map<String, dynamic> profissionalParaEmpresa = {
          'uid': profissionalUid,
          'nome': nome,
          'especialidade': profissao,
          'profissao': profissao,
          'telefone': telefone,
          'descricao': descricao,
          'experiencia': experiencia,
          'fotoUrl': fotoUrl,
          'empresaUid': empresaUid,
        };

        await empresaRef.update({
          'profissionais': FieldValue.arrayUnion([
            profissionalParaEmpresa,
          ]),
        });
      }

      // Deslogar Auth secundário
      await authSecundario.signOut();

      if (!mounted) return;

      // Devolver dados para a tela anterior
      Navigator.pop(
        context,
        {
          'uid': profissionalUid,
          'nome': nome,
          'especialidade': profissao,
          'profissao': profissao,
          'telefone': telefone,
          'descricao': descricao,
          'experiencia': experiencia,
          'fotoUrl': fotoUrl,
          'empresaUid': empresaUid ?? '',
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
      } else if (e.code == 'operation-not-allowed') {
        mensagem =
            'O login por e-mail e senha não está habilitado no Firebase.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao cadastrar profissional: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e'),
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

  // Campo de texto
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: Colors.black,
        ),
        cursorColor: Colors.black,
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

  // Descrição
  Widget _campoDescricao() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _descricaoController,
        maxLines: 4,
        style: const TextStyle(
          color: Colors.black,
        ),
        cursorColor: Colors.black,
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double molduraHeight = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quebra-cabeça superior
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
              const SizedBox(height: 10),

              // Cabeçalho
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

              // Conteúdo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Foto de perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: _carregando ? null : _selecionarFoto,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F1F1),
                            border: Border.all(
                              color: const Color(0xFF98B9A6),
                              width: 2,
                            ),
                          ),
                          child: _fotoSelecionada != null
                              ? ClipOval(
                                  child: Image.file(
                                    _fotoSelecionada!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 38,
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
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton(
                        onPressed: _carregando ? null : _selecionarFoto,
                        child: Text(
                          _fotoSelecionada == null
                              ? 'Selecionar foto'
                              : 'Alterar foto',
                          style: const TextStyle(
                            color: Color(0xFF76A085),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _campoTexto(
                      label: 'Nome',
                      controller: _nomeController,
                      keyboardType: TextInputType.name,
                    ),
                    _campoTexto(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    // Telefone
                    _campoTexto(
                      label: 'Telefone',
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _MascaraTelefone(),
                      ],
                    ),
                    _campoTexto(
                      label: 'Profissão / Especialidade',
                      controller: _profissaoController,
                      keyboardType: TextInputType.text,
                    ),
                    _campoTexto(
                      label: 'Experiência',
                      controller: _experienciaController,
                      keyboardType: TextInputType.text,
                    ),
                    _campoDescricao(),
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
                            _mostrarSenha = !_mostrarSenha;
                          });
                        },
                      ),
                    ),
                    _campoTexto(
                      label: 'Confirmar senha',
                      controller: _confirmarSenhaController,
                      obscureText: !_mostrarConfirmarSenha,
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
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF76A085),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cadastrar profissional',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Quebra-cabeça inferior
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

// Máscara de telefone
class _MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numeros = newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }

    String formatado = '';

    if (numeros.isNotEmpty) {
      formatado = '(${numeros.substring(
        0,
        numeros.length > 2 ? 2 : numeros.length,
      )}';
    }

    if (numeros.length >= 2) {
      formatado += ') ';
    }

    if (numeros.length > 2) {
      formatado += numeros.substring(
        2,
        numeros.length > 7 ? 7 : numeros.length,
      );
    }

    if (numeros.length > 7) {
      formatado += '-${numeros.substring(7)}';
    }

    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(
        offset: formatado.length,
      ),
    );
  }
}