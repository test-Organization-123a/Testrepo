import '../models/order.dart';
import '../services/order_service.dart';
import '../../core/locator.dart' as di;

class OrderRepository {
  final OrderService _service = di.Locator.orderService;

  Future<List<Order>> fetchAll() => _service.getOrders();
  Future<Order> fetchById(String id) => _service.getOrderById(id);

  Future<Order> create({
    required List<Map<String, dynamic>> items,
  }) =>
      _service.createOrder(items: items);

  Future<Order> update(String id, List<Map<String, dynamic>> items) =>
      _service.updateOrder(id, items);

  Future<void> delete(String id) => _service.deleteOrder(id);
}
