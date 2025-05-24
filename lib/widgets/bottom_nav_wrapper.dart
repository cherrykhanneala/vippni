import 'package:flutter/material.dart';

class BottomNavWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const BottomNavWrapper({
    super.key,
    required this.child,
    this.currentIndex = 3, // Default to menu index
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            // Navigate to the corresponding screen
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/products');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/earnings');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/menu');
                break;
            }
          }
        },
        selectedItemColor: const Color(0xFF31135F),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'My Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}