# Guia de Integração com API - Dashboard Motorista

Este documento fornece orientações para integrar a interface com APIs reais de backend.

## 1. Estrutura de Data Source

### Remote Data Source (para API calls)

```dart
// lib/features/motorista/data/datasources/motorista_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/driver_profile_model.dart';

class MotoristRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://api.seu-app.com/v1';

  MotoristRemoteDataSource({required this.dio});

  // Buscar perfil do motorista
  Future<DriverProfileModel> getDriverProfile(String driverId) async {
    try {
      final response = await dio.get(
        '$baseUrl/drivers/$driverId',
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
      return DriverProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do motorista: $e');
    }
  }

  // Atualizar status do motorista
  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      await dio.patch(
        '$baseUrl/drivers/$driverId/status',
        data: {'status': status},
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // Buscar nova corrida (poll)
  Future<TripModel?> getNewTrip(String driverId) async {
    try {
      final response = await dio.get(
        '$baseUrl/drivers/$driverId/new-trip',
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return TripModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar corrida: $e');
    }
  }

  // Aceitar corrida
  Future<void> acceptTrip(String tripId) async {
    try {
      await dio.post(
        '$baseUrl/trips/$tripId/accept',
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
    } catch (e) {
      throw Exception('Erro ao aceitar corrida: $e');
    }
  }

  // Iniciar corrida
  Future<void> startTrip(String tripId) async {
    try {
      await dio.post(
        '$baseUrl/trips/$tripId/start',
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
    } catch (e) {
      throw Exception('Erro ao iniciar corrida: $e');
    }
  }

  // Completar corrida
  Future<void> completeTrip(String tripId) async {
    try {
      await dio.post(
        '$baseUrl/trips/$tripId/complete',
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        },
      );
    } catch (e) {
      throw Exception('Erro ao completar corrida: $e');
    }
  }

  // Enviar localização em tempo real
  Future<void> updateLocation(String driverId, double lat, double lng) async {
    try {
      await dio.post(
        '$baseUrl/drivers/$driverId/location',
        data: {
          'latitude': lat,
          'longitude': lng,
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }
}
```

### Local Data Source (para cache)

```dart
// lib/features/motorista/data/datasources/motorista_local_data_source.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rota_em_flutter/features/motorista/domain/models/driver_profile_model.dart';

class MotoristLocalDataSource {
  static const String driverProfileKey = 'driver_profile';
  static const String driverLocationKey = 'driver_location';
  static const String currentTripKey = 'current_trip';

  final SharedPreferences sharedPreferences;

  MotoristLocalDataSource({required this.sharedPreferences});

  // Salvar perfil do motorista
  Future<void> cacheDriverProfile(DriverProfileModel profile) async {
    final json = jsonEncode(profile.toJson());
    await sharedPreferences.setString(driverProfileKey, json);
  }

  // Recuperar perfil do motorista
  DriverProfileModel? getCachedDriverProfile() {
    final jsonString = sharedPreferences.getString(driverProfileKey);
    if (jsonString != null) {
      return DriverProfileModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Limpar cache
  Future<void> clearCache() async {
    await sharedPreferences.remove(driverProfileKey);
    await sharedPreferences.remove(currentTripKey);
    await sharedPreferences.remove(driverLocationKey);
  }
}
```

## 2. Repository Implementation

```dart
// lib/features/motorista/data/repositories/motorista_repository_impl.dart
import 'package:rota_em_flutter/features/motorista/domain/repositories/motorista_repository.dart';
import 'package:rota_em_flutter/features/motorista/data/datasources/motorista_remote_data_source.dart';
import 'package:rota_em_flutter/features/motorista/data/datasources/motorista_local_data_source.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/driver_profile_model.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';

class MotoristRepositoryImpl implements MotoristRepository {
  final MotoristRemoteDataSource remoteDataSource;
  final MotoristLocalDataSource localDataSource;

  MotoristRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<DriverProfileModel> getDriverProfile(String driverId) async {
    try {
      final profile = await remoteDataSource.getDriverProfile(driverId);
      await localDataSource.cacheDriverProfile(profile);
      return profile;
    } catch (e) {
      final cached = localDataSource.getCachedDriverProfile();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<void> updateDriverStatus(String driverId, String status) async {
    await remoteDataSource.updateDriverStatus(driverId, status);
  }

  @override
  Future<TripModel?> getNewTrip(String driverId) async {
    return await remoteDataSource.getNewTrip(driverId);
  }

  @override
  Future<void> acceptTrip(String tripId) async {
    await remoteDataSource.acceptTrip(tripId);
  }

  @override
  Future<void> updateLocation(String driverId, double lat, double lng) async {
    await remoteDataSource.updateLocation(driverId, lat, lng);
  }
}
```

## 3. Atualizar o ViewModel para usar Repository

