import 'package:flutter/material.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ClipPath(
              clipper: HeaderWaveClipper(),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/3bnn2jd1_expires_30_days.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF6C757D),
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Nome',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'E-mail',
                              style: TextStyle(fontSize: 16, color: Color(0xFF495057)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    label: 'Cidade',
                    onTap: () => _showSnackBar(context, 'Opção Cidade clicada'),
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.favorite_border,
                    label: 'Favoritos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Favoritos()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.calendar_today_outlined,
                    label: 'Agendamentos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Agendamentos()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showSnackBar(context, 'Botão Editar clicado');
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 28),
                    label: const Text('Editar', style: TextStyle(color: Colors.black, fontSize: 18)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LOGIN()),
                        (route) => false,
                      );
                    },
                    splashColor: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Text('Sair', style: TextStyle(color: Colors.black, fontSize: 18)),
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.60);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.80);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.75, size.height * 1.0);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}