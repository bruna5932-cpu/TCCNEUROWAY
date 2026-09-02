import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TesteFirebase(),
    );
  }
}

class TesteFirebase extends StatelessWidget {
  const TesteFirebase({super.key});

  Future<void> salvarTeste() async {
    try {
      await FirebaseFirestore.instance.collection('testes').add({
        'nome': 'Fabio',
        'mensagem': 'Teste do Firebase',
        'data': DateTime.now(),
      });
      print('Dados salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar no Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Firebase'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: salvarTeste,
          child: const Text('Salvar no Firebase'),
        ),
      ),
    );
  }
}