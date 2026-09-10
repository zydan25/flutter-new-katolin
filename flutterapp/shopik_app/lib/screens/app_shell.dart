import 'package:flutter/material.dart';
import 'account_statement_screen.dart';
import 'main_home_screen.dart';
import 'operations_screen.dart';
import 'payment_network_screen.dart';
import 'reports_screen.dart';
import 'store_view_screen.dart';

/// Persistent bottom navigation shell matching web App.tsx (lines 2554-2615).
/// Tabs: المتجر / حسابي / السداد / العمليات / كشف حساب / التقارير
class AppShell extends StatefulWidget {
  final int initialIndex;
  final double walletBalance;
  final String apiToken;
  final String baseUrl;
  final String initialPhone;
  final String fullName;
  final String phone;
  final String governorate;
  final int pointsBalance;
  final ValueChanged<double>? onBalanceChanged;

  const AppShell({
    Key? key,
    this.initialIndex = 1,
    this.walletBalance = 99033.43,
    this.apiToken = '3241591d9733768e4b5d3226c96b200e04c7ca15',
    this.baseUrl = 'https://shopik.alattab.site',
    this.initialPhone = '',
    this.fullName = 'زيدان محمد عبدالله العطاب (محمد العطاب)',
    this.phone = '771642093',
    this.governorate = 'إب',
    this.pointsBalance = 0,
    this.onBalanceChanged,
  }) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color _crimson = Color(0xFF8B1D3B);
  static const Color _inactive = Color(0xFF94A3B8); // slate-400
  static const Color _emerald = Color(0xFF047857); // emerald-700

  late int _index;
  late double _balance;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _balance = widget.walletBalance;
  }

  void _onBalanceChanged(double v) {
    setState(() => _balance = v);
    widget.onBalanceChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      // 0: المتجر
      StoreViewScreen(
        onBackToMain: () => setState(() => _index = 1),
      ),
      // 1: حسابي
      MainHomeScreen(
        walletBalance: _balance,
        apiToken: widget.apiToken,
        baseUrl: widget.baseUrl,
        fullName: widget.fullName,
        phone: widget.phone,
        governorate: widget.governorate,
        pointsBalance: widget.pointsBalance,
        onBalanceChanged: _onBalanceChanged,
        onSwitchTab: (i) => setState(() => _index = i),
      ),
      // 2: السداد
      PaymentNetworkScreen(
        initialPhone: widget.initialPhone,
        walletBalance: _balance,
        apiToken: widget.apiToken,
        baseUrl: widget.baseUrl,
        onBalanceChanged: _onBalanceChanged,
        onOpenAccount: () => setState(() => _index = 1),
        onOpenStore: () => setState(() => _index = 0),
      ),
      // 3: العمليات
      OperationsScreen(
        apiToken: widget.apiToken,
        baseUrl: widget.baseUrl,
        onBackToMain: () {},
      ),
      // 4: كشف حساب
      AccountStatementScreen(
        customerName: widget.fullName,
        apiToken: widget.apiToken,
        baseUrl: widget.baseUrl,
        onBackToMain: () {},
      ),
      // 5: التقارير
      ReportsScreen(
        apiToken: widget.apiToken,
        baseUrl: widget.baseUrl,
        onBackToMain: () {},
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: tabs,
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.shopping_bag, label: 'المتجر', activeColor: _emerald),
      _NavItem(icon: Icons.home, label: 'حسابي', activeColor: _crimson),
      _NavItem(icon: Icons.credit_card, label: 'السداد', activeColor: _crimson),
      _NavItem(icon: Icons.history, label: 'العمليات', activeColor: _crimson),
      _NavItem(icon: Icons.description, label: 'كشف حساب', activeColor: _crimson),
      _NavItem(icon: Icons.bar_chart, label: 'التقارير', activeColor: _crimson),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B1D3B), Color(0xFFC62828)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _NavButton(
                      item: items[i],
                      active: _index == i,
                      onTap: () => setState(() => _index = i),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? item.activeColor : _AppShellState._inactive;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: active ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 21, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}