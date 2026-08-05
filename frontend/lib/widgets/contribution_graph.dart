import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/models/user_stats.dart';

/// GitHub-style contribution heatmap graph with cyberpunk neon colors.
class ContributionGraphWidget extends StatelessWidget {
  final ContributionGraph? data;
  final double cellSize;
  final double cellSpacing;

  const ContributionGraphWidget({
    super.key,
    required this.data,
    this.cellSize = 14,
    this.cellSpacing = 3,
  });

  Color _intensityColor(int intensity) {
    switch (intensity) {
      case 0:
        return CyberpunkColors.contribNone;
      case 1:
        return CyberpunkColors.contribLow;
      case 2:
        return CyberpunkColors.contribMedium;
      case 3:
        return CyberpunkColors.contribHigh;
      case 4:
        return CyberpunkColors.contribMax;
      default:
        return CyberpunkColors.contribNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: neonGlowDecoration(),
        child: const Center(
          child: Text(
            'NO DATA YET',
            style: TextStyle(
              color: CyberpunkColors.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
      );
    }

    // Organize days into weeks (7 rows × N columns)
    final days = data!.days;
    final totalWeeks = (days.length / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: neonGlowDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CONTRIBUTIONS',
                style: TextStyle(
                  color: CyberpunkColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${data!.activeDays} active days',
                style: const TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${data!.totalTasks} tasks',
                style: const TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${data!.totalXp} XP earned',
                style: const TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels
              Column(
                children: [
                  for (final day in ['M', '', 'W', '', 'F', '', 'S'])
                    SizedBox(
                      height: cellSize + cellSpacing,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: CyberpunkColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),

              // Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Most recent on the right
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int week = 0; week < totalWeeks; week++)
                        Column(
                          children: [
                            for (int day = 0; day < 7; day++)
                              _buildCell(week * 7 + day, days),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Less',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 4),
              for (int i = 0; i <= 4; i++) ...[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _intensityColor(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Text(
                'More',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int index, List<ContributionDay> days) {
    if (index >= days.length) {
      return SizedBox(
        width: cellSize + cellSpacing,
        height: cellSize + cellSpacing,
      );
    }

    final day = days[index];
    final color = _intensityColor(day.intensity);

    return Tooltip(
      message: '${day.date}: ${day.tasksCompleted} tasks, ${day.xpEarned} XP',
      child: Container(
        width: cellSize,
        height: cellSize,
        margin: EdgeInsets.all(cellSpacing / 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          boxShadow: day.intensity > 2
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
