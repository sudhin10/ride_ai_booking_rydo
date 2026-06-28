import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/card_model.dart';

class PaymentMethodTile extends StatelessWidget {
  final CardModel? card;
  final String? cashLabel;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PaymentMethodTile({
    super.key,
    this.card,
    this.cashLabel,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  IconData get _brandIcon {
    if (cashLabel != null) return Icons.payments_rounded;
    switch (card?.brand) {
      case 'visa':
      case 'mastercard':
      case 'amex':
        return Icons.credit_card_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = cashLabel ?? card!.masked;
    final subtitle = cashLabel != null ? 'Pay with cash' : '${card!.holderName} · ${card!.expiry}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(_brandIcon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (card?.isDefault ?? false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Default',
                    style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
              ),
            if (selected && cashLabel == null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded, color: AppColors.accent),
              ),
            if (onDelete != null)
              IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                  onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
