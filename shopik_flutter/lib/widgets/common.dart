import 'package:flutter/material.dart';

class AppColors {
  static const burgundy = Color(0xFF8B1D3B);
  static const cyan = Color(0xFF26C6DA);
  static const orange = Color(0xFFFED7AA);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF0284C7);
  static const indigo = Color(0xFF283593);
  static const page = Color(0xFFF4F6F9);
}

class PageCard extends StatelessWidget {
  const PageCard({super.key, required this.child, this.padding = const EdgeInsets.all(12)});
  final Widget child; final EdgeInsets padding;
  @override Widget build(BuildContext context) => Container(
    width: double.infinity, padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x11000000), offset: Offset(0, 2))]),
    child: child,
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.color = AppColors.burgundy});
  final String title; final Color color;
  @override Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
    child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
  );
}

class BusyOverlay extends StatelessWidget {
  const BusyOverlay({super.key, required this.visible, this.text = 'الرجاء الإنتظار قليلاً...'});
  final bool visible; final String text;
  @override Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(child: Container(color: Colors.black54, child: Center(child: Container(width: 220, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(strokeWidth: 3), const SizedBox(height: 16), Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))]))));
  }
}

class AmountDialog extends StatelessWidget {
  const AmountDialog({super.key, required this.title, required this.amount, required this.phone, required this.onConfirm});
  final String title, amount, phone; final VoidCallback onConfirm;
  @override Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.info_outline, color: AppColors.amber), SizedBox(width: 8), Text('تأكيد الطلب', style: TextStyle(fontWeight: FontWeight.w900))]),
    content: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 12), _row('رقم الهاتف', phone), _row('المبلغ', '$amount ر.ي')]),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), ElevatedButton(onPressed: onConfirm, child: const Text('موافق'))],
  );
}

Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: const TextStyle(color: Colors.black54)), Flexible(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.end))]));
