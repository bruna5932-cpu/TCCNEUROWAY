import 'package:flutter/material.dart';
import 'package:neuroway/menuprincipal.dart';

// 1. Corrigido o nome da classe de CRIARCONTA para CriarConta (PascalCase)
class CriarConta extends StatefulWidget {
  const CriarConta({super.key});

  @override
  CriarContaState createState() => CriarContaState();
}

class CriarContaState extends State<CriarConta> {
  // Controllers para capturar o texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Limpeza dos controllers para evitar vazamento de memória (Boa prática!)
  @override
  void dispose() {
    _userController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Conteúdo principal ---
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight * 0.75,
                  bottom: molduraHeight * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // --- SEÇÃO DO TÍTULO COM O BOTÃO DE VOLTAR ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Botão de voltar posicionado à esquerda
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                                onPressed: () {
                                  Navigator.maybePop(context);
                                },
                              ),
                            ),
                            // Título centralizado (Imagem ou Texto de fallback)
                            Image.asset(
                              "imagem/criarconta.png", // ATENÇÃO: Ajuste aqui para o caminho correto do seu asset
                              width: 224,
                              height: 147,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  "Criar Conta",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Campos de Formulário
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            _buildTextField("Nome de Usuário", _userController),
                            const SizedBox(height: 15),
                            _buildTextField("Cidade", _cityController),
                            const SizedBox(height: 15),
                            _buildTextField("E-mail", _emailController),
                            const SizedBox(height: 15),
                            _buildTextField("Senha", _passwordController, isPassword: true),

                            const SizedBox(height: 30),

                            // Botão Cadastrar
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const Menuprincipal()),
                                );
                                print("Usuário: ${_userController.text}");
                                print("E-mail: ${_emailController.text}");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF98B9A6),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25), // Deixei arredondado igual aos inputs para combinar
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Cadastrar",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
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
        ],
      ),
    );
  }

  // Função auxiliar para criar os campos estilizados
  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5D8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          suffixIcon: isPassword 
              ? const Icon(Icons.visibility_outlined, color: Colors.black) 
              : null,
        ),
      ),
    );
  }
}