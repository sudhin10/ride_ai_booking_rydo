import '../core/constants/api_endpoints.dart';
import '../models/ai_models.dart';
import 'api_client.dart';

class AiService {
  final _api = ApiClient.instance;

  /// Sends a natural-language message to the AI ride assistant.
  Future<({AssistantResult result, bool aiEnabled})> assistant(String message) async {
    final res = await _api.post(ApiEndpoints.aiAssistant, body: {'message': message});
    return (
      result: AssistantResult.fromJson(Map<String, dynamic>.from(res['result'])),
      aiEnabled: res['aiEnabled'] == true,
    );
  }

  /// ML-predicted fare/ETA/surge for a trip.
  Future<FarePrediction> predictFare({
    required double distanceKm,
    required String rideType,
    double demandLevel = 0.5,
    int? hour,
    int? dayOfWeek,
  }) async {
    final now = DateTime.now();
    final res = await _api.post(ApiEndpoints.aiPredictFare, body: {
      'distanceKm': distanceKm,
      'rideType': rideType,
      'demandLevel': demandLevel,
      'hour': hour ?? now.hour,
      'dayOfWeek': dayOfWeek ?? now.weekday % 7,
    });
    return FarePrediction.fromJson(Map<String, dynamic>.from(res['prediction']));
  }

  /// Submits a review; backend returns it with AI sentiment attached.
  Future<ReviewSentiment> submitReview({
    String? rideId,
    String? driverId,
    int rating = 5,
    required String text,
  }) async {
    final res = await _api.post(ApiEndpoints.reviews, body: {
      'rideId': rideId,
      'driverId': driverId,
      'rating': rating,
      'text': text,
    });
    return ReviewSentiment.fromJson(Map<String, dynamic>.from(res['review']['sentiment']));
  }
}
