import 'product.dart';
import 'user.dart';

class Order {
  final String id;
  final String customerId;
  final DateTime createdAt;
  final List<OrderItem> items;
  final User? customer;

  Order({
    required this.id,
    required this.customerId,
    required this.createdAt,
    this.items = const [],
    this.customer,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List<dynamic>?)
          ?.map((i) => OrderItem.fromJson(i))
          .toList() ??
          [],
      customer: json['customer'] != null
          ? User.fromJson(json['customer'])
          : null,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}
