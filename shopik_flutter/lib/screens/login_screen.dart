import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ShopikLoginScreen extends StatefulWidget {
  const ShopikLoginScreen({super.key});
  @override State<ShopikLoginScreen> createState() => _ShopikLoginScreenState();
}

class _ShopikLoginScreenState extends State<ShopikLoginScreen> {
  final phone = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final regPhone = TextEditingController();
  final regPassword = TextEditingController();
  final regConfirm = TextEditingController();
  final biometric = LocalAuthentication();
  bool registerMode = false;
  bool obscure = true;
  bool busy = false;
  bool bioBusy = false;
  bool checking = true;
  bool online = false;
  int? latency;
  String governorate = 'صنعاء';
  String? error;
  String? success;
  final governorates = const ['صنعاء','إب','تعز','عدن','الحديدة','ذمار','حضرموت','عمران','مأرب','المحويت'];

  @override void initState() { super.initState(); _health(); }
  @override void dispose() { phone.dispose(); password.dispose(); name.dispose(); regPhone.dispose(); regPassword.dispose(); regConfirm.dispose(); super.dispose(); }

  Future<void> _health() async {
    final start = DateTime.now();
    try {
      await context.read<AppController>().api.v2Root();
      if (!mounted) return;
      setState(() { online = true; latency = DateTime.now().difference(start).inMilliseconds; checking = false; });
    } catch (_) {
      if (mounted) setState(() { online = false; checking = false; });
    }
  }

  Future<void> _login() async {
    if (phone.text.trim().isEmpty || password.text.isEmpty) { setState(() => error = 'يرجى إدخال رقم الهاتف واسم الحساب وكلمة المرور'); return; }
    setState(() { busy = true; error = null; success = null; });
    final app = context.read<AppController>();
    final ok = await app.login(phone.text.trim(), password.text);
    if (!ok && mounted) setState(() => error = app.error ?? 'فشل تسجيل الدخول من الخادم');
    if (mounted) setState(() => busy = false);
  }

