import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../orders/orders_screen.dart';
import '../products/products_screen.dart';
import '../../screens/shop_screen.dart';
import 'package:vipnni/screens/menu_screen.dart';
 // Import the MenuScreen
// Import ProductUploadScreen for add button
import '../../core/auth_service.dart'; // Import the AuthService for role checking

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String userRole = 'pending'; // Default to 'pending'
  final AuthService _authService = AuthService();

  // Define the screens
  final List<Widget> _screens = [
    const ShopScreen(),
    const ProductsScreen(),
    const OrdersScreen(),
    const MenuScreen(), // Replace DashboardScreen with MenuScreen
  ];

  @override
  void initState() {
    super.initState();
    _getVendorRole(); // Fetch the vendor's role on screen initialization
  }

  Future<void> _getVendorRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? role = await _authService.getVendorRole(user.uid);
      if (role != null) {
        setState(() {
          userRole =
              role; // Set the user's role to either 'pending' or 'seller'
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (userRole == 'seller' || index == 0 || index == 3) {
              setState(() {
                _currentIndex = index;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your account is under review. Access restricted.'),
                ),
              );
            }
          },
          selectedItemColor: const Color(0xFF31135F),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_shopping_cart_rounded,
                color: userRole == 'seller' ? null : Colors.grey,
              ),
              label: 'My Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.monetization_on,
                color: userRole == 'seller' ? null : Colors.grey,
              ),
              label: 'My Earnings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
