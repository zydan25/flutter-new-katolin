import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../widgets/common.dart';
import 'screen_common.dart';

class FingerprintSettingsScreen extends StatefulWidget {
  const FingerprintSettingsScreen({super.key});
  @override State<FingerprintSettingsScreen> createState() => _FingerprintSettingsScreenState();
}

class _FingerprintSettingsScreenState extends State<FingerprintSettingsScreen> {
  static const storage = FlutterSecureStorage();
  final auth = LocalAuthentication();
  bool biometricLogin = true;
  bool biometricTransactions = true;
  bool hideBalance = false;
  bool pushNotifications = true;
  int autoLockMinutes = 5;
  String serverUrl = 'https://shopik.alattab.site';
  bool available = false;
  bool testing = false;
  String? testResult;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      available = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      final b = await storage.read(key: 'shopik_biometric_enabled');
      final tx = await storage.read(key: 'shopik_biometric_transactions');
      final hb = await storage.read(key: 'shopik_hide_balance');
      final pn = await storage.read(key: 'shopik_push_notifications');
      final lock = await storage.read(key: 'shopik_auto_lock_minutes');
      final url = await storage.read(key: 'shopik_server_url');
      biometricLogin = b != 'false';
      biometricTransactions = tx != 'false';
      hideBalance = hb == 'true';
      pushNotifications = pn != 'false';
      autoLockMinutes = int.tryParse(lock ?? '') ?? 5;
      serverUrl = (url == null || url.isEmpty) ? 'https://shopik.alattab.site' : url;
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _save(String key, String value) => storage.write(key: key, value: value);

  Future<void> _toggleLogin(bool value) async {
    if (value && !available) { setState(() => testResult = 'البصمة غير متاحة على هذا الجهاز.'); return; }
    if (value) {
      final ok = await auth.authenticate(localizedReason: 'يرجى لمس مستشعر البصمة لتفعيل الدخول السريع');
      if (!ok) return;
    }
    setState(() => biometricLogin = value);
    await _save('shopik_biometric_enabled', '$value');
    if (value && mounted) setState(() => testResult = 'تم تفعيل الدخول بالبصمة الحقيقية بنجاح ✓');
  }

  Future<void> _test() async {
    setState(() { testing = true; testResult = null; });
    try {
      final ok = available && await auth.authenticate(localizedReason: 'فحص وتجربة مستشعر البصمة الآن');
      if (mounted) setState(() => testResult = ok ? 'تمت المصادقة بالبصمة الحقيقية بنجاح تام ✓' : 'لم يتم التحقق من البصمة.');
    } catch (e) {
      if (mounted) setState(() => testResult = e.toString());
    } finally { if (mounted) setState(() => testing = false); }
  }

