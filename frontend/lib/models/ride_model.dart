import 'package:latlong2/latlong.dart';
import 'place_model.dart';
import 'driver_model.dart';

class RideModel {
  final String id;
  final Place pickup;
  final Place dropoff;
  final String rideType;
  final String status;
  final double distanceKm;
  final int durationMin;
  final double fare;
  final String paymentMethod;
  final String paymentStatus;
  final List<LatLng> route;
  final DriverModel? driver;
  final double? rating;
  final String riskLevel;
  final List<String> riskFlags;
  final DateTime createdAt;

  const RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.rideType,
    required this.status,
    required this.distanceKm,
    required this.durationMin,
    required this.fare,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.route,
    required this.createdAt,
    this.driver,
    this.rating,
    this.riskLevel = 'low',
    this.riskFlags = const [],
  });

  factory RideModel.fromJson(Map<String, dynamic> j) {
    final rawRoute = (j['route'] ?? []) as List;
    final route = rawRoute
        .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();
    DriverModel? driver;
    if (j['driver'] != null && j['driver'] is Map) {
      driver = DriverModel.fromJson(Map<String, dynamic>.from(j['driver']));
    }
    return RideModel(
      id: j['_id'] ?? j['id'] ?? '',
      pickup: Place.fromJson(Map<String, dynamic>.from(j['pickup'])),
      dropoff: Place.fromJson(Map<String, dynamic>.from(j['dropoff'])),
      rideType: j['rideType'] ?? 'economy',
      status: j['status'] ?? 'requested',
      distanceKm: (j['distanceKm'] ?? 0).toDouble(),
      durationMin: (j['durationMin'] ?? 0).toInt(),
      fare: (j['fare'] ?? 0).toDouble(),
      paymentMethod: j['paymentMethod'] ?? 'card',
      paymentStatus: j['paymentStatus'] ?? 'pending',
      route: route,
      driver: driver,
      rating: j['rating'] != null ? (j['rating'] as num).toDouble() : null,
      riskLevel: j['riskLevel'] ?? 'low',
      riskFlags: (j['riskFlags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isActive =>
      ['requested', 'accepted', 'arriving', 'in_progress'].contains(status);

  String get statusLabel {
    switch (status) {
      case 'accepted':
        return 'Driver assigned';
      case 'arriving':
        return 'Driver is arriving';
      case 'in_progress':
        return 'On the way to destination';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Finding a driver';
    }
  }
}
