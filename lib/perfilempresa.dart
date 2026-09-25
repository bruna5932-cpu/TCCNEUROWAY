import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';

class PerfilEmpresa extends StatefulWidget {
  const PerfilEmpresa({super.key});

  @override
  State<PerfilEmpresa> createState() => _PerfilEmpresaState();
}

class _PerfilEmpresaState extends State<PerfilEmpresa> {
  String nome = 'Carregando...';
  String cnpj = 'Carregando...';
  String categoria = 'Carregando...';
  String numero = 'Carregando...';
  String descricao = 'Carregando...';
  String endereco = 'Carregando...';

  String segunda = 'Não informado';
  String terca = 'Não informado';
  String quarta = 'Não informado';
  String quinta = 'Não informado';
  String sexta = 'Não informado';
  String sabado = 'Não informado';
  String domingo = 'Não informado';
  String feriados = 'Não informado';

  String instagram = 'Não informado';
  String facebook = 'Não informado';
  String tiktok = 'Não informado';
  String website = 'Não informado';

  String necessitaAgendamento = 'Não informado';

  String pagamentoCartao = 'Não informado';
  String pagamentoPix = 'Não informado';
  String pagamentoOutros = 'Não informado';

  List<Map<String, dynamic>> profissionais = [];
  List<dynamic> fotos = [];

  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    _buscarDadosEmpresa();
  }

  // Buscar dados da empresa
  Future<void> _buscarDadosEmpresa() async {
    try {
      final User? usuario =
          FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          nome = 'Usuário não identificado';
          cnpj = 'Não informado';
          categoria = 'Não informado';
          numero = 'Não informado';
          descricao = 'Não informado';
          endereco = 'Não informado';
          necessitaAgendamento = 'Não informado';
          carregando = false;
        });

        return;
      }

      final String uid = usuario.uid;

      DocumentSnapshot<Map<String, dynamic>> documento =
          await FirebaseFirestore.instance
              .collection('empresas')
              .doc(uid)
              .get();

      if (!documento.exists) {
        final QuerySnapshot<Map<String, dynamic>> resultado =
            await FirebaseFirestore.instance
                .collection('empresas')
                .where(
                  'uid',
                  isEqualTo: uid,
                )
                .limit(1)
                .get();

        if (resultado.docs.isNotEmpty) {
          documento = resultado.docs.first;
        }
      }

      if (documento.exists) {
        final Map<String, dynamic> dados =
            documento.data() ?? {};

        Map<String, dynamic> horarios = {};

        if (dados['horarios'] is Map) {
          horarios = Map<String, dynamic>.from(
            dados['horarios'],
          );
        }

        Map<String, dynamic> redesSociais = {};

        if (dados['redesSociais'] is Map) {
          redesSociais = Map<String, dynamic>.from(
            dados['redesSociais'],
          );
        }

        Map<String, dynamic> pagamentos = {};

        if (dados['formasPagamento'] is Map) {
          pagamentos = Map<String, dynamic>.from(
            dados['formasPagamento'],
          );
        }

        List<Map<String, dynamic>> profissionaisBanco = [];

        if (dados['profissionais'] is List) {
          for (final profissional
              in dados['profissionais']) {
            if (profissional is Map) {
              profissionaisBanco.add(
                Map<String, dynamic>.from(
                  profissional,
                ),
              );
            }
          }
        }

        List<dynamic> fotosBanco = [];

        if (dados['fotos'] is List) {
          fotosBanco =
              List<dynamic>.from(
            dados['fotos'],
          );
        }

        if (!mounted) return;

        setState(() {
          nome = _valor(dados['nome']);
          cnpj = _valor(dados['cnpj']);
          categoria = _valor(dados['categoria']);
          numero = _valor(dados['numero']);
          descricao = _valor(dados['descricao']);
          endereco = _valor(dados['endereco']);

          segunda = _valor(horarios['segunda']);
          terca = _valor(horarios['terca']);
          quarta = _valor(horarios['quarta']);
          quinta = _valor(horarios['quinta']);
          sexta = _valor(horarios['sexta']);
          sabado = _valor(horarios['sabado']);
          domingo = _valor(horarios['domingo']);
          feriados = _valor(horarios['feriados']);

          instagram = _valor(
            redesSociais['instagram'],
          );

          facebook = _valor(
            redesSociais['facebook'],
          );

          tiktok = _valor(
            redesSociais['tiktok'],
          );

          website = _valor(
            redesSociais['website'],
          );

          necessitaAgendamento =
              _valor(
            dados['necessitaAgendamento'],
          );

          pagamentoCartao =
              _valor(
            pagamentos['cartao'],
          );

          pagamentoPix =
              _valor(
            pagamentos['pix'],
          );

          pagamentoOutros =
              _valor(
            pagamentos['outros'],
          );

          profissionais =
              profissionaisBanco;

          fotos = fotosBanco;

          carregando = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        nome = 'Empresa não encontrada';
        cnpj = 'Não informado';
        categoria = 'Não informado';
        numero = 'Não informado';
        descricao = 'Não informado';
        endereco = 'Não informado';
        necessitaAgendamento = 'Não informado';
        carregando = false;
      });
    } on FirebaseException catch (e) {
      debugPrint(
        'Erro Firebase: ${e.code} - ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        nome = 'Erro ao carregar empresa';
        cnpj = 'Não disponível';
        categoria = 'Não disponível';
        numero = 'Não disponível';
        descricao = 'Não disponível';
        endereco = 'Não disponível';
        necessitaAgendamento = 'Não disponível';
        carregando = false;
      });
    } catch (e) {
      debugPrint(
        'Erro geral: $e',
      );

      if (!mounted) return;

      setState(() {
        nome = 'Erro ao carregar';
        cnpj = 'Não disponível';
        categoria = 'Não disponível';
        numero = 'Não disponível';
        descricao = 'Não disponível';
        endereco = 'Não disponível';
        necessitaAgendamento = 'Não disponível';
        carregando = false;
      });
    }
  }

  String _valor(dynamic valor) {
    if (valor == null) {
      return 'Não informado';
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return 'Não informado';
    }

    return texto;
  }

  // Referência da empresa
  Future<DocumentReference<Map<String, dynamic>>?>
      _obterReferenciaEmpresa() async {
    final usuario =
        FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return null;
    }

    final firestore =
        FirebaseFirestore.instance;

    final referencia =
        firestore
            .collection('empresas')
            .doc(usuario.uid);

    final documento =
        await referencia.get();

    if (documento.exists) {
      return referencia;
    }

    final resultado =
        await firestore
            .collection('empresas')
            .where(
              'uid',
              isEqualTo: usuario.uid,
            )
            .limit(1)
            .get();

    if (resultado.docs.isNotEmpty) {
      return resultado.docs.first.reference;
    }

    return null;
  }

  // Salvar campo simples
  Future<void> _salvarCampo(
    String campo,
    String valor,
  ) async {
    final referencia =
        await _obterReferenciaEmpresa();

    if (referencia == null) {
      _mostrarMensagem(
        'Empresa não encontrada.',
      );
      return;
    }

    try {
      setState(() {
        salvando = true;
      });

      await referencia.update({
        campo: valor.trim(),
      });

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Informação atualizada com sucesso.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Erro ao atualizar informação.',
      );

      debugPrint(
        'Erro ao salvar $campo: $e',
      );
    }
  }

  // Salvar mapa
  Future<void> _salvarMapa(
    String campo,
    Map<String, dynamic> dados,
  ) async {
    final referencia =
        await _obterReferenciaEmpresa();

    if (referencia == null) {
      _mostrarMensagem(
        'Empresa não encontrada.',
      );
      return;
    }

    try {
      setState(() {
        salvando = true;
      });

      await referencia.update({
        campo: dados,
      });

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Informações atualizadas com sucesso.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Erro ao atualizar informações.',
      );

      debugPrint(
        'Erro ao salvar $campo: $e',
      );
    }
  }

  // Salvar lista
  Future<void> _salvarLista(
    String campo,
    List<dynamic> dados,
  ) async {
    final referencia =
        await _obterReferenciaEmpresa();

    if (referencia == null) {
      _mostrarMensagem(
        'Empresa não encontrada.',
      );
      return;
    }

    try {
      setState(() {
        salvando = true;
      });

      await referencia.update({
        campo: dados,
      });

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Informações atualizadas com sucesso.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      _mostrarMensagem(
        'Erro ao atualizar informações.',
      );

      debugPrint(
        'Erro ao salvar $campo: $e',
      );
    }
  }

  // Sair
  Future<void> _sair() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LOGIN(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Erro ao sair: $e',
      );

      if (!mounted) return;

      _mostrarMensagem(
        'Erro ao sair da conta.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF98B9A6),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Color(0xFF6C757D),
                              child: Icon(
                                Icons.business,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome,
                                    style:
                                        const TextStyle(
                                      fontSize: 28,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    categoria,
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      color:
                                          Color(0xFF495057),
                                    ),
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        _buildProfileOption(
                          icon: Icons.badge_outlined,
                          label: 'CNPJ: $cnpj',
                          onTap: _mostrarCnpj,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.phone_outlined,
                          label: 'Telefone: $numero',
                          onTap: _mostrarTelefone,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.location_on_outlined,
                          label: endereco,
                          onTap: _mostrarEndereco,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon:
                              Icons.access_time_outlined,
                          label:
                              'Horários de funcionamento',
                          onTap: _mostrarHorarios,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon:
                              Icons.description_outlined,
                          label: 'Descrição',
                          onTap: _mostrarDescricao,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.public,
                          label: 'Redes sociais',
                          onTap:
                              _mostrarRedesSociais,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.calendar_month_outlined,
                          label:
                              'Agendamento: $necessitaAgendamento',
                          onTap:
                              _mostrarAgendamento,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.people_outline,
                          label:
                              'Profissionais (${profissionais.length})',
                          onTap:
                              _mostrarProfissionais,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon:
                              Icons.photo_library_outlined,
                          label:
                              'Fotos (${fotos.length})',
                          onTap: _mostrarFotos,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon: Icons.payment_outlined,
                          label:
                              'Formas de pagamento',
                          onTap:
                              _mostrarPagamentos,
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon:
                              Icons.favorite_border,
                          label: 'Favoritos',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const Scaffold(
                                  backgroundColor:
                                      Colors.white,
                                  body:
                                      Favoritos(),
                                ),
                              ),
                            );
                          },
                        ),

                        const Divider(height: 1),

                        _buildProfileOption(
                          icon:
                              Icons.calendar_today_outlined,
                          label: 'Agendamentos',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const Scaffold(
                                  backgroundColor:
                                      Colors.white,
                                  body:
                                      Agendamentos(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _mostrarMensagem(
                              'Toque em um campo acima para editá-lo.',
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                            size: 28,
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          style:
                              TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: _sair,
                          splashColor:
                              Colors.green.withOpacity(
                            0.3,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Text(
                                  'Sair',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.exit_to_app,
                                  color: Colors.black,
                                  size: 28,
                                ),
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
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  // CNPJ
  void _mostrarCnpj() {
    _mostrarEdicaoSimples(
      titulo: 'CNPJ',
      valorInicial: cnpj,
      campo: 'cnpj',
      keyboardType: TextInputType.number,
      onAtualizado: (valor) {
        setState(() {
          cnpj = valor;
        });
      },
    );
  }

  // Telefone
  void _mostrarTelefone() {
    _mostrarEdicaoSimples(
      titulo: 'Telefone',
      valorInicial: numero,
      campo: 'numero',
      keyboardType: TextInputType.phone,
      onAtualizado: (valor) {
        setState(() {
          numero = valor;
        });
      },
    );
  }

  // Endereço
  void _mostrarEndereco() {
    _mostrarEdicaoSimples(
      titulo: 'Endereço',
      valorInicial: endereco,
      campo: 'endereco',
      keyboardType: TextInputType.streetAddress,
      onAtualizado: (valor) {
        setState(() {
          endereco = valor;
        });
      },
    );
  }

  // Agendamento
  void _mostrarAgendamento() {
    String valorAtual =
        necessitaAgendamento;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Agendamento',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                    ),
                    onPressed: () {
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
              content: DropdownButtonFormField<String>(
                value:
                    valorAtual == 'SIM' ||
                            valorAtual == 'NÃO'
                        ? valorAtual
                        : null,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Necessita agendamento?',
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SIM',
                    child: Text('SIM'),
                  ),
                  DropdownMenuItem(
                    value: 'NÃO',
                    child: Text('NÃO'),
                  ),
                ],
                onChanged: (valor) {
                  setDialogState(() {
                    valorAtual =
                        valor ??
                            valorAtual;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF98B9A6,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(
                      dialogContext,
                    );

                    await _salvarCampo(
                      'necessitaAgendamento',
                      valorAtual,
                    );

                    if (mounted) {
                      setState(() {
                        necessitaAgendamento =
                            valorAtual;
                      });
                    }
                  },
                  child:
                      const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Caixa de edição simples
  void _mostrarEdicaoSimples({
    required String titulo,
    required String valorInicial,
    required String campo,
    required TextInputType keyboardType,
    required Function(String) onAtualizado,
  }) {
    final controller =
        TextEditingController(
      text: valorInicial ==
              'Não informado'
          ? ''
          : valorInicial,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(titulo),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content: TextField(
                controller: controller,
                enabled: editando,
                keyboardType:
                    keyboardType,
                maxLines:
                    titulo ==
                            'Endereço'
                        ? 3
                        : 1,
                decoration:
                    InputDecoration(
                  labelText:
                      titulo,
                  border:
                      const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final valor =
                          controller
                              .text
                              .trim();

                      if (valor.isEmpty) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarCampo(
                        campo,
                        valor,
                      );

                      if (mounted) {
                        onAtualizado(
                          valor,
                        );
                      }
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  // Horários
  void _mostrarHorarios() {
    final horarios = {
      'segunda': segunda,
      'terca': terca,
      'quarta': quarta,
      'quinta': quinta,
      'sexta': sexta,
      'sabado': sabado,
      'domingo': domingo,
      'feriados': feriados,
    };

    final controllers =
        <String, TextEditingController>{
      for (final entry in horarios.entries)
        entry.key: TextEditingController(
          text: entry.value == 'Não informado'
              ? ''
              : entry.value,
        ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Horários de funcionamento',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content:
                  SizedBox(
                width: double.maxFinite,
                child:
                    SingleChildScrollView(
                  child: Column(
                    children: [
                      _campoHorario(
                        'Segunda',
                        controllers['segunda']!,
                        editando,
                      ),
                      _campoHorario(
                        'Terça',
                        controllers['terca']!,
                        editando,
                      ),
                      _campoHorario(
                        'Quarta',
                        controllers['quarta']!,
                        editando,
                      ),
                      _campoHorario(
                        'Quinta',
                        controllers['quinta']!,
                        editando,
                      ),
                      _campoHorario(
                        'Sexta',
                        controllers['sexta']!,
                        editando,
                      ),
                      _campoHorario(
                        'Sábado',
                        controllers['sabado']!,
                        editando,
                      ),
                      _campoHorario(
                        'Domingo',
                        controllers['domingo']!,
                        editando,
                      ),
                      _campoHorario(
                        'Feriados',
                        controllers['feriados']!,
                        editando,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final novosHorarios =
                          {
                        'segunda':
                            controllers[
                                    'segunda']!
                                .text
                                .trim(),
                        'terca':
                            controllers[
                                    'terca']!
                                .text
                                .trim(),
                        'quarta':
                            controllers[
                                    'quarta']!
                                .text
                                .trim(),
                        'quinta':
                            controllers[
                                    'quinta']!
                                .text
                                .trim(),
                        'sexta':
                            controllers[
                                    'sexta']!
                                .text
                                .trim(),
                        'sabado':
                            controllers[
                                    'sabado']!
                                .text
                                .trim(),
                        'domingo':
                            controllers[
                                    'domingo']!
                                .text
                                .trim(),
                        'feriados':
                            controllers[
                                    'feriados']!
                                .text
                                .trim(),
                      };

                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarMapa(
                        'horarios',
                        novosHorarios,
                      );

                      if (mounted) {
                        setState(() {
                          segunda =
                              _valor(
                            novosHorarios[
                                'segunda'],
                          );
                          terca =
                              _valor(
                            novosHorarios[
                                'terca'],
                          );
                          quarta =
                              _valor(
                            novosHorarios[
                                'quarta'],
                          );
                          quinta =
                              _valor(
                            novosHorarios[
                                'quinta'],
                          );
                          sexta =
                              _valor(
                            novosHorarios[
                                'sexta'],
                          );
                          sabado =
                              _valor(
                            novosHorarios[
                                'sabado'],
                          );
                          domingo =
                              _valor(
                            novosHorarios[
                                'domingo'],
                          );
                          feriados =
                              _valor(
                            novosHorarios[
                                'feriados'],
                          );
                        });
                      }
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      for (final controller
          in controllers.values) {
        controller.dispose();
      }
    });
  }

  Widget _campoHorario(
    String label,
    TextEditingController controller,
    bool editando,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        enabled: editando,
        decoration:
            InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Descrição
  void _mostrarDescricao() {
    final controller =
        TextEditingController(
      text: descricao ==
              'Não informado'
          ? ''
          : descricao,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Descrição',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content: TextField(
                controller: controller,
                enabled: editando,
                maxLines: 7,
                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final valor =
                          controller
                              .text
                              .trim();

                      if (valor.isEmpty) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarCampo(
                        'descricao',
                        valor,
                      );

                      if (mounted) {
                        setState(() {
                          descricao =
                              valor;
                        });
                      }
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  // Redes sociais
  void _mostrarRedesSociais() {
    final controllers =
        <String, TextEditingController>{
      'instagram':
          TextEditingController(
        text: instagram ==
                'Não informado'
            ? ''
            : instagram,
      ),
      'facebook':
          TextEditingController(
        text: facebook ==
                'Não informado'
            ? ''
            : facebook,
      ),
      'tiktok':
          TextEditingController(
        text: tiktok ==
                'Não informado'
            ? ''
            : tiktok,
      ),
      'website':
          TextEditingController(
        text: website ==
                'Não informado'
            ? ''
            : website,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Redes sociais',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  children: [
                    _campoRede(
                      'Instagram',
                      controllers[
                          'instagram']!,
                      editando,
                    ),
                    _campoRede(
                      'Facebook',
                      controllers[
                          'facebook']!,
                      editando,
                    ),
                    _campoRede(
                      'TikTok',
                      controllers[
                          'tiktok']!,
                      editando,
                    ),
                    _campoRede(
                      'Website',
                      controllers[
                          'website']!,
                      editando,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final novasRedes =
                          {
                        'instagram':
                            controllers[
                                    'instagram']!
                                .text
                                .trim(),
                        'facebook':
                            controllers[
                                    'facebook']!
                                .text
                                .trim(),
                        'tiktok':
                            controllers[
                                    'tiktok']!
                                .text
                                .trim(),
                        'website':
                            controllers[
                                    'website']!
                                .text
                                .trim(),
                      };

                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarMapa(
                        'redesSociais',
                        novasRedes,
                      );

                      if (mounted) {
                        setState(() {
                          instagram =
                              _valor(
                            novasRedes[
                                'instagram'],
                          );
                          facebook =
                              _valor(
                            novasRedes[
                                'facebook'],
                          );
                          tiktok =
                              _valor(
                            novasRedes[
                                'tiktok'],
                          );
                          website =
                              _valor(
                            novasRedes[
                                'website'],
                          );
                        });
                      }
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      for (final controller
          in controllers.values) {
        controller.dispose();
      }
    });
  }

  Widget _campoRede(
    String label,
    TextEditingController controller,
    bool editando,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        enabled: editando,
        decoration:
            InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Profissionais
  void _mostrarProfissionais() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            bool editando = false;

            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profissionais (${profissionais.length})',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content: profissionais.isEmpty
                  ? const Text(
                      'Nenhum profissional cadastrado.',
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: ListView.builder(
                        itemCount:
                            profissionais.length,
                        itemBuilder:
                            (context, index) {
                          final profissional =
                              profissionais[index];

                          final nomeProfissional =
                              _valor(
                            profissional[
                                'nome'],
                          );

                          final profissao =
                              _valor(
                            profissional[
                                'profissao'],
                          );

                          final experiencia =
                              _valor(
                            profissional[
                                'experiencia'],
                          );

                          return Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .all(8),
                              child:
                                  editando
                                      ? Column(
                                          children: [
                                            TextField(
                                              controller:
                                                  TextEditingController(
                                                text:
                                                    nomeProfissional ==
                                                            'Não informado'
                                                        ? ''
                                                        : nomeProfissional,
                                              ),
                                              decoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Nome',
                                              ),
                                              onChanged:
                                                  (valor) {
                                                profissionais[
                                                        index]
                                                    [
                                                    'nome'] = valor;
                                              },
                                            ),
                                            TextField(
                                              controller:
                                                  TextEditingController(
                                                text:
                                                    profissao ==
                                                            'Não informado'
                                                        ? ''
                                                        : profissao,
                                              ),
                                              decoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Profissão',
                                              ),
                                              onChanged:
                                                  (valor) {
                                                profissionais[
                                                        index]
                                                    [
                                                    'profissao'] = valor;
                                              },
                                            ),
                                            TextField(
                                              controller:
                                                  TextEditingController(
                                                text:
                                                    experiencia ==
                                                            'Não informado'
                                                        ? ''
                                                        : experiencia,
                                              ),
                                              decoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Experiência',
                                              ),
                                              onChanged:
                                                  (valor) {
                                                profissionais[
                                                        index]
                                                    [
                                                    'experiencia'] = valor;
                                              },
                                            ),
                                          ],
                                        )
                                      : ListTile(
                                          leading:
                                              const CircleAvatar(
                                            backgroundColor:
                                                Color(
                                              0xFF6C757D,
                                            ),
                                            child:
                                                Icon(
                                              Icons
                                                  .person,
                                              color:
                                                  Colors.white,
                                            ),
                                          ),
                                          title:
                                              Text(
                                            nomeProfissional,
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                          subtitle:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                profissao,
                                              ),
                                              Text(
                                                'Experiência: $experiencia',
                                              ),
                                            ],
                                          ),
                                        ),
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarLista(
                        'profissionais',
                        profissionais,
                      );
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Fotos
  void _mostrarFotos() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool editando = false;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fotos (${fotos.length})',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content: fotos.isEmpty
                  ? const Text(
                      'Nenhuma foto cadastrada.',
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount:
                            fotos.length,
                        itemBuilder:
                            (context, index) {
                          final foto =
                              fotos[index]
                                  .toString();

                          return Stack(
                            children: [
                              Positioned.fill(
                                child:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                  child:
                                      Image.network(
                                    foto,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        color: Colors
                                            .grey
                                            .shade300,
                                        child:
                                            const Icon(
                                          Icons
                                              .broken_image,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (editando)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child:
                                      Container(
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Colors.white,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child:
                                        IconButton(
                                      icon:
                                          const Icon(
                                        Icons.delete,
                                        color:
                                            Colors.red,
                                      ),
                                      onPressed:
                                          () {
                                        setDialogState(
                                          () {
                                            fotos.removeAt(
                                              index,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarLista(
                        'fotos',
                        fotos,
                      );
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Pagamentos
  void _mostrarPagamentos() {
    final controllers =
        <String, TextEditingController>{
      'cartao':
          TextEditingController(
        text: pagamentoCartao ==
                'Não informado'
            ? ''
            : pagamentoCartao,
      ),
      'pix':
          TextEditingController(
        text: pagamentoPix ==
                'Não informado'
            ? ''
            : pagamentoPix,
      ),
      'outros':
          TextEditingController(
        text: pagamentoOutros ==
                'Não informado'
            ? ''
            : pagamentoOutros,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Formas de pagamento',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        editando = true;
                      });
                    },
                  ),
                ],
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  children: [
                    _campoPagamento(
                      'Cartão',
                      controllers[
                          'cartao']!,
                      editando,
                    ),
                    _campoPagamento(
                      'Pix',
                      controllers['pix']!,
                      editando,
                    ),
                    _campoPagamento(
                      'Outros',
                      controllers[
                          'outros']!,
                      editando,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Fechar'),
                ),
                if (editando)
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF98B9A6,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () async {
                      final pagamentos =
                          {
                        'cartao':
                            controllers[
                                    'cartao']!
                                .text
                                .trim(),
                        'pix':
                            controllers[
                                    'pix']!
                                .text
                                .trim(),
                        'outros':
                            controllers[
                                    'outros']!
                                .text
                                .trim(),
                      };

                      Navigator.pop(
                        dialogContext,
                      );

                      await _salvarMapa(
                        'formasPagamento',
                        pagamentos,
                      );

                      if (mounted) {
                        setState(() {
                          pagamentoCartao =
                              _valor(
                            pagamentos[
                                'cartao'],
                          );
                          pagamentoPix =
                              _valor(
                            pagamentos[
                                'pix'],
                          );
                          pagamentoOutros =
                              _valor(
                            pagamentos[
                                'outros'],
                          );
                        });
                      }
                    },
                    child:
                        const Text('Salvar'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      for (final controller
          in controllers.values) {
        controller.dispose();
      }
    });
  }

  Widget _campoPagamento(
    String label,
    TextEditingController controller,
    bool editando,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        enabled: editando,
        decoration:
            InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _linhaInformacao(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 23,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(valor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(
    String mensagem,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }
}