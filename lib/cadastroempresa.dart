import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neuroway/menuprincipal.dart';
import 'package:neuroway/cadastroprofi.dart';

class CadastroEmpresa extends StatefulWidget {
  const CadastroEmpresa({super.key});

  @override
  State<CadastroEmpresa> createState() => _CadastroEmpresaState();
}

class _CadastroEmpresaState extends State<CadastroEmpresa> {
  // Formulário
  final _formKey = GlobalKey<FormState>();

  String _necessitaAgendamento = 'NÃO';

  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _carregando = false;

  // Foto
  Uint8List? _fotoEmpresaBytes;
  final ImagePicker _seletorImagem = ImagePicker();

  // Controladores
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  // Categorias
  String _categoriaSelecionada = 'Saúde';

  final List<String> _categorias = [
    'Saúde',
    'Educação',
    'Estética',
    'Cuidados Pessoais',
  ];

  // Dias e horários
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

  final Map<String, TextEditingController> _aberturaControllers = {};
  final Map<String, TextEditingController> _fechamentoControllers = {};

  // Redes sociais
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Formas de pagamento
  final Map<String, bool> _formasPagamento = {
    'Cartão': false,
    'Pix': false,
    'Dinheiro': false,
    'Outros': false,
  };

  // Profissionais
  final List<Map<String, dynamic>> _profissionais = [];

  @override
  void initState() {
    super.initState();

    for (final dia in _diasSelecionados.keys) {
      _aberturaControllers[dia] = TextEditingController();
      _fechamentoControllers[dia] = TextEditingController();
    }
  }

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

    for (final controller in _aberturaControllers.values) {
      controller.dispose();
    }

    for (final controller in _fechamentoControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Selecionar foto
  Future<void> _selecionarFoto() async {
    try {
      final XFile? imagem = await _seletorImagem.pickImage(
        source: ImageSource.gallery,
        imageQuality: 45,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (imagem == null) return;

      final bytes = await imagem.readAsBytes();

      if (bytes.isEmpty) {
        _mostrarMensagem(
          'Não foi possível carregar a foto.',
        );
        return;
      }

      // Evitar documento grande
      if (bytes.length > 450000) {
        _mostrarMensagem(
          'A foto é muito grande. Escolha uma imagem menor.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _fotoEmpresaBytes = bytes;
      });
    } catch (e) {
      debugPrint('Erro ao selecionar foto: $e');

      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível selecionar a foto.',
      );
    }
  }

  // Adicionar profissional
Future<void> _adicionarProfissional() async {
  final resultado = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CadastroPage(
        empresaUid: null,
      ),
    ),
  );

  if (resultado == null || resultado is! Map) {
    return;
  }

  final String uid =
      resultado['uid']?.toString() ?? '';

  final String nome =
      resultado['nome']?.toString() ?? '';

  final String email =
      resultado['email']?.toString() ?? '';

  final String especialidade =
      resultado['especialidade']
              ?.toString() ??
          '';

  final String profissao =
      resultado['profissao']
              ?.toString() ??
          especialidade;

  final String telefone =
      resultado['telefone']
              ?.toString() ??
          '';

  final String descricao =
      resultado['descricao']
              ?.toString() ??
          '';

  final String experiencia =
      resultado['experiencia']
              ?.toString() ??
          '';

  final String fotoPerfilBase64 =
      resultado['fotoPerfilBase64']
              ?.toString() ??
          '';

  if (nome.trim().isEmpty) {
    return;
  }

  if (!mounted) return;

