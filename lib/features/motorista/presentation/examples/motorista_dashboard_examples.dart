import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/features/motorista/presentation/viewmodels/motorista_dashboard_viewmodel.dart';
import 'package:rota_em_flutter/features/motorista/presentation/views/motorista_dashboard_view.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';

/// Exemplo de uso da interface de Dashboard do Motorista
void main() {
  runApp(const MotoristaDashboardExample());
}

class MotoristaDashboardExample extends StatelessWidget {
  const MotoristaDashboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motorista Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (_) => MotoristaDashboardViewmodel(),
        child: const MotoristaDashboardView(),
      ),
    );
  }
}

// ============================================================================
// EXEMPLOS DE USO DO VIEWMODEL
// ============================================================================

/// Exemplo 1: Simular o fluxo completo de uma corrida
void exampleCompleteTrip(MotoristaDashboardViewmodel viewModel) {
  // Passo 1: Simular uma nova corrida chegando
  viewModel.simulateIncomingTrip();
  // Output: currentTrip != null com status 'pending'

  // Passo 2: Aceitar a corrida
  viewModel.acceptTrip(viewModel.currentTrip!);
  // Output: currentTrip status = 'accepted'

  // Passo 3: Começar a corrida
  viewModel.startTrip();
  // Output: currentTrip status = 'in_progress'

  // Passo 4: Atualizar localização durante a corrida
  viewModel.updateCurrentLocation(-23.5560, -46.6400);
  // Output: driver.currentLat/Lng atualizado

  // Passo 5: Completar a corrida
  viewModel.completeTrip();
  // Output: currentTrip status = 'completed', earnings = 45.50

  // Passo 6: Finalizar e retornar ao estado online
  viewModel.endTrip();
  // Output: currentTrip = null, driver.status = 'online'
}

/// Exemplo 2: Alternar status online/offline
void exampleToggleOnlineStatus(MotoristaDashboardViewmodel viewModel) {
  // Motorista está offline inicialmente
  print('Status inicial: ${viewModel.driver.status}'); // offline

  // Clica para ficar online
  viewModel.toggleOnlineStatus();
  print('Status após toggle: ${viewModel.driver.status}'); // online

  // Clica novamente para ficar offline
  viewModel.toggleOnlineStatus();
  print('Status após segundo toggle: ${viewModel.driver.status}'); // offline
}

/// Exemplo 3: Monitorar mudanças de estado com listener
void exampleListenerPattern(MotoristaDashboardViewmodel viewModel) {
  // Adicionar listener para reações a mudanças
  viewModel.addListener(() {
    if (viewModel.currentTrip != null) {
      print('Nova corrida recebida!');
      print('Passageiro: ${viewModel.currentTrip!.passengername}');
      print('Status: ${viewModel.currentTrip!.status}');
    }

    if (viewModel.isOnline) {
      print('Motorista está online e pronto para corridas');
    }
  });

  // Disparar mudança
  viewModel.simulateIncomingTrip();
}

/// Exemplo 4: Criar uma corrida customizada
void exampleCustomTrip(MotoristaDashboardViewmodel viewModel) {
  final customTrip = TripModel(
    id: 'trip_custom_001',
    passengername: 'Maria Santos',
    passengerPhone: '(11) 99999-8888',
    passengerPhoto: 'assets/maria.jpg',
    pickupLocation: 'Av. Paulista, 1000',
    dropoffLocation: 'Rua Augusta, 500',
    status: 'pending',
    createdAt: DateTime.now(),
    estimatedArrival: DateTime.now().add(const Duration(minutes: 8)),
    pickupLat: -23.5614,
    pickupLng: -46.6562,
    dropoffLat: -23.5501,
    dropoffLng: -46.6461,
    distance: 3.5,
    estimatedTime: 8,
  );

  // Aceitar essa corrida customizada
  viewModel.acceptTrip(customTrip);
  viewModel.startTrip();
}

/// Exemplo 5: Usar em um widget com Consumer
class MotoristaDashboardExampleWidget extends StatelessWidget {
  const MotoristaDashboardExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MotoristaDashboardViewmodel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              // Header com status
              Container(
                color: Colors.blue,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Motorista: ${viewModel.driver.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Badge de status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: viewModel.isOnline ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        viewModel.isOnline ? 'ONLINE' : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Corpo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações do motorista
                      _buildSection(
                        title: 'Informações do Motorista',
                        children: [
                          _buildInfoRow('Nome', viewModel.driver.name),
                          _buildInfoRow('Telefone', viewModel.driver.phone),
                          _buildInfoRow('Veículo', viewModel.driver.vehicleModel),
                          _buildInfoRow('Placa', viewModel.driver.vehiclePlate),
                          _buildInfoRow('Rating', '${viewModel.driver.rating} ⭐'),
                          _buildInfoRow('Total de Corridas', '${viewModel.driver.totalTrips}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Corrida atual (se houver)
                      if (viewModel.currentTrip != null)
                        _buildSection(
                          title: 'Corrida Atual',
                          children: [
                            _buildInfoRow(
                              'Passageiro',
                              viewModel.currentTrip!.passengername,
                            ),
                            _buildInfoRow(
                              'Pickup',
                              viewModel.currentTrip!.pickupLocation,
                            ),
                            _buildInfoRow(
                              'Dropoff',
                              viewModel.currentTrip!.dropoffLocation,
                            ),
                            _buildInfoRow(
                              'Status',
                              viewModel.currentTrip!.status,
                            ),
                            _buildInfoRow(
                              'Distância',
                              '${viewModel.currentTrip!.distance} km',
                            ),
                            _buildInfoRow(
                              'Tempo Est.',
                              '${viewModel.currentTrip!.estimatedTime} min',
                            ),
                            if (viewModel.currentTrip!.earnings != null)
                              _buildInfoRow(
                                'Ganho',
                                'R\$ ${viewModel.currentTrip!.earnings!.toStringAsFixed(2)}',
                              ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => viewModel.toggleOnlineStatus(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: viewModel.isOnline ? Colors.red : Colors.green,
                              ),
                              child: Text(
                                viewModel.isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => viewModel.simulateIncomingTrip(),
                              child: const Text('SIMULAR CORRIDA'),
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.currentTrip != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => viewModel.startTrip(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('INICIAR CORRIDA'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => viewModel.completeTrip(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('COMPLETAR CORRIDA'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => viewModel.endTrip(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('FINALIZAR'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
