import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Rutas"),
      ),
      body: const Center(
        child: Text(
          "Aquí aparecerá el historial de rutas",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
