import 'package:flutter/material.dart';
import 'package:mysty/models/task.dart';
import 'package:mysty/services/database_service.dart';

/// State management for tasks.
class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _priorityFilter;
  int? _categoryFilter;
  bool? _completedFilter;
  TaskCompleteResult? _lastCompleteResult;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  TaskCompleteResult? get lastCompleteResult => _lastCompleteResult;

  /// Fetch tasks from local database with current filters.
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _db.getTasks(
        search: _searchQuery,
        priority: _priorityFilter,
        categoryId: _categoryFilter,
        completed: _completedFilter,
      );
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new task.
  Future<bool> createTask({
    required String title,
    String? description,
    String priority = 'MEDIUM',
    String? dueDate,
    int? categoryId,
  }) async {
    try {
      await _db.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        categoryId: categoryId,
      );
      await fetchTasks();
      return true;
    } catch (e) {
      _error = 'Failed to create task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Complete a task and receive XP.
  Future<TaskCompleteResult?> completeTask(int taskId) async {
    try {
      final result = await _db.completeTask(taskId);
      _lastCompleteResult = result;
      await fetchTasks();
      return result;
    } catch (e) {
      _error = 'Failed to complete task: $e';
      notifyListeners();
      return null;
    }
  }

  /// Delete a task.
  Future<bool> deleteTask(int taskId) async {
    try {
      await _db.deleteTask(taskId);
      await fetchTasks();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update filters and refresh.
  void setSearchQuery(String? query) {
    _searchQuery = query;
    fetchTasks();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    fetchTasks();
  }

  void setCategoryFilter(int? categoryId) {
    _categoryFilter = categoryId;
    fetchTasks();
  }

  void setCompletedFilter(bool? completed) {
    _completedFilter = completed;
    fetchTasks();
  }

  void clearFilters() {
    _searchQuery = null;
    _priorityFilter = null;
    _categoryFilter = null;
    _completedFilter = null;
    fetchTasks();
  }

  void clearLastResult() {
    _lastCompleteResult = null;
  }
}
