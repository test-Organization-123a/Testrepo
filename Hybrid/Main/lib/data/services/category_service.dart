import '../../core/locator.dart' as di;
import 'api_service.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService _api = di.Locator.api;

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final data = await _api.get('categories');
    if (data is List) {
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Get a single category by ID
  Future<Category> getCategoryById(String id) async {
    final data = await _api.get('categories/$id');
    return Category.fromJson(data);
  }

  /// Create a new category (admin only)
  Future<Category> createCategory({
    required String name,
    required String description,
  }) async {
    final data = await _api.post('categories', {
      'name': name,
      'description': description,
    });
    return Category.fromJson(data);
  }

  /// Update a category (admin only)
  Future<Category> updateCategory(String id, Map<String, dynamic> fields) async {
    final data = await _api.put('categories/$id', fields);
    return Category.fromJson(data);
  }

  /// Delete a category (admin only)
  Future<void> deleteCategory(String id) async {
    await _api.delete('categories/$id');
  }
}
