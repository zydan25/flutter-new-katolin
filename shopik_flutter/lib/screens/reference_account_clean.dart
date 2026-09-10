import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../widgets/common.dart';
import 'screen_common.dart';
import 'reference_security.dart';

class OperationsView extends StatefulWidget {
  const OperationsView({super.key});

  @override
  State<OperationsView> createState() => _OperationsViewState();
}

class _OperationsViewState extends State<OperationsView> {
  final search = TextEditingController();
  String filter = 'all';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final query = search.text.trim().toLowerCase();
    final rows = app.operations.where((row) {
      final status = '${row['status'] ?? ''}'.toLowerCase();
      final text = '${row['id'] ?? ''} ${row['phone'] ?? ''} ${row['service'] ?? row['packageName'] ?? ''}'.toLowerCase();
      final matchesFilter = filter == 'all' ||
          (filter == 'success' && (status == 'success' || status == 'completed')) ||
          (filter == 'pending' &&
              (status == 'pending' || status == 'queued' || status == 'processing')) ||
          (filter == 'failed' && (status == 'failed' || status == 'rejected'));
      return (query.isEmpty || text.contains(query)) && matchesFilter;
    }).toList();

    return ScreenFrame(
      title: 'سجل العمليات',
      color: AppColors.burgundy,
      actions: [
        IconButton(
          onPressed: app.refreshWalletAndReports,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFEF3C7),
            padding: const EdgeInsets.all(9),
            child: const Text(
              'تعرض الصفحة عمليات العميل المسترجعة من خادم Django فقط.',
              style: TextStyle(
                fontSize: 9.5,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'بحث برقم العملية أو الهاتف أو الخدمة...',
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in const {
                        'all': 'الكل',
                        'success': 'ناجحة',
                        'pending': 'قيد الانتظار',
                        'failed': 'فاشلة',
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ChoiceChip(
                            selected: filter == entry.key,
                            label: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            selectedColor: AppColors.burgundy,
                            labelStyle: TextStyle(
                              color: filter == entry.key
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            onSelected: (_) => setState(() => filter = entry.key),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: app.refreshWalletAndReports,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (rows.isEmpty)
                    const EmptyState(
                      text: 'لا توجد عمليات مطابقة.',
                      icon: Icons.receipt_long_outlined,
                    ),
                  for (final row in rows)
                    RefOperationTile(
                      operation: row,
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => OperationDetailModal(operation: row),
                      ),
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

class OperationDetailModal extends StatelessWidget {
  const OperationDetailModal({super.key, required this.operation});

  final Map<String, dynamic> operation;

  @override
  Widget build(BuildContext context) {
    final status = '${operation['status'] ?? ''}'.toLowerCase();
    final good = status == 'success' || status == 'completed';
    final values = <String, String>{
      'رقم العملية': '${operation['id'] ?? '-'}',
      'الخدمة': '${operation['service'] ?? operation['packageName'] ?? '-'}',
      'الهاتف': '${operation['phone'] ?? '-'}',
      'المبلغ': '${operation['amount'] ?? 0} ${operation['currency'] ?? 'YER'}',
      'الحالة': '${operation['status'] ?? '-'}',
      'التاريخ': '${operation['created_at'] ?? operation['date'] ?? '-'}',
    };

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            good ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: good ? AppColors.emerald : AppColors.amber,
          ),
          const SizedBox(width: 6),
          const Text(
            'تفاصيل العملية',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return ScreenFrame(
      title: 'كشف الحساب',
      color: AppColors.teal,
      actions: [
        IconButton(
          onPressed: app.refreshWalletAndReports,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: app.refreshWalletAndReports,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            PageCard(
              child: Column(
                children: [
                  const Text(
                    'الرصيد الحالي',
                    style: TextStyle(fontSize: 9, color: AppColors.muted),
                  ),
                  Text(
                    money(app.walletBalance),
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${app.statement.length} قيداً محاسبياً',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (app.statement.isEmpty)
              const EmptyState(
                text: 'لا توجد قيود محاسبية.',
                icon: Icons.account_balance_wallet_outlined,
              ),
            for (final row in app.statement)
              PageCard(
                margin: const EdgeInsets.only(bottom: 7),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.blue,
                  ),
                  title: Text(
                    '${row['description'] ?? row['service'] ?? row['reference'] ?? 'قيد محاسبي'}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    '${row['date'] ?? row['created_at'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.muted,
                    ),
                  ),
                  trailing: Text(
                    '${row['amount'] ?? row['value'] ?? 0} ${row['currency'] ?? 'YER'}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final success = app.operations
        .where((o) => ['success', 'completed'].contains('${o['status'] ?? ''}'))
        .length;
    final failed = app.operations
        .where((o) => ['failed', 'rejected'].contains('${o['status'] ?? ''}'))
        .length;

    return ScreenFrame(
      title: 'التقارير والإحصائيات',
      color: AppColors.indigo,
      actions: [
        IconButton(
          onPressed: app.refreshWalletAndReports,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: app.refreshWalletAndReports,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Expanded(
                  child: RefMetric(
                    title: 'كل العمليات',
                    value: '${app.operations.length}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RefMetric(
                    title: 'ناجحة',
                    value: '$success',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RefMetric(
                    title: 'فاشلة',
                    value: '$failed',
                    icon: Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ملخص مباشر من الخادم',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الرصيد: ${money(app.walletBalance)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.burgundy,
                    ),
                  ),
                  Text(
                    'المنتجات: ${app.products.length} • المتاجر: ${app.vendors.length} • الطلبات: ${app.orders.length}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const RefSection(
              title: 'آخر العمليات الناجحة',
              icon: Icons.trending_up_rounded,
              color: AppColors.emerald,
            ),
            const SizedBox(height: 7),
            for (final row in app.operations
                .where((o) => ['success', 'completed'].contains('${o['status'] ?? ''}'))
                .take(8))
              RefOperationTile(operation: row),
          ],
        ),
      ),
    );
  }
}

class SubscriberTransferScreen extends StatefulWidget {
  const SubscriberTransferScreen({super.key});

  @override
  State<SubscriberTransferScreen> createState() =>
      _SubscriberTransferScreenState();
}

class _SubscriberTransferScreenState extends State<SubscriberTransferScreen> {
  final receiver = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();

  Map<String, dynamic>? lookup;
  bool busy = false;

  @override
  void dispose() {
    receiver.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> lookupRecipient() async {
    final phone = receiver.text.trim();
    if (phone.isEmpty) return;

    setState(() => busy = true);
    try {
      lookup = await context.read<AppController>().recipientLookup(phone);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> transfer() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0 || lookup == null) return;

    setState(() => busy = true);
    try {
      final app = context.read<AppController>();
      final result = await app.api.transfer(
        recipient: receiver.text.trim(),
        amount: value,
        note: note.text.trim(),
      );
      await app.refreshWalletAndReports();

      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'نجح التحويل',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'المبلغ: ${result['amount'] ?? value} ر.ي\n'
              'المستلم: ${lookup!['receiver_name'] ?? receiver.text}\n'
              'المرجع: ${result['journal'] ?? result['id'] ?? '-'}',
              textAlign: TextAlign.center,
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تم'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'تحويل لمشترك',
      color: AppColors.amber,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          PageCard(
            child: Column(
              children: [
                TextField(
                  controller: receiver,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم المستلم',
                    prefixIcon: Icon(Icons.person_search_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : lookupRecipient,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('فحص المستلم'),
                  ),
                ),
              ],
            ),
          ),
          if (lookup != null) ...[
            const SizedBox(height: 8),
            PageCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFFBEB),
                  child: Icon(Icons.person, color: AppColors.amber),
                ),
                title: Text(
                  '${lookup!['receiver_name'] ?? receiver.text}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${lookup!['receiver_phone'] ?? receiver.text}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          PageCard(
            child: Column(
              children: [
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ',
                    suffixText: 'ر.ي',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظة اختيارية',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: busy || lookup == null ? null : transfer,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.black87,
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      'تنفيذ التحويل',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WifiNetworksScreen extends StatelessWidget {
  const WifiNetworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return ScreenFrame(
      title: 'شبكات وكروت الوايفاي',
      color: AppColors.teal,
      actions: [
        IconButton(
          onPressed: app.refreshAll,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: app.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const RefSection(
              title: 'الشبكات المتاحة',
              icon: Icons.wifi_rounded,
              color: AppColors.teal,
            ),
            const SizedBox(height: 7),
            if (app.wifi.isEmpty)
              const EmptyState(
                text: 'لا توجد شبكات متاحة من الخادم.',
                icon: Icons.wifi_off_outlined,
              ),
            for (final network in app.wifi)
              PageCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${network['name'] ?? 'شبكة'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${network['location'] ?? network['description'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.muted,
                      ),
                    ),
                    if (network['denominations'] is List)
                      for (final raw in (network['denominations'] as List)
                          .whereType<Map>())
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.confirmation_number_outlined,
                            color: AppColors.teal,
                          ),
                          title: Text(
                            '${raw['name'] ?? 'فئة'}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            '${raw['available_cards'] ?? ''} متاح',
                            style: const TextStyle(fontSize: 8),
                          ),
                          trailing: TextButton(
                            onPressed: () => _buy(
                              context,
                              network,
                              Map<String, dynamic>.from(raw),
                            ),
                            child: Text(
                              '${raw['sale_price'] ?? raw['price'] ?? ''} ر.ي',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const RefSection(
              title: 'الكروت المشتراة',
              icon: Icons.confirmation_number_outlined,
              color: AppColors.blue,
            ),
            const SizedBox(height: 7),
            if (app.wifiCards.isEmpty)
              const EmptyState(
                text: 'لا توجد كروت مشتراة.',
                icon: Icons.confirmation_number_outlined,
              ),
            for (final card in app.wifiCards)
              PageCard(
                margin: const EdgeInsets.only(bottom: 7),
                child: Text(
                  'PIN: ${card['pin_code'] ?? '-'}\n'
                  'Serial: ${card['serial_number'] ?? '-'}\n'
                  'الشبكة: ${card['network_name'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _buy(
    BuildContext context,
    Map network,
    Map<String, dynamic> denomination,
  ) async {
    final networkId = int.tryParse('${network['id'] ?? ''}');
    final denominationId = int.tryParse('${denomination['id'] ?? ''}');
    final price = double.tryParse(
      '${denomination['sale_price'] ?? denomination['price'] ?? 0}',
    );
    if (networkId == null || denominationId == null || price == null) return;

    try {
      final app = context.read<AppController>();
      final result = await app.api.wifiPurchase(
        networkId: networkId,
        denominationId: denominationId,
        phone: app.user?.phone ?? '',
        price: price,
      );
      await app.refreshAll();

      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('تم شراء الكرت'),
            content: Text(
              'PIN: ${result['pin'] ?? result['pin_code'] ?? '-'}\n'
              'Serial: ${result['card_number'] ?? result['serial_number'] ?? '-'}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تم'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class UserProfileEditScreen extends StatelessWidget {
  const UserProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return ScreenFrame(
      title: 'الملف الشخصي',
      color: const Color(0xFF475569),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          PageCard(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.burgundy,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    app.user?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(app.user?.phone ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('المحافظة'),
                  trailing: Text(app.user?.governorate ?? ''),
                ),
                const Divider(),
                const Text(
                  'البيانات معروضة مباشرة من خادم Django.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final rows = <Widget>[
      ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileEditScreen()),
        ),
        leading: const Icon(Icons.person_outline),
        title: const Text('الملف الشخصي'),
      ),
      ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FingerprintSettingsScreen()),
        ),
        leading: const Icon(Icons.fingerprint_rounded),
        title: const Text('البصمة والأمان'),
      ),
      ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
        leading: const Icon(Icons.notifications_none_rounded),
        title: const Text('الإشعارات'),
      ),
      ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountStatementScreen()),
        ),
        leading: const Icon(Icons.receipt_long_outlined),
        title: const Text('كشف الحساب'),
      ),
      ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupportScreen()),
        ),
        leading: const Icon(Icons.support_agent_rounded),
        title: const Text('الدعم والمساعدة'),
      ),
      ListTile(
        onTap: app.refreshAll,
        leading: const Icon(Icons.sync_rounded),
        title: const Text('مزامنة البيانات'),
      ),
      ListTile(
        onTap: () => showAboutDialog(
          context: context,
          applicationName: 'شبيك | SHOPIK',
          applicationVersion: '1.0.0',
          applicationLegalese: 'Yemen Code for Smart Technologies',
        ),
        leading: const Icon(Icons.info_outline_rounded),
        title: const Text('عن التطبيق'),
      ),
      ListTile(
        onTap: app.logout,
        leading: const Icon(Icons.logout_rounded, color: Colors.red),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
        ),
      ),
    ];

    return ScreenFrame(
      title: 'الإعدادات',
      color: const Color(0xFF475569),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          PageCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.burgundy,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    app.user?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(app.user?.phone ?? ''),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('الرصيد'),
                  trailing: Text(
                    money(app.walletBalance),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.burgundy,
                    ),
                  ),
                ),
                const Divider(),
                ...rows,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return ScreenFrame(
      title: 'الإشعارات',
      color: const Color(0xFF475569),
      child: RefreshIndicator(
        onRefresh: app.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (app.notifications.isEmpty)
              const EmptyState(
                text: 'لا توجد إشعارات من الخادم.',
                icon: Icons.notifications_none_rounded,
              ),
            for (final notification in app.notifications)
              PageCard(
                margin: const EdgeInsets.only(bottom: 7),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.burgundy,
                  ),
                  title: Text(
                    '${notification['title'] ?? 'إشعار'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    '${notification['body'] ?? notification['message'] ?? ''}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: TextButton(
                    onPressed: int.tryParse('${notification['id'] ?? ''}') == null
                        ? null
                        : () async {
                            await app.api.markNotificationRead(
                              int.parse('${notification['id']}'),
                            );
                            await app.refreshAll();
                          },
                    child: const Text(
                      'قراءة',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final controller = TextEditingController();
  Map<String, dynamic>? data;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      data = await context.read<AppController>().api.support();
    } catch (_) {
      // Keep the screen usable even when support has no initial data.
    }
    if (mounted) setState(() {});
  }

  Future<void> _send() async {
    final message = controller.text.trim();
    if (message.isEmpty) return;

    setState(() => busy = true);
    try {
      data = await context
          .read<AppController>()
          .api
          .sendSupportMessage(message);
      controller.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversation = data?['conversation'];
    final messages = conversation is Map && conversation['messages'] is List
        ? (conversation['messages'] as List).whereType<Map>().toList()
        : <Map>[];

    return ScreenFrame(
      title: 'التواصل مع الإدارة',
      color: const Color(0xFF475569),
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد رسائل بعد.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final message in messages)
                        Align(
                          alignment: message['sender_role'] == 'customer'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 7),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: message['sender_role'] == 'customer'
                                  ? AppColors.burgundy
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${message['body'] ?? ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color: message['sender_role'] == 'customer'
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: busy ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
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
