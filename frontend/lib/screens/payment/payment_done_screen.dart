import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

class PaymentDoneScreen extends StatelessWidget {
  const PaymentDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SettingsProvider>().speak('Payment successful.'));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 24),
              const Text('Payment Done',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your payment was processed successfully.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              PrimaryButton(
                label: 'Done',
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
