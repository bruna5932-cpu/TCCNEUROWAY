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

  bool _ehEmpresa = false;
  bool _carregandoTipoUsuario = true;

  String _profissionalSelecionado = 'Todos';

  List<String> _profissionais = [];

  // Cor dos ícones dos agendamentos.
  // Um pouco mais escura que o verde principal do aplicativo.
  static const Color _verdeIcone = Color(0xFF5F856D);

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(() {
      setState(() {
        _pesquisa =
            _pesquisaController.text.trim().toLowerCase();
      });
    });

    _verificarTipoUsuario();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // ============================================================
  // VERIFICA SE O USUÁRIO É EMPRESA
  // ============================================================

  Future<void> _verificarTipoUsuario() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          _ehEmpresa = false;
          _carregandoTipoUsuario = false;
        });

        return;
      }

      final documento = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(usuario.uid)
          .get();

      if (!mounted) return;

      if (documento.exists) {
        final dados = documento.data();

        final listaProfissionais =
            dados?['profissionais'];

        final nomes = <String>[];

        if (listaProfissionais is List) {
          for (final profissional in listaProfissionais) {
            if (profissional is Map) {
              final nome = profissional['nome'];

              if (nome != null &&
                  nome.toString().trim().isNotEmpty) {
                nomes.add(nome.toString().trim());
              }
            }
          }
        }

        setState(() {
          _ehEmpresa = true;
          _profissionais = nomes.toSet().toList();
          _carregandoTipoUsuario = false;
        });
      } else {
        setState(() {
          _ehEmpresa = false;
          _profissionais = [];
          _carregandoTipoUsuario = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Erro ao verificar tipo de usuário: $e',
      );

      if (!mounted) return;

      setState(() {
        _ehEmpresa = false;
        _profissionais = [];
        _carregandoTipoUsuario = false;
      });
    }
  }

  // ============================================================
  // STREAM DOS AGENDAMENTOS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _agendamentosStream() {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Stream.empty();
    }

    // EMPRESA:
    // Mostra todos os agendamentos recebidos pela empresa.
    if (_ehEmpresa == true) {
      return FirebaseFirestore.instance
          .collection('agendamentos')
          .where(
            'empresaId',
            isEqualTo: usuario.uid,
          )
          .snapshots();
    }

    // USUÁRIO:
    // Mostra somente os próprios agendamentos.
    return FirebaseFirestore.instance
        .collection('agendamentos')
        .where(
          'usuarioId',
          isEqualTo: usuario.uid,
        )
        .snapshots();
  }

  // ============================================================
  // FORMATA DATA
  // ============================================================

  String _formatarData(dynamic data) {
    DateTime? dataConvertida;

    if (data is Timestamp) {
      dataConvertida = data.toDate();
    } else if (data is DateTime) {
      dataConvertida = data;
    } else if (data is String) {
      dataConvertida = DateTime.tryParse(data);
    }

    if (dataConvertida == null) {
      return 'Data não informada';
    }

    final dia =
        dataConvertida.day.toString().padLeft(2, '0');

    final mes =
        dataConvertida.month.toString().padLeft(2, '0');

    final ano =
        dataConvertida.year.toString();

    return '$dia/$mes/$ano';
  }

  // ============================================================
  // FORMATA STATUS
  // ============================================================

  String _statusFormatado(String status) {
    switch (status.toLowerCase().trim()) {
      case 'compareceu':
      case 'foi':
        return 'Compareceu';

      case 'não compareceu':
      case 'nao compareceu':
      case 'não foi':
      case 'nao foi':
        return 'Não compareceu';

      case 'pendente':
      default:
        return 'Pendente';
    }
  }

  // ============================================================
  // DROPDOWN DE STATUS
  // SOMENTE EMPRESA
  // ============================================================

  Widget _buildDropdownStatus(
    DocumentSnapshot<Map<String, dynamic>> documento,
    String statusAtual,
  ) {
    String valorAtual =
        statusAtual.toLowerCase().trim();

    if (valorAtual == 'foi') {
      valorAtual = 'compareceu';
    }

    if (valorAtual == 'não foi' ||
        valorAtual == 'nao foi') {
      valorAtual = 'não compareceu';
    }

    if (valorAtual != 'pendente' &&
        valorAtual != 'compareceu' &&
        valorAtual != 'não compareceu') {
      valorAtual = 'pendente';
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: valorAtual,
        isDense: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 21,
          color: _verdeIcone,
        ),
        items: const [
          DropdownMenuItem<String>(
            value: 'pendente',
            child: Text(
              'Pendente',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'compareceu',
            child: Text(
              'Compareceu',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          DropdownMenuItem<String>(
            value: 'não compareceu',
            child: Text(
              'Não compareceu',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
        onChanged: (novoStatus) async {
          if (novoStatus == null) return;

          try {
            await documento.reference.update({
              'status': novoStatus,
            });
          } catch (e) {
            debugPrint(
              'Erro ao atualizar status: $e',
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Não foi possível atualizar o status.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // ============================================================
  // CANCELAR AGENDAMENTO
  // ============================================================

  Future<void> _cancelarAgendamento(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancelar agendamento',
          ),
          content: const Text(
            'Tem certeza que deseja cancelar este agendamento?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Não',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF76A085),
              ),
              child: const Text(
                'Sim, cancelar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await documento.reference.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agendamento cancelado.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Erro ao cancelar agendamento: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível cancelar o agendamento.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FILTRO
  // ============================================================

  bool _filtrarAgendamento(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados =
        documento.data() ?? <String, dynamic>{};

    // Filtro por profissional somente para empresa.
    if (_ehEmpresa == true &&
        _profissionalSelecionado != 'Todos') {
      final profissional =
          (dados['profissional'] ?? '')
              .toString()
              .trim();

      if (profissional !=
          _profissionalSelecionado) {
        return false;
      }
    }

    if (_pesquisa.isEmpty) {
      return true;
    }

    final empresaNome =
        (dados['empresaNome'] ?? '')
            .toString()
            .toLowerCase();

    final profissional =
        (dados['profissional'] ?? '')
            .toString()
            .toLowerCase();

    final horario =
        (dados['horario'] ?? '')
            .toString()
            .toLowerCase();

    final usuarioNome =
        (dados['usuarioNome'] ??
                dados['nomeUsuario'] ??
                dados['clienteNome'] ??
                '')
            .toString()
            .toLowerCase();

    final status =
        (dados['status'] ?? '')
            .toString()
            .toLowerCase();

    final dataFormatada =
        _formatarData(dados['data'])
            .toLowerCase();

    return empresaNome.contains(_pesquisa) ||
        profissional.contains(_pesquisa) ||
        horario.contains(_pesquisa) ||
        usuarioNome.contains(_pesquisa) ||
        status.contains(_pesquisa) ||
        dataFormatada.contains(_pesquisa);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // IMPORTANTE:
      // NÃO colocar bottomNavigationBar aqui.
      // A barra inferior pertence ao Menuprincipal.

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTopo(),

            Expanded(
              child: _carregandoTipoUsuario
                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color: Color(0xFF76A085),
                      ),
                    )
                  : _buildListaAgendamentos(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOPO
  // MESMO ESTILO DA TELA DE FAVORITOS
  // ============================================================

  Widget _buildTopo() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Image.asset(
            'imagem/quebrasuperior.png',
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 26,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Menuprincipal(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF5F5F5,
                    ),
                    borderRadius:
                        BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(
                        0xFFD4D4D4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                      ),

                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 26,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: TextField(
                          controller:
                              _pesquisaController,
                          textInputAction:
                              TextInputAction.search,
                          decoration:
                              const InputDecoration(
                            hintText:
                                'Buscar agendamentos',
                            hintStyle:
                                TextStyle(
                              color: Color(
                                0xFF757575,
                              ),
                              fontSize: 16,
                            ),
                            border:
                                InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[300],
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Icon(
                        Icons.calendar_month,
                        color: _verdeIcone,
                        size: 22,
                      ),

                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // FILTRO DE PROFISSIONAL
        // SOMENTE EMPRESA
        // ======================================================

        if (_ehEmpresa == true &&
            _profissionais.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              10,
            ),
            child: Container(
              height: 50,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF5F5F5,
                ),
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(
                    0xFFD4D4D4,
                  ),
                ),
              ),
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<String>(
                  value:
                      _profissionalSelecionado,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: _verdeIcone,
                  ),
                  items: [
                    const DropdownMenuItem<
                        String>(
                      value: 'Todos',
                      child: Text(
                        'Todos os profissionais',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(
                            0xFF555555,
                          ),
                        ),
                      ),
                    ),
                    ..._profissionais.map(
                      (profissional) {
                        return DropdownMenuItem<
                            String>(
                          value: profissional,
                          child: Text(
                            profissional,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              color: Color(
                                0xFF555555,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor == null) return;

                    setState(() {
                      _profissionalSelecionado =
                          valor;
                    });
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _buildListaAgendamentos() {
    final usuario =
        FirebaseAuth.instance.currentUser;

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

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _agendamentosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF76A085),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(30),
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

        final documentos =
            snapshot.data?.docs ?? [];

        final agendamentos =
            documentos
                .where(_filtrarAgendamento)
                .toList();

        // Ordenação por data e horário.
        agendamentos.sort(
          (a, b) {
            final dadosA = a.data();
            final dadosB = b.data();

            final dataA = dadosA['data'];
            final dataB = dadosB['data'];

            DateTime? dateA;
            DateTime? dateB;

            if (dataA is Timestamp) {
              dateA = dataA.toDate();
            }

            if (dataB is Timestamp) {
              dateB = dataB.toDate();
            }

            if (dateA != null &&
                dateB != null) {
              final comparacao =
                  dateA.compareTo(dateB);

              if (comparacao != 0) {
                return comparacao;
              }
            }

            final horarioA =
                (dadosA['horario'] ?? '')
                    .toString();

            final horarioB =
                (dadosB['horario'] ?? '')
                    .toString();

            return horarioA.compareTo(
              horarioB,
            );
          },
        );

        if (agendamentos.isEmpty) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(30),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 70,
                    color: Colors.grey[400],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(
                    _pesquisa.isEmpty
                        ? (_ehEmpresa == true
                            ? 'Você ainda não possui agendamentos recebidos.'
                            : 'Você ainda não possui agendamentos.')
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
            left: 16,
            right: 16,
            top: 4,
            bottom: 20,
          ),
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final documento =
                agendamentos[index];

            final dados =
                documento.data() ??
                    <String, dynamic>{};

            return _buildAgendamentoCard(
              documento,
              dados,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CARD
  // ESTILO BASEADO NO CARD DE FAVORITOS
  // ============================================================

  Widget _buildAgendamentoCard(
    DocumentSnapshot<Map<String, dynamic>>
        documento,
    Map<String, dynamic> dados,
  ) {
    final empresaNome =
        (dados['empresaNome'] ??
                'Empresa')
            .toString();

    final profissional =
        (dados['profissional'] ??
                'Não informado')
            .toString();

    final horario =
        (dados['horario'] ??
                'Não informado')
            .toString();

    final data =
        _formatarData(dados['data']);

    final status =
        (dados['status'] ??
                'pendente')
            .toString();

    final usuarioNome =
        (dados['usuarioNome'] ??
                dados['nomeUsuario'] ??
                dados['clienteNome'] ??
                'Cliente')
            .toString();

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(
              0xFFE0E0E0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.06,
              ),
              blurRadius: 6,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // CABEÇALHO DO CARD
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE5EDE8,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: _verdeIcone,
                    size: 34,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ehEmpresa == true
                            ? 'Agendamento recebido'
                            : empresaNome,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      if (_ehEmpresa == true)
                        Text(
                          'Cliente: $usuarioNome',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              TextStyle(
                            fontSize: 14,
                            color:
                                Colors.grey[600],
                          ),
                        )
                      else
                        Text(
                          'Agendamento',
                          style:
                              TextStyle(
                            fontSize: 14,
                            color:
                                Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // DATA
            // ==================================================

            _buildInformacao(
              Icons.calendar_today,
              'Data',
              data,
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // HORÁRIO
            // ==================================================

            _buildInformacao(
              Icons.access_time,
              'Horário',
              horario,
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // PROFISSIONAL
            // ==================================================

            _buildInformacao(
              Icons.person,
              'Profissional',
              profissional,
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // STATUS
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF5F5F5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 19,
                    color: _verdeIcone,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  if (_ehEmpresa == true)
                    Expanded(
                      child:
                          _buildDropdownStatus(
                        documento,
                        status,
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        _statusFormatado(
                          status,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // CANCELAR
            // SOMENTE USUÁRIO
            // ==================================================

            if (_ehEmpresa != true)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      _cancelarAgendamento(
                        documento,
                      );
                    },
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          _verdeIcone,
                      side: const BorderSide(
                        color: _verdeIcone,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancelar agendamento',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMAÇÃO DO CARD
  // ============================================================

  Widget _buildInformacao(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Icon(
          icone,
          size: 19,
          color: _verdeIcone,
        ),

        const SizedBox(
          width: 10,
        ),

        Text(
          '$titulo: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        Expanded(
          child: Text(
            valor,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(
                0xFF555555,
              ),
            ),
          ),
        ),
      ],
    );
  }
}