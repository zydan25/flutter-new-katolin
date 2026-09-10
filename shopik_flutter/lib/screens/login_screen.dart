import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  @override void dispose() { phone.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    final p = phone.text.trim(); final pass = password.text;
    if (p.isEmpty || pass.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل رقم الهاتف وكلمة المرور'))); return; }
    final ok = await context.read<AppController>().login(p, pass);
    if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AppController>().error ?? 'تعذر تسجيل الدخول')));
  }
  @override Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(builder: (_, c) => SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), child: ConstrainedBox(constraints: BoxConstraints(minHeight: c.maxHeight - 48), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 78, height: 78, decoration: BoxDecoration(color: AppColors.burgundy, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 40)),
        const SizedBox(height: 18), const Text('شبيك | SHOPIK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('البوابة المتكاملة للخدمات الرقمية والمتجر الذكي', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)), const SizedBox(height: 28),
        PageCard(child: Column(children: [
          TextField(controller: phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'رقم الهاتف أو اسم المستخدم', prefixIcon: Icon(Icons.phone_android_rounded))),
          const SizedBox(height: 12), TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_off : Icons.visibility)))),
          const SizedBox(height: 18), SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: app.loading ? null : submit, child: app.loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w900)))),
        ])),
        const SizedBox(height: 16), const Text('الحساب والمصادقة تُدار من خادم Django مباشرة؛ لا يوجد Token ثابت داخل التطبيق.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black45)),
      ]))))));
  }
}
