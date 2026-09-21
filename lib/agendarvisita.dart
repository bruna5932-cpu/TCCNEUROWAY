import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendarVisita extends StatefulWidget {
  final String? empresaId;
  final String? empresaNome;
  final List<Map<String, dynamic>> profissionais;

  const AgendarVisita({
    super.key,
    this.empresaId,
    this.empresaNome,
    this.profissionais = const [],
  });

  @override
  State<AgendarVisita> createState() => _AgendarVisitaState();
}

class _AgendarVisitaState extends State<AgendarVisita> {
  late DateTime _mesAtual;
  DateTime? _dataSelecionada;

  String? _profissionalSelecionado;
  String? _horarioSelecionado;

  bool _agendando = false;

  final List<String> _diasSemana = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
  ];

  final List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final List<String> _horarios = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];

  @override
  void initState() {
    super.initState();

    final hoje = DateTime.now();

    _mesAtual = DateTime(
      hoje.year,
      hoje.month,
    );

    _dataSelecionada = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );
  }

  void _mesAnterior() {
    final hoje = DateTime.now();

    final mesAnterior = DateTime(
      _mesAtual.year,
      _mesAtual.month - 1,
    );

    final mesAtual = DateTime(
      hoje.year,
      hoje.month,
    );

    if (mesAnterior.isBefore(mesAtual)) {
      return;
    }

    setState(() {
      _mesAtual = mesAnterior;
    });
  }

  void _proximoMes() {
    setState(() {
      _mesAtual = DateTime(
        _mesAtual.year,
        _mesAtual.month + 1,
      );
    });
  }

  bool _ehHoje(DateTime data) {
    final hoje = DateTime.now();

    return data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
  }

  bool _ehDataPassada(DateTime data) {
    final hoje = DateTime.now();

    final hojeSemHora = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    return data.isBefore(hojeSemHora);
  }

  int _quantidadeDiasNoMes() {
    return DateTime(
      _mesAtual.year,
      _mesAtual.month + 1,
      0,
    ).day;
  }

  int _primeiroDiaDoMes() {
    return DateTime(
          _mesAtual.year,
          _mesAtual.month,
          1,
        ).weekday %
        7;
  }

  void _selecionarData(int dia) {
    final data = DateTime(
      _mesAtual.year,
      _mesAtual.month,
      dia,
    );

    if (_ehDataPassada(data)) {
      return;
    }

    setState(() {
      _dataSelecionada = data;
      _horarioSelecionado = null;
    });
  }

  Widget _buildCalendario() {
    final quantidadeDias = _quantidadeDiasNoMes();
    final primeiroDia = _primeiroDiaDoMes();

    final quantidadeCelulas =
        primeiroDia + quantidadeDias;

    final quantidadeLinhas =
        (quantidadeCelulas / 7).ceil();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB9BDBD),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _mesAnterior,
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 3,
                    right: 8,
                  ),
                  child: Text(
                    '<',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_meses[_mesAtual.month - 1]} ${_mesAtual.year}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _proximoMes,
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 3,
                  ),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: _diasSemana.map((dia) {
              return Expanded(
                child: Center(
                  child: Text(
                    dia,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 3),

          ...List.generate(
            quantidadeLinhas,
            (linha) {
              return Row(
                children: List.generate(
                  7,
                  (coluna) {
                    final indice =
                        linha * 7 + coluna;

                    final dia =
                        indice - primeiroDia + 1;

                    if (dia < 1 ||
                        dia > quantidadeDias) {
                      return const Expanded(
                        child: SizedBox(
                          height: 27,
                        ),
                      );
                    }

                    final data = DateTime(
                      _mesAtual.year,
                      _mesAtual.month,
                      dia,
                    );

                    final selecionada =
                        _dataSelecionada != null &&
                        _dataSelecionada!.year ==
                            data.year &&
                        _dataSelecionada!.month ==
                            data.month &&
                        _dataSelecionada!.day ==
                            data.day;

                    final hoje = _ehHoje(data);
                    final passada =
                        _ehDataPassada(data);

                    return Expanded(
                      child: GestureDetector(
                        onTap: passada
                            ? null
                            : () =>
                                _selecionarData(dia),
                        child: Container(
                          height: 27,
                          margin:
                              const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: selecionada
                                ? const Color(
                                    0xFF76A085,
                                  )
                                : hoje
                                    ? const Color(
                                        0xFFD0DDD4,
                                      )
                                    : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$dia',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    selecionada ||
                                            hoje
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: passada
                                    ? Colors.grey
                                    : selecionada
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfissional() {
    if (widget.profissionais.isEmpty) {
      return Row(
        children: [
          const Text(
            'Profissional:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 28,
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black54,
                  ),
                ),
              ),
              child: const Text(
                'Nenhum profissional cadastrado',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Text(
          'Profissional:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _profissionalSelecionado,
              hint: const Text(
                'Selecione o profissional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              items: widget.profissionais
                  .map((profissional) {
                final nome =
                    (profissional['nome'] ?? '')
                        .toString();

                if (nome.isEmpty) {
                  return null;
                }

                return DropdownMenuItem<String>(
                  value: nome,
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                );
              })
                  .whereType<
                      DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  _profissionalSelecionado =
                      valor;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorario() {
    return Row(
      children: [
        const Text(
          'Horário:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _horarioSelecionado,
              hint: const Text(
                'Selecione o horário',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              items: _horarios.map((horario) {
                return DropdownMenuItem<String>(
                  value: horario,
                  child: Text(
                    horario,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _dataSelecionada == null
                  ? null
                  : (valor) {
                      setState(() {
                        _horarioSelecionado =
                            valor;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _agendar() async {
    if (_dataSelecionada == null) {
      _mostrarMensagem(
        'Selecione uma data.',
        vermelho: true,
      );
      return;
    }

    if (widget.profissionais.isNotEmpty &&
        _profissionalSelecionado == null) {
      _mostrarMensagem(
        'Selecione um profissional.',
        vermelho: true,
      );
      return;
    }

    if (_horarioSelecionado == null) {
      _mostrarMensagem(
        'Selecione um horário.',
        vermelho: true,
      );
      return;
    }

    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      _mostrarMensagem(
        'Faça login para realizar um agendamento.',
        vermelho: true,
      );
      return;
    }

    setState(() {
      _agendando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .add({
        'usuarioId': usuario.uid,
        'empresaId': widget.empresaId,
        'empresaNome': widget.empresaNome,
        'profissional':
            _profissionalSelecionado ?? '',
        'horario': _horarioSelecionado,
        'data': Timestamp.fromDate(
          _dataSelecionada!,
        ),
        'status': 'pendente',
        'criadoEm':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _mostrarMensagem(
        'Agendamento realizado com sucesso!',
      );

      setState(() {
        _horarioSelecionado = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensagem(
        'Não foi possível realizar o agendamento.',
        vermelho: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _agendando = false;
        });
      }
    }
  }

  void _mostrarMensagem(
    String mensagem, {
    bool vermelho = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor:
            vermelho ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final molduraHeight =
        screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: molduraHeight * 0.75,
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
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
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'Agendar cliente',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 3),

                  _buildCalendario(),

                  const SizedBox(height: 7),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        _buildProfissional(),

                        const SizedBox(height: 2),

                        _buildHorario(),

                        const SizedBox(height: 16),

                        if (_dataSelecionada != null)
                          Text(
                            'Data: '
                            '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
                            '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
                            '${_dataSelecionada!.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: 80,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: _agendando
                                ? null
                                : _agendar,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF76A085,
                              ),
                              foregroundColor:
                                  Colors.black,
                              elevation: 0,
                              padding:
                                  EdgeInsets.zero,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(4),
                              ),
                            ),
                            child: _agendando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Agendar',
                                    style:
                                        TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: molduraHeight,
                child: Image.asset(
                  'imagem/quebrasuperior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment:
                      Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}