import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroway/menuprincipal.dart';

class Agendamentos extends StatefulWidget {
  const Agendamentos({super.key});

  @override
  State<Agendamentos> createState() => _AgendamentosState();
}

class _AgendamentosState extends State<Agendamentos> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(() {
      setState(() {
        _pesquisa = _pesquisaController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _agendamentosStream() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return FirebaseFirestore.instance
          .collection('agendamentos')
          .where(
            'usuarioId',
            isEqualTo: '__usuario_nao_logado__',
          )
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('agendamentos')
        .where(
          'usuarioId',
          isEqualTo: usuario.uid,
        )
        .snapshots();
  }

  List<DocumentSnapshot<Map<String, dynamic>>> _filtrarAgendamentos(
    List<DocumentSnapshot<Map<String, dynamic>>> documentos,
  ) {
    if (_pesquisa.isEmpty) {
      return documentos;
    }

    return documentos.where((documento) {
      final dados = documento.data() ?? {};

      final empresaNome =
          (dados['empresaNome'] ?? '').toString().toLowerCase();

      final profissional =
          (dados['profissional'] ?? '').toString().toLowerCase();

      final horario =
          (dados['horario'] ?? '').toString().toLowerCase();

      String dataTexto = '';

      final data = dados['data'];

      if (data is Timestamp) {
        final date = data.toDate();

        final dia = date.day.toString().padLeft(2, '0');
        final mes = date.month.toString().padLeft(2, '0');
        final ano = date.year.toString();

        dataTexto = '$dia/$mes/$ano';
      }

      return empresaNome.contains(_pesquisa) ||
          profissional.contains(_pesquisa) ||
          horario.contains(_pesquisa) ||
          dataTexto.contains(_pesquisa);
    }).toList();
  }

  Future<void> _cancelarAgendamento(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) async {
    try {
      await documento.reference.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Agendamento cancelado com sucesso.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Erro ao cancelar agendamento: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível cancelar o agendamento.',
            ),
          ),
        );
      }
    }
  }

  String _formatarData(dynamic valor) {
    if (valor is Timestamp) {
      final data = valor.toDate();

      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();

      return '$dia/$mes/$ano';
    }

    return 'Data não informada';
  }

  String _diaDaSemana(dynamic valor) {
    if (valor is Timestamp) {
      final data = valor.toDate();

      const dias = [
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Sábado',
        'Domingo',
      ];

      return dias[data.weekday - 1];
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTopo(),

            const SizedBox(height: 15),

            _buildBarraPesquisa(),

            const SizedBox(height: 20),

            Expanded(
              child: _buildListaAgendamentos(),
            ),
          ],
        ),
      ),
    );
  }

  // Quebra-cabeça fixo no topo
  Widget _buildTopo() {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Image.asset(
        'imagem/quebrasuperior.png',
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }

  // Seta + barra de pesquisa
  Widget _buildBarraPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Menuprincipal(),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 50,
            ),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 28,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SearchBarAgendamentos(
              controller: _pesquisaController,
            ),
          ),
        ],
      ),
    );
  }

  // Lista de agendamentos com rolagem
  Widget _buildListaAgendamentos() {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Faça login para visualizar seus agendamentos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _agendamentosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF98B9A6),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                'Erro ao carregar agendamentos:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        final agendamentos = _filtrarAgendamentos(
          documentos,
        );

        if (agendamentos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 70,
                    color: Colors.grey[400],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _pesquisa.isEmpty
                        ? 'Você ainda não possui agendamentos.'
                        : 'Nenhum agendamento encontrado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: 20,
          ),
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final documento = agendamentos[index];

            final dados = documento.data() ?? <String, dynamic>{};

            return _buildAgendamentoCard(
              documento,
              dados,
            );
          },
        );
      },
    );
  }

  // Card do agendamento
  Widget _buildAgendamentoCard(
    DocumentSnapshot<Map<String, dynamic>> documento,
    Map<String, dynamic> dados,
  ) {
    final String empresaNome =
        (dados['empresaNome'] ??
                dados['empresa'] ??
                'Empresa')
            .toString();

    final String profissional =
        (dados['profissional'] ??
                'Profissional não informado')
            .toString();

    final String horario =
        (dados['horario'] ??
                'Horário não informado')
            .toString();

    final String data = _formatarData(
      dados['data'],
    );

    final String diaSemana = _diaDaSemana(
      dados['data'],
    );

    final String status =
        (dados['status'] ?? 'pendente').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 3,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 70,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '$data - $diaSemana',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    horario,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(
              color: Colors.black54,
              thickness: 2,
              width: 20,
            ),

            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresaNome,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Profissional: $profissional',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF76A085),
                            size: 20,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              'Status: $status',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _mostrarConfirmacaoCancelamento(
                          documento,
                          empresaNome,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  // Confirmação para cancelar
  void _mostrarConfirmacaoCancelamento(
    DocumentSnapshot<Map<String, dynamic>> documento,
    String empresaNome,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cancelar agendamento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente cancelar o agendamento em $empresaNome?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Não',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await _cancelarAgendamento(
                  documento,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Sim, cancelar',
              ),
            ),
          ],
        );
      },
    );
  }
}

// Barra de pesquisa
class SearchBarAgendamentos extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarAgendamentos({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFFD0D3D8),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          const Icon(
            Icons.search,
            color: Color(0xFF9E9E9E),
            size: 26,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              textAlignVertical:
                  TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Buscar no agendamentos',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 18,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}