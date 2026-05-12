import 'package:flutter/material.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/driver_profile_model.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';

class MotoristaDashboardViewmodel extends ChangeNotifier {
  // Driver profile
  late DriverProfileModel _driver;
  
  // Current trip
  TripModel? _currentTrip;
  
  // UI state
  bool _isLoading = false;
  bool _isOnline = false;
  String? _error;
  bool _showTripDetails = false;

  // Getters
  DriverProfileModel get driver => _driver;
  TripModel? get currentTrip => _currentTrip;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get error => _error;
  bool get showTripDetails => _showTripDetails;

  MotoristaDashboardViewmodel() {
    _initializeDriver();
  }

  void _initializeDriver() {
    _driver = DriverProfileModel(
      id: '1',
      name: 'Isabelle',
      phone: '(11) 98765-4321',
      email: 'isabelle@email.com',
      profilePhoto: 'assets/driver_photo.jpg',
      vehicleModel: 'Toyota Corolla 2022',
      vehiclePlate: 'ABC-1234',
      vehicleColor: 'Prata',
      rating: 4.8,
      totalTrips: 156,
      status: 'offline',
      currentLat: -23.5505,
      currentLng: -46.6333,
    );
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    _driver = _driver.copyWith(
      status: _isOnline ? 'online' : 'offline',
    );
    notifyListeners();
  }

  void acceptTrip(TripModel trip) {
    _currentTrip = trip.copyWith(status: 'accepted');
    _driver = _driver.copyWith(status: 'on_trip');
    notifyListeners();
  }

  void startTrip() {
    if (_currentTrip != null) {
      _currentTrip = _currentTrip!.copyWith(status: 'in_progress');
      _showTripDetails = true;
      notifyListeners();
    }
  }

  void completeTrip() {
    if (_currentTrip != null) {
      _currentTrip = _currentTrip!.copyWith(
        status: 'completed',
        earnings: 45.50,
      );
      notifyListeners();
    }
  }

  void endTrip() {
    _currentTrip = null;
    _driver = _driver.copyWith(status: 'online');
    _showTripDetails = false;
    notifyListeners();
  }

  void updateCurrentLocation(double lat, double lng) {
    _driver = _driver.copyWith(
      currentLat: lat,
      currentLng: lng,
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Simula recebimento de uma nova corrida
  void simulateIncomingTrip() {
    _currentTrip = TripModel(
      id: 'trip_001',
      passengername: 'João Silva',
      passengerPhone: '(11) 91234-5678',
      passengerPhoto: 'assets/passenger_photo.jpg',
      pickupLocation: 'Rua A, 123 - São Paulo',
      dropoffLocation: 'Avenida Paulista, 500 - São Paulo',
      status: 'pending',
      createdAt: DateTime.now(),
      estimatedArrival: DateTime.now().add(const Duration(minutes: 4)),
      pickupLat: -23.5505,
      pickupLng: -46.6333,
      dropoffLat: -23.5616,
      dropoffLng: -46.6559,
      distance: 2.1,
      estimatedTime: 4,
    );
    notifyListeners();
  }
}
