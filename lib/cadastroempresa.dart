
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroway/menuprincipal.dart';
import 'package:neuroway/cadastroprofi.dart';

class CadastroEmpresa extends StatefulWidget {
  const CadastroEmpresa({super.key});

  @override
  State<CadastroEmpresa> createState() => _CadastroEmpresaState();
}

class _CadastroEmpresaState extends State<CadastroEmpresa> {
  final _formKey = GlobalKey<FormState>();

  String _necessitaAgendamento = 'NÃO';

  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _carregando = false;

  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _cnpjController =
      TextEditingController();

  final TextEditingController _telefoneController =
      TextEditingController();

  final TextEditingController _descricaoController =
      TextEditingController();

  final TextEditingController _enderecoController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _senhaController =
      TextEditingController();

  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  String _categoriaSelecionada = 'Saúde';

  final List<String> _categorias = [
    'Saúde',
    'Educação',
    'Estética',
    'Cuidados Pessoais',
  ];

  final Map<String, bool> _diasSelecionados = {
    'Segunda': false,
    'Terça': false,
    'Quarta': false,
    'Quinta': false,
    'Sexta': false,
    'Sábado': false,
    'Domingo': false,
    'Feriados': false,
  };

  final Map<String, TimeOfDay?> _horarioAbertura = {
    'Segunda': null,
    'Terça': null,
    'Quarta': null,
    'Quinta': null,
    'Sexta': null,
    'Sábado': null,
    'Domingo': null,
    'Feriados': null,
  };

  final Map<String, TimeOfDay?> _horarioFechamento = {
    'Segunda': null,
    'Terça': null,
    'Quarta': null,
    'Quinta': null,
    'Sexta': null,
    'Sábado': null,
    'Domingo': null,
    'Feriados': null,
  };

  final TextEditingController _instagramController =
      TextEditingController();

  final TextEditingController _facebookController =
      TextEditingController();

  final TextEditingController _tiktokController =
      TextEditingController();

  final TextEditingController _websiteController =
      TextEditingController();

  final Map<String, bool> _formasPagamento = {
    'Cartão': false,
    'Pix': false,
    'Dinheiro': false,
    'Outros': false,
  };

  final List<Map<String, String>> _profissionais = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  // ============================================================
  // ADICIONAR PROFISSIONAL
  // ============================================================