  setState(() {
    _profissionais.add({
      'uid': uid,
      'nome': nome,
      'email': email,
      'especialidade': especialidade,
      'profissao': profissao,
      'telefone': telefone,
      'descricao': descricao,
      'experiencia': experiencia,
      'fotoPerfilBase64':
          fotoPerfilBase64,
    });
  });
}

  // Remover profissional
  Future<void> _removerProfissional(int index) async {
    if (index < 0 || index >= _profissionais.length) {
      return;
    }

    final profissional = _profissionais[index];

    final nome = profissional['nome']?.trim().isNotEmpty == true
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
            'Tem certeza que deseja excluir esse profissional?\n\n$nome',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF76A085),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
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

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _profissionais.removeAt(index);
    });

    _mostrarMensagem(
      'Profissional excluído com sucesso.',
    );
  }

  // Mostrar mensagem
  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Cadastrar empresa
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

    // Validar horários
    for (final dia in _diasSelecionados.keys) {
      if (_diasSelecionados[dia] == true) {
        final abertura =
            _aberturaControllers[dia]!.text;

        final fechamento =
            _fechamentoControllers[dia]!.text;

        if (abertura.length != 5 ||
            fechamento.length != 5) {
          _mostrarMensagem(
            'Informe os horários completos de $dia.',
          );
          return;
        }

        final regex = RegExp(
          r'^([01]\d|2[0-3]):[0-5]\d$',
        );

        if (!regex.hasMatch(abertura) ||
            !regex.hasMatch(fechamento)) {
          _mostrarMensagem(
            'Horário inválido em $dia. Utilize o formato HH:MM.',
          );
          return;
        }
      }
    }

    setState(() {
      _carregando = true;
    });

    try {
      // Preparar foto antes do cadastro
      String fotoPerfilBase64 = '';

      if (_fotoEmpresaBytes != null) {
        fotoPerfilBase64 = base64Encode(
          _fotoEmpresaBytes!,
        );

        // Base64 aumenta o tamanho da imagem
        if (fotoPerfilBase64.length > 650000) {
          _mostrarMensagem(
            'A foto é muito grande. Escolha uma imagem menor.',
          );

          if (mounted) {
            setState(() {
              _carregando = false;
            });
          }

          return;
        }
      }

      // Criar usuário
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

      // Horários
      final Map<String, dynamic> horarios = {};

      for (final dia in _diasSelecionados.keys) {
        horarios[dia] = {
          'abertura':
              _diasSelecionados[dia] == true
                  ? _aberturaControllers[dia]!.text
                  : '',
          'fechamento':
              _diasSelecionados[dia] == true
                  ? _fechamentoControllers[dia]!.text
                  : '',
          'aberto':
              _diasSelecionados[dia] ?? false,
        };
      }

      // Redes sociais
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

      // Pagamentos
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
      // Preparar profissionais com UID da empresa
      final profissionaisEmpresa =
          _profissionais.map((profissional) {
        return <String, dynamic>{
          ...profissional,
          'empresaUid': usuario.uid,
        };
      }).toList();

      // Salvar empresa
      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(usuario.uid)
          .set({
        'uid': usuario.uid,
        'tipoUsuario': 'empresa',
        'nome':
            _nomeController.text.trim(),
        'cnpj':
            _cnpjController.text.trim(),
        'categoria':
            _categoriaSelecionada,
        'telefone':
            _telefoneController.text.trim(),
        'descricao':
            _descricaoController.text.trim(),
        'endereco':
            _enderecoController.text.trim(),
        'email':
            _emailController.text.trim(),

        // Foto no Firestore
        'fotoPerfilBase64':
            fotoPerfilBase64,

        'horarios': horarios,
        'redesSociais': redesSociais,
        'necessitaAgendamento':
            _necessitaAgendamento,
        'profissionais':
            profissionaisEmpresa,
        'fotos': [],
        'formasPagamento':
            formasPagamento,
        'criadoEm':
            FieldValue.serverTimestamp(),
      });
      // Atualizar o vínculo dos profissionais com a empresa
      for (final profissional in profissionaisEmpresa) {
        final uidProfissional =
            profissional['uid']?.toString().trim() ?? '';

        if (uidProfissional.isEmpty) {
          continue;
        }

        await FirebaseFirestore.instance
            .collection('profissionais')
            .doc(uidProfissional)
            .set(
          {
            'empresaUid': usuario.uid,
          },
          SetOptions(
            merge: true,
          ),
        );
      }

      // Nome no Firebase Auth
      await usuario.updateDisplayName(
        _nomeController.text.trim(),
      );

      if (!mounted) return;

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
      debugPrint(
        'Erro ao cadastrar empresa: $e',
      );

      _mostrarMensagem(
        'Erro ao cadastrar empresa.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // Campo de texto
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
        style: const TextStyle(
          color: Colors.black,
        ),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          floatingLabelStyle:
              const TextStyle(
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide:
                const BorderSide(
              color: Colors.black,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // Foto da empresa
  Widget _buildFotoEmpresa() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Foto da empresa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _carregando
                ? null
                : _selecionarFoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    const Color(0xFFF1F1F1),
                border: Border.all(
                  color:
                      const Color(0xFF98B9A6),
                  width: 2,
                ),
              ),
              child: _fotoEmpresaBytes != null
                  ? ClipOval(
                      child: Image.memory(
                        _fotoEmpresaBytes!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .add_a_photo_outlined,
                          size: 38,
                          color:
                              Colors.black54,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: _carregando
                ? null
                : _selecionarFoto,
            child: Text(
              _fotoEmpresaBytes == null
                  ? 'Selecionar foto'
                  : 'Alterar foto',
              style: const TextStyle(
                color: Color(0xFF76A085),
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profissionais
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
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  _adicionarProfissional,
              icon: const Icon(
                Icons.person_add,
                size: 18,
              ),
              label:
                  const Text('Adicionar'),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF76A085,
                ),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
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
              color:
                  Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    Colors.grey.shade300,
              ),
            ),
            child: const Text(
              'Nenhum profissional adicionado.',
              textAlign:
                  TextAlign.center,
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
                    profissional['nome'] ??
                        '';

                final especialidade =
                    profissional[
                            'especialidade'] ??
                        '';

                return Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    border: Border.all(
                      color: Colors
                          .grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 4,
                        offset:
                            const Offset(
                          0,
                          2,
                        ),
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
                          ).withOpacity(
                            0.15,
                          ),
                          shape:
                              BoxShape.circle,
                        ),
                        child:
                            const Icon(
                          Icons.person,
                          color: Color(
                            0xFF76A085,
                          ),
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
                                    FontWeight
                                        .bold,
                                color:
                                    Colors.black,
                              ),
                            ),
                            if (especialidade
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                especialidade,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
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
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                            color:
                                Colors.red,
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

  // Horários
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
        const SizedBox(height: 5),
        Text(
          'Digite os horários no formato 00:00.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
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
                  const EdgeInsets
                      .symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration:
                  BoxDecoration(
                border: Border.all(
                  color: Colors
                      .grey.shade300,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Column(
                children: [
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
                    onChanged: (valor) {
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
                  if (_diasSelecionados[
                          dia] ==
                      true)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        left: 12,
                        right: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                _campoHorario(
                              label:
                                  'Abertura',
                              controller:
                                  _aberturaControllers[
                                      dia]!,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                _campoHorario(
                              label:
                                  'Fechamento',
                              controller:
                                  _fechamentoControllers[
                                      dia]!,
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

  // Campo de horário
  Widget _campoHorario({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter
            .digitsOnly,
        _MascaraHorario(),
      ],
      cursorColor: Colors.black,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '00:00',
        prefixIcon: const Icon(
          Icons.access_time,
          color: Colors.black54,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        labelStyle:
            const TextStyle(
          color: Colors.black,
        ),
        floatingLabelStyle:
            const TextStyle(
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          borderSide:
              const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          borderSide:
              const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // Redes sociais
  Widget _buildRedesSociaisSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Redes sociais',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        _campoTexto(
          label: 'Instagram',
          controller:
              _instagramController,
          hint: '@suaempresa',
        ),

        _campoTexto(
          label: 'Facebook',
          controller:
              _facebookController,
        ),

        _campoTexto(
          label: 'TikTok',
          controller:
              _tiktokController,
        ),

        _campoTexto(
          label: 'Website',
          controller:
              _websiteController,
          keyboardType:
              TextInputType.url,
        ),
      ],
    );
  }

  // Pagamentos
  Widget _buildFormasPagamentoSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Formas de pagamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
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
                style:
                    const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              value:
                  _formasPagamento[
                      forma],
              activeColor:
                  Colors.black,
              checkColor:
                  Colors.white,
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

  // Tela
  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context)
            .size
            .height;

    final double screenWidth =
        MediaQuery.of(context)
            .size
            .width;

    final double molduraHeight =
        screenHeight * 0.15;

    return Scaffold(
      backgroundColor:
          Colors.white,
      resizeToAvoidBottomInset:
          true,
      body: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Quebra-cabeça superior
            SizedBox(
              height: molduraHeight,
              width: double.infinity,
              child: Image.asset(
                'imagem/quebrasuperior.png',
                width:
                    double.infinity,
                fit: BoxFit.cover,
                alignment:
                    Alignment.topCenter,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // Cabeçalho
            Padding(
              padding:
                  const EdgeInsets.only(
                left: 32,
                right: 16,
              ),
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        padding:
                            EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .arrow_back_ios_new,
                          color:
                              Colors.black,
                          size: 22,
                        ),
                        onPressed:
                            _carregando
                                ? null
                                : () =>
                                    Navigator
                                        .maybePop(
                                  context,
                                ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 150,
                        width: 260,
                        child:
                            Image.asset(
                          'imagem/Cadastro_empresa.png',
                          width: 260,
                          height: 150,
                          fit:
                              BoxFit.contain,
                          alignment:
                              Alignment
                                  .center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal:
                    screenWidth * 0.06,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    // Nome
                    _campoTexto(
                      label: 'Nome',
                      controller:
                          _nomeController,
                      validator:
                          (valor) {
                        if (valor == null ||
                            valor
                                .trim()
                                .isEmpty) {
                          return 'Informe o nome da empresa.';
                        }

                        return null;
                      },
                    ),

                    // CNPJ
                    _campoTexto(
                      label: 'CNPJ',
                      controller:
                          _cnpjController,
                      hint:
                          '11.111.111/1111-11',
                      keyboardType:
                          TextInputType
                              .number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        _MascaraCNPJ(),
                      ],
                      validator:
                          (valor) {
                        final numeros =
                            valor?.replaceAll(
                                  RegExp(
                                    r'\D',
                                  ),
                                  '',
                                ) ??
                                '';

                        if (numeros
                            .isEmpty) {
                          return 'Informe o CNPJ.';
                        }

                        if (numeros
                                .length !=
                            14) {
                          return 'Informe um CNPJ completo.';
                        }

                        return null;
                      },
                    ),

                    // Categoria
                    DropdownButtonFormField<
                        String>(
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
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          _categorias.map(
                        (categoria) {
                          return DropdownMenuItem<
                              String>(
                            value:
                                categoria,
                            child: Text(
                              categoria,
                              style:
                                  const TextStyle(
                                color: Colors
                                    .black,
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

                    // Telefone
                    _campoTexto(
                      label:
                          'Telefone',
                      controller:
                          _telefoneController,
                      hint:
                          '(11) 11111-1111',
                      keyboardType:
                          TextInputType
                              .phone,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        _MascaraTelefone(),
                      ],
                      validator:
                          (valor) {
                        final numeros =
                            valor?.replaceAll(
                                  RegExp(
                                    r'\D',
                                  ),
                                  '',
                                ) ??
                                '';

                        if (numeros
                            .isEmpty) {
                          return 'Informe o telefone.';
                        }

                        if (numeros
                                .length !=
                            11) {
                          return 'Informe um telefone completo.';
                        }

                        return null;
                      },
                    ),

                    // Descrição
                    _campoTexto(
                      label:
                          'Descrição',
                      controller:
                          _descricaoController,
                      maxLines: 4,
                      validator:
                          (valor) {
                        if (valor == null ||
                            valor
                                .trim()
                                .isEmpty) {
                          return 'Informe uma descrição.';
                        }

                        return null;
                      },
                    ),

                    // Endereço
                    _campoTexto(
                      label:
                          'Endereço',
                      controller:
                          _enderecoController,
                      validator:
                          (valor) {
                        if (valor == null ||
                            valor
                                .trim()
                                .isEmpty) {
                          return 'Informe o endereço.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // Foto
                    _buildFotoEmpresa(),

                    const SizedBox(
                      height: 20,
                    ),

                    // Profissionais
                    _buildProfissionaisSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // Horários
                    _buildHorariosSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // Agendamento
                    const Text(
                      'Agendamento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Colors.black,
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
                          color: Colors
                              .grey
                              .shade300,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<
                              String>(
                            title:
                                const Text(
                              'SIM',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .black,
                              ),
                            ),
                            value: 'SIM',
                            groupValue:
                                _necessitaAgendamento,
                            activeColor:
                                Colors
                                    .black,
                            onChanged:
                                (valor) {
                              setState(
                                () {
                                  _necessitaAgendamento =
                                      valor!;
                                },
                              );
                            },
                          ),
                          RadioListTile<
                              String>(
                            title:
                                const Text(
                              'NÃO',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .black,
                              ),
                            ),
                            value: 'NÃO',
                            groupValue:
                                _necessitaAgendamento,
                            activeColor:
                                Colors
                                    .black,
                            onChanged:
                                (valor) {
                              setState(
                                () {
                                  _necessitaAgendamento =
                                      valor!;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // Redes sociais
                    _buildRedesSociaisSection(),

                    const SizedBox(
                      height: 10,
                    ),

                    // Pagamentos
                    _buildFormasPagamentoSection(),

                    const SizedBox(
                      height: 25,
                    ),

                    // Dados de acesso
                    const Text(
                      'Dados de acesso',
                      style: TextStyle(
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

                    // E-mail
                    _campoTexto(
                      label: 'E-mail',
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      validator:
                          (valor) {
                        if (valor == null ||
                            valor
                                .trim()
                                .isEmpty) {
                          return 'Informe o e-mail.';
                        }

                        if (!valor
                            .contains('@')) {
                          return 'Informe um e-mail válido.';
                        }

                        return null;
                      },
                    ),

                    // Senha
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
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
                          if (valor ==
                                  null ||
                              valor
                                  .isEmpty) {
                            return 'Informe uma senha.';
                          }

                          if (valor
                                  .length <
                              6) {
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
                                    .circular(
                              12,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                            borderSide:
                                const BorderSide(
                              color: Colors
                                  .black,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(
                                () {
                                  _mostrarSenha =
                                      !_mostrarSenha;
                                },
                              );
                            },
                            icon: Icon(
                              _mostrarSenha
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                              color: Colors
                                  .black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Confirmar senha
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
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
                          if (valor ==
                                  null ||
                              valor
                                  .isEmpty) {
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
                                    .circular(
                              12,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                            borderSide:
                                const BorderSide(
                              color: Colors
                                  .black,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(
                                () {
                                  _mostrarConfirmarSenha =
                                      !_mostrarConfirmarSenha;
                                },
                              );
                            },
                            icon: Icon(
                              _mostrarConfirmarSenha
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                              color: Colors
                                  .black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // Cadastrar
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
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                            _carregando
                                ? const SizedBox(
                                    width:
                                        24,
                                    height:
                                        24,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors
                                          .white,
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
                                          FontWeight
                                              .bold,
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

            // Quebra-cabeça inferior
            SizedBox(
              height:
                  molduraHeight,
              width:
                  double.infinity,
              child: Image.asset(
                'imagem/quebrainferior.png',
                width:
                    double.infinity,
                fit: BoxFit.cover,
                alignment:
                    Alignment
                        .bottomCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Máscara de horário
class _MascaraHorario
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

    if (numeros.length > 4) {
      numeros =
          numeros.substring(
        0,
        4,
      );
    }

    String formatado = numeros;

    if (numeros.length > 2) {
      formatado =
          '${numeros.substring(0, 2)}:${numeros.substring(2)}';
    }

    return TextEditingValue(
      text: formatado,
      selection:
          TextSelection.collapsed(
        offset:
            formatado.length,
      ),
    );
  }
}

// Máscara de CNPJ
class _MascaraCNPJ
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

    if (numeros.length > 14) {
      numeros =
          numeros.substring(
        0,
        14,
      );
    }

    String formatado = '';

    if (numeros.isNotEmpty) {
      formatado =
          numeros.substring(
        0,
        numeros.length > 2
            ? 2
            : numeros.length,
      );
    }

    if (numeros.length > 2) {
      formatado +=
          '.${numeros.substring(
        2,
        numeros.length > 5
            ? 5
            : numeros.length,
      )}';
    }

    if (numeros.length > 5) {
      formatado +=
          '.${numeros.substring(
        5,
        numeros.length > 8
            ? 8
            : numeros.length,
      )}';
    }

    if (numeros.length > 8) {
      formatado +=
          '/${numeros.substring(
        8,
        numeros.length > 12
            ? 12
            : numeros.length,
      )}';
    }

    if (numeros.length > 12) {
      formatado +=
          '-${numeros.substring(12)}';
    }

    return TextEditingValue(
      text: formatado,
      selection:
          TextSelection.collapsed(
        offset:
            formatado.length,
      ),
    );
  }
}

// Máscara de telefone
class _MascaraTelefone
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
          numeros.substring(
        0,
        11,
      );
    }

    String formatado = '';

    if (numeros.isNotEmpty) {
      formatado =
          '(${numeros.substring(
        0,
        numeros.length > 2
            ? 2
            : numeros.length,
      )}';
    }

    if (numeros.length >= 2) {
      formatado += ') ';
    }

    if (numeros.length > 2) {
      formatado +=
          numeros.substring(
        2,
        numeros.length > 7
            ? 7
            : numeros.length,
      );
    }

    if (numeros.length > 7) {
      formatado +=
          '-${numeros.substring(7)}';
    }

    return TextEditingValue(
      text: formatado,
      selection:
          TextSelection.collapsed(
        offset:
            formatado.length,
      ),
    );
  }
}