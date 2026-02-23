import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/order_provider.dart';
import '../../../data/services/cart_service.dart';

class CartFooter extends StatefulWidget {
  final double total;
  final VoidCallback onClear;

  const CartFooter({
    super.key,
    required this.total,
    required this.onClear,
  });

  @override
  State<CartFooter> createState() => _CartFooterState();
}

class _CartFooterState extends State<CartFooter> {
  bool _isLoading = false;

  Future<void> _checkout() async {
    final orderProvider = context.read<OrderProvider>();
    final items = CartService.getCartItems();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderItems = items.map((item) {
        final product = item['product'];
        final quantity = item['quantity'];
        return {
          'productId': product.id,
          'quantity': quantity,
        };
      }).toList();

      await orderProvider.createOrder(orderItems);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      CartService.clearCart();
      widget.onClear();

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().contains('error:')
          ? e.toString().split('error:').last.trim()
          : e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $message'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Total: €${widget.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _checkout,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Checkout'),
            ),
            OutlinedButton(
              onPressed: widget.onClear,
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}
