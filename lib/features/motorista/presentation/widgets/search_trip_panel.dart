import 'package:flutter/material.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/driver_profile_model.dart';

class SearchTripPanel extends StatefulWidget {
  final DriverProfileModel driver;
  final VoidCallback onStartTrip;
  final VoidCallback onSimulateTrip;

  const SearchTripPanel({
    super.key,
    required this.driver,
    required this.onStartTrip,
    required this.onSimulateTrip,
  });

  @override
  State<SearchTripPanel> createState() => _SearchTripPanelState();
}

class _SearchTripPanelState extends State<SearchTripPanel> {
  late TextEditingController _locationController;
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: 'Local Atual');
    _destinationController = TextEditingController(text: 'Empresa X');
  }

  @override
  void dispose() {
    _locationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com foto e saudação
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Oi, Isabelle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Como você está hoje?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Local atual
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Local Atual',
              prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
              suffixIcon: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Destination
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'Empresa X',
              prefixIcon: const Icon(Icons.location_on, color: Colors.red),
              suffixIcon: IconButton(
                icon: const Icon(Icons.swap_vert),
                onPressed: () {
                  // Swap locations
                  final temp = _locationController.text;
                  _locationController.text = _destinationController.text;
                  _destinationController.text = temp;
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSimulateTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Navigation icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIcon(Icons.people, 'Passageiros'),
              _buildNavIcon(Icons.directions_car, 'Veículos'),
              _buildNavIcon(Icons.location_on, 'Locais'),
              _buildNavIcon(Icons.notifications, 'Avisos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
