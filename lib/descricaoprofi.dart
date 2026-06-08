import 'package:flutter/material.dart';

class ProfessionalProfilePage extends StatelessWidget {
  const ProfessionalProfilePage({super.key});

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
                    // Topo colorido com quebra-cabeças e foto de perfil
                    const ProfileHeaderSection(),
                    
                    const SizedBox(height: 16),

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
            // Barra de Navegação Inferior Customizada
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
        // Faixa superior colorida (Simulando o padrão de quebra-cabeça com cores)
        Container(
          height: 90,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red, Colors.purple, Colors.blue, Colors.green, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: const Opacity(
            opacity: 0.3,
            child: Icon(Icons.extension, size: 50, color: Colors.white),
          ),
        ),
        // Botão de voltar
        Positioned(
          top: 45,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
            onPressed: () {},
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
          // CORREÇÃO: Sintaxe de padding corrigida para evitar erros em tempo de execução
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
            // CORREÇÃO: Propriedade trocada de 'alignment: Alignment.centerRight' para 'mainAxisAlignment'
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

// MARK: - Bottom Navigation Bar Component
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.grey, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.grey, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.grey, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}