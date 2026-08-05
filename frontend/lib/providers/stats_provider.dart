import 'package:flutter/material.dart';
import 'package:mysty/models/user_stats.dart';
import 'package:mysty/services/database_service.dart';

/// State management for user stats and contribution graph.
class StatsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  UserStats? _stats;
  ContributionGraph? _contributions;
  bool _isLoading = false;
  String? _error;

  UserStats? get stats => _stats;
  ContributionGraph? get contributions => _contributions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch user stats from local database.
  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _db.getStats();
    } catch (e) {
      _error = 'Failed to load stats: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch contribution graph data.
  Future<void> fetchContributions({int months = 6}) async {
    try {
      _contributions = await _db.getContributions(months: months);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load contributions: $e';
      notifyListeners();
    }
  }

  /// Refresh all stats data.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchStats(),
      fetchContributions(),
    ]);
  }
}
