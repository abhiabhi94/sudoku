import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/level_progress.dart';
import '../providers/progress_provider.dart';
import '../ui/colors.dart';
import '../utils/format.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// The home screen: three tiers, ten levels each, with unlock + best-time state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final totalGames = notifier.totalGamesCompleted;

    final tiers = <_TierInfo>[
      _TierInfo(1, tierColors[0], l10n.tierBeginner, l10n.tierBeginnerTag),
      _TierInfo(2, tierColors[1], l10n.tierAdvanced, l10n.tierAdvancedTag),
      _TierInfo(3, tierColors[2], l10n.tierExpert, l10n.tierExpertTag),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appTitle,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w900, color: textInk),
                          ),
                          Text(
                            l10n.appTagline,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.settings_rounded),
                      tooltip: l10n.homeSettings,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: _GamesCompletedPill(count: totalGames, label: l10n.homeGamesCompleted),
              ),
            ),
            for (final tier in tiers)
              _TierSliver(
                tier: tier,
                progress: progress,
                isUnlocked: notifier.isUnlocked,
                l10n: l10n,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _TierInfo {
  const _TierInfo(this.tier, this.color, this.name, this.tag);
  final int tier;
  final Color color;
  final String name;
  final String tag;
}

class _GamesCompletedPill extends StatelessWidget {
  const _GamesCompletedPill({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900, color: primaryIndigo),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TierSliver extends StatelessWidget {
  const _TierSliver({
    required this.tier,
    required this.progress,
    required this.isUnlocked,
    required this.l10n,
  });

  final _TierInfo tier;
  final Map<int, LevelProgress> progress;
  final bool Function(int level) isUnlocked;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: tier.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(
                  tier.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800, color: textInk),
                ),
                const SizedBox(width: 8),
                Text('· ${tier.tag}', style: const TextStyle(color: textFaint)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List<Widget>.generate(10, (i) {
                final level = i + 1;
                final globalLevel = (tier.tier - 1) * 10 + level;
                final lp = progress[globalLevel] ?? LevelProgress.empty(globalLevel);
                return _LevelTile(
                  level: level,
                  globalLevel: globalLevel,
                  color: tier.color,
                  progress: lp,
                  unlocked: isUnlocked(globalLevel),
                  l10n: l10n,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.globalLevel,
    required this.color,
    required this.progress,
    required this.unlocked,
    required this.l10n,
  });

  final int level;
  final int globalLevel;
  final Color color;
  final LevelProgress progress;
  final bool unlocked;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cleared = progress.completed;
    return Semantics(
      label: l10n.levelNumber(level),
      button: unlocked,
      child: Material(
        color: unlocked ? surfaceWhite : backgroundSoft,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: unlocked
              ? () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GameScreen(globalLevel: globalLevel),
                    ),
                  )
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cleared ? color : gridLineSoft,
                width: cleared ? 2 : 1,
              ),
            ),
            child: Center(
              child: unlocked
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$level',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: cleared ? color : textInk,
                          ),
                        ),
                        if (cleared && progress.bestTimeMs != null)
                          Text(
                            formatDurationMs(progress.bestTimeMs!),
                            style: const TextStyle(fontSize: 10, color: textMuted),
                          )
                        else if (cleared)
                          Icon(Icons.check_rounded, size: 14, color: color),
                      ],
                    )
                  : Icon(Icons.lock_rounded, color: textFaint, size: 20),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
