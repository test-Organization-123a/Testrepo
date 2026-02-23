import 'package:flutter/material.dart';
import '../../screens/admin_screens/admin_products_screen.dart';
import '../../screens/admin_screens/admin_categories_screen.dart';
import '../../screens/admin_screens/admin_orders_screen.dart';
import '../../screens/admin_screens/admin_locations_screen.dart';

enum AdminDestination { products, categories, orders, locations }

class AdminBottomNavigationWidget extends StatelessWidget {
  final AdminDestination currentDestination;

  const AdminBottomNavigationWidget({
    super.key,
    required this.currentDestination,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.orange[50],
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.orange[400],
      currentIndex: currentDestination.index,
      onTap: (index) {
        final destination = AdminDestination.values[index];
        
        if (destination == currentDestination) return;
        
        switch (destination) {
          case AdminDestination.products:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
              (route) => false,
            );
            break;
          case AdminDestination.categories:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()),
              (route) => false,
            );
            break;
          case AdminDestination.orders:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              (route) => false,
            );
            break;
          case AdminDestination.locations:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminLocationsScreen()),
              (route) => false,
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          activeIcon: Icon(Icons.location_on),
          label: 'Locations',
        ),
      ],
    );
  }
}