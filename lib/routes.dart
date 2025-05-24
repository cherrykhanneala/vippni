import 'package:flutter/material.dart';
import 'package:vipnni/features/auth/login_screen.dart';
import 'package:vipnni/features/auth/signup_screen.dart';
import 'package:vipnni/features/auth/forgot_password.dart';
import 'package:vipnni/features/home/home_screen.dart';
import 'package:vipnni/features/products/product_upload_screen.dart';
import 'package:vipnni/features/products/products_screen.dart';
import 'package:vipnni/features/orders/orders_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String productUpload = '/product-upload';
  static const String products = '/products';
  static const String orders = '/orders';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case productUpload:
        return MaterialPageRoute(builder: (_) => const ProductUploadScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}