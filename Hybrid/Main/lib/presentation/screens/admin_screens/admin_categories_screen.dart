import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import '../../../data/models/category.dart';
import '../../state/category_provider.dart';
import '../../widgets/generic_page_items/admin_bottom_navigation.dart';
import '../../widgets/form_dialogs/category_form_dialog.dart';
import '../../widgets/admin_cards/admin_category_card.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  Future<void> _openCategoryDialog({Category? category}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CategoryFormDialog(existingCategory: category),
    );

    if (result == true && mounted) {
      context.read<CategoryProvider>().loadCategories();
    }
  }

  Future<void> _deleteCategory(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone and will affect all products in this category.'),
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
      await context.read<CategoryProvider>().deleteCategory(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final isLoading = categoryProvider.isLoading;
          final error = categoryProvider.error;
          final categories = categoryProvider.categories;

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
                    onPressed: () => categoryProvider.loadCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product category!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => categoryProvider.loadCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return AdminCategoryCard(
                  category: category,
                  onEdit: () => _openCategoryDialog(category: category),
                  onDelete: () => _deleteCategory(category.id, category.name),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoryDialog(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      bottomNavigationBar: const AdminBottomNavigationWidget(
        currentDestination: AdminDestination.categories,
      ),
    );
  }
}
