import 'package:flutter/material.dart';
import 'package:mysty/models/category.dart';
import 'package:mysty/services/database_service.dart';

/// State management for categories.
class CategoryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all categories.
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _db.getCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new category.
  Future<bool> createCategory({
    required String name,
    String color = '#00fff5',
    String? icon,
  }) async {
    try {
      await _db.createCategory(name: name, color: color, icon: icon);
      await fetchCategories();
      return true;
    } catch (e) {
      _error = 'Failed to create category: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a category.
  Future<bool> deleteCategory(int categoryId) async {
    try {
      await _db.deleteCategory(categoryId);
      await fetchCategories();
      return true;
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }
}
