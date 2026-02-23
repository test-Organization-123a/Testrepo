import 'package:flutter/foundation.dart';
import '../../core/locator.dart' as di;
import '../../data/models/category.dart' as cat;
import '../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = di.Locator.categoryRepository;

  List<cat.Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<cat.Category> get categories => _categories;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load all categories from backend
  Future<void> loadCategories() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get a single category (already in memory if loaded)
  cat.Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add new category (Admin)
  Future<void> addCategory(String name, String description) async {
    try {
      final newCategory = await _repo.create(name: name, description: description);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update existing category (Admin)
  Future<void> updateCategory(String id, Map<String, dynamic> fields) async {
    try {
      final updated = await _repo.update(id, fields);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete category (Admin)
  Future<void> deleteCategory(String id) async {
    try {
      await _repo.delete(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
