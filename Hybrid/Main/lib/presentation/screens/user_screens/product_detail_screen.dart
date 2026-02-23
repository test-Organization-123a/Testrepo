import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/product.dart';
import '../../../data/services/cart_service.dart';
import '../../widgets/generic_page_items/header.dart';
import '../../widgets/generic_page_items/bottom_navigation.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  void _nextImage() {
    if (_currentImageIndex < widget.product.imageUrls.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _addToCart() {
    for (int i = 0; i < _quantity; i++) {
      CartService.addToCart(widget.product);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} (x$_quantity) added to cart'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareProduct() {
    Share.share(
      'Check out this product: ${widget.product.name} for €${widget.product.price}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: SingleChildScrollView(
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentDestination: AppDestination.shop,
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(isMobile: true),
        _buildProductInfo(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: _buildImageSection(isMobile: false)),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection({required bool isMobile}) {
    double height = isMobile ? 300 : 500;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SizedBox(
            
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.product.imageUrls.isNotEmpty
                    ? widget.product.imageUrls[_currentImageIndex]
                    : 'https://via.placeholder.com/400',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          if (widget.product.imageUrls.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _previousImage,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _nextImage,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
          ],

          if (widget.product.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.product.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? Colors.orange
                          : Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '€${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.inventory, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Stock: ${widget.product.stock}',
                style: TextStyle(
                  color: widget.product.stock > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description.isNotEmpty
                ? widget.product.description
                : 'No description available.',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < widget.product.stock
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.orange),
                onPressed: () {
                  _shareProduct();
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: widget.product.stock > 0 ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart),
                    const SizedBox(width: 8),
                    Text(
                      widget.product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