  Future<void> _adicionarProfissional() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroPage(),
      ),
    );

    if (resultado != null && resultado is Map) {
      final nome =
          resultado['nome']?.toString() ?? '';

      final especialidade =
          resultado['especialidade']?.toString() ?? '';

      final uid =
          resultado['uid']?.toString() ?? '';

      if (nome.trim().isNotEmpty) {
        setState(() {
          _profissionais.add({
            'uid': uid,
            'nome': nome,
            'especialidade': especialidade,
          });
        });
      }
    }
  }

  // ============================================================
  // EXCLUIR PROFISSIONAL
  // ============================================================

  Future<void> _removerProfissional(int index) async {
    if (index < 0 || index >= _profissionais.length) {
      return;
    }

    final profissional = _profissionais[index];

    final nome =
        profissional['nome']?.trim().isNotEmpty == true
            ? profissional['nome']!.trim()
            : 'este profissional';

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir profissional',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir esse profissional?\n\n'
            '$nome',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF76A085),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _profissionais.removeAt(index);
    });

    try {
      final usuario =
          FirebaseAuth.instance.currentUser;

      if (usuario != null) {
        final empresaRef = FirebaseFirestore.instance
            .collection('empresas')
            .doc(usuario.uid);

        final empresaDoc =
            await empresaRef.get();

        if (empresaDoc.exists) {
          await empresaRef.update({
            'profissionais': _profissionais,
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Erro ao atualizar profissionais no Firestore: $e',
      );
    }

    _mostrarMensagem(
      'Profissional excluído com sucesso.',
    );
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void _mostrarMensagem(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // HORÁRIOS
  // ============================================================

  Future<void> _selecionarHorario(
    String dia,
    bool abertura,
  ) async {
    final horarioAtual = abertura
        ? _horarioAbertura[dia]
        : _horarioFechamento[dia];

    final selecionado = await showTimePicker(
      context: context,
      initialTime: horarioAtual ??
          const TimeOfDay(
            hour: 8,
            minute: 0,
          ),
    );

    if (selecionado == null) {
      return;
    }

    setState(() {
      if (abertura) {
        _horarioAbertura[dia] = selecionado;
      } else {
        _horarioFechamento[dia] = selecionado;
      }
    });
  }

  String _formatarHorario(TimeOfDay? horario) {
    if (horario == null) {
      return '--:--';
    }

    return horario.format(context);
  }

  // ============================================================
  // CADASTRAR EMPRESA
  // ============================================================

  Future<void> _cadastrarEmpresa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_senhaController.text !=
        _confirmarSenhaController.text) {
      _mostrarMensagem(
        'As senhas não coincidem.',
      );
      return;
    }

    if (_senhaController.text.length < 6) {
      _mostrarMensagem(
        'A senha deve possuir pelo menos 6 caracteres.',
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final credencial =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      final usuario = credencial.user;

      if (usuario == null) {
        throw Exception(
          'Não foi possível criar o usuário.',
        );
      }

      final Map<String, dynamic> horarios = {};

      for (final dia in _diasSelecionados.keys) {
        horarios[dia] = {
          'abertura':
              _horarioAbertura[dia] != null
                  ? _horarioAbertura[dia]!.format(context)
                  : '',
          'fechamento':
              _horarioFechamento[dia] != null
                  ? _horarioFechamento[dia]!.format(context)
                  : '',
          'aberto':
              _diasSelecionados[dia] ?? false,
        };
      }

      final Map<String, dynamic> redesSociais = {
        'instagram':
            _instagramController.text.trim(),
        'facebook':
            _facebookController.text.trim(),
        'tiktok':
            _tiktokController.text.trim(),
        'website':
            _websiteController.text.trim(),
      };

      final Map<String, dynamic> formasPagamento = {
        'cartao':
            _formasPagamento['Cartão'] ?? false,
        'pix':
            _formasPagamento['Pix'] ?? false,
        'dinheiro':
            _formasPagamento['Dinheiro'] ?? false,
        'outros':
            _formasPagamento['Outros'] ?? false,
      };

      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(usuario.uid)
          .set({
        'uid': usuario.uid,
        'tipoUsuario': 'empresa',
        'nome': _nomeController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'categoria': _categoriaSelecionada,
        'telefone':
            _telefoneController.text.trim(),
        'descricao':
            _descricaoController.text.trim(),
        'endereco':
            _enderecoController.text.trim(),
        'email':
            _emailController.text.trim(),
        'horarios': horarios,
        'redesSociais': redesSociais,
        'necessitaAgendamento':
            _necessitaAgendamento,
        'profissionais':
            _profissionais,
        'fotos': [],
        'formasPagamento':
            formasPagamento,
        'criadoEm':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Empresa cadastrada com sucesso!',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const Menuprincipal(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mensagem =
          'Erro ao cadastrar empresa.';

      if (e.code == 'email-already-in-use') {
        mensagem =
            'Este e-mail já está sendo utilizado.';
      } else if (e.code == 'invalid-email') {
        mensagem =
            'O e-mail informado é inválido.';
      } else if (e.code == 'weak-password') {
        mensagem =
            'A senha informada é muito fraca.';
      }

      _mostrarMensagem(mensagem);
    } catch (e) {
      _mostrarMensagem(
        'Erro ao cadastrar empresa: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFISSIONAIS
  // ============================================================

  Widget _buildProfissionaisSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Profissionais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _adicionarProfissional,
              icon: const Icon(
                Icons.person_add,
                size: 18,
              ),
              label: const Text(
                'Adicionar',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF76A085),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_profissionais.isEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: const Text(
              'Nenhum profissional adicionado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          )
        else
          Column(
            children: List.generate(
              _profissionais.length,
              (index) {
                final profissional =
                    _profissionais[index];

                final nome =
                    profissional['nome'] ?? '';

                final especialidade =
                    profissional['especialidade'] ??
                        '';

                return Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.04),
                        blurRadius: 4,
                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF76A085,
                          ).withOpacity(0.15),
                          shape:
                              BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color:
                              Color(0xFF76A085),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              nome,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.black,
                              ),
                            ),

                            if (especialidade
                                .trim()
                                .isNotEmpty)
                              ...[
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  especialidade,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ),

                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () =>
                              _removerProfissional(
                            index,
                          ),
                          tooltip:
                              'Excluir profissional',
                          padding:
                              EdgeInsets.zero,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ============================================================
  // HORÁRIOS
  // ============================================================

  Widget _buildHorariosSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Horários de funcionamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 10),

        ..._diasSelecionados.keys.map(
          (dia) {
            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration:
                  BoxDecoration(
                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            CheckboxListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          title: Text(
                            dia,
                            style:
                                const TextStyle(
                              color:
                                  Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          value:
                              _diasSelecionados[
                                  dia],
                          activeColor:
                              Colors.black,
                          checkColor:
                              Colors.white,
                          selected: false,
                          onChanged:
                              (valor) {
                            setState(() {
                              _diasSelecionados[
                                      dia] =
                                  valor ?? false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading,
                        ),
                      ),
                    ],
                  ),

                  if (_diasSelecionados[
                          dia] ==
                      true)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton(
                              onPressed: () =>
                                  _selecionarHorario(
                                dia,
                                true,
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    Colors.black,
                                side:
                                    const BorderSide(
                                  color:
                                      Colors.black,
                                ),
                              ),
                              child: Text(
                                'Abertura: ${_formatarHorario(_horarioAbertura[dia])}',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.black,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                                OutlinedButton(
                              onPressed: () =>
                                  _selecionarHorario(
                                dia,
                                false,
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    Colors.black,
                                side:
                                    const BorderSide(
                                  color:
                                      Colors.black,
                                ),
                              ),
                              child: Text(
                                'Fechamento: ${_formatarHorario(_horarioFechamento[dia])}',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // REDES SOCIAIS
  // ============================================================

  Widget _buildRedesSociaisSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Redes sociais',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        _campoTexto(
          label: 'Instagram',
          controller: _instagramController,
          hint: '@suaempresa',
        ),

        _campoTexto(
          label: 'Facebook',
          controller: _facebookController,
        ),

        _campoTexto(
          label: 'TikTok',
          controller: _tiktokController,
        ),

        _campoTexto(
          label: 'Website',
          controller: _websiteController,
          keyboardType:
              TextInputType.url,
        ),
      ],
    );
  }

  // ============================================================
  // FORMAS DE PAGAMENTO
  // ============================================================

  Widget _buildFormasPagamentoSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Formas de pagamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        ..._formasPagamento.keys.map(
          (forma) {
            return CheckboxListTile(
              contentPadding:
                  EdgeInsets.zero,
              title: Text(
                forma,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              value:
                  _formasPagamento[forma],
              activeColor: Colors.black,
              checkColor: Colors.white,
              selected: false,
              onChanged: (valor) {
                setState(() {
                  _formasPagamento[
                          forma] =
                      valor ?? false;
                });
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context).size.height;

    final double screenWidth =
        MediaQuery.of(context).size.width;

    final double molduraHeight =
        screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(),

        child: Column(
          children: [

            // ==================================================
            // QUEBRA-CABEÇA SUPERIOR
            // ==================================================

            SizedBox(
              height: molduraHeight,
              width: double.infinity,
              child: Image.asset(
                'imagem/quebrasuperior.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            // MESMO ESPAÇO DA TELA PROFISSIONAL
            const SizedBox(height: 10),

            // ==================================================
            // CABEÇALHO
            // ==================================================

            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 16,
              ),
              child: SizedBox(
                height: 150,

                child: Stack(
                  alignment: Alignment.center,

                  children: [

                    // SETA
                    Positioned(
                      left: 0,

                      child: IconButton(
                        padding: EdgeInsets.zero,

                        constraints:
                            const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),

                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 22,
                        ),

                        onPressed: _carregando
                            ? null
                            : () {
                                Navigator.maybePop(
                                  context,
                                );
                              },
                      ),
                    ),

                    // IMAGEM DA EMPRESA
                    Center(
                      child: SizedBox(
                        height: 150,
                        width: 260,
                        child: Image.asset(
                          'imagem/Cadastro_empresa.png',
                          width: 260,
                          height: 150,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // FORMULÁRIO
            // ==================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // NOME
                    // ==================================================

                    _campoTexto(
                      label: 'Nome',
                      controller:
                          _nomeController,
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o nome da empresa.';
                        }

                        return null;
                      },
                    ),

                    // ==================================================
                    // CNPJ
                    // ==================================================

                    _campoTexto(
                      label: 'CNPJ',
                      controller:
                          _cnpjController,
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          14,
                        ),
                      ],
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o CNPJ.';
                        }

                        return null;
                      },
                    ),

                    // ==================================================
                    // CATEGORIA
                    // ==================================================

                    DropdownButtonFormField<String>(
                      value:
                          _categoriaSelecionada,

                      decoration:
                          InputDecoration(
                        labelText:
                            'Categoria',
                        filled: true,
                        fillColor:
                            Colors.white,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),

                      items:
                          _categorias.map(
                        (categoria) {
                          return DropdownMenuItem<
                              String>(
                            value:
                                categoria,
                            child:
                                Text(
                              categoria,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.black,
                              ),
                            ),
                          );
                        },
                      ).toList(),

                      onChanged:
                          (valor) {
                        if (valor == null) {
                          return;
                        }

                        setState(() {
                          _categoriaSelecionada =
                              valor;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ==================================================
                    // TELEFONE
                    // ==================================================

                    _campoTexto(
                      label: 'Telefone',
                      controller:
                          _telefoneController,
                      keyboardType:
                          TextInputType.phone,
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o telefone.';
                        }

                        return null;
                      },
                    ),

                    // ==================================================
                    // DESCRIÇÃO
                    // ==================================================

                    _campoTexto(
                      label: 'Descrição',
                      controller:
                          _descricaoController,
                      maxLines: 4,
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe uma descrição.';
                        }

                        return null;
                      },
                    ),

                    // ==================================================
                    // ENDEREÇO
                    // ==================================================

                    _campoTexto(
                      label: 'Endereço',
                      controller:
                          _enderecoController,
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o endereço.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // PROFISSIONAIS
                    // ==================================================

                    _buildProfissionaisSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // HORÁRIOS
                    // ==================================================

                    _buildHorariosSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // AGENDAMENTO
                    // ==================================================

                    const Text(
                      'Agendamento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      decoration:
                          BoxDecoration(
                        border:
                            Border.all(
                          color:
                              Colors.grey.shade300,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: Column(
                        children: [

                          RadioListTile<String>(
                            title:
                                const Text(
                              'SIM',
                              style:
                                  TextStyle(
                                color:
                                    Colors.black,
                              ),
                            ),
                            value: 'SIM',
                            groupValue:
                                _necessitaAgendamento,
                            activeColor:
                                Colors.black,
                            onChanged:
                                (valor) {
                              setState(() {
                                _necessitaAgendamento =
                                    valor!;
                              });
                            },
                          ),

                          RadioListTile<String>(
                            title:
                                const Text(
                              'NÃO',
                              style:
                                  TextStyle(
                                color:
                                    Colors.black,
                              ),
                            ),
                            value: 'NÃO',
                            groupValue:
                                _necessitaAgendamento,
                            activeColor:
                                Colors.black,
                            onChanged:
                                (valor) {
                              setState(() {
                                _necessitaAgendamento =
                                    valor!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // REDES SOCIAIS
                    // ==================================================

                    _buildRedesSociaisSection(),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // FORMAS DE PAGAMENTO
                    // ==================================================

                    _buildFormasPagamentoSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // DADOS DE ACESSO
                    // ==================================================

                    const Text(
                      'Dados de acesso',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.black,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // E-MAIL
                    // ==================================================

                    _campoTexto(
                      label: 'E-mail',
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      validator:
                          (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o e-mail.';
                        }

                        if (!valor.contains('@')) {
                          return 'Informe um e-mail válido.';
                        }

                        return null;
                      },
                    ),

                    // ==================================================
                    // SENHA
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child:
                          TextFormField(
                        controller:
                            _senhaController,

                        obscureText:
                            !_mostrarSenha,

                        validator:
                            (valor) {
                          if (valor == null ||
                              valor.isEmpty) {
                            return 'Informe uma senha.';
                          }

                          if (valor.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }

                          return null;
                        },

                        decoration:
                            InputDecoration(
                          labelText:
                              'Senha',

                          filled: true,
                          fillColor:
                              Colors.white,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(() {
                                _mostrarSenha =
                                    !_mostrarSenha;
                              });
                            },

                            icon: Icon(
                              _mostrarSenha
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // CONFIRMAR SENHA
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child:
                          TextFormField(
                        controller:
                            _confirmarSenhaController,

                        obscureText:
                            !_mostrarConfirmarSenha,

                        validator:
                            (valor) {
                          if (valor == null ||
                              valor.isEmpty) {
                            return 'Confirme a senha.';
                          }

                          if (valor !=
                              _senhaController
                                  .text) {
                            return 'As senhas não coincidem';
                          }

                          return null;
                        },

                        decoration:
                            InputDecoration(
                          labelText:
                              'Confirmar senha',

                          filled: true,
                          fillColor:
                              Colors.white,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(() {
                                _mostrarConfirmarSenha =
                                    !_mostrarConfirmarSenha;
                              });
                            },

                            icon: Icon(
                              _mostrarConfirmarSenha
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // BOTÃO CADASTRAR
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,

                      child:
                          ElevatedButton(
                        onPressed:
                            _carregando
                                ? null
                                : _cadastrarEmpresa,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF76A085,
                          ),

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                        ),

                        child:
                            _carregando
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                      strokeWidth:
                                          2.5,
                                    ),
                                  )
                                : const Text(
                                    'Cadastrar empresa',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // QUEBRA-CABEÇA INFERIOR
            // ==================================================

            SizedBox(
              height: molduraHeight,
              width: double.infinity,

              child: Image.asset(
                'imagem/quebrainferior.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment:
                    Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

