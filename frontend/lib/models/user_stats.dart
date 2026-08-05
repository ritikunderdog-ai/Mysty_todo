// User stats and contribution graph data models.

class UserStats {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final String levelTitle;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final String? lastActiveDate;

  UserStats({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.levelTitle,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    this.lastActiveDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXp: json['total_xp'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      level: json['level'],
      levelTitle: json['level_title'],
      xpForCurrentLevel: json['xp_for_current_level'],
      xpForNextLevel: json['xp_for_next_level'],
      lastActiveDate: json['last_active_date'],
    );
  }

  /// Progress ratio for XP bar (0.0 - 1.0)
  double get levelProgress {
    if (xpForNextLevel == 0) return 1.0;
    return xpForCurrentLevel / xpForNextLevel;
  }
}

class ContributionDay {
  final String date;
  final int tasksCompleted;
  final int xpEarned;
  final int intensity;

  ContributionDay({
    required this.date,
    required this.tasksCompleted,
    required this.xpEarned,
    required this.intensity,
  });

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: json['date'],
      tasksCompleted: json['tasks_completed'],
      xpEarned: json['xp_earned'],
      intensity: json['intensity'],
    );
  }
}

class ContributionGraph {
  final List<ContributionDay> days;
  final int totalTasks;
  final int totalXp;
  final int activeDays;

  ContributionGraph({
    required this.days,
    required this.totalTasks,
    required this.totalXp,
    required this.activeDays,
  });

  factory ContributionGraph.fromJson(Map<String, dynamic> json) {
    return ContributionGraph(
      days: (json['days'] as List)
          .map((d) => ContributionDay.fromJson(d))
          .toList(),
      totalTasks: json['total_tasks'],
      totalXp: json['total_xp'],
      activeDays: json['active_days'],
    );
  }
}
