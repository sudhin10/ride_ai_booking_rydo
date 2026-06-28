import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<SettingsProvider>().speak('Password changed successfully.'));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
              ),
              const SizedBox(height: 28),
              const Text('Password Changed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('Your password has been updated successfully.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Sign In',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, Routes.signIn, (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
