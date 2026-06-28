import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/place_model.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/geocoding_service.dart';

class SelectDestinationScreen extends StatefulWidget {
  const SelectDestinationScreen({super.key});

  @override
  State<SelectDestinationScreen> createState() => _SelectDestinationScreenState();
}

class _SelectDestinationScreenState extends State<SelectDestinationScreen> {
  final _geo = GeocodingService();
  final _search = TextEditingController();
  List<Place> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _results = _geo.suggestions;
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<SettingsProvider>().speak('Search or choose your destination from the list.'));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String q) async {
    setState(() => _loading = true);
    final r = await _geo.search(q);
    if (!mounted) return;
    setState(() {
      _results = r;
      _loading = false;
    });
  }

  void _select(Place place) {
    final ride = context.read<RideProvider>();
    final origin = ride.currentLatLng;
    // Pickup defaults to current location.
    ride.setPickup(Place(
      address: 'Current location',
      lat: origin?.latitude ?? place.lat,
      lng: origin?.longitude ?? place.lng,
    ));
    ride.setDropoff(place);
    context.read<SettingsProvider>().speak('Destination set to ${place.address}.');
    Navigator.pushNamed(context, Routes.chooseRide);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose destination')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _search,
                onChanged: (v) => _runSearch(v),
                decoration: InputDecoration(
                  hintText: 'Search for a place or address',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Suggestions',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = _results[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.accentSoft,
                        child: Icon(Icons.place_rounded, color: AppColors.accent),
                      ),
                      title: Text(p.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _select(p),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
