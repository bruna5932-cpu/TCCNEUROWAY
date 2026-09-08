import 'package:flutter/material.dart';
import 'package:neuroway/cadastroempresa.dart';
import 'package:neuroway/menuprincipal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Profissionais',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CadastroPage(),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CAMPOS DE TEXTO
  // ============================================================

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _experienciaController = TextEditingController();

  // ============================================================
  // ADICIONAR FOTO
  // ============================================================

  Future<void> _adicionarFoto() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Botão Adicionar Foto clicado!'),
      ),
    );
  }

  // ============================================================
  // CADASTRAR
  // ============================================================

  void _cadastrar() {
    // Verifica todos os campos obrigatórios
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Se todos os campos estiverem preenchidos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Navegação para cadastro de empresa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroEmpresa(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _profissaoController.dispose();
    _experienciaController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // CONTEÚDO
          // ======================================================

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
                    clipBehavior: Clip.antiAlias,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
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

                            // ==================================================
                            // NOME
                            // ==================================================

                            _buildTextField(
                              label: 'Nome:',
                              controller: _nomeController,
                            ),

                            // ==================================================
                            // E-MAIL
                            // ==================================================

                            _buildTextField(
                              label: 'E-mail:',
                              controller: _emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),

                            // ==================================================
                            // TELEFONE
                            // ==================================================

                            _buildTextField(
                              label: 'Telefone:',
                              controller: _telefoneController,
                              hintText:
                                  '+__ (__) ____-____',
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
                              label: 'Tempo de experiência:',
                              controller:
                                  _experienciaController,
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // FOTO
                            // ==================================================

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

                            // ==================================================
                            // BOTÃO CADASTRAR
                            // ==================================================

                            ElevatedButton(
                              onPressed: _cadastrar,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF98B9A6),
                                foregroundColor:
                                    Colors.black,

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

                              child: const Text(
                                "Cadastrar",
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

          // ======================================================
          // MOLDURA SUPERIOR
          // ======================================================

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

          // ======================================================
          // MOLDURA INFERIOR
          // ======================================================

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

          // ======================================================
          // BOTÃO VOLTAR
          // ======================================================

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
                  padding: EdgeInsets.all(8.0),
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
  // CAMPO DE TEXTO
  // ============================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // ==================================================
          // LABEL
          // ==================================================

          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 8),

          // ==================================================
          // CAMPO
          // ==================================================

          Expanded(
            child: TextFormField(
              controller: controller,

              keyboardType: keyboardType,

              maxLines: maxLines,

              style: const TextStyle(
                fontSize: 16,
              ),

              // ==================================================
              // VALIDAÇÃO
              // ==================================================

              validator: (value) {
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

                // ==================================================
                // LINHA NORMAL
                // ==================================================

                enabledBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),

                // ==================================================
                // LINHA QUANDO SELECIONADO
                // ==================================================

                focusedBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),

                // ==================================================
                // MENSAGEM DE ERRO
                // ==================================================

                errorStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}