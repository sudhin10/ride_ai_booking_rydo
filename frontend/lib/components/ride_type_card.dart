import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/fare_option_model.dart';

class RideTypeCard extends StatelessWidget {
  final FareOption option;
  final bool selected;
  final VoidCallback onTap;
  const RideTypeCard({super.key, required this.option, required this.selected, required this.onTap});

  IconData get _icon {
    switch (option.rideType) {
      case 'comfort':
        return Icons.airline_seat_recline_extra_rounded;
      case 'premium':
        return Icons.directions_car_filled_rounded;
      case 'van':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.local_taxi_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.label}, ${Formatters.money(option.fare)}, ${option.durationMin} minutes',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: selected ? Colors.white : AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('${option.description} · ${Formatters.duration(option.durationMin)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text(Formatters.money(option.fare),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
