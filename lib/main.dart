import 'package:flutter/material.dart';
import 'package:neuroway/inicio.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Adicionado construtor com chave (boa prática)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Páginas",
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: true, 
      ),
      home: const INICIO(),
    );
  }
}