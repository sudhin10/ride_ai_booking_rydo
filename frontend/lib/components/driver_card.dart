import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/driver_model.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  const DriverCard({super.key, required this.driver, this.onCall, this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentSoft,
            backgroundImage: driver.avatarUrl.isNotEmpty ? NetworkImage(driver.avatarUrl) : null,
            child: driver.avatarUrl.isEmpty
                ? Text(driver.name.isNotEmpty ? driver.name[0] : '?',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text('${driver.carColor} ${driver.carModel} · ${driver.carPlate}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${driver.rating} · ${driver.totalTrips} trips',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),
          _circleBtn(Icons.message_rounded, onMessage),
          const SizedBox(width: 8),
          _circleBtn(Icons.call_rounded, onCall, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap, {Color color = AppColors.accent}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
