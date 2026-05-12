class TripModel {
  final String id;
  final String passengername;
  final String passengerPhone;
  final String passengerPhoto;
  final String pickupLocation;
  final String dropoffLocation;
  final String status; // pending, accepted, in_progress, completed
  final DateTime createdAt;
  final DateTime? estimatedArrival;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double distance; // em km
  final int estimatedTime; // em minutos
  final double? earnings;

  TripModel({
    required this.id,
    required this.passengername,
    required this.passengerPhone,
    required this.passengerPhoto,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.status,
    required this.createdAt,
    this.estimatedArrival,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distance,
    required this.estimatedTime,
    this.earnings,
  });

  TripModel copyWith({
    String? id,
    String? passengername,
    String? passengerPhone,
    String? passengerPhoto,
    String? pickupLocation,
    String? dropoffLocation,
    String? status,
    DateTime? createdAt,
    DateTime? estimatedArrival,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? distance,
    int? estimatedTime,
    double? earnings,
  }) {
    return TripModel(
      id: id ?? this.id,
      passengername: passengername ?? this.passengername,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      earnings: earnings ?? this.earnings,
    );
  }
}