  Future<void> _register() async {
    if (name.text.trim().isEmpty || regPhone.text.trim().isEmpty || regPassword.text.isEmpty || regConfirm.text.isEmpty) { setState(() => error = 'يرجى ملء جميع الحقول المطلوبة'); return; }
    if (regPassword.text.length < 8) { setState(() => error = 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل'); return; }
    if (regPassword.text != regConfirm.text) { setState(() => error = 'كلمة المرور وتأكيدها غير متطابقين'); return; }
    setState(() { busy = true; error = null; success = null; });
    final app = context.read<AppController>();
    final ok = await app.register(phone: regPhone.text.trim(), password: regPassword.text, fullName: name.text.trim(), governorate: governorate);
    if (mounted) {
      if (ok) success = 'تم إنشاء الحساب وربطه بخادم شبيك بنجاح';
      else error = app.error ?? 'تعذر إنشاء الحساب في الخادم';
      setState(() => busy = false);
    }
  }

  Future<void> _biometricLogin() async {
    setState(() { bioBusy = true; error = null; success = null; });
    try {
      final token = await context.read<AppController>().api.token();
      if (token == null || token.isEmpty) throw Exception('سجّل الدخول مرة واحدة بكلمة المرور قبل استخدام البصمة.');
      final ok = await biometric.authenticate(localizedReason: 'تسجيل الدخول إلى تطبيق شبيك بالبصمة');
      if (!ok) throw Exception('لم يتم التحقق من البصمة.');
      final raw = await context.read<AppController>().api.me();
      final obj = raw['user'] is Map ? Map<String,dynamic>.from(raw['user']) : raw;
      final app = context.read<AppController>();
      app.user = UserProfile.fromJson(obj);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await app.refreshAll(quiet: true);
      app.notifyStateChanged();
    } on PlatformException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'مستشعر البصمة غير متاح');
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => bioBusy = false);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 16), child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(99)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: checking ? Colors.amber : online ? AppColors.emerald : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 6), Text(checking ? 'جاري فحص الاتصال بالخادم...' : online ? 'الخادم متصل ونشط (shopik.alattab.site) • ${latency ?? '-'}ms' : 'خادم شبيك السحابي', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF334155)))])),
        const SizedBox(height: 12),
        Container(width: 82, height: 82, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x180F172A), blurRadius: 14, offset: Offset(0, 5))]), child: const ClipRRect(borderRadius: BorderRadius.all(Radius.circular(20)), child: Icon(Icons.shopping_bag_rounded, color: AppColors.burgundy, size: 46))),
        const SizedBox(height: 13),
        const Text('تطبيق شبيك | SHOPIK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('البوابة المتكاملة لسداد الاتصالات، المتجر الذكي، وشبكات الوايفاي', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 15),
        PageCard(padding: const EdgeInsets.all(13), child: Column(children: [
          if (error != null) _message(error!, false),
          if (success != null) _message(success!, true),
          if (!registerMode) Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0F766E)]), borderRadius: BorderRadius.circular(16)), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), leading: const Icon(Icons.verified_user_rounded, color: Colors.white), title: const Text('دخول مباشر بحساب الخادم النشط', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)), subtitle: const Text('المصادقة الحقيقية فقط — بدون رمز ثابت داخل التطبيق', style: TextStyle(color: Colors.white70, fontSize: 8.5)), trailing: const Icon(Icons.arrow_back_ios_rounded, size: 13, color: Colors.white))),
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: _tab('تسجيل الدخول', !registerMode, () => setState(() { registerMode = false; error = null; success = null; }))), Expanded(child: _tab('حساب جديد', registerMode, () => setState(() { registerMode = true; error = null; success = null; })))])),
          const SizedBox(height: 12),
          if (!registerMode) ...[
            _field(phone, 'رقم الهاتف / اسم الحساب', Icons.smartphone_rounded, ltr: true, digits: true), const SizedBox(height: 9),
            TextField(controller: password, obscureText: obscure, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), labelText: 'كلمة المرور', suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded)), isDense: true)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 47, child: FilledButton(onPressed: busy ? null : _login, style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: busy ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تسجيل الدخول المباشر', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)))),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, height: 43, child: OutlinedButton.icon(onPressed: bioBusy ? null : _biometricLogin, icon: bioBusy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.burgundy)) : const Icon(Icons.fingerprint_rounded, color: AppColors.burgundy, size: 19), label: Text(bioBusy ? 'جاري فحص مستشعر البصمة...' : 'تسجيل الدخول بالبصمة الحيوية', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)))),
          ] else ...[
            _field(name, 'الاسم الكامل / الرباعي', Icons.person_outline_rounded), const SizedBox(height: 8),
            _field(regPhone, 'رقم الهاتف (اليمن)', Icons.smartphone_rounded, ltr: true, digits: true, maxLength: 9), const SizedBox(height: 8),
            DropdownButtonFormField<String>(initialValue: governorate, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), labelText: 'المحافظة', isDense: true), items: governorates.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)))).toList(), onChanged: (v) { if (v != null) setState(() => governorate = v); }),
            const SizedBox(height: 8), _field(regPassword, 'كلمة المرور (8 أحرف على الأقل)', Icons.lock_outline_rounded, obscure: true), const SizedBox(height: 8), _field(regConfirm, 'تأكيد كلمة المرور', Icons.lock_outline_rounded, obscure: true), const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 47, child: FilledButton(onPressed: busy ? null : _register, style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: busy ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('إنشاء الحساب والتسجيل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)))),
          ],
        ])),
        const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: AppColors.border)), child: const Text('برمجة وتطوير: يمن كود للتقنيات الذكية', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.muted))),
      ])),
    );
  }
  Widget _message(String text, bool ok) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: ok ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2), border: Border.all(color: ok ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded, color: ok ? AppColors.emerald : Colors.red, size: 17), const SizedBox(width: 7), Expanded(child: Text(text, style: TextStyle(fontSize: 9.5, color: ok ? const Color(0xFF047857) : const Color(0xFFBE123C), fontWeight: FontWeight.w800)))]));
  Widget _tab(String text, bool active, VoidCallback onTap) => GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: active ? AppColors.burgundy : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? Colors.white : Colors.black54))));
  Widget _field(TextEditingController c, String label, IconData icon, {bool ltr = false, bool digits = false, bool obscure = false, int? maxLength}) => TextField(controller: c, obscureText: obscure, textDirection: ltr ? TextDirection.ltr : TextDirection.rtl, keyboardType: digits ? TextInputType.phone : TextInputType.text, inputFormatters: digits ? [FilteringTextInputFormatter.digitsOnly] : null, maxLength: maxLength, decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label, counterText: '', isDense: true));
}

class LoginScreen extends StatelessWidget { const LoginScreen({super.key}); @override Widget build(BuildContext context) => const ShopikLoginScreen(); }
