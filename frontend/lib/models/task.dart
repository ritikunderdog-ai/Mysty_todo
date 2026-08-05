/// Task data model matching the backend Task schema.
enum Priority { LOW, MEDIUM, HIGH }

class CategoryBrief {
  final int id;
  final String name;
  final String color;

  CategoryBrief({required this.id, required this.name, required this.color});

  factory CategoryBrief.fromJson(Map<String, dynamic> json) {
    return CategoryBrief(
      id: json['id'],
      name: json['name'],
      color: json['color'],
    );
  }
}

class Task {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final Priority priority;
  final String? dueDate;
  final int? categoryId;
  final CategoryBrief? category;
  final String createdAt;
  final String? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    this.categoryId,
    this.category,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'],
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.MEDIUM,
      ),
      dueDate: json['due_date'],
      categoryId: json['category_id'],
      category: json['category'] != null
          ? CategoryBrief.fromJson(json['category'])
          : null,
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
    );
  }

  /// Check if the task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.parse(dueDate!).isBefore(DateTime.now());
  }

  /// Days remaining until due date (negative if overdue)
  int? get daysRemaining {
    if (dueDate == null) return null;
    return DateTime.parse(dueDate!)
        .difference(DateTime.now())
        .inDays;
  }
}

/// Response when completing a task — includes XP breakdown
class TaskCompleteResult {
  final Task task;
  final int xpEarned;
  final int streakBonus;
  final int totalXp;
  final int currentStreak;
  final int level;
  final String levelTitle;

  TaskCompleteResult({
    required this.task,
    required this.xpEarned,
    required this.streakBonus,
    required this.totalXp,
    required this.currentStreak,
    required this.level,
    required this.levelTitle,
  });

  factory TaskCompleteResult.fromJson(Map<String, dynamic> json) {
    return TaskCompleteResult(
      task: Task.fromJson(json['task']),
      xpEarned: json['xp_earned'],
      streakBonus: json['streak_bonus'],
      totalXp: json['total_xp'],
      currentStreak: json['current_streak'],
      level: json['level'],
      levelTitle: json['level_title'],
    );
  }
}
