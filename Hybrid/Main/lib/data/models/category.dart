import 'product.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.products = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => Product.fromJson(p))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}
