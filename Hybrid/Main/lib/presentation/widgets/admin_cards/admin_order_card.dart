import 'package:flutter/material.dart';
import '../../../data/models/order.dart';

class AdminOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  double _calculateOrderTotal() {
    return order.items.fold(0.0, (sum, item) {
      final price = item.product?.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = _calculateOrderTotal();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            Icons.receipt_long,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(order.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (order.customer != null) ...[
              const SizedBox(height: 2),
              Text(
                'Customer: ${order.customer!.email}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'Total: €${total.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit order',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete order',
            ),
          ],
        ),
        children: [
          if (order.items.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.product?.name ?? 'Unknown Product',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Quantity: ${item.quantity}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.product != null 
                                ? '€${item.product!.price.toStringAsFixed(2)}'
                                : 'N/A',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.product != null 
                                ? '€${(item.product!.price * item.quantity).toStringAsFixed(2)}'
                                : 'N/A',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}