import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'history_screen.dart';
import 'stats_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? userLocation;
  LatLng? destination;

  List<LatLng> routePoints = [];

  double ahorroDinero = 0;
  double ahorroCO2 = 0;
  double ahorroCombustible = 0;
  double distancia = 0;

  int ecoScore = 0;

  String transporteSeleccionado = "Caminar";

  final TextEditingController destinoController = TextEditingController();

  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void calcularImpacto() {
    if (userLocation == null || destination == null) return;

    distancia = distance.as(LengthUnit.Kilometer, userLocation!, destination!);

    if (transporteSeleccionado == "Caminar") {
      ahorroDinero = distancia * 1.5;
      ahorroCO2 = distancia * 0.4;
      ahorroCombustible = distancia * 0.15;
      ecoScore = 95;
    } else if (transporteSeleccionado == "Bicicleta") {
      ahorroDinero = distancia * 1.2;
      ahorroCO2 = distancia * 0.35;
      ahorroCombustible = distancia * 0.12;
      ecoScore = 90;
    } else if (transporteSeleccionado == "Bus") {
      ahorroDinero = distancia * 0.8;
      ahorroCO2 = distancia * 0.20;
      ahorroCombustible = distancia * 0.05;
      ecoScore = 70;
    } else {
      ahorroDinero = distancia * 0.2;
      ahorroCO2 = distancia * 0.05;
      ahorroCombustible = distancia * 0.01;
      ecoScore = 30;
    }
  }

  Future<void> buscarDestino(String lugar) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$lugar&format=json&limit=1");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]["lat"]);
        double lon = double.parse(data[0]["lon"]);

        setState(() {
          destination = LatLng(lat, lon);

          routePoints = [userLocation!, destination!];

          calcularImpacto();
        });
      }
    }
  }

  void generarEcoRuta() {
    String destino = destinoController.text;

    if (destino.isEmpty) return;

    buscarDestino(destino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoRuta Inteligente 🌱"),
      ),
      body: userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// BUSCADOR
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: destinoController,
                          decoration: const InputDecoration(
                            hintText: "Buscar destino...",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: generarEcoRuta,
                        child: const Text("Ir"),
                      )
                    ],
                  ),
                ),

                /// TRANSPORTE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    value: transporteSeleccionado,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "Caminar",
                        child: Text("🚶 Caminar"),
                      ),
                      DropdownMenuItem(
                        value: "Bicicleta",
                        child: Text("🚲 Bicicleta"),
                      ),
                      DropdownMenuItem(
                        value: "Bus",
                        child: Text("🚌 Bus"),
                      ),
                      DropdownMenuItem(
                        value: "Auto",
                        child: Text("🚗 Auto"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        transporteSeleccionado = value!;

                        calcularImpacto();
                      });
                    },
                  ),
                ),

                /// MAPA
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: userLocation!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.ecoruta',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 5,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          if (destination != null)
                            Marker(
                              point: destination!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.flag,
                                size: 35,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// PANEL ECO
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.green[100],
                  child: Column(
                    children: [
                      Text("📏 Distancia: ${distancia.toStringAsFixed(2)} km"),
                      Text(
                          "💰 Ahorro económico: \$${ahorroDinero.toStringAsFixed(2)}"),
                      Text(
                          "🌿 CO₂ reducido: ${ahorroCO2.toStringAsFixed(2)} kg"),
                      Text(
                          "⛽ Combustible ahorrado: ${ahorroCombustible.toStringAsFixed(2)} L"),
                      Text("🌱 EcoScore del viaje: $ecoScore / 100"),

                      /// BOTONES DE NAVEGACIÓN
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HistoryScreen(),
                                  ),
                                );
                              },
                              child: const Text("Historial"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatsScreen(),
                                  ),
                                );
                              },
                              child: const Text("Estadísticas"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutScreen(),
                                  ),
                                );
                              },
                              child: const Text("Info"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
