import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/models/task.dart';

/// Priority indicator badge with glow effect.
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  Color get _color {
    switch (priority) {
      case Priority.LOW:
        return CyberpunkColors.priorityLow;
      case Priority.MEDIUM:
        return CyberpunkColors.priorityMedium;
      case Priority.HIGH:
        return CyberpunkColors.priorityHigh;
    }
  }

  String get _label {
    switch (priority) {
      case Priority.LOW:
        return 'LOW';
      case Priority.MEDIUM:
        return 'MED';
      case Priority.HIGH:
        return 'HIGH';
    }
  }

  IconData get _icon {
    switch (priority) {
      case Priority.LOW:
        return Icons.arrow_downward_rounded;
      case Priority.MEDIUM:
        return Icons.remove_rounded;
      case Priority.HIGH:
        return Icons.arrow_upward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: compact ? 12 : 14),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
