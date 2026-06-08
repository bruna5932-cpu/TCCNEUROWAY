
import 'package:flutter/material.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({Key? key}) : super(key: key);

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  // Lista para controlar o estado de "favorito" de cada item
  final List<bool> _isFavorite = [true, true, true]; // Iniciados como true já que é a tela de favoritos

  @override
  Widget build(BuildContext context) {
    // Retornamos apenas o conteúdo essencial, permitindo que o Scaffold do Menuprincipal gerencie a estrutura do app
    return Column(
      children: [
                const SizedBox(height: 16),
          Image.network(
                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/3bnn2jd1_expires_30_days.png",
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.fill,
                      ),

              const SizedBox(height: 20),
        // Barra de busca com botão de voltar integrada ao design limpo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              Expanded(
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F4),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(color: const Color(0xFFD0D3D8), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 26),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Buscar nos favoritos",
                            hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: const Color(0xFFB0B3B8),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 24),
                      const SizedBox(width: 6),
                      const Text(
                        "SJC",
                        style: TextStyle(color: Color(0xFF7D828A), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Lista de Barbearias / Profissionais Favoritados
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildBarberCard(
                index: 0,
                title: "Barbearia",
                isAvatar: false,
                imageUrl: "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500", 
              ),
              _buildBarberCard(
                index: 1,
                title: "Marcos Silva",
                isAvatar: true,
                imageUrl: "", 
              ),
              _buildBarberCard(
                index: 2,
                title: "Barbearia Premium",
                isAvatar: false,
                imageUrl: "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500", 
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Componente de cartão customizado adaptado ao design principal do seu app
  Widget _buildBarberCard({
    required int index,
    required String title,
    required bool isAvatar,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {
        print("Clicou no item: $title");
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE0E2E5), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna da Esquerda: Imagem/Avatar + Estrelas
            Column(
              children: [
                if (isAvatar)
                  Container(
                    width: 90,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 55, color: Colors.white),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),

            // Coluna da Direita: Textos e Botão de Favorito
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isFavorite[index] ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite[index] ? Colors.red : Colors.black45,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite[index] = !_isFavorite[index];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Barbearia desde 2015 com atendimento especializado há 7 anos.\nAmbiente calmo, organizado e silencioso, trazendo conforto aos nossos clientes.",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Endereço
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.red, size: 14),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          "Av. Andrômeda, 1232 - Jardim Satélite",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}