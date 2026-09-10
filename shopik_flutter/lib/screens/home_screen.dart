import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../widgets/common.dart';
import 'reports_screen.dart';
import 'transfer_screen.dart';
import 'wifi_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  bool showBalance = false;
  @override Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final tiles = [
      ['متجر شبيك (سوق بلس)', 'المنتجات والسلة والطلبات', Icons.shopping_bag, Colors.green, const StoreShortcut()],
      ['شبكة السداد', 'يمن موبايل، YOU، سبأفون، 4G، نت', Icons.credit_card, AppColors.burgundy, const PaymentShortcut()],
      ['سجل العمليات', '${app.operations.length} عملية من الخادم', Icons.history, AppColors.blue, const OperationsShortcut()],
      ['كشف الحساب', 'القيود والحركات المالية', Icons.description, Colors.teal, const StatementShortcut()],
      ['التقارير والإحصائيات', 'مؤشرات وأداء الخدمات', Icons.bar_chart, Colors.indigo, const ReportsScreen()],
      ['تحويل لمشترك', 'تحويل رصيد برقم الهاتف', Icons.send, Colors.amber.shade700, const TransferScreen()],
      ['كروت الوايفاي', 'الشبكات والكروت المشتراة', Icons.wifi, Colors.teal.shade700, const WifiScreen()],
      ['الطلبات', '${app.orders.length} طلبات متجر', Icons.local_shipping, Colors.deepOrange, const OrdersScreen()],
    ];
    return RefreshIndicator(onRefresh: app.refreshAll, child: ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 24), children: [
      Row(children: [CircleAvatar(radius: 22, backgroundColor: AppColors.burgundy, child: Text(app.user?.name.isNotEmpty == true ? app.user!.name.characters.first : 'ز', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('تطبيق شبيك وسوق بلس', style: TextStyle(color: Colors.black54, fontSize: 11)), Text(app.user?.name ?? 'حسابي الرقمي', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))])), IconButton(onPressed: () => app.refreshWalletAndReports(), icon: const Icon(Icons.refresh))]),
      const SizedBox(height: 12),
      PageCard(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('رصيدي', style: TextStyle(fontWeight: FontWeight.w700)), IconButton(onPressed: () => setState(() => showBalance = !showBalance), icon: Icon(showBalance ? Icons.visibility : Icons.visibility_off))]), const SizedBox(height: 4), Text(showBalance ? '${app.walletBalance.toStringAsFixed(2)} ر.ي' : '••••••••', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.burgundy)), const SizedBox(height: 8), Align(alignment: Alignment.centerRight, child: Text('${app.user?.phone ?? ''}  •  ${app.user?.governorate ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.black54)))])),
      const SizedBox(height: 12),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: tiles.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.22), itemBuilder: (_, i) { final t = tiles[i]; return _Tile(title: t[0] as String, subtitle: t[1] as String, icon: t[2] as IconData, color: t[3] as Color, child: t[4] as Widget); }),
      const SizedBox(height: 12),
      PageCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('آخر العمليات', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 6), if (app.operations.isEmpty) const Text('لا توجد عمليات مسترجعة من الخادم', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12)) else ...app.operations.take(5).map((e) => ListTile(contentPadding: EdgeInsets.zero, dense: true, leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.receipt_long, color: AppColors.blue, size: 18)), title: Text('${e['service'] ?? 'عملية خدمة'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), subtitle: Text('${e['created_at'] ?? ''}', style: const TextStyle(fontSize: 10)), trailing: Text('${e['amount'] ?? ''} ${e['currency'] ?? 'YER'}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))) ])),
    ]));
  }
}

class _Tile extends StatelessWidget { const _Tile({required this.title, required this.subtitle, required this.icon, required this.color, required this.child}); final String title, subtitle; final IconData icon; final Color color; final Widget child; @override Widget build(BuildContext context) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => child)), borderRadius: BorderRadius.circular(17), child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x14000000))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: Colors.white, size: 20)), const Spacer(), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)), const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 9.5))])); }

class StoreShortcut extends StatelessWidget { const StoreShortcut({super.key}); @override Widget build(BuildContext context) => const StoreScreen(); }
class PaymentShortcut extends StatelessWidget { const PaymentShortcut({super.key}); @override Widget build(BuildContext context) => const PaymentScreen(); }
class OperationsShortcut extends StatelessWidget { const OperationsShortcut({super.key}); @override Widget build(BuildContext context) => const OperationsScreen(); }
class StatementShortcut extends StatelessWidget { const StatementShortcut({super.key}); @override Widget build(BuildContext context) => const AccountScreen(); }
