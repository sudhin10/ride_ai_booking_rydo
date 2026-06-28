import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../components/map_view.dart';
import '../../components/ride_type_card.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../providers/payment_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

class ChooseRideScreen extends StatefulWidget {
  const ChooseRideScreen({super.key});

  @override
  State<ChooseRideScreen> createState() => _ChooseRideScreenState();
}

class _ChooseRideScreenState extends State<ChooseRideScreen> {
  bool _confirming = false;
  final _ai = AiService();
  FarePrediction? _prediction;
  bool _predLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ride = context.read<RideProvider>();
      await context.read<PaymentProvider>().loadCards();
      final ok = await ride.fetchEstimates();
      if (!mounted) return;
      if (ok && ride.selectedFare != null) {
        context.read<SettingsProvider>().speak(
            'Choose your ride. ${ride.selectedFare!.label} is ${Formatters.money(ride.selectedFare!.fare)}.');
        _fetchPrediction();
      }
    });
  }

  Future<void> _fetchPrediction() async {
    final ride = context.read<RideProvider>();
    final fare = ride.selectedFare;
    if (fare == null) return;
    setState(() => _predLoading = true);
    try {
      // Higher demand assumption during rush hours -> drives the surge model.
      final hour = DateTime.now().hour;
      final demand = (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 20) ? 0.8 : 0.45;
      final p = await _ai.predictFare(
        distanceKm: fare.distanceKm,
        rideType: ride.selectedRideType,
        demandLevel: demand,
      );
      if (mounted) setState(() => _prediction = p);
    } catch (_) {
      // prediction is best-effort; ignore failures
    } finally {
      if (mounted) setState(() => _predLoading = false);
    }
  }

  Widget _predictionBanner() {
    if (_predLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('AI estimating demand…', style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    final p = _prediction;
    if (p == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI prediction: ~${p.predictedEtaMin} min · ${Formatters.money(p.predictedFare)}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                p.isSurging
                    ? 'Higher demand right now (${p.surgeMultiplier}x surge)'
                    : 'Normal demand · ${p.source == 'ml-model' ? 'ML model' : 'estimate'}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    final ride = context.read<RideProvider>();
    final result = await ride.confirmRide();
    if (!mounted) return;
    setState(() => _confirming = false);
    if (result != null) {
      context.read<SettingsProvider>().speak(
          'Ride confirmed. Your driver ${result.driver?.name ?? ''} is on the way.');
      Navigator.pushReplacementNamed(context, Routes.tracking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ride.error ?? 'Could not book ride'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final payment = context.watch<PaymentProvider>();
    final pickup = ride.pickup;
    final dropoff = ride.dropoff;

    final routePoints = (pickup != null && dropoff != null)
        ? [LatLng(pickup.lat, pickup.lng), LatLng(dropoff.lat, dropoff.lng)]
        : <LatLng>[];
    final center = dropoff != null
        ? LatLng((pickup!.lat + dropoff.lat) / 2, (pickup.lng + dropoff.lng) / 2)
        : (ride.currentLatLng ?? const LatLng(37.7749, -122.4194));

    final markers = <Marker>[
      if (pickup != null)
        MapView.pin(LatLng(pickup.lat, pickup.lng), icon: Icons.trip_origin_rounded, color: AppColors.success),
      if (dropoff != null)
        MapView.pin(LatLng(dropoff.lat, dropoff.lng), icon: Icons.location_on_rounded, color: AppColors.danger),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a ride')),
      body: Column(
        children: [
          SizedBox(
            height: 240,
            child: MapView(
              center: center,
              zoom: 12.5,
              markers: markers,
              routePoints: routePoints,
              interactive: false,
            ),
          ),
          Expanded(
            child: ride.loading && ride.fareOptions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (dropoff != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(children: [
                            _routeRow(Icons.trip_origin_rounded, AppColors.success, pickup?.address ?? 'Pickup'),
                            const Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: SizedBox(height: 18, child: VerticalDivider(width: 2)),
                            ),
                            _routeRow(Icons.location_on_rounded, AppColors.danger, dropoff.address),
                          ]),
                        ),
                      const SizedBox(height: 16),
                      ...ride.fareOptions.map((o) => RideTypeCard(
                            option: o,
                            selected: ride.selectedRideType == o.rideType,
                            onTap: () {
                              ride.setRideType(o.rideType);
                              context.read<SettingsProvider>().speak(
                                  '${o.label}, ${Formatters.money(o.fare)}, ${o.durationMin} minutes.');
                              _fetchPrediction();
                            },
                          )),
                      _predictionBanner(),
                    ],
                  ),
          ),
          // Payment + confirm bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamed(context, Routes.paymentMethods, arguments: 'select'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      const Icon(Icons.credit_card_rounded, color: AppColors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ride.paymentMethod == 'cash'
                              ? 'Cash'
                              : payment.defaultCard?.masked ?? 'Add a payment method',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: ride.selectedFare != null
                      ? 'Confirm · ${Formatters.money(ride.selectedFare!.fare)}'
                      : 'Confirm ride',
                  loading: _confirming,
                  onPressed: ride.selectedFare == null ? null : _confirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeRow(IconData icon, Color color, String text) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}
