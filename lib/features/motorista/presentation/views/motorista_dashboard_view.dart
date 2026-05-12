import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/features/motorista/presentation/viewmodels/motorista_dashboard_viewmodel.dart';
import 'package:rota_em_flutter/features/motorista/presentation/widgets/search_trip_panel.dart';
import 'package:rota_em_flutter/features/motorista/presentation/widgets/trip_info_card.dart';
import 'package:rota_em_flutter/features/motorista/presentation/widgets/navigation_instruction_card.dart';

class MotoristaDashboardView extends StatefulWidget {
  const MotoristaDashboardView({super.key});

  @override
  State<MotoristaDashboardView> createState() => _MotoristaDashboardViewState();
}

class _MotoristaDashboardViewState extends State<MotoristaDashboardView> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.add(
      const Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(-23.5505, -46.6333),
        infoWindow: InfoWindow(title: 'Meu Local'),
      ),
    );
  }

  void _addTripMarkers(context) {
    final viewModel = Provider.of<MotoristaDashboardViewmodel>(context, listen: false);
    if (viewModel.currentTrip != null) {
      final trip = viewModel.currentTrip!;
      
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(trip.pickupLat, trip.pickupLng),
          infoWindow: InfoWindow(title: 'Pickup: ${trip.pickupLocation}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(trip.dropoffLat, trip.dropoffLng),
          infoWindow: InfoWindow(title: 'Dropoff: ${trip.dropoffLocation}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      _addPolyline(trip);
      _animateCamera(trip.pickupLat, trip.pickupLng);
      setState(() {});
    }
  }

  void _addPolyline(dynamic trip) {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(trip.pickupLat, trip.pickupLng),
          LatLng(trip.dropoffLat, trip.dropoffLng),
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  void _animateCamera(double lat, double lng) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MotoristaDashboardViewmodel(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Consumer<MotoristaDashboardViewmodel>(
          builder: (context, viewModel, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Para telas grandes (desktop/tablet), layout lado a lado
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      // Painel esquerdo - Search
                      Container(
                        width: 320,
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: SearchTripPanel(
                            driver: viewModel.driver,
                            onStartTrip: () => viewModel.startTrip(),
                            onSimulateTrip: () => viewModel.simulateIncomingTrip(),
                          ),
                        ),
                      ),
                      // Separador
                      Container(
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      // Mapa à direita
                      Expanded(
                        child: Stack(
                          children: [
                            _buildMap(),
                            // Instruction card
                            if (viewModel.currentTrip != null &&
                                viewModel.currentTrip!.status == 'in_progress')
                              Positioned(
                                top: 16,
                                left: 16,
                                right: 16,
                                child: NavigationInstructionCard(
                                  instruction: 'Turn Right',
                                  streetName: 'toward R. Ramos Batista',
                                  distance: '250m',
                                ),
                              ),
                            // Trip info card
                            if (viewModel.currentTrip != null &&
                                viewModel.currentTrip!.status == 'in_progress')
                              Positioned(
                                bottom: 20,
                                left: 16,
                                right: 16,
                                child: TripInfoCard(
                                  trip: viewModel.currentTrip!,
                                  onEndTrip: () {
                                    viewModel.endTrip();
                                    _markers.clear();
                                    _polylines.clear();
                                    setState(() {});
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Para telas pequenas (mobile), layout em coluna
                return Stack(
                  children: [
                    _buildMap(),
                    // Painel de busca flutuante
                    if (viewModel.currentTrip == null)
                      Positioned(
                        bottom: 20,
                        left: 12,
                        right: 12,
                        child: SingleChildScrollView(
                          child: SearchTripPanel(
                            driver: viewModel.driver,
                            onStartTrip: () => viewModel.startTrip(),
                            onSimulateTrip: () => viewModel.simulateIncomingTrip(),
                          ),
                        ),
                      )
                    else ...[
                      // Instruction card mobile
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: NavigationInstructionCard(
                          instruction: 'Turn Right',
                          streetName: 'toward R. Ramos Batista',
                          distance: '250m',
                        ),
                      ),
                      // Trip info card mobile
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: TripInfoCard(
                          trip: viewModel.currentTrip!,
                          onEndTrip: () {
                            viewModel.endTrip();
                            _markers.clear();
                            _polylines.clear();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Consumer<MotoristaDashboardViewmodel>(
      builder: (context, viewModel, _) {
        if (viewModel.currentTrip != null && _markers.length == 1) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _addTripMarkers(context);
          });
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(viewModel.driver.currentLat, viewModel.driver.currentLng),
            zoom: 12,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}