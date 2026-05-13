import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/Screens/cart_screen.dart';
import 'package:Rujta/Screens/home.dart';
import 'package:Rujta/Screens/user_profile_screen.dart';
import 'package:Rujta/view_model/cart_controller.dart';

/// Bottom navigation: Home · Cart · Profile — cart badge from [CartController].
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  Widget _cartNavIcon({required bool active}) {
    final cart = context.watch<CartController>();
    final icon =
        active ? Icons.shopping_cart : Icons.shopping_cart_outlined;
    final count = cart.totalItemCount;
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        sizing: StackFit.expand,
        children: const [
          HomePage(),
          CartScreen(),
          UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kMainColor,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _cartNavIcon(active: false),
            activeIcon: _cartNavIcon(active: true),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
