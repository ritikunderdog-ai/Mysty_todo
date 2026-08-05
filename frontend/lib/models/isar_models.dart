import 'package:isar/isar.dart';
import 'package:mysty/models/task.dart';

part 'isar_models.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late String color;
  String? icon;
}

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  late bool isCompleted;

  @enumerated
  late Priority priority;

  String? dueDate;
  int? categoryId;

  late String createdAt;
  String? completedAt;
}

@collection
class UserStatsModel {
  Id id = 1;

  int totalXp = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  String? lastActiveDate;
}

@collection
class DailyLogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String logDate;

  int tasksCompleted = 0;
  int xpEarned = 0;
}
