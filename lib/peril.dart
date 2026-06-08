import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Define o fundo branco para alinhar com o app
      body: SafeArea(
        top: false, // Permite que a imagem de topo preencha a área da status bar
        child: Column(
          children: [
            
            // === 1. IMAGEM DA WEB COM CORTE EM ONDA (INTEGRADA AO APP) ===
            ClipPath(
              clipper: HeaderWaveClipper(), // Aplica o efeito de onda na base da imagem
              child: SizedBox(
                width: double.infinity,
                height: 200, // Aumentado levemente para dar espaço ao desenho da onda
                child: Image.network(
                  "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/3bnn2jd1_expires_30_days.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // O restante do conteúdo agora fica dentro do Expanded com scroll
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  
                  // === 2. INFORMAÇÕES DO PERFIL LOGO EMBAIXO ===
                  Row(
                    children: [
                      // Avatar circular cinza
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF6C757D),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Nome e Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Nome',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'E-mail',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 3. Lista de Opções (Cidade, Favoritos, Agendamentos)
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    label: 'Cidade',
                    onTap: () => _showSnackBar(context, 'Opção Cidade clicada'),
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.favorite_border,
                    label: 'Favoritos',
                    onTap: () => _showSnackBar(context, 'Opção Favoritos clicada'),
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.calendar_today_outlined,
                    label: 'Agendamentos',
                    onTap: () => _showSnackBar(context, 'Opção Agendamentos clicada'),
                  ),
                ],
              ),
            ),

            // Botões Inferiores (Editar e Sair) - Fixos no rodapé
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Editar
                  TextButton.icon(
                    onPressed: () {
                      _showSnackBar(context, 'Botão Editar clicado');
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 28),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  // Botão Sair
                  InkWell(
                    onTap: () {
                      _showSnackBar(context, 'Saindo do aplicativo...');
                    },
                    splashColor: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Text(
                            'Sair',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.exit_to_app, color: Colors.black, size: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 28),
      title: Text(label, style: const TextStyle(fontSize: 18, color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// === CLASSE RESPONSÁVEL POR CRIAR O DESIGN EM ONDA NA PARTE INFERIOR ===
class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Começa desenhando do canto superior esquerdo até quase o fim da altura na esquerda
    path.lineTo(0, size.height * 0.75);

    // Primeira curva da onda (subindo levemente no primeiro quarto da tela)
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.60);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.80);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    // Segunda curva da onda (descendo suavemente em direção à direita)
    var secondControlPoint = Offset(size.width * 0.75, size.height * 1.0);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    // Fecha o desenho ligando os cantos superiores e finaliza
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}