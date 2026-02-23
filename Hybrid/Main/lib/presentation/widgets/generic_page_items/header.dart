import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/login_screen.dart';
import '../../state/auth_provider.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  /// A simple header with title, optional menu button, and logout.
  /// [showMenuButton] determines if the menu button is shown (for example on a mobile screen).
  /// [onMenuPressed] is a callback function that is called when the menu button is pressed. By default, it opens the drawer.
  const CustomHeader({
    super.key,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    
    return AppBar(
      title: const Text(
        'ClimbEasy',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.orange,
      centerTitle: true,
      leading: (showMenuButton)
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed:
                    onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
        ),
      ],
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
