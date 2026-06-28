import '../core/constants/api_endpoints.dart';
import '../models/fare_option_model.dart';
import '../models/place_model.dart';
import '../models/ride_model.dart';
import 'api_client.dart';

class RideService {
  final _api = ApiClient.instance;

  Future<List<FareOption>> estimate(Place pickup, Place dropoff) async {
    final res = await _api.post(ApiEndpoints.rideEstimate,
        body: {'pickup': pickup.toJson(), 'dropoff': dropoff.toJson()});
    return (res['options'] as List).map((e) => FareOption.fromJson(e)).toList();
  }

  Future<RideModel> createRide({
    required Place pickup,
    required Place dropoff,
    required String rideType,
    required String paymentMethod,
  }) async {
    final res = await _api.post(ApiEndpoints.rides, body: {
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'rideType': rideType,
      'paymentMethod': paymentMethod,
    });
    return RideModel.fromJson(res['ride']);
  }

  Future<List<RideModel>> myRides() async {
    final res = await _api.get(ApiEndpoints.rides);
    return (res['rides'] as List).map((e) => RideModel.fromJson(e)).toList();
  }

  Future<RideModel?> activeRide() async {
    final res = await _api.get(ApiEndpoints.activeRide);
    return res['ride'] == null ? null : RideModel.fromJson(res['ride']);
  }

  Future<RideModel> updateStatus(String id, String status) async {
    final res = await _api.patch('${ApiEndpoints.rides}/$id/status', body: {'status': status});
    return RideModel.fromJson(res['ride']);
  }

  Future<void> rate(String id, int rating) async {
    await _api.post('${ApiEndpoints.rides}/$id/rate', body: {'rating': rating});
  }
}
