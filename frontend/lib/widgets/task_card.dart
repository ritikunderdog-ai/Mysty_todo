import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/models/task.dart';
import 'package:mysty/widgets/priority_badge.dart';

/// Cyberpunk-styled task card with glassmorphism and neon borders.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final borderColor = task.isCompleted
        ? CyberpunkColors.primary.withValues(alpha: 0.3)
        : isOverdue
            ? CyberpunkColors.error.withValues(alpha: 0.5)
            : CyberpunkColors.cardBorder;

    return Dismissible(
      key: ValueKey(task.id),
      direction: task.isCompleted
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      background: _buildSwipeBackground(
        color: CyberpunkColors.primary,
        icon: Icons.check_circle_outline,
        label: 'COMPLETE',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: CyberpunkColors.error,
        icon: Icons.delete_outline,
        label: 'DELETE',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && !task.isCompleted) {
          onComplete?.call();
          return false; // Don't actually dismiss
        } else if (direction == DismissDirection.endToStart) {
          return await _confirmDelete(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? CyberpunkColors.surface.withValues(alpha: 0.5)
                : CyberpunkColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: task.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: task.isCompleted ? null : onComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? CyberpunkColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? CyberpunkColors.primary
                          : CyberpunkColors.textSecondary,
                      width: 2,
                    ),
                    boxShadow: task.isCompleted
                        ? [
                            BoxShadow(
                              color: CyberpunkColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: CyberpunkColors.primary,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? CyberpunkColors.textSecondary
                                  : CyberpunkColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: CyberpunkColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: task.priority, compact: true),
                      ],
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(
                          color: CyberpunkColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (task.category != null) ...[
                          _buildTag(
                            task.category!.name,
                            _parseColor(task.category!.color),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (task.dueDate != null)
                          _buildDueDate(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDueDate() {
    final days = task.daysRemaining;
    Color dateColor;
    String dateText;

    if (task.isCompleted) {
      dateColor = CyberpunkColors.textSecondary;
      dateText = 'Done';
    } else if (days == null) {
      return const SizedBox.shrink();
    } else if (days < 0) {
      dateColor = CyberpunkColors.error;
      dateText = '${-days}d overdue';
    } else if (days == 0) {
      dateColor = CyberpunkColors.accent;
      dateText = 'Due today';
    } else if (days <= 3) {
      dateColor = CyberpunkColors.accent;
      dateText = '${days}d left';
    } else {
      dateColor = CyberpunkColors.textSecondary;
      dateText = '${days}d left';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, color: dateColor, size: 12),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: TextStyle(color: dateColor, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required AlignmentGeometry alignment,
  }) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return CyberpunkColors.primary;
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: CyberpunkColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: CyberpunkColors.error, width: 1),
            ),
            title: const Text(
              'DELETE TASK?',
              style: TextStyle(
                color: CyberpunkColors.error,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            content: Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: CyberpunkColors.textSecondary,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL', style: TextStyle(color: CyberpunkColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('DELETE', style: TextStyle(color: CyberpunkColors.error)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
