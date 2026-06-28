import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/transaction_tile.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';

class WalletScreen extends StatefulWidget {
  final bool embedded;
  const WalletScreen({super.key, this.embedded = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadTransactions();
      context.read<SettingsProvider>().speak('Wallet.');
    });
  }

  Future<void> _topUp() async {
    final amounts = [10.0, 20.0, 50.0, 100.0];
    final chosen = await showModalBottomSheet<double>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Top up wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ...amounts.map((a) => ListTile(
                  title: Text(Formatters.money(a)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(context, a),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    try {
      await ApiClient.instance.post(ApiEndpoints.walletTopup, body: {'amount': chosen});
      if (!mounted) return;
      await context.read<AuthProvider>().refreshUser();
      await context.read<PaymentProvider>().loadTransactions();
      if (!mounted) return;
      context.read<SettingsProvider>().speak('Wallet topped up by ${Formatters.money(chosen)}.');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final payment = context.watch<PaymentProvider>();
    final balance = auth.user?.walletBalance ?? 0;

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wallet balance', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(Formatters.money(balance),
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _topUp,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Top up'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.paymentMethods),
                    icon: const Icon(Icons.credit_card_rounded, color: Colors.white),
                    label: const Text('Cards', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        minimumSize: const Size.fromHeight(48)),
                  ),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Recent transactions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (payment.transactions.isEmpty)
          const SizedBox(
            height: 220,
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No transactions yet',
              message: 'Your ride payments and top-ups will appear here.',
            ),
          )
        else
          ...payment.transactions.map((t) => TransactionTile(txn: t)),
      ],
    );

    if (widget.embedded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallet'), automaticallyImplyLeading: false),
        body: body,
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Wallet')), body: body);
  }
}
