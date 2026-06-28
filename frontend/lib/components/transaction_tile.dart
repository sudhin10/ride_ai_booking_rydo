import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel txn;
  const TransactionTile({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final credit = txn.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: (credit ? AppColors.success : AppColors.accent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(credit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: credit ? AppColors.success : AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description.isEmpty ? _typeLabel(txn.type) : txn.description,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(Formatters.date(txn.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${credit ? '+' : '-'}${Formatters.money(txn.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: credit ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'topup':
        return 'Wallet top-up';
      case 'refund':
        return 'Refund';
      default:
        return 'Ride payment';
    }
  }
}
