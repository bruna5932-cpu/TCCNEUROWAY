import 'package:flutter/material.dart';
import 'descricaoprofi.dart';

class DescricaoLocalScreen extends StatefulWidget {
  const DescricaoLocalScreen({super.key});

  @override
  State<DescricaoLocalScreen> createState() => _DescricaoLocalScreenState();
}

class _DescricaoLocalScreenState extends State<DescricaoLocalScreen> {
  bool _isFavorited = false;
  
  // --- ATUALIZADO: Agora usa a mesma variável de controle do primeiro código ---
  int _currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabeçalho
              Image.network(
                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/0kaf4f8w_expires_30_days.png",
                height: 149,
                width: double.infinity,
                fit: BoxFit.fill,
              ),

              const SizedBox(height: 16),

              // 2. Título, Estrelas e Botão de Favorito
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                key: const Key('header_section'),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text(
                      'Barbearia',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star_half, color: Colors.amber, size: 16),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorited = !_isFavorited;
                        });
                        print('Favorito clicado: $_isFavorited');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Carrossel de Imagens
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16.0),
                  children: [
                    _buildImageCard('https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=500'),
                    const SizedBox(width: 12),
                    _buildImageCard('https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&w=500'),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(isActive: true),
                    _buildDot(isActive: false),
                    _buildDot(isActive: false),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Descrição
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descrição',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barbearia desde 2018 com atendimento especializado por 2 profissionais.\nAmbiente limpo, organizado e silencioso, trazendo conforto aos nossos clientes.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Divider(thickness: 1),
              ),

              // 5. Profissionais
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profissionais',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Descricaoprofi(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildProfessionalAvatar('Alisson Silva', '4 anos de exp.'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProfessionalAvatar('João Souza', '2 anos de exp.'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(isActive: true),
                    _buildDot(isActive: false),
                    _buildDot(isActive: false),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 6. Localização
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localização',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Av. Andrômeda, 1.232 - Jardim Satélite, São José dos Campos - SP, 12230-001',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 7. Horário de Funcionamento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Horário de funcionamento',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Segunda à sexta: 09:00 às 18:00\nSábado, domingo e feriados: 08:30 às 17:00',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 8. Botão Agende seu horário (WhatsApp)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => print('Botão do WhatsApp / Agendamento clicado!'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Agende seu horário',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/whatsApp.png',
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.chat, color: Colors.green, size: 28);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // --- PASSO 9: MODIFICADO PARA REPRODUZIR EXATAMENTE O SEU PRIMEIRO CÓDIGO ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF9E9E9E),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _currentIndex = index; 
            });
            print('Menu inferior atualizado para o index: $index');
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 28),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month, size: 28),
              label: 'Agenda',
              activeIcon: Icon(Icons.calendar_month, size: 28),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 200,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[700] : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProfessionalAvatar(String name, String experience) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.grey, size: 30),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                experience,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}