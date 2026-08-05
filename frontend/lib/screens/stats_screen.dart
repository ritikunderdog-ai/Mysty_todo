import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/providers/stats_provider.dart';
import 'package:mysty/widgets/xp_bar.dart';
import 'package:mysty/widgets/streak_counter.dart';
import 'package:mysty/widgets/contribution_graph.dart';

/// Stats screen displaying XP, streak, level, and contribution graph.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<StatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stats == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: CyberpunkColors.primary,
              ),
            );
          }

          final stats = provider.stats;
          if (stats == null) {
            return const Center(
              child: Text(
                'NO STATS AVAILABLE',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: CyberpunkColors.primary,
            backgroundColor: CyberpunkColors.surface,
            onRefresh: () => provider.refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'STATS',
                    style: TextStyle(
                      color: CyberpunkColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // XP Bar (full)
                  XpBar(
                    currentXp: stats.xpForCurrentLevel,
                    xpForNext: stats.xpForNextLevel,
                    level: stats.level,
                    levelTitle: stats.levelTitle,
                  ),
                  const SizedBox(height: 16),

                  // Streak and total XP row
                  Row(
                    children: [
                      Expanded(
                        child: StreakCounter(
                          streak: stats.currentStreak,
                          longestStreak: stats.longestStreak,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: neonGlowDecoration(
                            glowColor: CyberpunkColors.secondary,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: CyberpunkColors.secondary,
                                size: 40,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${stats.totalXp}',
                                style: const TextStyle(
                                  color: CyberpunkColors.secondary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'TOTAL XP',
                                style: TextStyle(
                                  color: CyberpunkColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contribution graph
                  ContributionGraphWidget(
                    data: provider.contributions,
                  ),
                  const SizedBox(height: 20),

                  // XP Rules card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: neonGlowDecoration(
                      glowColor: CyberpunkColors.accent,
                      blurRadius: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'XP RULES',
                          style: TextStyle(
                            color: CyberpunkColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRule('LOW priority', '+10 XP', CyberpunkColors.priorityLow),
                        _buildRule('MEDIUM priority', '+25 XP', CyberpunkColors.priorityMedium),
                        _buildRule('HIGH priority', '+50 XP', CyberpunkColors.priorityHigh),
                        _buildRule('Early completion', '+15 XP', CyberpunkColors.primary),
                        _buildRule('Streak bonus/day', '+5 XP (max +50)', CyberpunkColors.streakFire),
                        const Divider(color: CyberpunkColors.cardBorder, height: 20),
                        _buildRule('Break streak', '-20% total XP', CyberpunkColors.error),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRule(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CyberpunkColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
