import 'package:flutter/material.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/models/product.dart';
import 'cart_item_tile.dart';
import 'cart_footer.dart';

class CartPopup extends StatefulWidget {
  const CartPopup({super.key});

  @override
  State<CartPopup> createState() => _CartPopupState();
}

class _CartPopupState extends State<CartPopup> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cartItems = CartService.getCartItems();
    final total = CartService.getTotal();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Align(
      alignment: isMobile ? Alignment.bottomCenter : Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile
              ? MediaQuery.of(context).size.width * 0.9
              : MediaQuery.of(context).size.width * 0.5,
          height: isMobile
              ? MediaQuery.of(context).size.height * 0.55
              : MediaQuery.of(context).size.height * 0.4,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Cart is empty'))
                    : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item['product'] as Product;
                    final quantity = item['quantity'] as int;
                    return CartItemTile(
                      product: product,
                      quantity: quantity,
                      onQuantityChanged: (newQty) {
                        CartService.updateQuantity(product.id, newQty);
                        _refresh();
                      },
                      onDelete: () {
                        CartService.removeFromCart(product.id);
                        _refresh();
                      },
                    );
                  },
                ),
              ),
              CartFooter(
                total: total,
                onClear: () {
                  CartService.clearCart();
                  _refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
