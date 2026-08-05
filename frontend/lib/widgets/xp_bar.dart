import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';

/// Animated XP progress bar with neon glow.
class XpBar extends StatelessWidget {
  final int currentXp;
  final int xpForNext;
  final int level;
  final String levelTitle;
  final bool compact;

  const XpBar({
    super.key,
    required this.currentXp,
    required this.xpForNext,
    required this.level,
    required this.levelTitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNext > 0 ? (currentXp / xpForNext).clamp(0.0, 1.0) : 1.0;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 16),
      decoration: neonGlowDecoration(
        glowColor: CyberpunkColors.primary,
        blurRadius: compact ? 6 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CyberpunkColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: CyberpunkColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'LV.$level',
                      style: TextStyle(
                        color: CyberpunkColors.primary,
                        fontSize: compact ? 10 : 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    levelTitle.toUpperCase(),
                    style: TextStyle(
                      color: CyberpunkColors.secondary,
                      fontSize: compact ? 10 : 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXp / $xpForNext XP',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: compact ? 10 : 12,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  height: compact ? 6 : 10,
                  decoration: BoxDecoration(
                    color: CyberpunkColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: compact ? 6 : 10,
                  width: MediaQuery.of(context).size.width * progress * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [CyberpunkColors.primary, CyberpunkColors.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkColors.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