  Widget _switchRow(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged, {Color color = AppColors.burgundy}) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      secondary: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 22)),
      title: Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
      value: value,
      activeColor: color,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final token = app.api.currentTokenPreview;
    return ScreenFrame(title: 'إعدادات البصمة والحماية', color: AppColors.burgundy, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)), IconButton(onPressed: app.logout, icon: const Icon(Icons.logout_rounded))], child: ListView(padding: const EdgeInsets.all(12), children: [
      PageCard(child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.fingerprint_rounded, color: AppColors.burgundy, size: 28)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المصادقة البيومترية (Android Biometric / Keystore)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('مفتاح الجلسة محفوظ بطريقة آمنة داخل الجهاز', style: TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w600))])), StatusBadge(text: available ? 'متاح ✓' : 'غير متاح', color: available ? AppColors.emerald : Colors.red)]),
      if (testResult != null) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(15)), child: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white, size: 17), const SizedBox(width: 7), Expanded(child: Text(testResult!, style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w900))) ]))],
      const SizedBox(height: 9),
      PageCard(padding: EdgeInsets.zero, child: Column(children: [
        _switchRow('تسجيل الدخول السريع بالبصمة', 'تخطي كتابة كلمة المرور وفتح التطبيق بالبصمة', Icons.fingerprint_rounded, biometricLogin, _toggleLogin),
        const Divider(height: 1),
        _switchRow('طلب البصمة قبل تأكيد عمليات التسديد', 'حماية إضافية قبل خصم الرصيد أو تنفيذ التحويل', Icons.security_rounded, biometricTransactions, (v) { setState(() => biometricTransactions = v); _save('shopik_biometric_transactions', '$v'); }),
        const Divider(height: 1),
        ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1), leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.lock_clock_rounded, color: Color(0xFF475569))), title: const Text('القفل التلقائي للتطبيق', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), subtitle: const Text('عند ترك التطبيق في الخلفية', style: TextStyle(fontSize: 9, color: AppColors.muted)), trailing: DropdownButton<int>(value: autoLockMinutes, underline: const SizedBox.shrink(), items: const [DropdownMenuItem(value:1,child:Text('دقيقة')),DropdownMenuItem(value:5,child:Text('5 دقائق')),DropdownMenuItem(value:15,child:Text('15 دقيقة')),DropdownMenuItem(value:30,child:Text('30 دقيقة'))], onChanged:(v){if(v!=null){setState(()=>autoLockMinutes=v);_save('shopik_auto_lock_minutes','$v');}})),
      ])),
      const SizedBox(height: 9),
      SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: testing ? null : _test, style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), icon: testing ? const SizedBox(width:17,height:17,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.fingerprint_rounded), label: Text(testing ? 'جاري قراءة البصمة...' : 'فحص وتجربة مستشعر البصمة الآن', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 9),
      PageCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Row(children: [Icon(Icons.settings_rounded, color: AppColors.burgundy, size: 17), SizedBox(width: 6), Text('تفضيلات الخصوصية والإشعارات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]), const SizedBox(height: 4), _switchRow('إخفاء الرصيد تلقائياً', 'إخفاء الرصيد عند فتح التطبيق لحماية الخصوصية', Icons.visibility_off_rounded, hideBalance, (v){setState(()=>hideBalance=v);_save('shopik_hide_balance','$v');}, color: const Color(0xFF475569)), const Divider(), _switchRow('إشعارات العمليات الفورية', 'تنبيهات وصول الحوالات ونتائج السداد', Icons.notifications_active_rounded, pushNotifications, (v){setState(()=>pushNotifications=v);_save('shopik_push_notifications','$v');}, color: const Color(0xFF475569))])),
      const SizedBox(height: 9),
      PageCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Row(children: [Icon(Icons.dns_rounded, color: AppColors.burgundy, size: 17), SizedBox(width: 6), Text('عنوان الخادم المركزي (Backend URL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), TextField(controller: TextEditingController(text: serverUrl), textDirection: TextDirection.ltr, decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF1F5F9), border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 5), const Text('الخادم الرسمي المعتمد: shopik.alattab.site', style: TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w700))])),
      const SizedBox(height: 9),
      PageCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('بيانات الجلسة الحالية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(height: 5), _SessionLine('رقم الهاتف', app.user?.phone ?? '-'), _SessionLine('حالة التخزين', 'مشفر ومخزن محلياً ✓', color: AppColors.emerald), _SessionLine('توكن المصادقة', token)])),
      const SizedBox(height: 9),
      SizedBox(width: double.infinity, height: 46, child: OutlinedButton.icon(onPressed: app.logout, style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Color(0xFFFECACA), backgroundColor: Color(0xFFFFF1F2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), icon: const Icon(Icons.logout_rounded), label: const Text('تسجيل الخروج من الحساب', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)))),
    ]));
  }
}

class _SessionLine extends StatelessWidget { const _SessionLine(this.label,this.value,{this.color}); final String label,value; final Color? color; @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:const TextStyle(fontSize:9,color:AppColors.muted)),Flexible(child:Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900,color:color??const Color(0xFF0F172A))))])); }
