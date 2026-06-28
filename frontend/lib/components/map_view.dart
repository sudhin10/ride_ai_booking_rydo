import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_colors.dart';

/// Reusable OpenStreetMap-backed map. No API key required.
class MapView extends StatelessWidget {
  final MapController? controller;
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<LatLng> routePoints;
  final bool interactive;

  const MapView({
    super.key,
    required this.center,
    this.controller,
    this.zoom = 14,
    this.markers = const [],
    this.routePoints = const [],
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rydo.app',
        ),
        if (routePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(points: routePoints, strokeWidth: 4.5, color: AppColors.accent),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  static Marker pin(LatLng point, {required IconData icon, Color color = AppColors.accent}) {
    return Marker(
      point: point,
      width: 44,
      height: 44,
      child: Icon(icon, color: color, size: 40),
    );
  }
}
