import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'operations_screen.dart';
import 'store_screen.dart';
import 'account_screen.dart';
import 'wifi_screen.dart';

class HomeShell extends StatefulWidget { const HomeShell({super.key}); @override State<HomeShell> createState() => _HomeShellState(); }
class _HomeShellState extends State<HomeShell> {
  int index = 0;
  late final pages = const [HomeScreen(), PaymentScreen(), StoreScreen(), OperationsScreen(), AccountScreen()];
  @override Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'حسابي'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'السداد'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'المتجر'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history_toggle_off), label: 'العمليات'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'الإعدادات'),
        ],
      ),
      floatingActionButton: index == 0 ? FloatingActionButton.small(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WifiScreen())), child: const Icon(Icons.wifi)) : null,
    );
  }
}
