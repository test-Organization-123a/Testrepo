import '../models/category.dart';
import '../services/category_service.dart';
import '../../core/locator.dart' as di;

class CategoryRepository {
  final CategoryService _service = di.Locator.categoryService;

  Future<List<Category>> fetchAll() => _service.getCategories();

  Future<Category> fetchById(String id) => _service.getCategoryById(id);

  Future<Category> create({
    required String name,
    required String description,
  }) =>
      _service.createCategory(name: name, description: description);

  Future<Category> update(String id, Map<String, dynamic> fields) =>
      _service.updateCategory(id, fields);

  Future<void> delete(String id) => _service.deleteCategory(id);
}
