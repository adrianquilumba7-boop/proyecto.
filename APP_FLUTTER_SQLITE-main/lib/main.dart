import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(EcoRutaApp());
}

class EcoRutaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRuta Inteligente',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}


