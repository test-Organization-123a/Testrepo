import 'package:flutter/material.dart';
import '../../screens/user_screens/shop_screen.dart';
import '../../screens/user_screens/locations_screen.dart';

enum AppDestination { shop, locations }

class BottomNavigationWidget extends StatelessWidget {
  final AppDestination currentDestination;

  const BottomNavigationWidget({
    super.key,
    required this.currentDestination,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.orange[50],
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.orange[400],
      currentIndex: currentDestination.index,
      onTap: (index) {
        final destination = AppDestination.values[index];
        
        if (destination == currentDestination) return;
        
        switch (destination) {
          case AppDestination.shop:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ShopScreen()),
              (route) => false,
            );
            break;
          case AppDestination.locations:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LocationsScreen()),
              (route) => false,
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Shop',
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