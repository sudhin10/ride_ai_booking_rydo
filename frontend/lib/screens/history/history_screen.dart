import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/ride_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/ride_service.dart';
import '../../widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _rides = RideService();
  late Future<List<RideModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _rides.myRides();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SettingsProvider>().speak('Your trips.'));
  }

  Future<void> _refresh() async {
    setState(() => _future = _rides.myRides());
    await _future;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<RideModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rides = snap.data ?? [];
          if (rides.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 120),
              EmptyState(
                icon: Icons.history_rounded,
                title: 'No trips yet',
                message: 'Book your first ride and it will show up here.',
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (_, i) {
              final r = rides[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.trip_origin_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.pickup.address, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const Padding(
                      padding: EdgeInsets.only(left: 7),
                      child: SizedBox(height: 14, child: VerticalDivider(width: 2)),
                    ),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.dropoff.address, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Formatters.shortDate(r.createdAt),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(r.status).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(r.statusLabel,
                              style: TextStyle(
                                  color: _statusColor(r.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Text(Formatters.money(r.fare),
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        automaticallyImplyLeading: !widget.embedded,
      ),
      body: body,
    );
  }
}
