import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A read-only "where to?" style field used to open the destination picker.
class PlaceSearchField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const PlaceSearchField({
    super.key,
    required this.hint,
    required this.onTap,
    this.value,
    this.icon = Icons.search_rounded,
    this.iconColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
