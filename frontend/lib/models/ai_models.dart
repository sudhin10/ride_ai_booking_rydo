/// Structured response from the AI ride assistant.
class AssistantResult {
  final String reply;
  final String intent; // book_ride | ask_fare | smalltalk | help
  final String? pickup;
  final String? dropoff;
  final String? rideType;
  final String? when;
  final String source; // openai | fallback

  const AssistantResult({
    required this.reply,
    required this.intent,
    this.pickup,
    this.dropoff,
    this.rideType,
    this.when,
    this.source = 'fallback',
  });

  factory AssistantResult.fromJson(Map<String, dynamic> j) => AssistantResult(
        reply: j['reply'] ?? '',
        intent: j['intent'] ?? 'smalltalk',
        pickup: j['pickup'],
        dropoff: j['dropoff'],
        rideType: j['rideType'],
        when: j['when'],
        source: j['source'] ?? 'fallback',
      );

  bool get isBooking => intent == 'book_ride' && (dropoff?.isNotEmpty ?? false);
}

/// ML fare/ETA/surge prediction.
class FarePrediction {
  final double predictedFare;
  final int predictedEtaMin;
  final double surgeMultiplier;
  final String source; // ml-model | fallback

  const FarePrediction({
    required this.predictedFare,
    required this.predictedEtaMin,
    required this.surgeMultiplier,
    this.source = 'fallback',
  });

  factory FarePrediction.fromJson(Map<String, dynamic> j) => FarePrediction(
        predictedFare: (j['predictedFare'] ?? 0).toDouble(),
        predictedEtaMin: (j['predictedEtaMin'] ?? 0).toInt(),
        surgeMultiplier: (j['surgeMultiplier'] ?? 1).toDouble(),
        source: j['source'] ?? 'fallback',
      );

  bool get isSurging => surgeMultiplier > 1.05;
}

/// Sentiment result attached to a review.
class ReviewSentiment {
  final String label; // positive | neutral | negative
  final double score;
  final String summary;
  final String source;

  const ReviewSentiment({
    required this.label,
    required this.score,
    required this.summary,
    this.source = 'lexicon',
  });

  factory ReviewSentiment.fromJson(Map<String, dynamic> j) => ReviewSentiment(
        label: j['label'] ?? 'neutral',
        score: (j['score'] ?? 0).toDouble(),
        summary: j['summary'] ?? '',
        source: j['source'] ?? 'lexicon',
      );
}
