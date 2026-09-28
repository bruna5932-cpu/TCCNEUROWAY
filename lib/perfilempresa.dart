import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neuroway/favoritos.dart';
import 'package:neuroway/agendamentos.dart';
import 'package:neuroway/login.dart';
import 'package:neuroway/cadastroprofi.dart';

class PerfilEmpresa extends StatefulWidget {
  const PerfilEmpresa({super.key});

  @override
  State<PerfilEmpresa> createState() => _PerfilEmpresaState();
}

class _PerfilEmpresaState extends State<PerfilEmpresa> {
  final Color verde = const Color(0xFF98B9A6);

  String? empresaUid;

  String nome = 'Carregando...';
  String cnpj = 'Não informado';
  String categoria = 'Não informado';
  String numero = 'Não informado';
  String descricao = 'Não informado';
  String endereco = 'Não informado';
  String fotoPerfilUrl = '';

  String instagram = 'Não informado';
  String facebook = 'Não informado';
  String tiktok = 'Não informado';
  String website = 'Não informado';

  String necessitaAgendamento = 'Não informado';

  String pagamentoCartao = 'Não informado';
  String pagamentoPix = 'Não informado';
  String pagamentoOutros = 'Não informado';

  final List<String> dias = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
    'feriados',
  ];

  final Map<String, String> nomesDias = {
    'segunda': 'Segunda-feira',
    'terca': 'Terça-feira',
    'quarta': 'Quarta-feira',
    'quinta': 'Quinta-feira',
    'sexta': 'Sexta-feira',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
    'feriados': 'Feriados',
  };

  Map<String, Map<String, dynamic>> horarios = {};
  List<Map<String, dynamic>> profissionais = [];
  List<dynamic> fotos = [];

  bool carregando = true;
  bool salvando = false;
  bool enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _buscarDadosEmpresa();
  }

  String _valor(dynamic valor) {
    if (valor == null || valor.toString().trim().isEmpty) {
      return 'Não informado';
    }

    return valor.toString().trim();
  }

  // Referência da empresa
  Future<DocumentReference<Map<String, dynamic>>?>
      _obterReferenciaEmpresa() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return null;

    final firestore = FirebaseFirestore.instance;
    final referencia = firestore.collection('empresas').doc(usuario.uid);
    final documento = await referencia.get();

    if (documento.exists) {
      empresaUid = usuario.uid;
      return referencia;
    }

    final resultado = await firestore
        .collection('empresas')
        .where('uid', isEqualTo: usuario.uid)
        .limit(1)
        .get();

    if (resultado.docs.isNotEmpty) {
      empresaUid = resultado.docs.first.id;
      return resultado.docs.first.reference;
    }

    return null;
  }

  // Buscar dados da empresa
  Future<void> _buscarDadosEmpresa() async {
    try {
      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        if (!mounted) return;

        setState(() {
          nome = 'Empresa não encontrada';
          carregando = false;
        });

        return;
      }

      final documento = await referencia.get();
      final dados = documento.data() ?? {};

      final Map<String, dynamic> horariosBanco =
          dados['horarios'] is Map
              ? Map<String, dynamic>.from(dados['horarios'])
              : {};

      final Map<String, Map<String, dynamic>> horariosConvertidos = {};

      for (final dia in dias) {
        final valor = horariosBanco[dia];

        if (valor is Map) {
          horariosConvertidos[dia] =
              Map<String, dynamic>.from(valor);
        } else {
          final texto = valor?.toString() ?? '';

          if (texto.isNotEmpty &&
              texto != 'Não informado' &&
              texto.toLowerCase() != 'fechado') {
            final partes = texto.split('-');

            horariosConvertidos[dia] = {
              'aberto': true,
              'abertura': partes.isNotEmpty ? partes[0].trim() : '',
              'fechamento': partes.length > 1 ? partes[1].trim() : '',
            };
          } else {
            horariosConvertidos[dia] = {
              'aberto': false,
              'abertura': '',
              'fechamento': '',
            };
          }
        }
      }

      final redes = dados['redesSociais'] is Map
          ? Map<String, dynamic>.from(dados['redesSociais'])
          : {};

      final pagamentos = dados['formasPagamento'] is Map
          ? Map<String, dynamic>.from(dados['formasPagamento'])
          : {};

      final profissionaisBanco = <Map<String, dynamic>>[];

      if (dados['profissionais'] is List) {
        for (final item in dados['profissionais']) {
          if (item is Map) {
            profissionaisBanco.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      if (!mounted) return;

      setState(() {
        nome = _valor(dados['nome']);
        cnpj = _valor(dados['cnpj']);
        categoria = _valor(dados['categoria']);
        numero = _valor(dados['telefone'] ?? dados['numero']);
        descricao = _valor(dados['descricao']);
        endereco = _valor(dados['endereco']);
        fotoPerfilUrl = dados['fotoPerfilUrl']?.toString() ?? '';

        horarios = horariosConvertidos;

        instagram = _valor(redes['instagram']);
        facebook = _valor(redes['facebook']);
        tiktok = _valor(redes['tiktok']);
        website = _valor(redes['website']);

        necessitaAgendamento = _valor(dados['necessitaAgendamento']);

        pagamentoCartao = _valor(pagamentos['cartao']);
        pagamentoPix = _valor(pagamentos['pix']);
        pagamentoOutros = _valor(pagamentos['outros']);

        profissionais = profissionaisBanco;

        fotos = dados['fotos'] is List
            ? List<dynamic>.from(dados['fotos'])
            : [];

        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar empresa: $e');

      if (!mounted) return;

      setState(() {
        nome = 'Erro ao carregar empresa';
        carregando = false;
      });
    }
  }

  // Salvar informações
  Future<void> _salvarCampo(String campo, dynamic valor) async {
    try {
      if (mounted) {
        setState(() {
          salvando = true;
        });
      }

      final referencia = await _obterReferenciaEmpresa();

      if (referencia == null) {
        _mostrarMensagem('Empresa não encontrada.');
        return;
      }

      await referencia.update({campo: valor});

      if (!mounted) return;

      _mostrarMensagem('Informação atualizada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao salvar $campo: $e');

      if (mounted) {
        _mostrarMensagem('Erro ao atualizar informação.');
      }
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Future<void> _salvarMapa(
    String campo,
    Map<String, dynamic> dados,
  ) async {
    await _salvarCampo(campo, dados);
  }

  Future<void> _salvarLista(
    String campo,
    List<dynamic> dados,
  ) async {
    await _salvarCampo(campo, dados);
  }

  // Alterar foto da empresa
  Future<void> _alterarFoto() async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagem == null) return;

      if (mounted) {
        setState(() {
          enviandoFoto = true;
        });
      }

      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _mostrarMensagem('Usuário não identificado.');
        return;
      }

      final referenciaEmpresa = await _obterReferenciaEmpresa();

      if (referenciaEmpresa == null) {
        _mostrarMensagem('Empresa não encontrada.');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child(
            'empresas/${empresaUid ?? usuario.uid}/foto_perfil.jpg',
          );

      await storageRef.putFile(File(imagem.path));

      final url = await storageRef.getDownloadURL();

      await referenciaEmpresa.update({
        'fotoPerfilUrl': url,
      });

      if (!mounted) return;

      setState(() {
        fotoPerfilUrl = url;
      });

      _mostrarMensagem('Foto atualizada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao alterar foto: $e');
      _mostrarMensagem('Não foi possível alterar a foto.');
    } finally {
      if (mounted) {
        setState(() {
          enviandoFoto = false;
        });
      }
    }
  }

  // Sair da conta
  Future<void> _sair() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LOGIN(),
        ),
        (route) => false,
      );
    } catch (e) {
      _mostrarMensagem('Erro ao sair da conta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: carregando
            ? Center(
                child: CircularProgressIndicator(color: verde),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _alterarFoto,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: const Color(0xFFF1F1F1),
                                    backgroundImage: fotoPerfilUrl.isNotEmpty
                                        ? NetworkImage(fotoPerfilUrl)
                                        : null,
                                    child: fotoPerfilUrl.isEmpty
                                        ? const Icon(
                                            Icons.business,
                                            size: 55,
                                            color: Colors.black54,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: verde,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    categoria,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF495057),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        enviandoFoto ? null : _alterarFoto,
                                    child: Text(
                                      enviandoFoto
                                          ? 'Enviando foto...'
                                          : 'Alterar foto',
                                      style: TextStyle(color: verde),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _opcao(
                          Icons.badge_outlined,
                          'CNPJ: $cnpj',
                          _mostrarCnpj,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.phone_outlined,
                          'Telefone: $numero',
                          _mostrarTelefone,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.location_on_outlined,
                          endereco,
                          _mostrarEndereco,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.access_time_outlined,
                          'Horários de funcionamento',
                          _mostrarHorarios,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.description_outlined,
                          'Descrição',
                          _mostrarDescricao,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.public,
                          'Redes sociais',
                          _mostrarRedesSociais,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.calendar_month_outlined,
                          'Agendamento: $necessitaAgendamento',
                          _mostrarAgendamento,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.people_outline,
                          'Profissionais (${profissionais.length})',
                          _mostrarProfissionais,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.photo_library_outlined,
                          'Fotos (${fotos.length})',
                          _mostrarFotos,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.payment_outlined,
                          'Formas de pagamento',
                          _mostrarPagamentos,
                        ),
                        _divisor(),
                        _opcao(
                          Icons.favorite_border,
                          'Favoritos',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Scaffold(
                                  backgroundColor: Colors.white,
                                  body: Favoritos(),
                                ),
                              ),
                            );
                          },
                        ),
                        _divisor(),
                        _opcao(
                          Icons.calendar_today_outlined,
                          'Agendamentos',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Scaffold(
                                  backgroundColor: Colors.white,
                                  body: Agendamentos(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _sair,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Componentes
  Widget _divisor() {
    return const Divider(height: 1);
  }

  Widget _opcao(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
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
          fontSize: 17,
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

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Máscaras
  String _somenteNumeros(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _mascaraCnpj(String texto) {
    final numeros = _somenteNumeros(texto);
    final b = StringBuffer();

    for (int i = 0; i < numeros.length && i < 14; i++) {
      if (i == 2 || i == 5) b.write('.');
      if (i == 8) b.write('/');
      if (i == 12) b.write('-');

      b.write(numeros[i]);
    }

    return b.toString();
  }

  String _mascaraTelefone(String texto) {
    final numeros = _somenteNumeros(texto);

    if (numeros.isEmpty) return '';

    final b = StringBuffer();

    if (numeros.length >= 1) {
      b.write('(');
      b.write(numeros.substring(0, numeros.length >= 2 ? 2 : 1));
    }

    if (numeros.length >= 3) {
      b.write(') ');

      final limite = numeros.length > 7 ? 7 : numeros.length;
      b.write(numeros.substring(2, limite));
    }

    if (numeros.length > 7) {
      b.write('-');
      b.write(
        numeros.substring(
          7,
          numeros.length > 11 ? 11 : numeros.length,
        ),
      );
    }

    return b.toString();
  }

  void _mostrarCnpj() {
    _mostrarEdicaoSimples(
      titulo: 'CNPJ',
      valorInicial: cnpj,
      campo: 'cnpj',
      mascara: _mascaraCnpj,
      limite: 18,
      teclado: TextInputType.number,
      onAtualizado: (valor) {
        setState(() {
          cnpj = valor;
        });
      },
    );
  }

  void _mostrarTelefone() {
    _mostrarEdicaoSimples(
      titulo: 'Telefone',
      valorInicial: numero,
      campo: 'telefone',
      mascara: _mascaraTelefone,
      limite: 15,
      teclado: TextInputType.phone,
      onAtualizado: (valor) {
        setState(() {
          numero = valor;
        });
      },
    );
  }

  void _mostrarEndereco() {
    _mostrarEdicaoSimples(
      titulo: 'Endereço',
      valorInicial: endereco,
      campo: 'endereco',
      teclado: TextInputType.streetAddress,
      onAtualizado: (valor) {
        setState(() {
          endereco = valor;
        });
      },
    );
  }

  // Editar informações simples
  void _mostrarEdicaoSimples({
    required String titulo,
    required String valorInicial,
    required String campo,
    required TextInputType teclado,
    required Function(String) onAtualizado,
    String Function(String)? mascara,
    int? limite,
  }) {
    final controller = TextEditingController(
      text: valorInicial == 'Não informado' ? '' : valorInicial,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(titulo)),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(() => editando = true);
                },
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            enabled: editando,
            keyboardType: teclado,
            maxLength: limite,
            inputFormatters: mascara == null
                ? []
                : [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        final texto = mascara(newValue.text);

                        return TextEditingValue(
                          text: texto,
                          selection: TextSelection.collapsed(
                            offset: texto.length,
                          ),
                        );
                      },
                    ),
                  ],
            maxLines: titulo == 'Endereço' ? 3 : 1,
            decoration: InputDecoration(
              labelText: titulo,
              border: const OutlineInputBorder(),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final valor = controller.text.trim();

                  if (valor.isEmpty) {
                    _mostrarMensagem('Preencha o campo.');
                    return;
                  }

                  if (titulo == 'CNPJ' &&
                      _somenteNumeros(valor).length != 14) {
                    _mostrarMensagem('Digite um CNPJ válido.');
                    return;
                  }

                  Navigator.pop(dialogContext);

                  await _salvarCampo(campo, valor);

                  if (mounted) {
                    onAtualizado(valor);
                  }
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  // Horários de funcionamento
  void _mostrarHorarios() {
    final aberto = <String, bool>{};
    final aberturas = <String, TextEditingController>{};
    final fechamentos = <String, TextEditingController>{};

    for (final dia in dias) {
      final dados = horarios[dia] ?? {};

      aberto[dia] = dados['aberto'] == true;

      aberturas[dia] = TextEditingController(
        text: dados['abertura']?.toString() ?? '',
      );

      fechamentos[dia] = TextEditingController(
        text: dados['fechamento']?.toString() ?? '',
      );
    }

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text('Horários de funcionamento'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(() => editando = true);
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: dias.map((dia) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: verde,
                        title: Text(
                          nomesDias[dia]!,
                          style: const TextStyle(color: Colors.black),
                        ),
                        value: aberto[dia],
                        onChanged: editando
                            ? (valor) {
                                setDialogState(() {
                                  aberto[dia] = valor ?? false;
                                });
                              }
                            : null,
                      ),
                      if (aberto[dia] == true)
                        Row(
                          children: [
                            Expanded(
                              child: _campoHora(
                                'Abertura',
                                aberturas[dia]!,
                                editando,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _campoHora(
                                'Fechamento',
                                fechamentos[dia]!,
                                editando,
                              ),
                            ),
                          ],
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Fechado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final novosHorarios = <String, dynamic>{};

                  for (final dia in dias) {
                    final abertura = aberturas[dia]!.text.trim();
                    final fechamento = fechamentos[dia]!.text.trim();

                    if (aberto[dia] == true) {
                      if (!_horaValida(abertura) ||
                          !_horaValida(fechamento)) {
                        _mostrarMensagem(
                          'Confira os horários de ${nomesDias[dia]}.',
                        );
                        return;
                      }
                    }

                    novosHorarios[dia] = {
                      'aberto': aberto[dia] == true,
                      'abertura': aberto[dia] == true ? abertura : '',
                      'fechamento': aberto[dia] == true ? fechamento : '',
                    };
                  }

                  Navigator.pop(dialogContext);

                  await _salvarMapa('horarios', novosHorarios);

                  if (mounted) {
                    setState(() {
                      horarios = {
                        for (final dia in dias)
                          dia: Map<String, dynamic>.from(
                            novosHorarios[dia],
                          ),
                      };
                    });
                  }
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c in aberturas.values) {
        c.dispose();
      }

      for (final c in fechamentos.values) {
        c.dispose();
      }
    });
  }

  bool _horaValida(String valor) {
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(valor);
  }

  Widget _campoHora(
    String label,
    TextEditingController controller,
    bool editando,
  ) {
    return TextField(
      controller: controller,
      enabled: editando,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
        LengthLimitingTextInputFormatter(5),
        _MascaraHora(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:mm',
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Editar descrição
  void _mostrarDescricao() {
    final controller = TextEditingController(
      text: descricao == 'Não informado' ? '' : descricao,
    );

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Descrição')),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(() => editando = true);
                },
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            enabled: editando,
            maxLines: 7,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final valor = controller.text.trim();

                  if (valor.isEmpty) return;

                  Navigator.pop(dialogContext);

                  await _salvarCampo('descricao', valor);

                  if (mounted) {
                    setState(() {
                      descricao = valor;
                    });
                  }
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  // Editar redes sociais
  void _mostrarRedesSociais() {
    final controllers = {
      'instagram': TextEditingController(
        text: instagram == 'Não informado' ? '' : instagram,
      ),
      'facebook': TextEditingController(
        text: facebook == 'Não informado' ? '' : facebook,
      ),
      'tiktok': TextEditingController(
        text: tiktok == 'Não informado' ? '' : tiktok,
      ),
      'website': TextEditingController(
        text: website == 'Não informado' ? '' : website,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Redes sociais')),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(() => editando = true);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: entry.value,
                    enabled: editando,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final novasRedes = {
                    for (final entry in controllers.entries)
                      entry.key: entry.value.text.trim(),
                  };

                  Navigator.pop(dialogContext);

                  await _salvarMapa('redesSociais', novasRedes);

                  if (mounted) {
                    setState(() {
                      instagram = _valor(novasRedes['instagram']);
                      facebook = _valor(novasRedes['facebook']);
                      tiktok = _valor(novasRedes['tiktok']);
                      website = _valor(novasRedes['website']);
                    });
                  }
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
  }

  // Editar agendamento
  void _mostrarAgendamento() {
    String valorAtual = necessitaAgendamento;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agendamento'),
          content: DropdownButtonFormField<String>(
            value: valorAtual == 'SIM' || valorAtual == 'NÃO'
                ? valorAtual
                : null,
            decoration: const InputDecoration(
              labelText: 'Necessita agendamento?',
              border: OutlineInputBorder(),
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
                valorAtual = valor ?? valorAtual;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _salvarCampo(
                  'necessitaAgendamento',
                  valorAtual,
                );

                if (mounted) {
                  setState(() {
                    necessitaAgendamento = valorAtual;
                  });
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // Gerenciar profissionais
  void _mostrarProfissionais() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Profissionais (${profissionais.length})'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: profissionais.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum profissional cadastrado.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: profissionais.length,
                          itemBuilder: (context, index) {
                            final profissional = profissionais[index];

                            final nomeProfissional =
                                _valor(profissional['nome']);

                            final especialidade = _valor(
                              profissional['especialidade'] ??
                                  profissional['profissao'],
                            );

                            final fotoUrl =
                                profissional['fotoUrl']?.toString() ?? '';

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: verde,
                                  backgroundImage: fotoUrl.isNotEmpty
                                      ? NetworkImage(fotoUrl)
                                      : null,
                                  child: fotoUrl.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                title: Text(nomeProfissional),
                                subtitle: Text(especialidade),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmar =
                                        await showDialog<bool>(
                                      context: dialogContext,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          'Excluir profissional',
                                        ),
                                        content: const Text(
                                          'Tem certeza que deseja excluir esse profissional?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      setDialogState(() {
                                        profissionais.removeAt(index);
                                      });

                                      await _salvarLista(
                                        'profissionais',
                                        profissionais,
                                      );

                                      if (mounted) {
                                        setState(() {});
                                      }

                                      _mostrarMensagem(
                                        'Profissional excluído com sucesso.',
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Identificar empresa
                      final uidEmpresa = empresaUid ??
                          FirebaseAuth.instance.currentUser?.uid;

                      if (uidEmpresa == null ||
                          uidEmpresa.trim().isEmpty) {
                        _mostrarMensagem(
                          'Não foi possível identificar a empresa.',
                        );
                        return;
                      }

                      // Abrir cadastro do profissional
                      final novo =
                          await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CadastroPage(
                            empresaUid: uidEmpresa,
                          ),
                        ),
                      );

                      // Atualizar lista visual
                      if (novo != null && mounted) {
                        final novoProfissional =
                            Map<String, dynamic>.from(novo);

                        final uidNovo =
                            novoProfissional['uid']?.toString() ?? '';

                        final existe = profissionais.any(
                          (profissional) =>
                              profissional['uid']?.toString() == uidNovo,
                        );

                        if (!existe) {
                          setDialogState(() {
                            profissionais.add(novoProfissional);
                          });
                        }

                        setState(() {});

                        _mostrarMensagem(
                          'Profissional adicionado com sucesso.',
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Adicionar profissional'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  // Gerenciar fotos
  void _mostrarFotos() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Fotos (${fotos.length})'),
          content: fotos.isEmpty
              ? const Text('Nenhuma foto cadastrada.')
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
                    itemCount: fotos.length,
                    itemBuilder: (context, index) {
                      final foto = fotos[index].toString();

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                foto,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () async {
                                setDialogState(() {
                                  fotos.removeAt(index);
                                });

                                await _salvarLista('fotos', fotos);

                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  // Editar formas de pagamento
  void _mostrarPagamentos() {
    final controllers = {
      'cartao': TextEditingController(
        text: pagamentoCartao == 'Não informado' ? '' : pagamentoCartao,
      ),
      'pix': TextEditingController(
        text: pagamentoPix == 'Não informado' ? '' : pagamentoPix,
      ),
      'outros': TextEditingController(
        text: pagamentoOutros == 'Não informado' ? '' : pagamentoOutros,
      ),
    };

    bool editando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text('Formas de pagamento'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setDialogState(() => editando = true);
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: entry.value,
                  enabled: editando,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
            if (editando)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final pagamentos = {
                    for (final entry in controllers.entries)
                      entry.key: entry.value.text.trim(),
                  };

                  Navigator.pop(dialogContext);

                  await _salvarMapa('formasPagamento', pagamentos);

                  if (mounted) {
                    setState(() {
                      pagamentoCartao = _valor(pagamentos['cartao']);
                      pagamentoPix = _valor(pagamentos['pix']);
                      pagamentoOutros = _valor(pagamentos['outros']);
                    });
                  }
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    ).then((_) {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
  }
}

// Máscara de horário
class _MascaraHora extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final limitado = numeros.length > 4
        ? numeros.substring(0, 4)
        : numeros;

    String resultado = limitado;

    if (limitado.length > 2) {
      resultado =
          '${limitado.substring(0, 2)}:${limitado.substring(2)}';
    }

    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(
        offset: resultado.length,
      ),
    );
  }
}