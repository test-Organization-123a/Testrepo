import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/climbing_bg.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
