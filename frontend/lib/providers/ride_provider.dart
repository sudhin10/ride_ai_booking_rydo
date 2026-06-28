import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../models/fare_option_model.dart';
import '../models/place_model.dart';
import '../models/ride_model.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../services/ride_service.dart';
import '../services/socket_service.dart';

class RideProvider extends ChangeNotifier {
  final _rides = RideService();
  final _drivers = DriverService();
  final _location = LocationService();
  final _socket = SocketService();

  // Map / location
  LatLng? currentLatLng;
  List<DriverModel> nearbyDrivers = [];

  // Booking flow
  Place? pickup;
  Place? dropoff;
  List<FareOption> fareOptions = [];
  String selectedRideType = 'economy';
  String paymentMethod = 'card';

  // Active ride + live tracking
  RideModel? activeRide;
  LatLng? driverLatLng;
  int etaMinutes = 0;
  String trackingPhase = 'arriving';

  bool loading = false;
  String? error;

  Future<void> initLocation() async {
    currentLatLng = await _location.currentLocation();
    notifyListeners();
    await loadNearbyDrivers();
  }

  Future<void> loadNearbyDrivers() async {
    if (currentLatLng == null) return;
    try {
      nearbyDrivers = await _drivers.nearby(currentLatLng!.latitude, currentLatLng!.longitude);
      notifyListeners();
    } catch (_) {}
  }

  void setPickup(Place p) {
    pickup = p;
    notifyListeners();
  }

  void setDropoff(Place p) {
    dropoff = p;
    notifyListeners();
  }

  void setRideType(String type) {
    selectedRideType = type;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  FareOption? get selectedFare {
    for (final f in fareOptions) {
      if (f.rideType == selectedRideType) return f;
    }
    return fareOptions.isNotEmpty ? fareOptions.first : null;
  }

  Future<bool> fetchEstimates() async {
    if (pickup == null || dropoff == null) return false;
    _setLoading(true);
    try {
      fareOptions = await _rides.estimate(pickup!, dropoff!);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<RideModel?> confirmRide() async {
    if (pickup == null || dropoff == null) return null;
    _setLoading(true);
    try {
      activeRide = await _rides.createRide(
        pickup: pickup!,
        dropoff: dropoff!,
        rideType: selectedRideType,
        paymentMethod: paymentMethod,
      );
      return activeRide;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---- live tracking ----
  void startTracking({
    required void Function(double lat, double lng, int eta, String phase) onLocation,
    required void Function(String status) onStatus,
  }) {
    if (activeRide == null) return;
    _socket.onDriverLocation = (lat, lng, eta, phase) {
      driverLatLng = LatLng(lat, lng);
      etaMinutes = eta;
      trackingPhase = phase;
      notifyListeners();
      onLocation(lat, lng, eta, phase);
    };
    _socket.onStatus = (status) {
      if (activeRide != null) {
        activeRide = _copyStatus(activeRide!, status);
        notifyListeners();
      }
      onStatus(status);
    };
    _socket.connectAndSubscribe(activeRide!.id);
  }

  RideModel _copyStatus(RideModel r, String status) {
    final mapped = status == 'arrived_destination' ? 'in_progress' : status;
    return RideModel(
      id: r.id,
      pickup: r.pickup,
      dropoff: r.dropoff,
      rideType: r.rideType,
      status: mapped,
      distanceKm: r.distanceKm,
      durationMin: r.durationMin,
      fare: r.fare,
      paymentMethod: r.paymentMethod,
      paymentStatus: r.paymentStatus,
      route: r.route,
      driver: r.driver,
      rating: r.rating,
      createdAt: r.createdAt,
    );
  }

  Future<RideModel?> completeRide() async {
    if (activeRide == null) return null;
    try {
      activeRide = await _rides.updateStatus(activeRide!.id, 'completed');
      return activeRide;
    } catch (e) {
      error = e.toString();
      return null;
    }
  }

  Future<void> cancelRide() async {
    if (activeRide == null) return;
    try {
      await _rides.updateStatus(activeRide!.id, 'cancelled');
    } catch (_) {}
    stopTracking();
    activeRide = null;
    notifyListeners();
  }

  Future<void> rateRide(int rating) async {
    if (activeRide == null) return;
    await _rides.rate(activeRide!.id, rating);
  }

  void stopTracking() {
    _socket.dispose();
    driverLatLng = null;
  }

  void resetBooking() {
    pickup = null;
    dropoff = null;
    fareOptions = [];
    selectedRideType = 'economy';
    activeRide = null;
    driverLatLng = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    loading = v;
    if (v) error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
