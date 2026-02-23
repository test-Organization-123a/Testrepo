import 'dart:io';
import 'dart:typed_data';
import '../models/product.dart';
import 'api_service.dart';
import '../../core/locator.dart' as di;

class ProductService {
  final ApiService _api = di.Locator.api;

  /// Get all products
  Future<List<Product>> getProducts() async {
    final data = await _api.get('products');
    if (data is List) {
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Get a product by ID
  Future<Product> getProductById(String id) async {
    final data = await _api.get('products/$id');
    return Product.fromJson(data);
  }

  /// Create a new product (Admin only)
  Future<Product> createProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required String categoryId,
    List<File>? imageFiles,
    Uint8List? webImageBytes,
    String? webImageName,
  }) async {
    final data = await _api.postMultipart(
      'products',
      fields: {
        'name': name,
        'price': price.toString(),
        'stock': stock.toString(),
        'description': description,
        'categoryId': categoryId,
      },
      files: imageFiles,
      webImageBytes: webImageBytes,
      webImageName: webImageName,
    );

    return Product.fromJson(data);
  }

  Future<Product> updateProduct(
      String id, {
        required String name,
        required double price,
        required int stock,
        required String description,
        required String categoryId,
        File? imageFile,
        Uint8List? webImageBytes,
        String? webImageName,
        List<String>? existingImages,
      }) async {
    final fields = {
      'name': name,
      'description': description,
      'price': price.toString(),
      'stock': stock.toString(),
      'categoryId': categoryId,
    };

    if (existingImages != null && existingImages.isNotEmpty) {
      for (int i = 0; i < existingImages.length; i++) {
        fields['existingImages[$i]'] = existingImages[i];
      }
    }

    final data = await _api.putMultipart(
      'products/$id',
      fields: fields,
      files: imageFile != null ? [imageFile] : null,
      webImageBytes: webImageBytes,
      webImageName: webImageName,
    );

    return Product.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('products/$id');
  }
}