```dart
// lib/features/motorista/presentation/viewmodels/motorista_dashboard_viewmodel.dart (Parte modificada)
import 'package:flutter/material.dart';
import 'package:rota_em_flutter/features/motorista/domain/repositories/motorista_repository.dart';
import 'package:geolocator/geolocator.dart';

class MotoristaDashboardViewmodel extends ChangeNotifier {
  final MotoristRepository motoristRepository;
  
  // ... resto do código ...

  MotoristaDashboardViewmodel({required this.motoristRepository}) {
    _initializeDriver();
    _startLocationTracking();
  }

  // Buscar perfil real da API
  void loadDriverProfile(String driverId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _driver = await motoristRepository.getDriverProfile(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alternar status e sincronizar com API
  void toggleOnlineStatus() async {
    try {
      _isOnline = !_isOnline;
      _driver = _driver.copyWith(
        status: _isOnline ? 'online' : 'offline',
      );
      
      // Sincronizar com API
      await motoristRepository.updateDriverStatus(
        _driver.id,
        _driver.status,
      );
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar status: $e';
      _isOnline = !_isOnline; // Reverter estado
      notifyListeners();
    }
  }

  // Buscar nova corrida (pode ser feito com polling ou WebSocket)
  void startListeningForTrips() {
    // Implementar com Timer ou StreamSocket
    Future.doWhile(() async {
      if (_isOnline) {
        try {
          final trip = await motoristRepository.getNewTrip(_driver.id);
          if (trip != null) {
            _currentTrip = trip;
            notifyListeners();
          }
        } catch (e) {
          _error = e.toString();
        }
      }
      await Future.delayed(const Duration(seconds: 5)); // Poll a cada 5s
      return true;
    });
  }

  // Rastrear localização em tempo real
  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualizar a cada 10m
      ),
    ).listen((Position position) {
      updateCurrentLocation(position.latitude, position.longitude);
      
      // Enviar para API a cada 30 segundos
      // Implementar com debounce/throttle
      motoristRepository.updateLocation(
        _driver.id,
        position.latitude,
        position.longitude,
      ).catchError((e) {
        print('Erro ao enviar localização: $e');
      });
    });
  }

  // Aceitar corrida via API
  void acceptTrip(TripModel trip) async {
    try {
      await motoristRepository.acceptTrip(trip.id);
      _currentTrip = trip.copyWith(status: 'accepted');
      _driver = _driver.copyWith(status: 'on_trip');
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao aceitar corrida: $e';
      notifyListeners();
    }
  }
}
```

## 4. Configuração de Providers no main.dart

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    
    return MultiProvider(
      providers: [
        // Data sources
        Provider<MotoristRemoteDataSource>(
          create: (_) => MotoristRemoteDataSource(dio: dio),
        ),
        Provider<MotoristLocalDataSource>(
          create: (_) => MotoristLocalDataSource(
            sharedPreferences: /* inject SharedPreferences */
          ),
        ),
        // Repository
        Provider<MotoristRepository>(
          create: (context) => MotoristRepositoryImpl(
            remoteDataSource: context.read<MotoristRemoteDataSource>(),
            localDataSource: context.read<MotoristLocalDataSource>(),
          ),
        ),
        // ViewModel
        ChangeNotifierProvider(
          create: (context) => MotoristaDashboardViewmodel(
            motoristRepository: context.read<MotoristRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Rota em Flutter',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

## 5. Modelos com Métodos fromJson/toJson

```dart
// Adicionar ao TripModel
extension TripModelJson on TripModel {
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      passengername: json['passenger_name'],
      passengerPhone: json['passenger_phone'],
      passengerPhoto: json['passenger_photo'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'])
          : null,
      pickupLat: json['pickup_latitude'],
      pickupLng: json['pickup_longitude'],
      dropoffLat: json['dropoff_latitude'],
      dropoffLng: json['dropoff_longitude'],
      distance: (json['distance'] as num).toDouble(),
      estimatedTime: json['estimated_time'],
      earnings: (json['earnings'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_name': passengername,
      'passenger_phone': passengerPhone,
      'passenger_photo': passengerPhoto,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'pickup_latitude': pickupLat,
      'pickup_longitude': pickupLng,
      'dropoff_latitude': dropoffLat,
      'dropoff_longitude': dropoffLng,
      'distance': distance,
      'estimated_time': estimatedTime,
      'earnings': earnings,
    };
  }
}
```

## 6. Endpoints da API Sugeridos

```
POST   /api/v1/drivers/login
POST   /api/v1/drivers/logout
GET    /api/v1/drivers/{id}
PATCH  /api/v1/drivers/{id}
PATCH  /api/v1/drivers/{id}/status
POST   /api/v1/drivers/{id}/location
GET    /api/v1/drivers/{id}/new-trip
GET    /api/v1/trips/{id}
POST   /api/v1/trips/{id}/accept
POST   /api/v1/trips/{id}/start
POST   /api/v1/trips/{id}/complete
GET    /api/v1/trips/{id}/history
```

## 7. Tratamento de Erros e Retry Logic

```dart
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  static const maxRetries = 3;
  int retryCount = 0;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      handler.resolve(retry(err.requestOptions));
    } else {
      retryCount = 0;
      handler.next(err);
    }
  }

  bool shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode ?? 0) == 429 || // Rate limit
        (error.response?.statusCode ?? 0) >= 500; // Server error
  }

  Future<Response<dynamic>> retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return Dio().request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

## 8. WebSockets para Real-time Updates (Alternativa ao Polling)

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

class TripWebSocketService {
  final WebSocketChannel channel;
  final String driverId;

  TripWebSocketService({
    required this.channel,
    required this.driverId,
  });

  void connect() {
    channel.sink.add(jsonEncode({
      'action': 'subscribe',
      'driver_id': driverId,
      'events': ['new_trip', 'trip_update', 'driver_update']
    }));
  }

  Stream<dynamic> getEvents() {
    return channel.stream.map((data) => jsonDecode(data));
  }

  void disconnect() {
    channel.sink.close();
  }
}
```

## Próximas Etapas

1. ✅ Implementar Data Sources (Remote e Local)
2. ✅ Implementar Repository
3. ✅ Adicionar métodos fromJson/toJson aos modelos
4. ✅ Integrar Geolocator para localização em tempo real
5. ✅ Implementar WebSocket ou Polling para novas corridas
6. ✅ Adicionar tratamento de erros e retry logic
7. ✅ Implementar autenticação com tokens
8. ✅ Adicionar logging e analytics
9. ✅ Implementar offline mode com sincronização
10. ✅ Testes de integração com API
