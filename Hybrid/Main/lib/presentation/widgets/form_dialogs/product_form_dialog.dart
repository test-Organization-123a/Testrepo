import '../../../data/models/product.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' hide Locator;
import '../../state/category_provider.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../state/product_provider.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? existingProduct;
  const ProductFormDialog({super.key, this.existingProduct});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  Uint8List? _webImageBytes;
  String? _webImageName;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  File? _pickedImage;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _selectedCategoryId = p?.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _webImageName = picked.name;
          _pickedImage = null;
        });
      } else {
        setState(() {
          _pickedImage = File(picked.path);
          _webImageBytes = null;
          _webImageName = null;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.existingProduct == null) {
        await context.read<ProductProvider>().createProduct(
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_stockController.text) ?? 0,
          categoryId: _selectedCategoryId!,
          images: _pickedImage != null ? [_pickedImage!] : null,
          webImageBytes: _webImageBytes,
          webImageName: _webImageName,
        );
      } else {
        await context.read<ProductProvider>().updateProduct(
          id: widget.existingProduct!.id,
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_stockController.text) ?? 0,
          categoryId: _selectedCategoryId!,
          images: _pickedImage != null ? [_pickedImage!] : null,
          webImageBytes: _webImageBytes,
          webImageName: _webImageName,
          existingImages: widget.existingProduct!.imageUrls,
        );
      }
      if (!mounted) return;
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;
    final loading = categoryProvider.isLoading;

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
                Icon(Icons.inventory, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.existingProduct == null ? 'Add Product' : 'Edit Product',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: const Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Enter product name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Price (€)',
                                prefixIcon: const Icon(Icons.euro),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final price = double.tryParse(v ?? '');
                                if (price == null || price < 0) {
                                  return 'Enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: InputDecoration(
                                labelText: 'Stock',
                                prefixIcon: const Icon(Icons.inventory_2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final stock = int.tryParse(v ?? '');
                                if (stock == null || stock < 0) {
                                  return 'Enter valid stock';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          initialValue: categories.any((cat) => cat.id == _selectedCategoryId)
                              ? _selectedCategoryId
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCategoryId = v),
                          validator: (v) => v == null ? 'Please select a category' : null,
                        ),
                      const SizedBox(height: 24),

                      Text(
                        'Product Image',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (kIsWeb) {
                              if (_webImageBytes != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else if (widget.existingProduct?.imageUrls.isNotEmpty == true) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.existingProduct!.imageUrls.first,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.image_not_supported, size: 48),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              if (_pickedImage != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _pickedImage!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.image_not_supported, size: 48),
                                    ),
                                  ),
                                );
                              } else if (widget.existingProduct?.imageUrls.isNotEmpty == true) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.existingProduct!.imageUrls.first,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.image_not_supported, size: 48),
                                    ),
                                  ),
                                );
                              }
                            }
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('No image selected', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.existingProduct == null ? 'Add Product' : 'Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
