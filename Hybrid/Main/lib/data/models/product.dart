import '../../config/api_config.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final List<String> imageUrls;
  final String? categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrls,
    this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];

    if (json['images'] is List) {
      urls = (json['images'] as List)
          .map((img) {
        if (img is Map && img['url'] != null) {
          final String rawUrl = img['url'];
          return rawUrl.startsWith('http')
              ? rawUrl
              : '${ApiConfig.baseUrl}$rawUrl';
        } else if (img is String && img.isNotEmpty) {
          return img.startsWith('http')
              ? img
              : '${ApiConfig.baseUrl}$img';
        }
        return '';
      })
          .where((u) => u.isNotEmpty)
          .toList();
    } else if (json['imageUrl'] is String && (json['imageUrl'] as String).isNotEmpty) {
      final rawUrl = json['imageUrl'];
      urls = [
        rawUrl.startsWith('http') ? rawUrl : '${ApiConfig.baseUrl}$rawUrl'
      ];
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: json['stock'] ?? 0,
      imageUrls: urls,
      categoryId: json['categoryId'],
      categoryName: json['category']?['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'categoryId': categoryId,
    'images': imageUrls
        .map((url) => {
      'url': url.replaceFirst(ApiConfig.baseUrl, ''),
    })
        .toList(),
  };

  String get firstImage =>
      imageUrls.isNotEmpty ? imageUrls.first : 'https://via.placeholder.com/150';
}
