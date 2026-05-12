class DriverProfileModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String profilePhoto;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;
  final double rating;
  final int totalTrips;
  final String status; // online, offline, on_trip
  final double currentLat;
  final double currentLng;

  DriverProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profilePhoto,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
    required this.rating,
    required this.totalTrips,
    required this.status,
    required this.currentLat,
    required this.currentLng,
  });

  DriverProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profilePhoto,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    double? rating,
    int? totalTrips,
    String? status,
    double? currentLat,
    double? currentLng,
  }) {
    return DriverProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      status: status ?? this.status,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
    );
  }
}
