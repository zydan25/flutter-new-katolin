import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String currentBaseUrl;
  final VoidCallback? onLogout;
  final Function(String newUrl)? onBaseUrlChanged;
  final VoidCallback? onBackToMain;

  const SettingsScreen({
    Key? key,
    this.currentBaseUrl = 'https://shopik.alattab.site',
    this.onLogout,
    this.onBaseUrlChanged,
    this.onBackToMain,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Login & Security Toggles (Matches Screenshot 11)
  bool _biometricLoginEnabled = true;
  bool _biometricOperationsEnabled = true;
  bool _pinCodeEnabled = false;

  // Balance Alert Settings
  bool _balanceAlertEnabled = true;
  final TextEditingController _balanceAlertController = TextEditingController(text: '5000');

  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentBaseUrl);
  }

  @override
  void dispose() {
    _balanceAlertController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showChangePinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تغيير الرمز السري', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'الرمز السري الحالي', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'الرمز السري الجديد', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث الرمز السري بنجاح!', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceLicenseDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: const Text(
            'هذا الجهاز مرخص وموثق بنجاح برقم المعرف الأمني لجهازك مع نظام التشفير المتقدم.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تم', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFC62828))),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeServerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تغيير عنوان الخادم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'رابط الخادم (Backend URL)',
              border: OutlineInputBorder(),
              hintText: 'https://shopik.alattab.site',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: () {
                widget.onBaseUrlChanged?.call(_urlController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تغيير الخادم إلى: ${_urlController.text.trim()}', style: const TextStyle(fontFamily: 'Cairo'))),
                );
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828), // Deep Red matching screenshot
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            tooltip: 'عودة',
            onPressed: () {
              if (widget.onBackToMain != null) {
                widget.onBackToMain!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مشاركة رابط التطبيق', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // =========================================================================
            // Section 1: إعدادات الدخول (Matches Screenshot 11)
            // =========================================================================
            _buildSectionHeader('إعدادات الدخول'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // 1. Biometric Login
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    title: 'تفعيل البصمة للدخول للحساب',
                    value: _biometricLoginEnabled,
                    onChanged: (val) {
                      setState(() => _biometricLoginEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'تم تفعيل الدخول عبر البصمة بنجاح' : 'تم تعطيل الدخول عبر البصمة', style: const TextStyle(fontFamily: 'Cairo')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // 2. Biometric Confirm Operations
                  _buildSwitchTile(
                    icon: Icons.security,
                    title: 'تفعيل البصمة لتأكيد العمليات',
                    value: _biometricOperationsEnabled,
                    onChanged: (val) {
                      setState(() => _biometricOperationsEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'تم تفعيل البصمة لتأكيد عمليات التسديد' : 'تم إلغاء البصمة لتأكيد العمليات', style: const TextStyle(fontFamily: 'Cairo')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // 3. PIN Code
                  _buildSwitchTile(
                    icon: Icons.lock_outline,
                    title: 'تفعيل الرمز السري',
                    value: _pinCodeEnabled,
                    onChanged: (val) => setState(() => _pinCodeEnabled = val),
                  ),
                  const Divider(height: 1),

                  // 4. Change PIN
                  ListTile(
                    leading: const Icon(Icons.key, color: Color(0xFFC62828)),
                    title: const Text('تغيير الرمز السري', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey),
                    onTap: _showChangePinDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =========================================================================
            // Section 2: تأكيد الأجهزة (Matches Screenshot 11)
            // =========================================================================
            _buildSectionHeader('تأكيد الأجهزة'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Color(0xFF1976D2)),
                    title: const Text('ترخيص هذا الجهاز', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey),
                    onTap: () => _showDeviceLicenseDialog('ترخيص هذا الجهاز'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.mobile_friendly, color: Color(0xFF2E7D32)),
                    title: const Text('ترخيص جهاز جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey),
                    onTap: () => _showDeviceLicenseDialog('ترخيص جهاز جديد'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner, color: Color(0xFF6A1B9A)),
                    title: const Text('ترخيص جهاز الويب (التقاط الباركود)', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فتح قارئ رمز QR لربط نسخة الويب...', style: TextStyle(fontFamily: 'Cairo'))),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =========================================================================
            // Section 3: اعدادات اخرى (Matches Screenshot 11)
            // =========================================================================
            _buildSectionHeader('اعدادات اخرى'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Balance Notification Alert (Matches Screenshot 11)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: Color(0xFFF57C00)),
                            const SizedBox(width: 8),
                            const Text('اشعاري عندما يكون رصيدي', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 65,
                              height: 32,
                              child: TextField(
                                controller: _balanceAlertController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('ر.ي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Switch(
                          value: _balanceAlertEnabled,
                          activeColor: const Color(0xFFC62828),
                          onChanged: (val) => setState(() => _balanceAlertEnabled = val),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // App Version (Matches Screenshot 11)
                  ListTile(
                    leading: const Icon(Icons.android, color: Color(0xFF388E3C)),
                    title: const Text('اصدار التطبيق: 939', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC62828)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('أنت تستخدم أحدث إصدار من Shopik', style: TextStyle(fontFamily: 'Cairo'))),
                        );
                      },
                      child: const Text('تحديث التطبيق', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Divider(height: 1),

                  // Change Server URL
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined, color: Color(0xFF0288D1)),
                    title: const Text('تغيير عنوان الخادم', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(widget.currentBaseUrl, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey)),
                    trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    onTap: _showChangeServerDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFC62828),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFEF9A9A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من هذا الحساب؟', style: TextStyle(fontFamily: 'Cairo')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onLogout?.call();
                          },
                          child: const Text('تسجيل خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
              label: const Text(
                'تسجيل خروج',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF455A64),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC62828), size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFC62828),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
