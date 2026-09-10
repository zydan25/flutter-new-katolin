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
  final identifier = TextEditingController();
  final password = TextEditingController();
  final registerName = TextEditingController();
  final registerPhone = TextEditingController();
  final registerPassword = TextEditingController();
  final registerConfirm = TextEditingController();
  final auth = LocalAuthentication();
  String governorate = 'إب';
  bool registerMode = false;
  bool obscure = true;
  bool busy = false;
  bool bioBusy = false;
  bool checking = true;
  bool online = false;
  int? latency;
  String? error;
  String? success;
  final governorates = const ['صنعاء', 'إب', 'تعز', 'عدن', 'الحديدة', 'ذمار', 'حضرموت', 'عمران', 'مأرب', 'المحويت'];

  @override void initState() { super.initState(); _health(); }
  @override void dispose() { identifier.dispose(); password.dispose(); registerName.dispose(); registerPhone.dispose(); registerPassword.dispose(); registerConfirm.dispose(); super.dispose(); }

  Future<void> _health() async {
    final started = DateTime.now();
    try {
      await context.read<AppController>().api.v2Root();
      if (!mounted) return;
      setState(() { online = true; latency = DateTime.now().difference(started).inMilliseconds; checking = false; });
    } catch (_) {
      if (mounted) setState(() { online = false; checking = false; });
    }
  }

  Future<void> _login() async {
    if (identifier.text.trim().isEmpty || password.text.isEmpty) { setState(() => error = 'يرجى إدخال رقم الهاتف أو اسم الحساب وكلمة المرور'); return; }
    setState(() { busy = true; error = null; success = null; });
    final ok = await context.read<AppController>().login(identifier.text.trim(), password.text);
    if (!ok && mounted) setState(() => error = context.read<AppController>().error ?? 'تعذر تسجيل الدخول من الخادم');
    if (mounted) setState(() => busy = false);
  }

  Future<void> _register() async {
    if (registerName.text.trim().isEmpty || registerPhone.text.trim().isEmpty || registerPassword.text.isEmpty || registerConfirm.text.isEmpty) { setState(() => error = 'يرجى ملء جميع الحقول المطلوبة'); return; }
    if (registerPassword.text.length < 8) { setState(() => error = 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل'); return; }
    if (registerPassword.text != registerConfirm.text) { setState(() => error = 'كلمة المرور وتأكيدها غير متطابقين'); return; }
    setState(() { busy = true; error = null; success = null; });
    final ok = await context.read<AppController>().register(phone: registerPhone.text.trim(), password: registerPassword.text, fullName: registerName.text.trim(), governorate: governorate);
    if (mounted) {
      if (ok) success = 'تم إنشاء الحساب وتفعيل المحفظة في الخادم بنجاح';
      else error = context.read<AppController>().error ?? 'تعذر إنشاء الحساب في الخادم';
      setState(() => busy = false);
    }
  }

  Future<void> _biometric() async {
    setState(() { bioBusy = true; error = null; success = null; });
    try {
      final secureToken = await context.read<AppController>().api.token();
      if (secureToken == null || secureToken.isEmpty) throw Exception('سجّل الدخول مرة واحدة بكلمة المرور قبل استخدام البصمة.');
      final authenticated = await auth.authenticate(localizedReason: 'تأكيد تسجيل الدخول إلى شبيك');
      if (!authenticated) throw Exception('لم يتم التحقق من البصمة.');
      final me = await context.read<AppController>().api.me();
      final raw = me['user'] is Map ? Map<String, dynamic>.from(me['user']) : me;
      context.read<AppController>().user = UserProfile.fromJson(raw);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await context.read<AppController>().refreshAll(quiet: true);
      context.read<AppController>().notifyListeners();
      if (mounted) setState(() => success = 'تم التحقق بالبصمة من جلسة الخادم');
    } on PlatformException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'مستشعر البصمة غير متاح');
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => bioBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.page, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 14), child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(99)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: checking ? Colors.amber : online ? AppColors.emerald : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 6), Text(checking ? 'جاري فحص الاتصال بالخادم...' : online ? 'الخادم متصل ونشط (shopik.alattab.site) • ${latency ?? ''}ms' : 'خادم شبيك السحابي', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF334155)))])),
      const SizedBox(height: 12),
      Container(width: 82, height: 82, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x180F172A), blurRadius: 14, offset: Offset(0, 5))]), child: const Icon(Icons.shopping_bag_rounded, color: AppColors.burgundy, size: 45)),
      const SizedBox(height: 13), const Text('تطبيق شبيك | SHOPIK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4), const Text('البوابة المتكاملة لسداد الاتصالات، المتجر الذكي، وشبكات الوايفاي', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w700)),
      const SizedBox(height: 15),
      PageCard(padding: const EdgeInsets.all(13), child: Column(children: [
        if (error != null) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFFFFF1F2), border: Border.all(color: const Color(0xFFFECACA)), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.error_outline_rounded, color: Colors.red, size: 17), const SizedBox(width: 7), Expanded(child: Text(error!, style: const TextStyle(fontSize: 9.5, color: Color(0xFFBE123C), fontWeight: FontWeight.w800)))])),
        if (success != null) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFFECFDF5), border: Border.all(color: const Color(0xFFA7F3D0)), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 17), const SizedBox(width: 7), Expanded(child: Text(success!, style: const TextStyle(fontSize: 9.5, color: Color(0xFF047857), fontWeight: FontWeight.w800)))])),
        if (!registerMode) Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: _login, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0F766E)]), borderRadius: BorderRadius.circular(16)), child: const ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3), leading: Icon(Icons.verified_user_rounded, color: Colors.white), title: Text('دخول مباشر بحساب الخادم النشط', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)), subtitle: Text('المصادقة الحقيقية فقط — بدون رمز ثابت داخل التطبيق', style: TextStyle(color: Colors.white70, fontSize: 8.5)), trailing: Icon(Icons.arrow_back_ios_rounded, size: 13, color: Colors.white))))),
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: GestureDetector(onTap: () => setState(() { registerMode = false; error = null; success = null; }), child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: !registerMode ? AppColors.burgundy : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text('تسجيل الدخول', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: !registerMode ? Colors.white : Colors.black54)))), Expanded(child: GestureDetector(onTap: () => setState(() { registerMode = true; error = null; success = null; }), child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: registerMode ? AppColors.burgundy : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text('حساب جديد', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: registerMode ? Colors.white : Colors.black54))))])),
        const SizedBox(height: 12),
        if (!registerMode) ...[
          _field(identifier, 'رقم الهاتف / اسم الحساب', Icons.smartphone_rounded, textDirection: TextDirection.ltr),
          const SizedBox(height: 9),
          TextField(controller: password, obscureText: obscure, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), labelText: 'كلمة المرور / الرمز السري', suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded)), isDense: true)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 47, child: FilledButton(onPressed: busy ? null : _login, style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: busy ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تسجيل الدخول المباشر', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 43, child: OutlinedButton.icon(onPressed: bioBusy ? null : _biometric, icon: bioBusy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.burgundy)) : const Icon(Icons.fingerprint_rounded, color: AppColors.burgundy, size: 19), label: Text(bioBusy ? 'جاري فحص مستشعر البصمة...' : 'تسجيل الدخول بالبصمة الحيوية', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)))),
          const SizedBox(height: 6), const Text('البصمة تستخدم جلسة محفوظة ومصادقة الجهاز؛ لا توجد بيانات دخول ثابتة داخل الكود.', textAlign: TextAlign.center, style: TextStyle(fontSize: 8.5, color: Colors.black45, fontWeight: FontWeight.w600)),
        ] else ...[
          _field(registerName, 'الاسم الكامل / الرباعي', Icons.person_outline_rounded),
          const SizedBox(height: 8),
          _field(registerPhone, 'رقم الهاتف (اليمن)', Icons.smartphone_rounded, textDirection: TextDirection.ltr, digitsOnly: true, maxLength: 9),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: governorate, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), labelText: 'المحافظة', isDense: true), items: governorates.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)))).toList(), onChanged: (v) { if (v != null) setState(() => governorate = v); }),
          const SizedBox(height: 8),
          _field(registerPassword, 'كلمة المرور (8 أحرف على الأقل)', Icons.lock_outline_rounded, obscureText: true),
          const SizedBox(height: 8),
          _field(registerConfirm, 'تأكيد كلمة المرور', Icons.lock_outline_rounded, obscureText: true),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 47, child: FilledButton(onPressed: busy ? null : _register, style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: busy ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('إنشاء الحساب والتسجيل الفوري', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)))),
        ],
      ])),
      const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: AppColors.border)), child: const Text('برمجة وتطوير: يمن كود للتقنيات الذكية', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.muted))),
      const SizedBox(height: 5), const Text('Yemen Code for Smart Technologies © 2026 • جميع الحقوق محفوظة', style: TextStyle(fontSize: 8, color: Colors.black38)),
    ])));
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextDirection? textDirection, bool obscureText = false, bool digitsOnly = false, int? maxLength}) => TextField(controller: controller, obscureText: obscureText, textDirection: textDirection, keyboardType: digitsOnly ? TextInputType.phone : TextInputType.text, maxLength: maxLength, inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null, decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label, counterText: '', isDense: true));
}
