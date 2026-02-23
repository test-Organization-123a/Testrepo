import 'package:flutter/foundation.dart';
import '../../core/locator.dart' as di;
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = di.Locator.orderRepository;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load all orders (admin)
  Future<void> loadOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Create a new order
  Future<void> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final order = await _repo.create(items: items);
      _orders.add(order);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update an order
  Future<void> updateOrder(String id, List<Map<String, dynamic>> items) async {
    try {
      final updated = await _repo.update(id, items);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) _orders[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String id) async {
    try {
      await _repo.delete(id);
      _orders.removeWhere((o) => o.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
