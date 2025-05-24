import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shop_screen.dart';
import '../features/products/products_screen.dart';
import '../features/products/product_upload_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile_menu/wallet_history_screen.dart';
import 'profile_menu/terms_and_conditions.dart';
import 'profile_menu/privacy_policy.dart';
import 'profile_menu/return_policy_screen.dart';
import 'profile_menu/shop_information_screen.dart';
import '../features/products/stock_management_screen.dart';
import 'dummy_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF31135F),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGridMenuItem(
            context,
            icon: Icons.person,
            title: 'Shop',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.store,
            title: 'My Shop',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopInformationScreen(onNext: (_) => null)),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.add_box,
            title: 'Add Product',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductUploadScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.inventory,
            title: 'Products',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductsScreen()),
            ),
          ),


          _buildGridMenuItem(
            context,
            icon: Icons.point_of_sale,
            title: 'POS',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'POS')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Settings')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.inventory_2,
            title: 'Restock',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockManagementScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.campaign,
            title: 'Clearance Sale',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Clearance Sale')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletHistoryScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.message,
            title: 'Message',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Messages')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.account_balance,
            title: 'Bank Info',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Bank Info')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsAndConditions()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.people,
            title: 'About Us',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'About Us')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.security,
            title: 'Privacy Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.money,
            title: 'Refund Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Refund Policy')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.replay,
            title: 'Return Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReturnPolicyScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.cancel,
            title: 'Cancellation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DummyScreen(title: 'Cancellation')),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
          _buildGridMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF31135F), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {'showBottomNav': true}, // Pass flag to show bottom nav
    );
  }
}