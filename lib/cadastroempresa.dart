import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neuroway/menuprincipal.dart';

class CadastroEmpresa extends StatefulWidget {
  const CadastroEmpresa({super.key});

  @override
  State<CadastroEmpresa> createState() => _CadastroEmpresaState();
}

class _CadastroEmpresaState extends State<CadastroEmpresa> {
  String _necessitaAgendamento = 'NÃO';
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  void _realizarCadastro() {
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Menuprincipal()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final molduraHeight = screenHeight * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: molduraHeight * 0.75,
                  bottom: molduraHeight * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título "Cadastro de Empresa" no lugar da imagem
                      Center(
                        child: Text(
                          'Cadastro de Empresa',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(label: 'Nome:'),
                            _buildTextField(label: 'Categoria:', hint: '(escola, barbearia, restaurante...)'),
                            _buildTextField(
                              label: 'Número:',
                              hint: 'Apenas números (ex: 12999999999)',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 16),
                            const Text('Dias/horários de funcionamento:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            _buildHorariosGrid(),
                            const SizedBox(height: 16),
                            _buildTextField(label: 'Descrição:', maxLines: 3),
                            _buildTextField(label: 'Endereço completo:'),
                            const SizedBox(height: 16),
                            const Text('Redes sociais:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            _buildSocialInput(Icons.camera_alt, 'Instagram (URL ou @)'),
                            _buildSocialInput(Icons.facebook, 'Facebook (URL)'),
                            _buildSocialInput(Icons.music_note, 'TikTok'),
                            _buildSocialInput(Icons.language, 'Website'),
                            const SizedBox(height: 20),
                            const Text('Necessita agendamento?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            _buildAgendamentoOptions(),
                            const SizedBox(height: 20),
                            const Text('Descrição dos profissionais:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            _buildProfissionaisSection(),
                            const SizedBox(height: 20),
                            const Text('Fotos (até 15 fotos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            _buildFotosGrid(),
                            const SizedBox(height: 20),
                            const Text('Formas de pagamento:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            _buildPaymentInput('Cartão (crédito/débito):'),
                            _buildPaymentInput('Pix:'),
                            _buildPaymentInput('Outros:'),
                            const SizedBox(height: 16),
                            _buildTextField(label: 'Email:'),
                            _buildTextField(label: 'Senha:', obscureText: true, controller: _senhaController),
                            _buildTextField(label: 'Confirmar senha:', obscureText: true, controller: _confirmarSenhaController),
                            const SizedBox(height: 32),
                            Center(
                              child: ElevatedButton(
                                onPressed: _realizarCadastro,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF76A085),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: molduraHeight,
              child: Image.asset(
                'imagem/quebrainferior.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    int maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45, width: 1)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorariosGrid() {
    final dias = ['Segunda:', 'Terça:', 'Quarta:', 'Quinta:', 'Sexta:', 'Sábado:', 'Domingo:', 'Feriados:'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 10,
      ),
      itemCount: dias.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            SizedBox(width: 65, child: Text(dias[index], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: '__:__ às __:__', isDense: true, contentPadding: EdgeInsets.zero),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialInput(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentoOptions() {
    final opcoes = ['SIM', 'NÃO', 'OPCIONAL'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: opcoes.map((opcao) {
        final isSelected = _necessitaAgendamento == opcao;
        return InkWell(
          onTap: () => setState(() => _necessitaAgendamento = opcao),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey.shade300 : Colors.white,
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(opcao, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.black54)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfissionaisSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.black12, child: Icon(Icons.person, color: Colors.black54)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nome:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Especialidade/função', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(15)),
            child: const Column(
              children: [
                Icon(Icons.add, size: 24),
                Text('Adicionar\nprofissional', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFotosGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return InkWell(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width * 0.26,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned(top: 10, left: 0, right: 0, child: Icon(Icons.cloud_queue, color: Colors.white.withOpacity(0.9), size: 30)),
                  Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 40, color: Colors.lightGreen.shade400)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentInput(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 2)),
            ),
          ),
        ],
      ),
    );
  }
}