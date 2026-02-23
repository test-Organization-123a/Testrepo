import 'dart:io';
import 'dart:typed_data';
import '../models/product.dart';
import '../services/product_service.dart';
import '../../core/locator.dart' as di;

class ProductRepository {
  final ProductService _service = di.Locator.productService;

  Future<List<Product>> fetchAll() => _service.getProducts();
  Future<Product> fetchById(String id) => _service.getProductById(id);

  Future<Product> createProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required String categoryId,
    List<File>? images,
    Uint8List? webImageBytes,
    String? webImageName,
  }) =>
      _service.createProduct(
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
        imageFiles: images,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
      );

  Future<Product> updateProduct({
    required String id,
    required String name,
    required double price,
    required int stock,
    required String description,
    required String categoryId,
    List<File>? images,
    Uint8List? webImageBytes,
    String? webImageName,
    List<String>? existingImages,
  }) =>
      _service.updateProduct(
        id,
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
        imageFile: images != null && images.isNotEmpty ? images.first : null,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
        existingImages: existingImages,
      );

  Future<void> deleteProduct(String id) => _service.deleteProduct(id);
}
