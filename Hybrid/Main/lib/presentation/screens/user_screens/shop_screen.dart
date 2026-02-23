import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../state/product_provider.dart';
import '../../state/category_provider.dart';
import '../../widgets/cart/cart_popup.dart';
import '../../widgets/generic_page_items/filter_sidebar.dart';
import '../../widgets/user_cards/product_grid.dart';
import '../../widgets/generic_page_items/header.dart';
import '../../widgets/generic_page_items/bottom_navigation.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  final Set<String> _selectedCategoryIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onCategoryChanged(String categoryId, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategoryIds.add(categoryId);
      } else {
        _selectedCategoryIds.remove(categoryId);
      }
    });
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      final searchMatch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final categoryMatch = _selectedCategoryIds.isEmpty ||
          (product.categoryId != null && _selectedCategoryIds.contains(product.categoryId));
      
      return searchMatch && categoryMatch;
    }).toList();
  }

  void _showCartPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cart',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim1),
          child: const CartPopup(),
        );
      },
    );
  }

  Widget _buildFilterInfo(int totalProducts, int filteredProducts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Showing $filteredProducts of $totalProducts products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_searchQuery.isNotEmpty || _selectedCategoryIds.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategoryIds.clear();
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final filteredProducts = _getFilteredProducts(productProvider.products);

    return Scaffold(
      appBar: CustomHeader(
        showMenuButton: isMobile,
      ),
      drawer: isMobile ? Drawer(
        child: FilterSidebar(
          onSearchChanged: _filterProducts,
          categories: categoryProvider.categories,
          selectedCategoryIds: _selectedCategoryIds,
          onCategoryChanged: _onCategoryChanged,
        ),
      ) : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 250,
              color: Colors.grey[100],
              child: FilterSidebar(
                onSearchChanged: _filterProducts,
                categories: categoryProvider.categories,
                selectedCategoryIds: _selectedCategoryIds,
                onCategoryChanged: _onCategoryChanged,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                if (_searchQuery.isNotEmpty || _selectedCategoryIds.isNotEmpty)
                  _buildFilterInfo(productProvider.products.length, filteredProducts.length),
                Expanded(child: _buildBody(productProvider, isMobile, filteredProducts)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _showCartPopup,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentDestination: AppDestination.shop,
      ),
    );
  }

  Widget _buildBody(ProductProvider provider, bool isMobile, List<Product> filteredProducts) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load products\n${provider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () => provider.loadProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (provider.products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }
    if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(child: Text('No products match your search.'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadProducts,
      child: ProductGrid(
        products: filteredProducts,
        crossAxisCount: isMobile ? 2 : 4,
      ),
    );
  }
}
