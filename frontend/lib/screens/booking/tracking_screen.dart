import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../components/driver_card.dart';
import '../../components/map_view.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

/// Live ride tracking. Subscribes to Socket.IO and animates the driver marker
/// as the backend streams positions (driver -> pickup -> destination).
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _mapController = MapController();
  String _lastSpokenPhase = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTracking());
  }

  void _startTracking() {
    final ride = context.read<RideProvider>();
    final settings = context.read<SettingsProvider>();
    final driver = ride.activeRide?.driver;
    settings.speak(
        'Tracking your ride. ${driver?.name ?? 'Your driver'} is on the way in a ${driver?.carColor ?? ''} ${driver?.carModel ?? 'car'}.');

    ride.startTracking(
      onLocation: (lat, lng, eta, phase) {
        try {
          _mapController.move(LatLng(lat, lng), 15);
        } catch (_) {}
        if (phase != _lastSpokenPhase) {
          _lastSpokenPhase = phase;
          if (phase == 'arriving') {
            settings.speak('Your driver is arriving. Estimated $eta minutes.');
          } else if (phase == 'in_progress') {
            settings.speak('You are on the way to your destination. Estimated $eta minutes.');
          }
        }
      },
      onStatus: (status) {
        if (status == 'arrived_destination') {
          settings.speak('You have arrived at your destination.');
          _finish();
        }
      },
    );
  }

  Future<void> _finish() async {
    final ride = context.read<RideProvider>();
    await ride.completeRide();
    ride.stopTracking();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.rideComplete);
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel ride?'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, cancel', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<RideProvider>().cancelRide();
      if (!mounted) return;
      context.read<SettingsProvider>().speak('Ride cancelled.');
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final active = ride.activeRide;
    final pickup = active?.pickup;
    final dropoff = active?.dropoff;
    final driverPos = ride.driverLatLng;

    final center = driverPos ??
        (pickup != null ? LatLng(pickup.lat, pickup.lng) : const LatLng(37.7749, -122.4194));

    final markers = <Marker>[
      if (pickup != null)
        MapView.pin(LatLng(pickup.lat, pickup.lng),
            icon: Icons.trip_origin_rounded, color: AppColors.success),
      if (dropoff != null)
        MapView.pin(LatLng(dropoff.lat, dropoff.lng),
            icon: Icons.location_on_rounded, color: AppColors.danger),
      if (driverPos != null)
        MapView.pin(driverPos, icon: Icons.local_taxi_rounded, color: AppColors.primary),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(
              controller: _mapController,
              center: center,
              zoom: 14,
              markers: markers,
              routePoints: active?.route ?? const [],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12)],
                  ),
                  child: Text(
                    ride.etaMinutes > 0
                        ? '${active?.statusLabel ?? 'On the way'} · ETA ${ride.etaMinutes} min'
                        : (active?.statusLabel ?? 'Connecting...'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton.small(
                  heroTag: 'sos',
                  backgroundColor: AppColors.danger,
                  onPressed: _openSafety,
                  child: const Text('SOS',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (active?.driver != null)
                    DriverCard(
                      driver: active!.driver!,
                      onCall: () => _toast('Calling ${active.driver!.name}...'),
                      onMessage: () => _toast('Messaging ${active.driver!.name}...'),
                    ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: PrimaryButton(label: 'Cancel', outlined: true, onPressed: _cancel),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'I have arrived',
                        onPressed: _finish,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tripSummary() {
    final r = context.read<RideProvider>().activeRide;
    if (r == null) return 'Rydo trip';
    final d = r.driver;
    return 'Rydo trip in progress\n'
        'Driver: ${d?.name ?? 'Assigned'} (${d?.carColor ?? ''} ${d?.carModel ?? ''}, ${d?.carPlate ?? ''})\n'
        'From: ${r.pickup.address}\n'
        'To: ${r.dropoff.address}\n'
        'Fare: \$${r.fare.toStringAsFixed(2)}';
  }

  void _openSafety() {
    context.read<SettingsProvider>().speak(
        'Safety menu. Share your trip, or contact emergency.', interrupt: true);
    final emergency = context.read<AuthProvider>().user?.emergencyContact ?? '';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [
                Icon(Icons.shield_rounded, color: AppColors.danger),
                SizedBox(width: 10),
                Text('Safety', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded, color: AppColors.accent),
              title: const Text('Share trip details'),
              subtitle: const Text('Copy live trip info to send to someone'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: _tripSummary()));
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                _toast('Trip details copied — paste to share.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency_rounded, color: AppColors.warning),
              title: Text(emergency.isEmpty ? 'Add an emergency contact' : 'Alert $emergency'),
              subtitle: Text(emergency.isEmpty
                  ? 'Set one in Profile to enable quick alerts'
                  : 'Copies trip + contact for a quick call/text'),
              onTap: () async {
                if (emergency.isEmpty) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  return;
                }
                await Clipboard.setData(
                    ClipboardData(text: 'Emergency: $emergency\n${_tripSummary()}'));
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                _toast('Emergency info copied for $emergency.');
              },
            ),
            const ListTile(
              leading: Icon(Icons.local_police_rounded, color: AppColors.danger),
              title: Text('Call local emergency services'),
              subtitle: Text('Dial your local emergency number (e.g. 911 / 112)'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    context.read<SettingsProvider>().speak(msg);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    context.read<RideProvider>().stopTracking();
    super.dispose();
  }
}
