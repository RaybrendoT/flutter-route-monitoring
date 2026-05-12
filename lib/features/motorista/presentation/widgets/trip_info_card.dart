import 'package:flutter/material.dart';
import 'package:rota_em_flutter/features/motorista/domain/models/trip_model.dart';

class TripInfoCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onEndTrip;

  const TripInfoCard({
    super.key,
    required this.trip,
    required this.onEndTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Trip stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'arrival',
                value: '${trip.estimatedArrival?.hour}:${trip.estimatedArrival?.minute.toString().padLeft(2, '0')}',
                icon: Icons.schedule,
              ),
              _buildStatItem(
                label: 'min',
                value: '${trip.estimatedTime}',
                icon: Icons.timer,
              ),
              _buildStatItem(
                label: 'km',
                value: trip.distance.toStringAsFixed(1),
                icon: Icons.directions,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // End trip button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEndTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'End',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
