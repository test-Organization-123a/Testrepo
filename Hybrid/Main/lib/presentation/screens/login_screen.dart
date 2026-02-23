import 'package:flutter/material.dart';
import '../widgets/login/login_background.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LoginBackground(),
          Center(
            child: LoginForm(),
          ),
        ],
      ),
    );
  }
}
