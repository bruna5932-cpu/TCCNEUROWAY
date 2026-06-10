import 'package:flutter/material.dart';
import 'package:neuroway/cadastroconta.dart';
import 'package:neuroway/cadastroempresa.dart';
import 'package:neuroway/menuprincipal.dart';

class LOGIN extends StatefulWidget {
  const LOGIN({super.key});

  @override
  State<LOGIN> createState() => LOGINState();
}

class LOGINState extends State<LOGIN> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        bottom: false, 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Seção de Imagens de Topo ---
              Image.network(
                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/0kaf4f8w_expires_30_days.png",
                height: 149,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 224,
                  height: 147,
                  child: Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/t552npi8_expires_30_days.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Formulário (Apenas E-mail e Senha) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildTextField("E-mail", _emailController),
                    const SizedBox(height: 15),
                    _buildTextField("Senha", _passwordController, isPassword: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // --- Botões Centrais (Login e Cadastrar juntos ao centro) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Menuprincipal()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF98B9A6),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(width: 15), // Espaçamento entre os dois botões centrais

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CriarConta()), 
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF98B9A6),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
              
              const SizedBox(height: 40),
              
              // Botão: Quero cadastrar minha empresa
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CadastroEmpresa()),
                    );
                  },
                  child: const Text(
                    'Quero cadastrar\nminha empresa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- Quebra-cabeça de baixo colado no fim da tela ---
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 147,
                  child: Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/7gvs027p_expires_30_days.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método de Input customizado e minimalista
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