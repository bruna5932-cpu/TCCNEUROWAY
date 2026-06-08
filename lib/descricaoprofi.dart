import 'package:flutter/material.dart';

class Descricaoprofi extends StatelessWidget {
  const Descricaoprofi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/0kaf4f8w_expires_30_days.png",
                      height: 149,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),

                    const ProfileHeaderSection(),
                    
                    // Biografia/Descrição
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Sou o Marcos, tenho 32 anos e trabalho como barbeiro há 10 anos. '
                        'Comecei a atender clientes neurodivergentes há dois anos e sempre dou o melhor '
                        'para deixá-los confortáveis e satisfeitos!',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Divider(color: Colors.black45, thickness: 1),
                    ),

                    // Horários Disponíveis
                    const AvailabilitySection(),

                    const SizedBox(height: 16),

                    // Seção de Comentários
                    const CommentsSection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // --- ADICIONADO AQUI: A barra de navegação com as configurações do primeiro código ---
            const CustomBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}

// MARK: - Header Component
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botão de voltar
        Positioned(
          top: 45,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        // Botão de Favorito (Coração)
        Positioned(
          top: 95,
          right: 15,
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ),
        // Foto de Perfil e Nome
        Padding(
          padding: const EdgeInsets.only(top: 45, left: 45, right: 45),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar cinza
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Nome e Estrelas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Marcos\nSilva',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_half,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Availability Component
class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horários disponíveis na semana',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // Segunda
          const Text('Segunda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Row(
            children: [
              Text('12:30', style: TextStyle(fontSize: 14)),
              SizedBox(width: 40),
              Text('17:00', style: TextStyle(fontSize: 14)),
              SizedBox(width: 40),
              Text('18:00', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          // Quarta
          const Text('Quarta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Row(
            children: [
              Text('09:30', style: TextStyle(fontSize: 14)),
              SizedBox(width: 40),
              Text('13:00', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          // Sábado e Botão do WhatsApp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sábado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('11:30', style: TextStyle(fontSize: 14)),
                ],
              ),
              // Botão Agende seu horário
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Agende seu horário!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// MARK: - Comments Component
class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comentários',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[700]),
            ],
          ),
          const SizedBox(height: 12),

          // Comentário 1: Maria Aparecida
          const CommentCard(
            author: 'Maria Aparecida',
            content: 'Ótimo profissional. Levei meu filho autista de 15 anos para cortar o cabelo, o Marcos foi super gentil e paciente com ele. Está de nota 10.',
            likes: 35,
            dislikes: 0,
          ),

          const SizedBox(height: 12),

          // Comentário 2: José Augusto
          const CommentCard(
            author: 'José Augusto',
            content: 'Muito educado, porém estava não estava presente na hora marcada.',
            likes: 15,
            dislikes: 0,
          ),

          const SizedBox(height: 16),

          // Botão Faça um comentário
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Faça um comentário!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final String author;
  final String content;
  final int likes;
  final int dislikes;

  const CommentCard({
    super.key,
    required this.author,
    required this.content,
    required this.likes,
    required this.dislikes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text('$likes', style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 16),
              Icon(Icons.thumb_down_outlined, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text('$dislikes', style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// MARK: - CONFIGURAÇÃO MODIFICADA PARA A PRIMEIRA BARRA DE NAVEGAÇÃO
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0; // Controla o item selecionado localmente na tela

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}