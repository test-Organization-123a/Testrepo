import '../../core/locator.dart' as di;
import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _api = di.Locator.api;

  /// Get all orders (admin only)
  Future<List<Order>> getOrders() async {
    final data = await _api.get('orders');
    if (data is List) {
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Get order by ID
  Future<Order> getOrderById(String id) async {
    final data = await _api.get('orders/$id');
    return Order.fromJson(data);
  }

  /// Create new order (user)
  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
  }) async {
    final data = await _api.post('orders', {'items': items});
    return Order.fromJson(data);
  }

  /// Update order (admin/user)
  Future<Order> updateOrder(String id, List<Map<String, dynamic>> items) async {
    final data = await _api.put('orders/$id', {'items': items});
    return Order.fromJson(data);
  }

  /// Delete order (admin)
  Future<void> deleteOrder(String id) async {
    await _api.delete('orders/$id');
  }
}
