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
  // ============================================================
  // DADOS DA EMPRESA
  // ============================================================

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

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();
    _buscarDadosEmpresa();
  }

  // ============================================================
  // BUSCAR DADOS DA EMPRESA
  // ============================================================

  Future<void> _buscarDadosEmpresa() async {
    try {
      final User? usuario =
          FirebaseAuth.instance.currentUser;

      // ==========================================================
      // VERIFICA USUÁRIO LOGADO
      // ==========================================================

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

      debugPrint('========================================');
      debugPrint('PERFIL DA EMPRESA');
      debugPrint('UID: $uid');
      debugPrint('========================================');

      // ==========================================================
      // PROCURA A EMPRESA PELO UID
      // ==========================================================

      DocumentSnapshot<Map<String, dynamic>> documento =
          await FirebaseFirestore.instance
              .collection('empresas')
              .doc(uid)
              .get();

      // ==========================================================
      // CASO NÃO ENCONTRE PELO UID
      // PROCURA PELO CAMPO uid
      // ==========================================================

      if (!documento.exists) {
        debugPrint(
          'Empresa não encontrada pelo ID do documento.',
        );

        debugPrint(
          'Procurando empresa pelo campo uid...',
        );

        final QuerySnapshot<Map<String, dynamic>>
            resultado =
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

          debugPrint(
            'Empresa encontrada pelo campo uid.',
          );

          debugPrint(
            'ID do documento: ${documento.id}',
          );
        }
      }

      // ==========================================================
      // EMPRESA ENCONTRADA
      // ==========================================================

      if (documento.exists) {
        final Map<String, dynamic> dados =
            documento.data() ?? {};

        debugPrint('========================================');
        debugPrint('DADOS DA EMPRESA');
        debugPrint('Nome: ${dados['nome']}');
        debugPrint('CNPJ: ${dados['cnpj']}');
        debugPrint('Categoria: ${dados['categoria']}');
        debugPrint('Número: ${dados['numero']}');
        debugPrint('Descrição: ${dados['descricao']}');
        debugPrint('Endereço: ${dados['endereco']}');
        debugPrint(
          'Necessita agendamento: ${dados['necessitaAgendamento']}',
        );
        debugPrint('========================================');

        // ========================================================
        // HORÁRIOS
        // ========================================================

        Map<String, dynamic> horarios = {};

        if (dados['horarios'] is Map) {
          horarios =
              Map<String, dynamic>.from(
            dados['horarios'],
          );
        }

        // ========================================================
        // REDES SOCIAIS
        // ========================================================

        Map<String, dynamic> redesSociais = {};

        if (dados['redesSociais'] is Map) {
          redesSociais =
              Map<String, dynamic>.from(
            dados['redesSociais'],
          );
        }

        // ========================================================
        // FORMAS DE PAGAMENTO
        // ========================================================

        Map<String, dynamic> pagamentos = {};

        if (dados['formasPagamento'] is Map) {
          pagamentos =
              Map<String, dynamic>.from(
            dados['formasPagamento'],
          );
        }

        // ========================================================
        // PROFISSIONAIS
        // ========================================================

        List<Map<String, dynamic>>
            profissionaisBanco = [];

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

        // ========================================================
        // FOTOS
        // ========================================================

        List<dynamic> fotosBanco = [];

        if (dados['fotos'] is List) {
          fotosBanco =
              List<dynamic>.from(
            dados['fotos'],
          );
        }

        if (!mounted) return;

        setState(() {
          // ======================================================
          // INFORMAÇÕES PRINCIPAIS
          // ======================================================

          nome = _valor(
            dados['nome'],
          );

          cnpj = _valor(
            dados['cnpj'],
          );

          categoria = _valor(
            dados['categoria'],
          );

          numero = _valor(
            dados['numero'],
          );

          descricao = _valor(
            dados['descricao'],
          );

          endereco = _valor(
            dados['endereco'],
          );

          // ======================================================
          // HORÁRIOS
          // ======================================================

          segunda = _valor(
            horarios['segunda'],
          );

          terca = _valor(
            horarios['terca'],
          );

          quarta = _valor(
            horarios['quarta'],
          );

          quinta = _valor(
            horarios['quinta'],
          );

          sexta = _valor(
            horarios['sexta'],
          );

          sabado = _valor(
            horarios['sabado'],
          );

          domingo = _valor(
            horarios['domingo'],
          );

          feriados = _valor(
            horarios['feriados'],
          );

          // ======================================================
          // REDES SOCIAIS
          // ======================================================

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

          // ======================================================
          // AGENDAMENTO
          // ======================================================

          necessitaAgendamento = _valor(
            dados['necessitaAgendamento'],
          );

          // ======================================================
          // PAGAMENTOS
          // ======================================================

          pagamentoCartao = _valor(
            pagamentos['cartao'],
          );

          pagamentoPix = _valor(
            pagamentos['pix'],
          );

          pagamentoOutros = _valor(
            pagamentos['outros'],
          );

          // ======================================================
          // PROFISSIONAIS
          // ======================================================

          profissionais = profissionaisBanco;

          // ======================================================
          // FOTOS
          // ======================================================

          fotos = fotosBanco;

          carregando = false;
        });

        return;
      }

      // ==========================================================
      // EMPRESA NÃO ENCONTRADA
      // ==========================================================

      debugPrint(
        'NENHUMA EMPRESA ENCONTRADA.',
      );

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
    }

    // ============================================================
    // ERRO DO FIREBASE
    // ============================================================

    on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('ERRO FIREBASE NO PERFIL DA EMPRESA');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('========================================');

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
    }

    // ============================================================
    // ERRO GERAL
    // ============================================================

    catch (e) {
      debugPrint(
        'ERRO GERAL NO PERFIL DA EMPRESA: $e',
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

  // ============================================================
  // CONVERTER VALOR DO FIRESTORE
  // ============================================================

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

  // ============================================================
  // SAIR
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        top: false,

        child: Column(
          children: [

            // ==================================================
            // PARTE PRINCIPAL
            // ==================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),

                children: [

                  // ==================================================
                  // FOTO + NOME + CATEGORIA
                  // ==================================================

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

                            // NOME
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

                            // CATEGORIA
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

                  // ==================================================
                  // CNPJ
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.badge_outlined,
                    label: 'CNPJ: $cnpj',
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // TELEFONE
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.phone_outlined,
                    label: 'Telefone: $numero',
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // ENDEREÇO
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    label: endereco,
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // HORÁRIOS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.access_time_outlined,
                    label: 'Horários de funcionamento',
                    onTap: () {
                      _mostrarHorarios();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // DESCRIÇÃO
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.description_outlined,
                    label: 'Descrição',
                    onTap: () {
                      _mostrarDescricao();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // REDES SOCIAIS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.public,
                    label: 'Redes sociais',
                    onTap: () {
                      _mostrarRedesSociais();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // AGENDAMENTO
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.calendar_month_outlined,
                    label:
                        'Agendamento: $necessitaAgendamento',
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // PROFISSIONAIS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.people_outline,
                    label:
                        'Profissionais (${profissionais.length})',
                    onTap: () {
                      _mostrarProfissionais();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // FOTOS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.photo_library_outlined,
                    label:
                        'Fotos (${fotos.length})',
                    onTap: () {
                      _mostrarFotos();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // FORMAS DE PAGAMENTO
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.payment_outlined,
                    label: 'Formas de pagamento',
                    onTap: () {
                      _mostrarPagamentos();
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // FAVORITOS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.favorite_border,
                    label: 'Favoritos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Scaffold(
                            backgroundColor:
                                Colors.white,
                            body: Favoritos(),
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // AGENDAMENTOS
                  // ==================================================

                  _buildProfileOption(
                    icon: Icons.calendar_today_outlined,
                    label: 'Agendamentos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Scaffold(
                            backgroundColor:
                                Colors.white,
                            body: Agendamentos(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // PARTE INFERIOR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  // ==================================================
                  // EDITAR
                  // ==================================================

                  TextButton.icon(
                    onPressed: () {
                      _mostrarMensagem(
                        'Botão Editar clicado',
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

                  // ==================================================
                  // SAIR
                  // ==================================================

                  InkWell(
                    onTap: _sair,

                    splashColor:
                        Colors.green.withOpacity(
                      0.3,
                    ),

                    borderRadius:
                        BorderRadius.circular(10),

                    child: const Padding(
                      padding:
                          EdgeInsets.all(8),

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

  // ============================================================
  // ITEM DO PERFIL
  // ============================================================

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),

      title: Text(
        label,

        style:
            const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),

        maxLines: 2,

        overflow:
            TextOverflow.ellipsis,
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
        size: 16,
      ),

      onTap: onTap,
    );
  }

  // ============================================================
  // HORÁRIOS
  // ============================================================

  void _mostrarHorarios() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Horários de funcionamento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _linhaHorario(
                  'Segunda',
                  segunda,
                ),
                _linhaHorario(
                  'Terça',
                  terca,
                ),
                _linhaHorario(
                  'Quarta',
                  quarta,
                ),
                _linhaHorario(
                  'Quinta',
                  quinta,
                ),
                _linhaHorario(
                  'Sexta',
                  sexta,
                ),
                _linhaHorario(
                  'Sábado',
                  sabado,
                ),
                _linhaHorario(
                  'Domingo',
                  domingo,
                ),
                _linhaHorario(
                  'Feriados',
                  feriados,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _linhaHorario(
    String dia,
    String horario,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$dia:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              horario,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESCRIÇÃO
  // ============================================================

  void _mostrarDescricao() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Descrição',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Text(
              descricao,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REDES SOCIAIS
  // ============================================================

  void _mostrarRedesSociais() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Redes sociais',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _linhaInformacao(
                  Icons.camera_alt_outlined,
                  'Instagram',
                  instagram,
                ),

                _linhaInformacao(
                  Icons.facebook,
                  'Facebook',
                  facebook,
                ),

                _linhaInformacao(
                  Icons.music_note,
                  'TikTok',
                  tiktok,
                ),

                _linhaInformacao(
                  Icons.language,
                  'Website',
                  website,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PROFISSIONAIS
  // ============================================================

  void _mostrarProfissionais() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Profissionais (${profissionais.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: profissionais.isEmpty
              ? const Text(
                  'Nenhum profissional cadastrado.',
                )
              : SizedBox(
                  width: double.maxFinite,

                  child: ListView.builder(
                    shrinkWrap: true,

                    itemCount:
                        profissionais.length,

                    itemBuilder:
                        (context, index) {
                      final profissional =
                          profissionais[index];

                      final nomeProfissional =
                          _valor(
                        profissional['nome'],
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
                        child: ListTile(
                          leading:
                              const CircleAvatar(
                            backgroundColor:
                                Color(
                              0xFF6C757D,
                            ),
                            child: Icon(
                              Icons.person,
                              color:
                                  Colors.white,
                            ),
                          ),

                          title: Text(
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
                                CrossAxisAlignment
                                    .start,
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
                      );
                    },
                  ),
                ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FOTOS
  // ============================================================

  void _mostrarFotos() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Fotos (${fotos.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
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

                    itemCount: fotos.length,

                    itemBuilder:
                        (context, index) {
                      final foto =
                          fotos[index]
                              .toString();

                      return ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(10),

                        child: Image.network(
                          foto,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color: Colors.grey
                                  .shade300,

                              child: const Icon(
                                Icons
                                    .broken_image,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PAGAMENTOS
  // ============================================================

  void _mostrarPagamentos() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Formas de pagamento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _linhaInformacao(
                Icons.credit_card,
                'Cartão',
                pagamentoCartao,
              ),

              _linhaInformacao(
                Icons.pix,
                'Pix',
                pagamentoPix,
              ),

              _linhaInformacao(
                Icons.payments_outlined,
                'Outros',
                pagamentoOutros,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LINHA DE INFORMAÇÃO
  // ============================================================

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

                Text(
                  valor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _mostrarMensagem(
    String mensagem,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
        ),
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }
}

// ================================================================
// HEADER WAVE CLIPPER
// ================================================================

class HeaderWaveClipper
    extends CustomClipper<Path> {
  @override
  Path getClip(
    Size size,
  ) {
    Path path = Path();

    path.lineTo(
      0,
      size.height * 0.75,
    );

    final firstControlPoint =
        Offset(
      size.width * 0.25,
      size.height * 0.60,
    );

    final firstEndPoint =
        Offset(
      size.width * 0.5,
      size.height * 0.80,
    );

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint =
        Offset(
      size.width * 0.75,
      size.height * 1.0,
    );

    final secondEndPoint =
        Offset(
      size.width,
      size.height * 0.75,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(
      size.width,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}