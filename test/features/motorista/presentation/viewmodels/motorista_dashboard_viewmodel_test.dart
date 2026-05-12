import 'package:flutter_test/flutter_test.dart';
import 'package:rota_em_flutter/features/motorista/presentation/viewmodels/motorista_dashboard_viewmodel.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';

void main() {
  group('MotoristaDashboardViewmodel Tests', () {
    late MotoristaDashboardViewmodel viewModel;

    setUp(() {
      viewModel = MotoristaDashboardViewmodel();
    });

    test('Inicialização do driver profile', () {
      expect(viewModel.driver.name, 'Isabelle');
      expect(viewModel.driver.status, 'offline');
      expect(viewModel.isOnline, false);
      expect(viewModel.currentTrip, null);
    });

    test('Alternar status online/offline', () {
      expect(viewModel.driver.status, 'offline');
      expect(viewModel.isOnline, false);

      viewModel.toggleOnlineStatus();
      expect(viewModel.driver.status, 'online');
      expect(viewModel.isOnline, true);

      viewModel.toggleOnlineStatus();
      expect(viewModel.driver.status, 'offline');
      expect(viewModel.isOnline, false);
    });

    test('Simular corrida entrante', () {
      expect(viewModel.currentTrip, null);

      viewModel.simulateIncomingTrip();
      expect(viewModel.currentTrip, isNotNull);
      expect(viewModel.currentTrip!.passengername, 'João Silva');
      expect(viewModel.currentTrip!.status, 'pending');
      expect(viewModel.currentTrip!.distance, 2.1);
      expect(viewModel.currentTrip!.estimatedTime, 4);
    });

    test('Aceitar corrida', () {
      viewModel.simulateIncomingTrip();
      final trip = viewModel.currentTrip!;

      viewModel.acceptTrip(trip);
      expect(viewModel.currentTrip!.status, 'accepted');
      expect(viewModel.driver.status, 'on_trip');
    });

    test('Iniciar corrida', () {
      viewModel.simulateIncomingTrip();
      viewModel.acceptTrip(viewModel.currentTrip!);

      expect(viewModel.currentTrip!.status, 'accepted');

      viewModel.startTrip();
      expect(viewModel.currentTrip!.status, 'in_progress');
      expect(viewModel.showTripDetails, true);
    });

    test('Completar corrida', () {
      viewModel.simulateIncomingTrip();
      viewModel.acceptTrip(viewModel.currentTrip!);
      viewModel.startTrip();

      viewModel.completeTrip();
      expect(viewModel.currentTrip!.status, 'completed');
      expect(viewModel.currentTrip!.earnings, 45.50);
    });

    test('Finalizar corrida', () {
      viewModel.simulateIncomingTrip();
      viewModel.acceptTrip(viewModel.currentTrip!);
      viewModel.startTrip();
      viewModel.completeTrip();

      viewModel.endTrip();
      expect(viewModel.currentTrip, null);
      expect(viewModel.driver.status, 'online');
      expect(viewModel.showTripDetails, false);
    });

    test('Atualizar localização do motorista', () {
      final initialLat = viewModel.driver.currentLat;
      final initialLng = viewModel.driver.currentLng;

      viewModel.updateCurrentLocation(-23.5560, -46.6400);

      expect(viewModel.driver.currentLat, -23.5560);
      expect(viewModel.driver.currentLng, -46.6400);
      expect(viewModel.driver.currentLat, isNot(initialLat));
      expect(viewModel.driver.currentLng, isNot(initialLng));
    });

    test('Limpar erro', () {
      expect(viewModel.error, null);
      // Simular um erro sendo adicionado (se implementado)
      viewModel.clearError();
      expect(viewModel.error, null);
    });

    test('Múltiplas corridas em sequência', () {
      // Primeira corrida
      viewModel.simulateIncomingTrip();
      expect(viewModel.currentTrip!.passengername, 'João Silva');
      viewModel.acceptTrip(viewModel.currentTrip!);
      viewModel.startTrip();
      viewModel.completeTrip();
      expect(viewModel.currentTrip!.status, 'completed');

      viewModel.endTrip();
      expect(viewModel.currentTrip, null);

      // Segunda corrida
      viewModel.simulateIncomingTrip();
      expect(viewModel.currentTrip, isNotNull);
      expect(viewModel.currentTrip!.passengername, 'João Silva');
    });

    test('Dados do driver profile', () {
      expect(viewModel.driver.id, '1');
      expect(viewModel.driver.phone, '(11) 98765-4321');
      expect(viewModel.driver.email, 'isabelle@email.com');
      expect(viewModel.driver.vehicleModel, 'Toyota Corolla 2022');
      expect(viewModel.driver.vehiclePlate, 'ABC-1234');
      expect(viewModel.driver.vehicleColor, 'Prata');
      expect(viewModel.driver.rating, 4.8);
      expect(viewModel.driver.totalTrips, 156);
    });

    test('Dados da corrida simulada', () {
      viewModel.simulateIncomingTrip();
      final trip = viewModel.currentTrip!;

      expect(trip.id, 'trip_001');
      expect(trip.passengername, 'João Silva');
      expect(trip.passengerPhone, '(11) 91234-5678');
      expect(trip.pickupLocation, 'Rua A, 123 - São Paulo');
      expect(trip.dropoffLocation, 'Avenida Paulista, 500 - São Paulo');
      expect(trip.distance, 2.1);
      expect(trip.estimatedTime, 4);
    });

    test('Fluxo completo de uma corrida', () {
      // Estado inicial
      expect(viewModel.isOnline, false);
      expect(viewModel.currentTrip, null);

      // Ficar online
      viewModel.toggleOnlineStatus();
      expect(viewModel.isOnline, true);

      // Receber corrida
      viewModel.simulateIncomingTrip();
      expect(viewModel.currentTrip, isNotNull);
      expect(viewModel.currentTrip!.status, 'pending');

      // Aceitar corrida
      viewModel.acceptTrip(viewModel.currentTrip!);
      expect(viewModel.currentTrip!.status, 'accepted');
      expect(viewModel.driver.status, 'on_trip');

      // Iniciar corrida
      viewModel.startTrip();
      expect(viewModel.currentTrip!.status, 'in_progress');

      // Atualizar localização
      viewModel.updateCurrentLocation(-23.5550, -46.6350);
      expect(viewModel.driver.currentLat, -23.5550);

      // Completar corrida
      viewModel.completeTrip();
      expect(viewModel.currentTrip!.status, 'completed');

      // Finalizar
      viewModel.endTrip();
      expect(viewModel.currentTrip, null);
      expect(viewModel.driver.status, 'online');
      expect(viewModel.isOnline, true);
    });

    test('Notifier dispatch listeners', () {
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.toggleOnlineStatus();
      expect(notifyCount, 1);

      viewModel.simulateIncomingTrip();
      expect(notifyCount, 2);

      viewModel.acceptTrip(viewModel.currentTrip!);
      expect(notifyCount, 3);

      viewModel.startTrip();
      expect(notifyCount, 4);
    });
  });
}
