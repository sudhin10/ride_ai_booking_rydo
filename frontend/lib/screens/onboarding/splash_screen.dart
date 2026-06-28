import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    await auth.bootstrap();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // First launch -> ask about voice navigation before anything else.
    if (settings.isFirstLaunch && !settings.voicePrompted) {
      Navigator.pushReplacementNamed(context, Routes.voicePrompt);
      return;
    }

    if (auth.status == AuthStatus.authenticated) {
      settings.speak('Welcome back to Rydo. Where would you like to go today?');
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _WhiteLogo(),
            SizedBox(height: 24),
            SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteLogo extends StatelessWidget {
  const _WhiteLogo();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        AppLogo(size: 88, showText: false),
        SizedBox(height: 16),
        Text('Rydo',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 2)),
        SizedBox(height: 6),
        Text('Book a ride in seconds', style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
