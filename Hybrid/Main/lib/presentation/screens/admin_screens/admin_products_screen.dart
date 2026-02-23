import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import '../../../data/models/product.dart';
import '../../state/product_provider.dart';
import '../../widgets/form_dialogs/product_form_dialog.dart';
import '../../widgets/generic_page_items/admin_bottom_navigation.dart';
import '../../widgets/admin_cards/admin_product_card.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  Future<void> _openProductDialog({Product? product}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(existingProduct: product),
    );

    if (result == true && mounted) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  Future<void> _deleteProduct(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
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
      await context.read<ProductProvider>().deleteProduct(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final isLoading = productProvider.isLoading;
          final error = productProvider.error;
          final products = productProvider.products;
          

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
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product to the inventory!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productProvider.loadProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return AdminProductCard(
                  product: product,
                  onEdit: () => _openProductDialog(product: product),
                  onDelete: () => _deleteProduct(product.id, product.name),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductDialog(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      bottomNavigationBar: const AdminBottomNavigationWidget(
        currentDestination: AdminDestination.products,
      ),
    );
  }
}
