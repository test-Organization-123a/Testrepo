import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/locator.dart' as di;
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo = di.Locator.productRepository;

  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> createProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required String categoryId,
    List<File>? images,
    Uint8List? webImageBytes,
    String? webImageName,
  }) async {
    try {
      final product = await _repo.createProduct(
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
        images: images,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
      );
      _products.add(product);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct({
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
  }) async {
    try {
      final updated = await _repo.updateProduct(
        id: id,
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
        images: images,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
        existingImages: existingImages,
      );
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) _products[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
