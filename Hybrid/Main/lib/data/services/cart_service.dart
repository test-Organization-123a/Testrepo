import 'package:hive/hive.dart';
import '../models/product.dart';

class CartService {
  static final Box _cartBox = Hive.box('cart');

  static Map<String, dynamic> _getCart() {
    final raw = _cartBox.get('cart', defaultValue: {});
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  static List<Map<String, dynamic>> getCartItems() {
    final cart = _getCart();
    return cart.values
        .whereType<Map>()
        .map((item) => {
      'product': Product.fromJson(Map<String, dynamic>.from(item['product'])),
      'quantity': item['quantity'] ?? 1,
    })
        .toList();
  }

  static void addToCart(Product product) {
    final cart = _getCart();
    if (cart.containsKey(product.id)) {
      cart[product.id]['quantity'] = (cart[product.id]['quantity'] ?? 1) + 1;
    } else {
      cart[product.id] = {
        'product': product.toJson(),
        'quantity': 1,
      };
    }
    _cartBox.put('cart', cart);
  }

  static void updateQuantity(String productId, int newQty) {
    final cart = _getCart();
    if (cart.containsKey(productId)) {
      if (newQty > 0) {
        cart[productId]['quantity'] = newQty;
      } else {
        cart.remove(productId);
      }
      _cartBox.put('cart', cart);
    }
  }

  static void removeFromCart(String productId) {
    final cart = _getCart();
    cart.remove(productId);
    _cartBox.put('cart', cart);
  }

  static void clearCart() {
    _cartBox.put('cart', {});
  }

  static double getTotal() {
    final cart = _getCart();
    double total = 0;
    cart.forEach((key, item) {
      if (item is Map) {
        final product = Product.fromJson(Map<String, dynamic>.from(item['product']));
        final quantity = (item['quantity'] ?? 1) as int;
        total += product.price * quantity;
      }
    });
    return total;
  }
}