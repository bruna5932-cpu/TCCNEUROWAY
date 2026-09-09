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
  String _necessitaAgendamento = 'NÃO';

  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _carregando = false;

  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _categoriaController =
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

  final TextEditingController _instagramController =
      TextEditingController();

  final TextEditingController _facebookController =
      TextEditingController();

  final TextEditingController _tiktokController =
      TextEditingController();

  final TextEditingController _websiteController =
      TextEditingController();

  final TextEditingController _cartaoController =
      TextEditingController();

  final TextEditingController _pixController =
      TextEditingController();

  final TextEditingController _outrosPagamentoController =
      TextEditingController();

  final Map<String, TextEditingController> _horariosControllers =
      {};

  final List<Map<String, String>> _profissionais = [];

  bool get _senhasNaoCoincidem {
    return _senhaController.text !=
            _confirmarSenhaController.text &&
        _confirmarSenhaController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    final dias = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
      'Feriados',
    ];

    for (final dia in dias) {
      _horariosControllers[dia] =
          TextEditingController();
    }

    _senhaController.addListener(_atualizarSenhas);
    _confirmarSenhaController.addListener(_atualizarSenhas);
  }

  void _atualizarSenhas() {
    if (mounted) {
      setState(() {});
    }
  }

  // Adicionar profissional
  Future<void> _adicionarProfissional() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (resultado != null && resultado is Map) {
      final String nome =
          resultado['nome']?.toString() ?? '';

      final String especialidade =
          resultado['especialidade']?.toString() ?? '';

      final String uid =
          resultado['uid']?.toString() ?? '';

      if (nome.isNotEmpty) {
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

  // Realizar cadastro
  Future<void> _realizarCadastro() async {
    if (_senhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty) {
      _mostrarMensagem(
        'Preencha a senha e a confirmação de senha.',
      );
      return;
    }

    if (_senhaController.text.length < 6) {
      _mostrarMensagem(
        'A senha deve ter pelo menos 6 caracteres.',
      );
      return;
    }

    if (_senhaController.text !=
        _confirmarSenhaController.text) {
      setState(() {});
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _mostrarMensagem(
        'Digite o e-mail da empresa.',
      );
      return;
    }

    if (_carregando) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final String email =
          _emailController.text.trim();

      final String senha =
          _senhaController.text;

      final UserCredential credencial =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? usuario = credencial.user;

      if (usuario == null) {
        throw Exception(
          'Não foi possível criar o usuário.',
        );
      }

      final String uid = usuario.uid;

      // Horários
      final Map<String, String> horarios = {};

      _horariosControllers.forEach(
        (dia, controller) {
          horarios[dia] =
              controller.text.trim();
        },
      );

      // Profissionais
      final List<Map<String, String>> profissionais =
          _profissionais.map(
        (profissional) {
          return {
            'uid': profissional['uid'] ?? '',
            'nome': profissional['nome'] ?? '',
            'especialidade':
                profissional['especialidade'] ?? '',
          };
        },
      ).toList();

      // Salvar empresa no Firebase
      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(uid)
          .set({
        'uid': uid,
        'tipoUsuario': 'empresa',
        'nome': _nomeController.text.trim(),
        'categoria':
            _categoriaController.text.trim(),
        'telefone':
            _telefoneController.text.trim(),
        'descricao':
            _descricaoController.text.trim(),
        'endereco':
            _enderecoController.text.trim(),
        'email': email,
        'horarios': horarios,
        'redesSociais': {
          'instagram':
              _instagramController.text.trim(),
          'facebook':
              _facebookController.text.trim(),
          'tiktok':
              _tiktokController.text.trim(),
          'website':
              _websiteController.text.trim(),
        },
        'necessitaAgendamento':
            _necessitaAgendamento,
        'profissionais': profissionais,
        'fotos': [],
        'formasPagamento': {
          'cartao':
              _cartaoController.text.trim(),
          'pix':
              _pixController.text.trim(),
          'outros':
              _outrosPagamentoController.text.trim(),
        },
        'criadoEm':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem(
        'Empresa cadastrada com sucesso!',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const Menuprincipal(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem =
              'Este e-mail já está cadastrado.';
          break;

        case 'invalid-email':
          mensagem =
              'Digite um e-mail válido.';
          break;

        case 'weak-password':
          mensagem =
              'A senha é muito fraca.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O cadastro por e-mail e senha não está ativado no Firebase.';
          break;

        case 'configuration-not-found':
          mensagem =
              'A configuração do Firebase Authentication não foi encontrada.';
          break;

        case 'network-request-failed':
          mensagem =
              'Erro de conexão com o Firebase.';
          break;

        default:
          mensagem =
              'Erro ao criar a conta: ${e.message ?? e.code}';
      }

      _mostrarMensagem(mensagem);
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem(
        'Erro ao salvar os dados da empresa: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem(
        'Ocorreu um erro durante o cadastro.',
      );
    }
  }

  @override
  void dispose() {
    _senhaController.removeListener(
      _atualizarSenhas,
    );

    _confirmarSenhaController.removeListener(
      _atualizarSenhas,
    );

    _nomeController.dispose();
    _categoriaController.dispose();
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

    _cartaoController.dispose();
    _pixController.dispose();
    _outrosPagamentoController.dispose();

    for (final controller
        in _horariosControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final screenWidth =
        MediaQuery.of(context).size.width;

    final molduraHeight =
        screenHeight * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight * 0.75,
                  bottom: molduraHeight * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Cadastro de Empresa',
                          style: TextStyle(
                            fontSize:
                                screenWidth * 0.06,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Nome
                            _buildTextField(
                              label: 'Nome:',
                              controller:
                                  _nomeController,
                            ),

                            // Categoria
                            _buildTextField(
                              label: 'Categoria:',
                              controller:
                                  _categoriaController,
                              hint:
                                  '(escola, barbearia, restaurante...)',
                            ),

                            // Telefone
                            _buildTextField(
                              label: 'Telefone:',
                              controller:
                                  _telefoneController,
                              hint:
                                  '(12) 99999-9999',
                              keyboardType:
                                  TextInputType.phone,
                              inputFormatters: [
                                TelefoneInputFormatter(),
                              ],
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Horários
                            const Text(
                              'Dias/horários de funcionamento:',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _buildHorariosGrid(),

                            const SizedBox(
                              height: 18,
                            ),

                            // Descrição
                            _buildDescriptionField(),

                            // Endereço
                            _buildTextField(
                              label:
                                  'Endereço completo:',
                              controller:
                                  _enderecoController,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Redes sociais
                            const Text(
                              'Redes sociais:',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _buildSocialInput(
                              Icons.camera_alt,
                              'Instagram (URL ou @)',
                              _instagramController,
                            ),

                            _buildSocialInput(
                              Icons.facebook,
                              'Facebook (URL)',
                              _facebookController,
                            ),

                            _buildSocialInput(
                              Icons.music_note,
                              'TikTok',
                              _tiktokController,
                            ),

                            _buildSocialInput(
                              Icons.language,
                              'Website',
                              _websiteController,
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // Agendamento
                            const Text(
                              'Necessita agendamento?',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _buildAgendamentoOptions(),

                            const SizedBox(
                              height: 20,
                            ),

                            // Profissionais
                            const Text(
                              'Descrição dos profissionais:',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            _buildProfissionaisSection(),

                            const SizedBox(
                              height: 20,
                            ),

                            // Fotos
                            const Text(
                              'Fotos (até 15 fotos)',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            _buildFotosGrid(),

                            const SizedBox(
                              height: 20,
                            ),

                            // Pagamento
                            const Text(
                              'Formas de pagamento:',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _buildPaymentInput(
                              'Cartão (crédito/débito):',
                              _cartaoController,
                            ),

                            _buildPaymentInput(
                              'Pix:',
                              _pixController,
                            ),

                            _buildPaymentInput(
                              'Outros:',
                              _outrosPagamentoController,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // E-mail
                            _buildTextField(
                              label: 'Email:',
                              controller:
                                  _emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),

                            // Senha
                            _buildPasswordField(
                              label: 'Senha:',
                              controller:
                                  _senhaController,
                              mostrarSenha:
                                  _mostrarSenha,
                              onToggle: () {
                                setState(() {
                                  _mostrarSenha =
                                      !_mostrarSenha;
                                });
                              },
                            ),

                            // Confirmar senha
                            _buildPasswordField(
                              label:
                                  'Confirmar senha:',
                              controller:
                                  _confirmarSenhaController,
                              mostrarSenha:
                                  _mostrarConfirmarSenha,
                              onToggle: () {
                                setState(() {
                                  _mostrarConfirmarSenha =
                                      !_mostrarConfirmarSenha;
                                });
                              },
                            ),

                            if (_senhasNaoCoincidem)
                              const Padding(
                                padding:
                                    EdgeInsets.only(
                                  left: 4,
                                  top: 2,
                                ),
                                child: Text(
                                  'As senhas não coincidem',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),

                            const SizedBox(
                              height: 32,
                            ),

                            // Botão cadastrar
                            Center(
                              child:
                                  ElevatedButton(
                                onPressed:
                                    _carregando
                                        ? null
                                        : _realizarCadastro,
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF76A085,
                                  ),
                                  disabledBackgroundColor:
                                      Colors.grey,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: _carregando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Cadastrar',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(
                              height: 32,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Moldura superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
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
          ),

          // Moldura inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: molduraHeight,
                child: Image.asset(
                  'imagem/quebrainferior.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment:
                      Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Botão voltar
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Menuprincipal(),
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters:
                  inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                enabledBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black45,
                    width: 1,
                  ),
                ),
                focusedBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Descrição
  Widget _buildDescriptionField() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Descrição:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          TextField(
            controller: _descricaoController,
            maxLines: 3,
            minLines: 3,
            textAlignVertical:
                TextAlignVertical.top,
            decoration: InputDecoration(
              hintText:
                  'Digite uma descrição da empresa...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              contentPadding:
                  const EdgeInsets.all(10),
              enabledBorder:
                  const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black45,
                  width: 1,
                ),
              ),
              focusedBorder:
                  const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Senha
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool mostrarSenha,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !mostrarSenha,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                enabledBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black45,
                    width: 1,
                  ),
                ),
                focusedBorder:
                    const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    mostrarSenha
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horários
  Widget _buildHorariosGrid() {
    final dias = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
      'Feriados',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 4,
      ),
      itemCount: dias.length,
      itemBuilder: (context, index) {
        final dia = dias[index];

        return Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                '$dia:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            Expanded(
              child: TextField(
                controller:
                    _horariosControllers[dia],
                keyboardType:
                    TextInputType.number,
                inputFormatters: [
                  HorarioInputFormatter(),
                ],
                decoration:
                    const InputDecoration(
                  hintText:
                      '00:00 às 00:00',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Redes sociais
  Widget _buildSocialInput(
    IconData icon,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.black54,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              decoration:
                  InputDecoration(
                hintText: hint,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Agendamento
  Widget _buildAgendamentoOptions() {
    final opcoes = [
      'SIM',
      'NÃO',
      'OPCIONAL',
    ];

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceAround,
      children: opcoes.map((opcao) {
        final bool isSelected =
            _necessitaAgendamento ==
                opcao;

        return InkWell(
          onTap: () {
            setState(() {
              _necessitaAgendamento =
                  opcao;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color: isSelected
                  ? Colors.grey.shade300
                  : Colors.white,
              border:
                  Border.all(
                color: Colors.black38,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              opcao,
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                color: isSelected
                    ? Colors.black
                    : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Profissionais
  Widget _buildProfissionaisSection() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _profissionais.isEmpty
              ? Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(
                    border:
                        Border.all(
                      color: Colors.black26,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Colors.black12,
                        child: Icon(
                          Icons.person,
                          color:
                              Colors.black54,
                        ),
                      ),

                      SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          'Nenhum profissional adicionado',
                          style:
                              TextStyle(
                            color:
                                Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children:
                      _profissionais.map(
                    (profissional) {
                      return Container(
                        width:
                            double.infinity,
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 8,
                        ),
                        padding:
                            const EdgeInsets
                                .all(8),
                        decoration:
                            BoxDecoration(
                          border:
                              Border.all(
                            color:
                                Colors.black26,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Colors
                                      .black12,
                              child: Icon(
                                Icons.person,
                                color: Colors
                                    .black54,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    profissional[
                                            'nome'] ??
                                        '',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize:
                                          12,
                                    ),
                                  ),

                                  if ((profissional[
                                              'especialidade'] ??
                                          '')
                                      .isNotEmpty)
                                    Text(
                                      profissional[
                                              'especialidade'] ??
                                          '',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors
                                                .grey
                                                .shade600,
                                        fontSize:
                                            10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
        ),

        const SizedBox(width: 12),

        // Adicionar profissional
        InkWell(
          onTap:
              _adicionarProfissional,
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              border:
                  Border.all(
                color: Colors.black26,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.add,
                  size: 24,
                ),
                Text(
                  'Adicionar\nprofissional',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Fotos
  Widget _buildFotosGrid() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children:
          List.generate(3, (index) {
        return InkWell(
          onTap: () {
            _mostrarMensagem(
              'Função de fotos será adicionada posteriormente.',
            );
          },
          child: Container(
            width:
                MediaQuery.of(context)
                        .size
                        .width *
                    0.26,
            height: 90,
            decoration:
                BoxDecoration(
              color:
                  Colors.lightGreen.shade100,
              border:
                  Border.all(
                color:
                    Colors.green.shade300,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Icon(
                      Icons.cloud_queue,
                      color: Colors.white
                          .withOpacity(
                        0.9,
                      ),
                      size: 30,
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      color:
                          Colors.lightGreen
                              .shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Pagamento
  Widget _buildPaymentInput(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              decoration:
                  const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(
                  vertical: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mensagem
  void _mostrarMensagem(
    String mensagem,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(mensagem),
        duration:
            const Duration(
          seconds: 3,
        ),
      ),
    );
  }
}

// Máscara de telefone
class TelefoneInputFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numeros =
        newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (numeros.length > 11) {
      numeros =
          numeros.substring(0, 11);
    }

    String resultado = '';

    if (numeros.isNotEmpty) {
      resultado =
          '(${numeros.substring(
        0,
        numeros.length.clamp(0, 2),
      )}';

      if (numeros.length >= 2) {
        resultado += ') ';
      }

      if (numeros.length > 2) {
        final restante =
            numeros.substring(2);

        if (numeros.length <= 6) {
          resultado += restante;
        } else if (numeros.length <= 10) {
          resultado +=
              '${restante.substring(0, 4)}-';
          resultado +=
              restante.substring(4);
        } else {
          resultado +=
              '${restante.substring(0, 5)}-';
          resultado +=
              restante.substring(5);
        }
      }
    }

    return TextEditingValue(
      text: resultado,
      selection:
          TextSelection.collapsed(
        offset: resultado.length,
      ),
    );
  }
}

// Máscara de horário CORRIGIDA
class HorarioInputFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numeros =
        newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    // Máximo de 8 números:
    // 00 00 00 00
    if (numeros.length > 8) {
      numeros =
          numeros.substring(0, 8);
    }

    String resultado = '';

    // Primeiro horário
    if (numeros.length >= 1) {
      resultado += numeros.substring(0, 1);
    }

    if (numeros.length >= 2) {
      resultado +=
          ':${numeros.substring(1, 2)}';
    }

    if (numeros.length >= 3) {
      resultado +=
          numeros.substring(2, 3);
    }

    if (numeros.length >= 4) {
      resultado +=
          numeros.substring(3, 4);
    }

    // Segundo horário
    if (numeros.length >= 5) {
      resultado +=
          ' às ${numeros.substring(4, 5)}';
    }

    if (numeros.length >= 6) {
      resultado +=
          ':${numeros.substring(5, 6)}';
    }

    if (numeros.length >= 7) {
      resultado +=
          numeros.substring(6, 7);
    }

    if (numeros.length >= 8) {
      resultado +=
          numeros.substring(7, 8);
    }

    return TextEditingValue(
      text: resultado,
      selection:
          TextSelection.collapsed(
        offset: resultado.length,
      ),
    );
  }
}