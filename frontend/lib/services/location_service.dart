import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants/app_constants.dart';

/// Resolves the device position with graceful fallback to the demo city centre
/// (so the app is fully usable on emulators / web without GPS permission).
class LocationService {
  static const LatLng fallback =
      LatLng(AppConstants.defaultLat, AppConstants.defaultLng);

  Future<LatLng> currentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return fallback;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return fallback;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[location] falling back: $e');
      return fallback;
    }
  }
}
