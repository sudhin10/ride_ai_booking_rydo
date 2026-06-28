import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Accessibility'),
          _card(
            context,
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.voiceEnabled,
                  activeColor: AppColors.accent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Voice navigation',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                      'Reads screens and ride updates aloud for visually impaired riders.'),
                  secondary: const Icon(Icons.record_voice_over_rounded, color: AppColors.accent),
                  onChanged: (v) => settings.setVoiceEnabled(v),
                ),
                if (settings.voiceEnabled) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.speed_rounded, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Speech rate'),
                        Expanded(
                          child: Slider(
                            value: settings.speechRate,
                            min: 0.2,
                            max: 1.0,
                            divisions: 8,
                            activeColor: AppColors.accent,
                            label: '${(settings.speechRate * 100).round()}%',
                            onChanged: (v) => settings.setSpeechRate(v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => TtsService.instance.announce(
                          'This is a preview of the voice navigation speech rate.',
                          interrupt: true,
                          force: true),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Test voice'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Appearance'),
          _card(
            context,
            child: SwitchListTile(
              value: settings.themeMode == ThemeMode.dark,
              activeColor: AppColors.accent,
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Switch between light and dark themes.'),
              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.accent),
              onChanged: (v) => settings.toggleTheme(v),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('About'),
          _card(
            context,
            child: const Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline_rounded, color: AppColors.accent),
                  title: Text('Rydo'),
                  subtitle: Text('Version 1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 13)),
      );

  Widget _card(BuildContext context, {required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}
