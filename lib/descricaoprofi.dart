import 'package:flutter/material.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/favoritos.dart';
import 'package:neuroway/menuprincipal.dart'; 
import 'package:neuroway/peril.dart'; // Mantido caso use em outro local

// MARK: - TELA PRINCIPAL (Gerencia o estado e as telas)
class Descricaoprofi extends StatefulWidget {
  const Descricaoprofi({super.key});

  @override
  State<Descricaoprofi> createState() => _DescricaoprofiState();
}

class _DescricaoprofiState extends State<Descricaoprofi> {
  // Começa no index 3 para abrir direto na aba de Perfil do Marcos
  int _currentIndex = 3; 

  // Controlador para a barra de pesquisa da Home
  final TextEditingController _searchController = TextEditingController();

  // Lista de páginas correspondentes a cada aba do menu
  late final List<Widget> _paginas = [
    const Menuprincipal(),     // Index 0: Seu conteúdo customizado de Home (Menu Principal)
    const Favoritos(),         // Index 1: Tela de Favoritos real
    const Agendamentos(),      // Index 2: Tela de Agendamentos real
    _buildPerfilConteudo(),    // Index 3: CORRIGIDO - Agora exibe o perfil do Marcos/Alisson que você criou abaixo
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // O IndexedStack renderiza apenas a tela ativa, mas mantém o estado delas vivo
        child: IndexedStack(
          index: _currentIndex,
          children: _paginas,
        ),
      ),
      // A barra customizada fica aqui, enviando os cliques para o pai
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Atualiza a tela ativa ao clicar
          });
        },
      ),
    );
  }

  // Seu layout customizado da Home
  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Image.asset(
                  "imagem/quebrasuperior.png",
                  width: double.infinity,
                  height: 150, 
                  fit: BoxFit.cover, 
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 150,
                      child: Center(child: Text('Erro ao carregar imagem superior', style: TextStyle(color: Colors.red))),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(), // Substitua pelo seu SearchBarWidget se necessário
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Corrigido para evitar recursão infinita
                  return const Text('Item da lista'); 
                },
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // O layout de perfil criado por você (Index 3)
  Widget _buildPerfilConteudo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

// MARK: - BARRA DE NAVEGAÇÃO CUSTOMIZADA (Limpa, apenas visual e cliques)
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF9E9E9E),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onTap, // Repassa o índice clicado de volta para a tela pai rodar o setState
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

// MARK: - Sub-componentes visuais (Mantidos intactos)

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 45,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 95,
          right: 15,
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 45, left: 45, right: 45),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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

class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Horários disponíveis na semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
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
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Agende seu horário!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
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
              const Text('Comentários', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[700]),
            ],
          ),
          const SizedBox(height: 12),
          const CommentCard(
            author: 'Maria Aparecida',
            content: 'Ótimo profissional. Levei meu filho autista de 15 anos para cortar o cabelo, o Marcos foi super gentil e paciente com ele. Está de nota 10.',
            likes: 35,
            dislikes: 0,
          ),
          const SizedBox(height: 12),
          const CommentCard(
            author: 'José Augusto',
            content: 'Muito educado, porém estava não estava presente na hora marcada.',
            likes: 15,
            dislikes: 0,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Faça um comentário!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
          Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.3)),
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