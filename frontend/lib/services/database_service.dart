import 'dart:math';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'package:mysty/models/isar_models.dart';
import 'package:mysty/models/task.dart';
import 'package:mysty/models/category.dart';
import 'package:mysty/models/user_stats.dart';

/// Offline local database service using Isar.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  bool get isInitialized => _isar != null;

  Isar get isar {
    if (_isar == null) {
      throw StateError("DatabaseService has not been initialized. Call init() first.");
    }
    return _isar!;
  }

  /// Initialize Isar database and seed default data if needed.
  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      _isar = existing;
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CategoryModelSchema,
        TaskModelSchema,
        UserStatsModelSchema,
        DailyLogModelSchema,
      ],
      directory: dir.path,
      inspector: false,
    );

    await _seedDefaultsIfNeeded();
  }

  /// Seed initial categories and user stats on first launch.
  Future<void> _seedDefaultsIfNeeded() async {
    final categoryCount = await isar.categoryModels.count();
    if (categoryCount == 0) {
      await isar.writeTxn(() async {
        await isar.categoryModels.putAll([
          CategoryModel()
            ..name = 'Cybernetics'
            ..color = '#00fff5',
          CategoryModel()
            ..name = 'Netrunning'
            ..color = '#ff00ff',
          CategoryModel()
            ..name = 'Missions'
            ..color = '#f5ff00',
          CategoryModel()
            ..name = 'Upgrades'
            ..color = '#00ff88',
        ]);
      });
    }

    final statsCount = await isar.userStatsModels.count();
    if (statsCount == 0) {
      await isar.writeTxn(() async {
        await isar.userStatsModels.put(
          UserStatsModel()
            ..id = 1
            ..totalXp = 0
            ..currentStreak = 0
            ..longestStreak = 0,
        );
      });
    }
  }

  // ───────────────────── Tasks ─────────────────────

  /// Fetch tasks with optional filters.
  Future<List<Task>> getTasks({
    int? categoryId,
    String? priority,
    String? search,
    bool? completed,
  }) async {
    final allTasks = await isar.taskModels.where().findAll();
    final categoriesMap = {
      for (var c in await isar.categoryModels.where().findAll()) c.id: c
    };

    final filtered = allTasks.where((t) {
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (priority != null && t.priority.name.toUpperCase() != priority.toUpperCase()) return false;
      if (completed != null && t.isCompleted != completed) return false;
      if (search != null && search.trim().isNotEmpty) {
        final query = search.trim().toLowerCase();
        final titleMatch = t.title.toLowerCase().contains(query);
        final descMatch = t.description?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !descMatch) return false;
      }
      return true;
    }).toList();

    // Sort newest first
    filtered.sort((a, b) => b.id.compareTo(a.id));

    return filtered.map((t) {
      CategoryBrief? catBrief;
      if (t.categoryId != null && categoriesMap.containsKey(t.categoryId)) {
        final cat = categoriesMap[t.categoryId]!;
        catBrief = CategoryBrief(
          id: cat.id,
          name: cat.name,
          color: cat.color,
        );
      }

      return Task(
        id: t.id,
        title: t.title,
        description: t.description,
        isCompleted: t.isCompleted,
        priority: t.priority,
        dueDate: t.dueDate,
        categoryId: t.categoryId,
        category: catBrief,
        createdAt: t.createdAt,
        completedAt: t.completedAt,
      );
    }).toList();
  }

  /// Create a new task.
  Future<Task> createTask({
    required String title,
    String? description,
    String priority = 'MEDIUM',
    String? dueDate,
    int? categoryId,
  }) async {
    final priorityEnum = Priority.values.firstWhere(
      (e) => e.name.toUpperCase() == priority.toUpperCase(),
      orElse: () => Priority.MEDIUM,
    );

    final taskModel = TaskModel()
      ..title = title
      ..description = description
      ..isCompleted = false
      ..priority = priorityEnum
      ..dueDate = dueDate
      ..categoryId = categoryId
      ..createdAt = DateTime.now().toIso8601String();

    await isar.writeTxn(() async {
      await isar.taskModels.put(taskModel);
    });

    CategoryBrief? catBrief;
    if (categoryId != null) {
      final cat = await isar.categoryModels.get(categoryId);
      if (cat != null) {
        catBrief = CategoryBrief(id: cat.id, name: cat.name, color: cat.color);
      }
    }

    return Task(
      id: taskModel.id,
      title: taskModel.title,
      description: taskModel.description,
      isCompleted: taskModel.isCompleted,
      priority: taskModel.priority,
      dueDate: taskModel.dueDate,
      categoryId: taskModel.categoryId,
      category: catBrief,
      createdAt: taskModel.createdAt,
      completedAt: taskModel.completedAt,
    );
  }

  /// Update an existing task.
  Future<Task> updateTask(int taskId, Map<String, dynamic> fields) async {
    final taskModel = await isar.taskModels.get(taskId);
    if (taskModel == null) {
      throw Exception("Task $taskId not found");
    }

    if (fields.containsKey('title')) taskModel.title = fields['title'];
    if (fields.containsKey('description')) taskModel.description = fields['description'];
    if (fields.containsKey('is_completed')) taskModel.isCompleted = fields['is_completed'];
    if (fields.containsKey('priority')) {
      taskModel.priority = Priority.values.firstWhere(
        (e) => e.name.toUpperCase() == fields['priority'].toString().toUpperCase(),
        orElse: () => taskModel.priority,
      );
    }
    if (fields.containsKey('due_date')) taskModel.dueDate = fields['due_date'];
    if (fields.containsKey('category_id')) taskModel.categoryId = fields['category_id'];

    await isar.writeTxn(() async {
      await isar.taskModels.put(taskModel);
    });

    CategoryBrief? catBrief;
    if (taskModel.categoryId != null) {
      final cat = await isar.categoryModels.get(taskModel.categoryId!);
      if (cat != null) {
        catBrief = CategoryBrief(id: cat.id, name: cat.name, color: cat.color);
      }
    }

    return Task(
      id: taskModel.id,
      title: taskModel.title,
      description: taskModel.description,
      isCompleted: taskModel.isCompleted,
      priority: taskModel.priority,
      dueDate: taskModel.dueDate,
      categoryId: taskModel.categoryId,
      category: catBrief,
      createdAt: taskModel.createdAt,
      completedAt: taskModel.completedAt,
    );
  }

  /// Mark a task as completed and process XP / streak updates.
  Future<TaskCompleteResult> completeTask(int taskId) async {
    final taskModel = await isar.taskModels.get(taskId);
    if (taskModel == null) {
      throw Exception("Task $taskId not found");
    }

    final nowIso = DateTime.now().toIso8601String();

    if (!taskModel.isCompleted) {
      taskModel.isCompleted = true;
      taskModel.completedAt = nowIso;
      await isar.writeTxn(() async {
        await isar.taskModels.put(taskModel);
      });
    }

    // Base XP
    int baseXp = 25;
    switch (taskModel.priority) {
      case Priority.LOW:
        baseXp = 10;
        break;
      case Priority.MEDIUM:
        baseXp = 25;
        break;
      case Priority.HIGH:
        baseXp = 50;
        break;
    }

    // Early bonus
    int earlyBonus = 0;
    if (taskModel.dueDate != null) {
      try {
        final due = DateTime.parse(taskModel.dueDate!);
        final now = DateTime.now();
        final todayDate = DateTime(now.year, now.month, now.day);
        final dueDayDate = DateTime(due.year, due.month, due.day);
        if (todayDate.isBefore(dueDayDate)) {
          earlyBonus = 15;
        }
      } catch (_) {}
    }

    // Update stats and streak
    var stats = await isar.userStatsModels.get(1);
    stats ??= UserStatsModel()..id = 1;

    final todayDate = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(todayDate);

    if (stats.lastActiveDate == null) {
      stats.currentStreak = 1;
      stats.lastActiveDate = todayFormatted;
    } else {
      try {
        final lastActive = DateFormat('yyyy-MM-dd').parse(stats.lastActiveDate!);
        final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final currentDay = DateTime(todayDate.year, todayDate.month, todayDate.day);
        final daysDiff = currentDay.difference(lastActiveDay).inDays;

        if (daysDiff == 0) {
          // Already active today
        } else if (daysDiff == 1) {
          // Consecutive day
          stats.currentStreak += 1;
          stats.lastActiveDate = todayFormatted;
        } else if (daysDiff > 1) {
          // Streak broken
          final penalty = (stats.totalXp * 0.20).toInt();
          stats.totalXp = max(0, stats.totalXp - penalty);
          stats.currentStreak = 1;
          stats.lastActiveDate = todayFormatted;
        }
      } catch (_) {
        stats.currentStreak = 1;
        stats.lastActiveDate = todayFormatted;
      }
    }

    if (stats.currentStreak > stats.longestStreak) {
      stats.longestStreak = stats.currentStreak;
    }

    // Streak bonus
    final streakBonus = min(stats.currentStreak * 5, 50);
    final totalEarned = baseXp + earlyBonus + streakBonus;

    stats.totalXp += totalEarned;

    await isar.writeTxn(() async {
      await isar.userStatsModels.put(stats!);
    });

    // Update Daily Log
    var dailyLog = await isar.dailyLogModels.filter().logDateEqualTo(todayFormatted).findFirst();
    if (dailyLog == null) {
      dailyLog = DailyLogModel()
        ..logDate = todayFormatted
        ..tasksCompleted = 1
        ..xpEarned = totalEarned;
    } else {
      dailyLog.tasksCompleted += 1;
      dailyLog.xpEarned += totalEarned;
    }

    await isar.writeTxn(() async {
      await isar.dailyLogModels.put(dailyLog!);
    });

    CategoryBrief? catBrief;
    if (taskModel.categoryId != null) {
      final cat = await isar.categoryModels.get(taskModel.categoryId!);
      if (cat != null) {
        catBrief = CategoryBrief(id: cat.id, name: cat.name, color: cat.color);
      }
    }

    final updatedTask = Task(
      id: taskModel.id,
      title: taskModel.title,
      description: taskModel.description,
      isCompleted: taskModel.isCompleted,
      priority: taskModel.priority,
      dueDate: taskModel.dueDate,
      categoryId: taskModel.categoryId,
      category: catBrief,
      createdAt: taskModel.createdAt,
      completedAt: taskModel.completedAt,
    );

    final level = _calculateLevel(stats.totalXp);
    final levelTitle = _getLevelTitle(level);

    return TaskCompleteResult(
      task: updatedTask,
      xpEarned: totalEarned,
      streakBonus: streakBonus,
      totalXp: stats.totalXp,
      currentStreak: stats.currentStreak,
      level: level,
      levelTitle: levelTitle,
    );
  }

  /// Delete a task.
  Future<void> deleteTask(int taskId) async {
    await isar.writeTxn(() async {
      await isar.taskModels.delete(taskId);
    });
  }

  // ───────────────────── Categories ─────────────────────

  /// Fetch all categories with dynamic task counts.
  Future<List<Category>> getCategories() async {
    final categoryModels = await isar.categoryModels.where().findAll();
    final allTasks = await isar.taskModels.where().findAll();

    final counts = <int, int>{};
    for (var task in allTasks) {
      if (task.categoryId != null) {
        counts[task.categoryId!] = (counts[task.categoryId!] ?? 0) + 1;
      }
    }

    categoryModels.sort((a, b) => a.name.compareTo(b.name));

    return categoryModels.map((c) {
      return Category(
        id: c.id,
        name: c.name,
        color: c.color,
        icon: c.icon,
        taskCount: counts[c.id] ?? 0,
      );
    }).toList();
  }

  /// Create a category.
  Future<Category> createCategory({
    required String name,
    String color = '#00fff5',
    String? icon,
  }) async {
    final catModel = CategoryModel()
      ..name = name
      ..color = color
      ..icon = icon;

    await isar.writeTxn(() async {
      await isar.categoryModels.put(catModel);
    });

    return Category(
      id: catModel.id,
      name: catModel.name,
      color: catModel.color,
      icon: catModel.icon,
      taskCount: 0,
    );
  }

  /// Delete a category and set affected tasks' categoryId to null.
  Future<void> deleteCategory(int categoryId) async {
    await isar.writeTxn(() async {
      await isar.categoryModels.delete(categoryId);

      final affectedTasks = await isar.taskModels.filter().categoryIdEqualTo(categoryId).findAll();
      for (var task in affectedTasks) {
        task.categoryId = null;
        await isar.taskModels.put(task);
      }
    });
  }

  // ───────────────────── Stats ─────────────────────

  /// Fetch user stats.
  Future<UserStats> getStats() async {
    var stats = await isar.userStatsModels.get(1);
    if (stats == null) {
      stats = UserStatsModel()..id = 1;
      await isar.writeTxn(() async {
        await isar.userStatsModels.put(stats!);
      });
    }

    final level = _calculateLevel(stats.totalXp);
    final levelTitle = _getLevelTitle(level);
    final xpInCurrentLevel = stats.totalXp - ((level - 1) * 100);

    return UserStats(
      totalXp: stats.totalXp,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      level: level,
      levelTitle: levelTitle,
      xpForCurrentLevel: xpInCurrentLevel,
      xpForNextLevel: 100,
      lastActiveDate: stats.lastActiveDate,
    );
  }

  /// Fetch contribution graph data.
  Future<ContributionGraph> getContributions({int months = 6}) async {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: months * 30));
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);

    final logs = await isar.dailyLogModels.filter().logDateGreaterThan(startDateStr, include: true).findAll();
    final logMap = {for (var l in logs) l.logDate: l};

    int maxTasks = 1;
    for (var l in logs) {
      if (l.tasksCompleted > maxTasks) {
        maxTasks = l.tasksCompleted;
      }
    }

    final days = <ContributionDay>[];
    int totalTasks = 0;
    int totalXp = 0;
    int activeDays = 0;

    var curr = startDate;
    final endDate = DateTime(today.year, today.month, today.day);

    while (!curr.isAfter(endDate)) {
      final dateStr = DateFormat('yyyy-MM-dd').format(curr);
      final log = logMap[dateStr];

      if (log != null && log.tasksCompleted > 0) {
        final intensity = min(4, max(1, ((log.tasksCompleted / maxTasks) * 4).round()));
        days.add(ContributionDay(
          date: dateStr,
          tasksCompleted: log.tasksCompleted,
          xpEarned: log.xpEarned,
          intensity: intensity,
        ));
        totalTasks += log.tasksCompleted;
        totalXp += log.xpEarned;
        activeDays += 1;
      } else {
        days.add(ContributionDay(
          date: dateStr,
          tasksCompleted: 0,
          xpEarned: 0,
          intensity: 0,
        ));
      }
      curr = curr.add(const Duration(days: 1));
    }

    return ContributionGraph(
      days: days,
      totalTasks: totalTasks,
      totalXp: totalXp,
      activeDays: activeDays,
    );
  }

  // ───────────────────── Helpers ─────────────────────

  static const Map<int, String> _levelTitles = {
    1: "Street Kid",
    2: "Data Runner",
    3: "Netrunner",
    4: "Chrome Phantom",
    5: "Neon Assassin",
    6: "Ghost Protocol",
    7: "Daemon Lord",
    8: "Singularity",
  };

  int _calculateLevel(int totalXp) {
    final level = (totalXp ~/ 100) + 1;
    return min(level, 8);
  }

  String _getLevelTitle(int level) {
    if (level >= 8) return _levelTitles[8]!;
    return _levelTitles[level] ?? "Unknown";
  }
}
