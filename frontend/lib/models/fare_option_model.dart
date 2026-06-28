class FareOption {
  final String rideType;
  final double distanceKm;
  final int durationMin;
  final double fare;

  const FareOption({
    required this.rideType,
    required this.distanceKm,
    required this.durationMin,
    required this.fare,
  });

  factory FareOption.fromJson(Map<String, dynamic> j) => FareOption(
        rideType: j['rideType'] ?? 'economy',
        distanceKm: (j['distanceKm'] ?? 0).toDouble(),
        durationMin: (j['durationMin'] ?? 0).toInt(),
        fare: (j['fare'] ?? 0).toDouble(),
      );

  String get label {
    switch (rideType) {
      case 'comfort':
        return 'Comfort';
      case 'premium':
        return 'Premium';
      case 'van':
        return 'Van';
      default:
        return 'Economy';
    }
  }

  String get description {
    switch (rideType) {
      case 'comfort':
        return 'Newer cars, extra legroom';
      case 'premium':
        return 'Luxury rides, top drivers';
      case 'van':
        return 'Up to 6 passengers';
      default:
        return 'Affordable everyday rides';
    }
  }
}
