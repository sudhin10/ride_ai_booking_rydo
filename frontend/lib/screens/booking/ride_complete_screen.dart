import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

class RideCompleteScreen extends StatefulWidget {
  const RideCompleteScreen({super.key});

  @override
  State<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends State<RideCompleteScreen> {
  int _rating = 5;
  final _ai = AiService();
  final _review = TextEditingController();
  ReviewSentiment? _sentiment;
  bool _submitting = false;

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = context.read<RideProvider>().activeRide;
      context.read<SettingsProvider>().speak(
          'Trip complete. Your fare is ${Formatters.money(ride?.fare ?? 0)}. Please rate your driver.');
    });
  }

  Future<void> _submit() async {
    final ride = context.read<RideProvider>();
    final settings = context.read<SettingsProvider>();
    setState(() => _submitting = true);
    await ride.rateRide(_rating);

    // AI sentiment analysis on the written review (if any).
    if (_review.text.trim().isNotEmpty) {
      try {
        final sentiment = await _ai.submitReview(
          rideId: ride.activeRide?.id,
          driverId: ride.activeRide?.driver?.id,
          rating: _rating,
          text: _review.text.trim(),
        );
        if (mounted) {
          setState(() => _sentiment = sentiment);
          settings.speak('Thanks. Your review reads as ${sentiment.label}.');
        }
        // Briefly show the detected sentiment before leaving.
        await Future.delayed(const Duration(milliseconds: 900));
      } catch (_) {/* best-effort */}
    } else {
      settings.speak('Thank you for rating. Returning home.');
    }

    ride.resetBooking();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false);
  }

  Color _sentColor(String label) {
    switch (label) {
      case 'positive':
        return AppColors.success;
      case 'negative':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>().activeRide;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 20),
              const Text('Trip Completed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Total fare ${Formatters.money(ride?.fare ?? 0)} · ${Formatters.distance(ride?.distanceKm ?? 0)}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              if (ride?.driver != null)
                Text('How was your trip with ${ride!.driver!.name}?',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    iconSize: 40,
                    onPressed: () {
                      setState(() => _rating = i + 1);
                      context.read<SettingsProvider>().speak('${i + 1} stars');
                    },
                    icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppColors.warning),
                  );
                }),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Leave a review (AI will analyze it)',
                controller: _review,
                hint: 'e.g. Friendly driver, clean car, smooth ride',
              ),
              if (_sentiment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _sentColor(_sentiment!.label).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome_rounded, size: 16, color: _sentColor(_sentiment!.label)),
                      const SizedBox(width: 6),
                      Text(
                        'AI sentiment: ${_sentiment!.label} (${_sentiment!.score})',
                        style: TextStyle(
                            color: _sentColor(_sentiment!.label), fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ),
                ),
              const Spacer(),
              PrimaryButton(label: 'Submit & Done', loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
