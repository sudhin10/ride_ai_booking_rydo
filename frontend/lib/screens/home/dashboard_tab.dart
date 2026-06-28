import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../components/map_view.dart';
import '../../components/place_search_field.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final auth = context.watch<AuthProvider>();
    final center = ride.currentLatLng ?? LocationFallback.center;

    final markers = <Marker>[
      MapView.pin(center, icon: Icons.my_location_rounded, color: AppColors.accent),
      ...ride.nearbyDrivers.map((d) =>
          MapView.pin(LatLng(d.lat, d.lng), icon: Icons.local_taxi_rounded, color: AppColors.primary)),
    ];

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 180),
        child: FloatingActionButton.extended(
          heroTag: 'ai-fab',
          backgroundColor: AppColors.primary,
          onPressed: () {
            context.read<SettingsProvider>().speak('Opening AI assistant.');
            Navigator.pushNamed(context, Routes.aiAssistant);
          },
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('AI Assistant'),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(
              controller: _mapController,
              center: center,
              markers: markers,
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _circleAction(
                    icon: Icons.menu_rounded,
                    onTap: () => Navigator.pushNamed(context, Routes.settings),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
                    ),
                    child: Row(children: [
                      const Icon(Icons.waving_hand_rounded, size: 18, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text('Hi, ${auth.user?.name.split(' ').first ?? 'there'}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const Spacer(),
                  _circleAction(
                    icon: Icons.person_rounded,
                    onTap: () => Navigator.pushNamed(context, Routes.profile),
                  ),
                ],
              ),
            ),
          ),
          // Bottom "where to" sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Where are you going?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  PlaceSearchField(
                    hint: 'Enter destination',
                    icon: Icons.search_rounded,
                    onTap: () {
                      context.read<SettingsProvider>().speak('Select your destination.');
                      Navigator.pushNamed(context, Routes.selectDestination);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _quickChip(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          subtitle: auth.user?.homeAddress.isNotEmpty == true
                              ? auth.user!.homeAddress
                              : 'Set home',
                          onTap: () => Navigator.pushNamed(context, Routes.selectDestination),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickChip(
                          icon: Icons.work_rounded,
                          label: 'Work',
                          subtitle: auth.user?.workAddress.isNotEmpty == true
                              ? auth.user!.workAddress
                              : 'Set work',
                          onTap: () => Navigator.pushNamed(context, Routes.selectDestination),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _quickChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationFallback {
  static const center = LatLng(37.7749, -122.4194);
}
