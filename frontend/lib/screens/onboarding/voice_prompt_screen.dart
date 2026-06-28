import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';
import '../../widgets/primary_button.dart';

/// Shown once on first launch: asks whether to enable Voice Navigation (TTS)
/// guidance for visually impaired users. The prompt itself is spoken aloud so
/// that a user who cannot see the screen can still hear the choice.
class VoicePromptScreen extends StatefulWidget {
  const VoicePromptScreen({super.key});

  @override
  State<VoicePromptScreen> createState() => _VoicePromptScreenState();
}

class _VoicePromptScreenState extends State<VoicePromptScreen> {
  @override
  void initState() {
    super.initState();
    // Speak the prompt regardless of the current setting so it is heard.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TtsService.instance.init(enabled: true, rate: 0.5);
      await TtsService.instance.announce(
        'Welcome to Rydo. Would you like to enable voice navigation? '
        'This reads screens and ride updates aloud. '
        'Tap the top of the screen to enable, or the bottom to skip. '
        'You can change this anytime in Settings.',
        interrupt: true,
        force: true,
      );
    });
  }

  Future<void> _choose(bool enable) async {
    final settings = context.read<SettingsProvider>();
    await settings.setVoiceEnabled(enable, sync: false);
    await settings.completeFirstLaunch();
    if (!enable) await TtsService.instance.setEnabled(false);
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final next =
        auth.status == AuthStatus.authenticated ? Routes.home : Routes.signIn;
    Navigator.pushReplacementNamed(context, next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.record_voice_over_rounded,
                      size: 64, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Enable Voice Navigation?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text(
                'Designed for visually impaired riders, voice navigation reads '
                'screens and ride updates aloud as you use Rydo. '
                'You can turn it on or off anytime in Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Enable voice navigation',
                child: PrimaryButton(
                  label: 'Enable Voice Navigation',
                  icon: Icons.volume_up_rounded,
                  onPressed: () => _choose(true),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: 'Skip voice navigation for now',
                child: PrimaryButton(
                  label: 'Not now',
                  outlined: true,
                  onPressed: () => _choose(false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
