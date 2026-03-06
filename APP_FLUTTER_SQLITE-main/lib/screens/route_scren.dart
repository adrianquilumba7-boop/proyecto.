import 'package:flutter/material.dart';

class RouteScreen extends StatelessWidget {
  final String destino;

  RouteScreen({required this.destino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ruta Optimizada")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Destino: $destino",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.directions_walk, color: Colors.green),
              title: Text("Caminar 5 min"),
            ),

            ListTile(
              leading: Icon(Icons.directions_bus, color: Colors.blue),
              title: Text("Bus urbano 15 min"),
            ),

            ListTile(
              leading: Icon(Icons.pedal_bike, color: Colors.orange),
              title: Text("Bicicleta pública 7 min"),
            ),

            SizedBox(height: 30),

            Card(
              child: ListTile(
                title: Text("💰 Ahorro estimado: \$1.20"),
                subtitle: Text("🌍 CO₂ reducido: 0.8 kg"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}