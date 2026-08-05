import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';

/// Animated streak counter with fire icon and pulsing glow.
class StreakCounter extends StatefulWidget {
  final int streak;
  final int longestStreak;
  final bool compact;

  const StreakCounter({
    super.key,
    required this.streak,
    this.longestStreak = 0,
    this.compact = false,
  });

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.streak > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.streak == 0 && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streak > 0;
    final fireColor =
        isActive ? CyberpunkColors.streakFire : CyberpunkColors.textSecondary;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(widget.compact ? 8 : 16),
          decoration: neonGlowDecoration(
            glowColor: isActive
                ? CyberpunkColors.streakFire
                : CyberpunkColors.cardBorder,
            blurRadius: isActive ? 12 * _pulseAnimation.value : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fire icon with glow
              Transform.scale(
                scale: isActive ? _pulseAnimation.value : 1.0,
                child: Icon(
                  isActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                  color: fireColor,
                  size: widget.compact ? 28 : 40,
                  shadows: isActive
                      ? [
                          Shadow(
                            color: fireColor.withValues(alpha: 0.6),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              // Streak count
              Text(
                '${widget.streak}',
                style: TextStyle(
                  color: fireColor,
                  fontSize: widget.compact ? 20 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'STREAK',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: widget.compact ? 8 : 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              if (!widget.compact && widget.longestStreak > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'BEST: ${widget.longestStreak}',
                  style: TextStyle(
                    color: CyberpunkColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
