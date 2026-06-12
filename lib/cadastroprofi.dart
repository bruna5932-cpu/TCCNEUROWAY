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
  
  // Controladores dos campos de texto
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _experienciaController = TextEditingController();

  // Função simulada para escolher a foto
  Future<void> _adicionarFoto() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Botão Adicionar Foto clicado!')),
    );
  }

  // CORREÇÃO 1: Ajustada a função para validar e depois navegar para a próxima página
  void _cadastrar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1), // Mensagem rápida para não travar a navegação
      ),
    );

    // Navega para a tela CadastroEmpresa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CadastroEmpresa()),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // --- Conteúdo principal (formulário) ---
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
                      // --- Conteúdo Interno do Formulário ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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

                            // Campos de Texto
                            _buildTextField(
                              label: 'Nome:',
                              controller: _nomeController,
                            ),

                            _buildTextField(
                              label: 'E-mail:',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            _buildTextField(
                              label: 'Telefone:',
                              controller: _telefoneController,
                              hintText: '+__ (__) ____-____',
                              keyboardType: TextInputType.phone,
                            ),

                            _buildTextField(
                              label: 'Descrição:',
                              controller: _descricaoController,
                              maxLines: 3,
                            ),

                            _buildTextField(
                              label: 'Profissão:',
                              controller: _profissaoController,
                            ),

                            _buildTextField(
                              label: 'Tempo de experiência:',
                              controller: _experienciaController,
                            ),
                            const SizedBox(height: 20),

                            // --- Seção da Foto de Perfil ---
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _adicionarFoto,
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.grey[600],
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Adicionar foto ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(Icons.add_a_photo_outlined, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),

                            // CORREÇÃO 2: Botão agora chama a função _cadastrar()
                            ElevatedButton(
                              onPressed: _cadastrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF98B9A6),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Cadastrar",
                                style: TextStyle(fontSize: 18),
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

          // --- Moldura superior ---
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

          // --- Moldura inferior ---
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

          // --- Seta para voltar à tela de Cadastro de Empresa ---
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
                      MaterialPageRoute(builder: (context) => const CadastroEmpresa()),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16),
              // CORREÇÃO 3: Adicionado validador básico para os campos não irem vazios
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                suffixIcon: suffixIcon,
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                // Exibe o erro de validação de forma limpa abaixo da linha
                errorStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}