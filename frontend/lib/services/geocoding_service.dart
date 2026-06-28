import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

/// Free forward-geocoding via OpenStreetMap Nominatim (no API key).
/// Falls back to a curated list of demo places when offline so the booking
/// flow always works on emulators / web.
class GeocodingService {
  static const _curated = <Place>[
    Place(address: 'San Francisco Intl. Airport (SFO)', lat: 37.6213, lng: -122.3790),
    Place(address: 'Union Square, San Francisco', lat: 37.7880, lng: -122.4074),
    Place(address: 'Golden Gate Bridge', lat: 37.8199, lng: -122.4783),
    Place(address: 'Ferry Building, San Francisco', lat: 37.7955, lng: -122.3937),
    Place(address: "Fisherman's Wharf", lat: 37.8080, lng: -122.4177),
    Place(address: 'Oracle Park', lat: 37.7786, lng: -122.3893),
    Place(address: 'Twin Peaks', lat: 37.7544, lng: -122.4477),
    Place(address: 'Mission Dolores Park', lat: 37.7596, lng: -122.4269),
  ];

  List<Place> get suggestions => _curated;

  Future<List<Place>> search(String query) async {
    if (query.trim().isEmpty) return _curated;
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&limit=6&q=${Uri.encodeComponent(query)}');
      final res = await http.get(uri, headers: {'User-Agent': 'rydo-app/1.0'}).timeout(
          const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final results = list
            .map((e) => Place(
                  address: e['display_name'] ?? query,
                  lat: double.tryParse(e['lat'] ?? '') ?? 0,
                  lng: double.tryParse(e['lon'] ?? '') ?? 0,
                ))
            .where((p) => p.lat != 0)
            .toList();
        if (results.isNotEmpty) return results;
      }
    } catch (_) {/* offline fallback below */}
    final q = query.toLowerCase();
    final filtered = _curated.where((p) => p.address.toLowerCase().contains(q)).toList();
    return filtered.isEmpty ? _curated : filtered;
  }
}
