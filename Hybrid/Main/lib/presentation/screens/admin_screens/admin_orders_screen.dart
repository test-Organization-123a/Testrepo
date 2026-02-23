import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import '../../../data/models/order.dart';
import '../../state/order_provider.dart';
import '../../widgets/generic_page_items/admin_bottom_navigation.dart';
import '../../widgets/form_dialogs/order_edit_dialog.dart';
import '../../widgets/admin_cards/admin_order_card.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  Future<void> _editOrder(Order order) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => OrderEditDialog(order: order),
    );

    if (result == true && mounted) {
      context.read<OrderProvider>().loadOrders();
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order #${orderId.substring(0, 8)}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (!mounted) return;
      await context.read<OrderProvider>().deleteOrder(orderId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final isLoading = orderProvider.isLoading;
          final error = orderProvider.error;
          final orders = orderProvider.orders;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadOrders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here when customers place them',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[orders.length - 1 - index];
                return AdminOrderCard(
                  order: order,
                  onEdit: () => _editOrder(order),
                  onDelete: () => _deleteOrder(order.id),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNavigationWidget(
        currentDestination: AdminDestination.orders,
      ),
    );
  }
}
