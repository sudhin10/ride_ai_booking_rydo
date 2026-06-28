class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
  final double rating;
  final int totalTrips;
  final String carModel;
  final String carColor;
  final String carPlate;
  final String carType;
  final double lat;
  final double lng;

  const DriverModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.avatarUrl = '',
    this.rating = 4.8,
    this.totalTrips = 0,
    this.carModel = '',
    this.carColor = '',
    this.carPlate = '',
    this.carType = 'economy',
    this.lat = 0,
    this.lng = 0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> j) {
    final car = j['car'] ?? {};
    final coords = (j['location']?['coordinates'] ?? [0, 0]) as List;
    return DriverModel(
      id: j['_id'] ?? j['id'] ?? '',
      name: j['name'] ?? '',
      phone: j['phone'] ?? '',
      avatarUrl: j['avatarUrl'] ?? '',
      rating: (j['rating'] ?? 4.8).toDouble(),
      totalTrips: j['totalTrips'] ?? 0,
      carModel: car['model'] ?? '',
      carColor: car['color'] ?? '',
      carPlate: car['plate'] ?? '',
      carType: car['type'] ?? 'economy',
      lng: (coords.isNotEmpty ? coords[0] : 0).toDouble(),
      lat: (coords.length > 1 ? coords[1] : 0).toDouble(),
    );
  }
}
