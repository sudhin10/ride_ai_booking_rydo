import 'package:flutter_test/flutter_test.dart';
import 'package:rydo/models/fare_option_model.dart';

void main() {
  test('FareOption parses JSON and labels correctly', () {
    final f = FareOption.fromJson({
      'rideType': 'premium',
      'distanceKm': 5.2,
      'durationMin': 12,
      'fare': 18.4,
    });
    expect(f.label, 'Premium');
    expect(f.fare, 18.4);
    expect(f.durationMin, 12);
  });
}
