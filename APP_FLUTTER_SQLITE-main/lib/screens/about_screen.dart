import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acerca de la App"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "EcoRuta es una aplicación que ayuda a encontrar rutas más ecológicas.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
