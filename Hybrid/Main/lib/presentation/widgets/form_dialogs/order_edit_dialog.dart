import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../state/order_provider.dart';
import '../../state/product_provider.dart';

class OrderEditDialog extends StatefulWidget {
  final Order order;
  
  const OrderEditDialog({super.key, required this.order});

  @override
  State<OrderEditDialog> createState() => _OrderEditDialogState();
}

class _OrderEditDialogState extends State<OrderEditDialog> {
  final _formKey = GlobalKey<FormState>();
  
  List<OrderItemEdit> _editableItems = [];
  List<TextEditingController> _quantityControllers = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _editableItems = widget.order.items.map((item) => OrderItemEdit(
      id: item.id,
      productId: item.productId,
      quantity: item.quantity,
      product: item.product,
      originalQuantity: item.quantity,
    )).toList();

    _quantityControllers = _editableItems.map((item) => 
      TextEditingController(text: item.quantity.toString())
    ).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      _editableItems[index].quantity = newQuantity;
      _quantityControllers[index].text = newQuantity.toString();
      _markChanged();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _quantityControllers[index].dispose();
      _quantityControllers.removeAt(index);
      _editableItems.removeAt(index);
      _markChanged();
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = _editableItems.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
      }).toList();

      await context.read<OrderProvider>().updateOrder(widget.order.id, items);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateTotal() {
    return _editableItems.fold(0.0, (sum, item) {
      final price = item.product?.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Order #${widget.order.id.substring(0, 8)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created: ${_formatDate(widget.order.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (widget.order.customer != null)
                        Text(
                          'Customer: ${widget.order.customer!.email}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),

            Expanded(
              child: Form(
                key: _formKey,
                child: _editableItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, 
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No items in this order', 
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _editableItems.length,
                        itemBuilder: (context, index) {
                          final item = _editableItems[index];
                          final product = item.product;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product?.name ?? 'Unknown Product',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (product?.price != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '€${product!.price.toStringAsFixed(2)} each',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: item.quantity > 1
                                              ? () => _updateQuantity(index, item.quantity - 1)
                                              : null,
                                          icon: const Icon(Icons.remove),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: TextFormField(
                                            controller: _quantityControllers[index],
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                                            ),
                                            validator: (value) {
                                              final qty = int.tryParse(value ?? '');
                                              if (qty == null || qty < 1) {
                                                return 'Invalid';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              final qty = int.tryParse(value);
                                              if (qty != null && qty > 0) {
                                                setState(() {
                                                  _editableItems[index].quantity = qty;
                                                  _markChanged();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _updateQuantity(index, item.quantity + 1),
                                          icon: const Icon(Icons.add),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.orange[100],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (product?.price != null)
                                          Text(
                                            '€${(product!.price * item.quantity).toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          onPressed: () => _removeItem(index),
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Remove item',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const Divider(),

            // Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: €${_calculateTotal().toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItemEdit {
  final String id;
  final String productId;
  int quantity;
  final Product? product;
  final int originalQuantity;

  OrderItemEdit({
    required this.id,
    required this.productId,
    required this.quantity,
    this.product,
    required this.originalQuantity,
  });
}