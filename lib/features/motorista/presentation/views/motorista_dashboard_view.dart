import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MotoristaDashboardView extends StatelessWidget {
  const MotoristaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Motorista'),
      ),
      body: Column(
        children: [
          // Saudação
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor,
            child: const Text(
              'Olá, Motorista! Boa viagem!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // Mapa
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-23.5505, -46.6333), // São Paulo
                zoom: 12,
              ),
              markers: {
                const Marker(
                  markerId: MarkerId('current_location'),
                  position: LatLng(-23.5505, -46.6333),
                ),
              },
            ),
          ),
          // Cards de paradas
          Container(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Próxima parada'),
                        Text('Endereço: Rua A, 123'),
                        Text('Horário: 14:00'),
                      ],
                    ),
                  ),
                ),
                // Mais cards...
              ],
            ),
          ),
        ],
      ),
    );
  }
}