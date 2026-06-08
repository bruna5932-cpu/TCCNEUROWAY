import 'package:flutter/material.dart';
import 'package:neuroway/cadastroconta.dart';
import 'package:neuroway/cadastroempresa.dart';
import 'package:neuroway/menuprincipal.dart';


class LOGIN extends StatefulWidget {
  const LOGIN({super.key});//

  @override
  LOGINState createState() => LOGINState();
}

class LOGINState extends State<LOGIN> {
  // Os controllers devem ficar dentro da State para melhor gerenciamento de memória
   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        bottom: false, // Permite que a imagem ignore o padding seguro de baixo e cole de fato na tela
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

              // --- Campo de E-mail ---
              Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/6opmdniz_expires_30_days.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFF000000), fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: "Digite seu e-mail",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // --- Campo de Senha ---
              Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/6opmdniz_expires_30_days.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _senhaController,
                          obscureText: true,
                          style: const TextStyle(color: Color(0xFF000000), fontSize: 20),
                          decoration: const InputDecoration(
                            hintText: "Senha",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 42,
                        height: 31,
                        child: Image.network("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/1a8jndzr_expires_30_days.png"),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Rodapé (Login / Cadastrar) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Menuprincipal()),
                      );
                      },
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
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    // Link para Cadastrar
                      ElevatedButton(
                      onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CriarConta()),
                      );
                      },
                      // Ação de cadastro
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
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              // Ícone final opcional
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CadastroEmpresa()), // Substitua por 'CadastrarEmpresa()' ou a tela correta da sua empresa
                    );
                  },
                  child: const Text(
                    'Quero cadastrar\nminha empresa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Se quiser parecer mais com um link da web, experimente Colors.blue[800]
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
                
              ),
              const SizedBox(height: 20),
              // --- Quebra-cabeça de baixo colado no fim da tela ---
              Center(
                child: SizedBox(
                  width: double. infinity,
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
}