import 'package:flutter/material.dart';

class ColaboradorDashboardView extends StatelessWidget {
  const ColaboradorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Colaborador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status da rota
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Text('Status da Rota'),
                    Text('Em trânsito'),
                    Text('ETA: 15:30'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Timeline
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Partida'),
                    subtitle: Text('14:00'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Próxima parada'),
                    subtitle: Text('Em 10 min'),
                  ),
                ],
              ),
            ),
            // Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Marcar Presença'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Informar Ausência'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}