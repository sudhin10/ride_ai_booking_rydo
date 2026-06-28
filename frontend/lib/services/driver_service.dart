import '../core/constants/api_endpoints.dart';
import '../models/driver_model.dart';
import 'api_client.dart';

class DriverService {
  final _api = ApiClient.instance;

  Future<List<DriverModel>> nearby(double lat, double lng) async {
    final res = await _api.get('${ApiEndpoints.driversNearby}?lat=$lat&lng=$lng');
    return (res['drivers'] as List)
        .map((e) => DriverModel.fromJson(e['driver']))
        .toList();
  }
}
