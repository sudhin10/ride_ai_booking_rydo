class Place {
  final String address;
  final double lat;
  final double lng;

  const Place({required this.address, required this.lat, required this.lng});

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        address: j['address'] ?? '',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'address': address, 'lat': lat, 'lng': lng};
}
