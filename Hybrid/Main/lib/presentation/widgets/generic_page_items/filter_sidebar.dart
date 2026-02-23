import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import 'search_bar_widget.dart';

class FilterSidebar extends StatelessWidget {
  final Function(String)? onSearchChanged;
  final List<Category> categories;
  final Set<String> selectedCategoryIds;
  final Function(String, bool)? onCategoryChanged;

  const FilterSidebar({
    super.key,
    this.onSearchChanged,
    this.categories = const [],
    this.selectedCategoryIds = const {},
    this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (onSearchChanged != null) ...[
          SearchBarWidget(
            hintText: 'Search products...',
            onChanged: onSearchChanged!,
            padding: const EdgeInsets.only(bottom: 16),
          ),
          const Divider(),
        ],
        const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (categories.isNotEmpty && onCategoryChanged != null) ...[
          CheckboxListTile(
            value: selectedCategoryIds.length == categories.length,
            tristate: true,
            onChanged: (val) {
              if (val == true) {
                for (final category in categories) {
                  if (!selectedCategoryIds.contains(category.id)) {
                    onCategoryChanged!(category.id, true);
                  }
                }
              } else {
                for (final categoryId in Set.from(selectedCategoryIds)) {
                  onCategoryChanged!(categoryId, false);
                }
              }
            },
            title: const Text(
              'Select All',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Divider(height: 8),
        ],
        ...categories.map(
          (category) => CheckboxListTile(
            value: selectedCategoryIds.contains(category.id),
            onChanged: onCategoryChanged != null
                ? (val) => onCategoryChanged!(category.id, val ?? false)
                : null,
            title: Text(category.name),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No categories available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
