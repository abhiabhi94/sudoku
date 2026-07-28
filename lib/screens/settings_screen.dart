import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../ui/colors.dart';
import 'credits_screen.dart';

/// Settings: music (on/off + volume), vibration, language, and music credits.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.musicOn,
                  onChanged: notifier.setMusic,
                  secondary: const Text('🎵', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.settingsMusic),
                  subtitle: Text(l10n.settingsMusicSubtitle),
                ),
                if (settings.musicOn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up_rounded, color: textMuted),
                        Expanded(
                          child: Slider(
                            value: settings.musicVolume,
                            onChanged: notifier.setMusicVolume,
                          ),
                        ),
                        Text('${(settings.musicVolume * 100).round()}%',
                            style: const TextStyle(color: textMuted)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingCard(
            child: SwitchListTile(
              value: settings.hapticsOn,
              onChanged: notifier.setHaptics,
              secondary: const Text('📳', style: TextStyle(fontSize: 24)),
              title: Text(l10n.settingsVibration),
              subtitle: Text(l10n.settingsVibrationSubtitle),
            ),
          ),
          const SizedBox(height: 16),
          _SettingCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌐', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(l10n.settingsLanguage,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                      ButtonSegment(value: 'hi', label: Text(l10n.languageHindi)),
                    ],
                    selected: {settings.languageCode},
                    onSelectionChanged: (sel) => notifier.setLanguage(sel.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingCard(
            child: ListTile(
              leading: const Text('🎼', style: TextStyle(fontSize: 24)),
              title: Text(l10n.settingsCredits),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CreditsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Uses Material (not a decorated Container) so ListTile/SwitchListTile can
    // paint their background and ink on a Material ancestor.
    return Material(
      color: surfaceWhite,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
