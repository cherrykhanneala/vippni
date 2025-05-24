// auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../../core/auth_service.dart'; // Import your AuthService

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService =
        AuthService(); // Create an instance of AuthService

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while waiting for authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in
          return const HomeScreen();
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
