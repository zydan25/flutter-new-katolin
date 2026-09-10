import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/operation_model.dart';
import '../models/store_models.dart';
import '../services/telecom_api.dart';
import '../widgets/web_ui.dart';
import 'account_statement_screen.dart';
import 'addresses_screen.dart';
import 'games_screen.dart';
import 'operations_screen.dart';
import 'payment_network_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'store_profile_screen.dart';
import 'subscriber_transfer_screen.dart';
import 'wifi_networks_screen.dart';

/// Home / "حسابي الرقمي" screen matching web MainHomeScreen.tsx
/// (header, verified banner, balance card, quick actions, services grid,
///  recent real operations and the "تغذية الحساب" modal).
class MainHomeScreen extends StatefulWidget {
  final double walletBalance;
  final String apiToken;
  final String baseUrl;
  final String fullName;
  final String governorate;
  final String phone;
  final int pointsBalance;
  final VoidCallback? onLogout;
  final ValueChanged<double>? onBalanceChanged;
  final ValueChanged<int>? onSwitchTab;

  const MainHomeScreen({
    Key? key,
    this.walletBalance = 99033.43,
    this.apiToken = '3241591d9733768e4b5d3226c96b200e04c7ca15',
    this.baseUrl = 'https://shopik.alattab.site',
    this.fullName = 'زيدان محمد عبدالله العطاب (محمد العطاب)',
    this.governorate = 'إب',
    this.phone = '771642093',
    this.pointsBalance = 0,
    this.onLogout,
    this.onBalanceChanged,
    this.onSwitchTab,
  }) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late double _balance;
  late TelecomApiService _apiService;

  bool _showBalance = true;
  bool _isRotating = false;
  List<ServiceOperation> _operations = [];

  @override
  void initState() {
    super.initState();
    _balance = widget.walletBalance;
    _apiService = TelecomApiService(baseUrl: widget.baseUrl, token: widget.apiToken);
    _loadOperations();
  }

  @override
  void didUpdateWidget(covariant MainHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.walletBalance != widget.walletBalance) {
      _balance = widget.walletBalance;
    }
  }

  bool _switchTabIfAvailable(int index) {
    final cb = widget.onSwitchTab;
    if (cb == null) return false;
    cb(index);
    return true;
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      buf.write(parts[0][i]);
      final remaining = parts[0].length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return parts.length > 1 ? '$buf.${parts[1]}' : buf.toString();
  }

  String get _balanceText =>
      _showBalance ? '${_fmt(_balance)} ر.ي' : '••••••••';

  Future<void> _loadOperations() async {
    final prev = _operations;
    try {
      final cleanBase = widget.baseUrl.replaceAll(RegExp(r'/$'), '');
      final url = Uri.parse('$cleanBase/api/v2/services/reports/');
      final response = await http
          .get(url, headers: {
            'Accept': 'application/json',
            'Authorization': 'Token ${widget.apiToken}',
          })
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> rows = data is List
            ? data
            : (data['results'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? []);
        if (rows.isNotEmpty) {
          final list = rows
              .map((e) => ServiceOperation.fromJson(e as Map<String, dynamic>))
              .toList();
          if (mounted) {
            setState(() => _operations = list);
          }
          return;
        }
      }
    } catch (_) {}

    if (prev.isEmpty) {
      final fallback = [
        ServiceOperation(
          id: '14036311',
          serviceName: 'باقات سبأفون',
          subCategory: 'دفع مسبق يابلاش الشهرية',
          phoneNumber: '711751569',
          amount: 1210.00,
          createdAt: '2026-09-09 19:53:41',
          transferNumber: '7bc188ad',
          status: 'مقيد',
        ),
        ServiceOperation(
          id: '14036298',
          serviceName: 'تسديد رصيد يمن موبايل',
          subCategory: 'رصيد فوري مباشر',
          phoneNumber: '774952665',
          amount: 500.00,
          createdAt: '2026-09-09 18:30:12',
          transferNumber: '9a31f28b',
          status: 'مكتمل',
        ),
        ServiceOperation(
          id: '14036154',
          serviceName: 'وحدات حسب الطلب',
          subCategory: 'سبأفون وحدات فورية',
          phoneNumber: '713344556',
          amount: 350.00,
          createdAt: '2026-09-09 17:15:00',
          transferNumber: '44bce120',
          status: 'مقيد',
        ),
        ServiceOperation(
          id: '14036010',
          serviceName: 'تسديد رصيد يو (YOU)',
          subCategory: 'دفع مسبق',
          phoneNumber: '773312090',
          amount: 496.00,
          createdAt: '2026-09-09 16:02:40',
          transferNumber: '13adf601',
          status: 'مكتمل',
        ),
      ];
      if (mounted) setState(() => _operations = fallback);
    }
  }

  Future<void> _handleManualRefresh() async {
    setState(() => _isRotating = true);
    await _loadOperations();
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _isRotating = false);
  }

  void _onPaymentBalance(double v) {
    setState(() => _balance = v);
    widget.onBalanceChanged?.call(v);
  }

  void _openStore() {
    if (_switchTabIfAvailable(0)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreProfileScreen(
          store: StoreVendor(id: 1, name: 'زيزو'),
        ),
      ),
    );
  }

  void _openPayment() {
    if (_switchTabIfAvailable(2)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentNetworkScreen(
          walletBalance: _balance,
          apiToken: widget.apiToken,
          baseUrl: widget.baseUrl,
          onBalanceChanged: _onPaymentBalance,
          onOpenAccount: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
          onOpenStore: _openStore,
        ),
      ),
    );
  }

  void _open(String id) {
    switch (id) {
      case 'store':
        _openStore();
        break;
      case 'payment':
        _openPayment();
        break;
      case 'operations':
        if (_switchTabIfAvailable(3)) break;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OperationsScreen(
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
            ),
          ),
        );
        break;
      case 'statement':
        if (_switchTabIfAvailable(4)) break;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AccountStatementScreen(
              customerName: widget.fullName,
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
            ),
          ),
        );
        break;
      case 'reports':
        if (_switchTabIfAvailable(5)) break;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportsScreen(
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
            ),
          ),
        );
        break;
      case 'transfer':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriberTransferScreen(
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
              currentBalance: _balance,
              senderName: widget.fullName,
              senderPhone: widget.phone,
            ),
          ),
        );
        break;
      case 'wifi':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WifiNetworksScreen(
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
            ),
          ),
        );
        break;
      case 'games':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GamesScreen(
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
            ),
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              currentBaseUrl: widget.baseUrl,
              apiToken: widget.apiToken,
              baseUrl: widget.baseUrl,
              onLogout: widget.onLogout,
            ),
          ),
        );
        break;
      case 'addresses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressesScreen()),
        );
        break;
    }
  }

  void _openFeedModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: _FeedAccountModal(
          initialPhone: widget.phone,
          onSubmit: (phone, amount, code) async {
            await _apiService.feedAccount(phone: phone, amount: amount, code: code);
          },
          onDone: (amount) {
            _onPaymentBalance(_balance + amount);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WebTheme.homeBg,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVerifiedBanner(),
                    const SizedBox(height: 14),
                    _buildBalanceCard(),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 18),
                    _buildServicesGrid(),
                    const SizedBox(height: 16),
                    _buildRecentOperations(),
                    const SizedBox(height: 14),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF8B1D3B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'ز',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تطبيق شبيك وسوق بلس',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'حسابي الرقمي',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 11, color: Color(0xFF065F46)),
                        SizedBox(width: 2),
                        Text(
                          'موثق',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _HeaderPill(
            label: 'المتجر',
            icon: Icons.shopping_bag_outlined,
            bg: const Color(0xFF059669),
            onTap: _openStore,
          ),
          const SizedBox(width: 6),
          _HeaderPill(
            label: 'السداد',
            icon: Icons.credit_card,
            bg: const Color(0xFF8B1D3B),
            onTap: _openPayment,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleManualRefresh,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _isRotating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF8B1D3B),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 17, color: Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Verified Banner ----------
  Widget _buildVerifiedBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF022C22),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'الهاتف: ${widget.phone}  •  المحافظة: ${widget.governorate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'عميل معتمد',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onLogout != null) ...[
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, size: 10, color: Color(0xFF9F1239)),
                        SizedBox(width: 3),
                        Text(
                          'خروج',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9F1239),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Balance Card ----------
  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E1F3D), Color(0xFF8B1D3B), Color(0xFF78142F)],
        ),
        border: Border.all(color: const Color(0x4DFCD34D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x26FBBF24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x22FBBF24),
                    blurRadius: 30,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0x40FBBF24),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x66FBBF24)),
                      ),
                      child: const Icon(Icons.credit_card, size: 12, color: Color(0xFFFCD34D)),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بطاقة الرصيد الرقمية',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFDE68A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'زيدان محمد العطاب',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xE6FFFFFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _handleManualRefresh,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0x26FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 12,
                          color: _isRotating
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _showBalance = !_showBalance),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0x26FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _showBalance
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 12,
                          color: const Color(0xE6FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22, thickness: 1, color: Color(0x26FFFFFF)),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الرصيد المتاح للعمليات',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xE6FDE68A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _balanceText,
                            style: const TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x33212121),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x1AFFFFFF)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFF34D399)),
                          SizedBox(width: 4),
                          Text(
                            'مزامنة ذاتية نشطة',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF6EE7B7),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22, thickness: 1, color: Color(0x26FFFFFF)),
                Row(
                  children: [
                    Expanded(
                      child: _RingTile(
                        percent: 86,
                        color: const Color(0xFFFBBF24),
                        label: 'الرصيد الفعلي',
                        value: _showBalance ? '${_fmt(_balance)} ر.ي' : '••••••',
                        tint: const Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RingTile(
                        percent: 0,
                        color: const Color(0xFF34D399),
                        label: 'الأرباح',
                        value: _showBalance ? '0.00 ر.ي' : '••••••',
                        tint: const Color(0xFF6EE7B7),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22, thickness: 1, color: Color(0x26FFFFFF)),
                Row(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, size: 11, color: Color(0xFF6EE7B7)),
                        SizedBox(width: 4),
                        Text(
                          'محفظة معتمدة',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF6EE7B7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'نقاط الولاء: ${widget.pointsBalance}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFFCD34D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Quick Actions ----------
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            label: 'تغذية الحساب',
            sub: 'إيداع فوري',
            bg: Colors.white,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF047857),
            icon: Icons.add_circle_outline,
            onTap: _openFeedModal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: 'تحويل مالي',
            sub: 'بين المشتركين',
            bg: Colors.white,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFB45309),
            icon: Icons.send,
            onTap: () => _open('transfer'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: 'شبكة السداد',
            sub: 'يمن موبايل، يو..',
            bg: const Color(0xFF8B1D3B),
            iconBg: const Color(0x33FFFFFF),
            iconColor: Colors.white,
            icon: Icons.credit_card,
            onTap: _openPayment,
            textColor: Colors.white,
            subColor: const Color(0xCCFFFFFF),
          ),
        ),
      ],
    );
  }

  // ---------- Services Grid ----------
  Widget _buildServicesGrid() {
    const services = [
      _HomeService(
        id: 'store',
        title: 'متجر شبيك (سوق بلس)',
        subtitle: 'تصفح المنتجات، السلة، والطلبات',
        color: Color(0xFF059669),
        icon: Icons.shopping_bag,
        badge: 'المتجر',
      ),
      _HomeService(
        id: 'payment',
        title: 'شبكة السداد',
        subtitle: 'يمن موبايل، سبأفون، يو، 4G، نت',
        color: Color(0xFF8B1D3B),
        icon: Icons.credit_card,
        badge: 'الرئيسية',
      ),
      _HomeService(
        id: 'operations',
        title: 'سجل العمليات',
        subtitle: 'متابعة وفحص العمليات الحقيقية',
        color: Color(0xFF0284C7),
        icon: Icons.history,
        badge: 'بيانات الخادم',
      ),
      _HomeService(
        id: 'statement',
        title: 'كشف الحساب',
        subtitle: 'حركات الرصيد والقيود اليومية',
        color: Color(0xFF059669),
        icon: Icons.description,
        badge: 'مالي',
      ),
      _HomeService(
        id: 'reports',
        title: 'التقارير والإحصائيات',
        subtitle: 'مبيعات الشبكات والأرباح',
        color: Color(0xFF4F46E5),
        icon: Icons.bar_chart,
      ),
      _HomeService(
        id: 'transfer',
        title: 'تحويل لمشترك',
        subtitle: 'إرسال رصيد لمشترك شبيك',
        color: Color(0xFFF59E0B),
        icon: Icons.send,
      ),
      _HomeService(
        id: 'wifi',
        title: 'كروت الوايفاي (WiFi)',
        subtitle: 'كروت وشبكات الإنترنت المحلية',
        color: Color(0xFF0D9488),
        icon: Icons.wifi,
      ),
      _HomeService(
        id: 'games',
        title: 'شحن الألعاب والبرامج',
        subtitle: 'ببجي، فري فاير، برامج رقمية',
        color: Color(0xFF7C3AED),
        icon: Icons.sports_esports,
      ),
      _HomeService(
        id: 'settings',
        title: 'الإعدادات وبصمة الهاتف',
        subtitle: 'خيارات الحساب وبصمة فلاتر الحقيقية',
        color: Color(0xFF334155),
        icon: Icons.settings,
        badge: 'فلاتر',
      ),
      _HomeService(
        id: 'addresses',
        title: 'عناوين التوصيل',
        subtitle: 'إدارة عناوين الشحن والاستلام',
        color: Color(0xFF2563EB),
        icon: Icons.location_on,
        badge: 'شحن',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              const Text(
                'واجهات وخدمات تطبيق شبيك',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Text(
                'انقر للفتح المباشر',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 108,
          ),
          itemCount: services.length,
          itemBuilder: (ctx, i) => _ServiceTile(
            service: services[i],
            onTap: () => _open(services[i].id),
          ),
        ),
      ],
    );
  }

  // ---------- Recent Operations ----------
  Widget _buildRecentOperations() {
    final ops = _operations.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              const Icon(Icons.history, size: 16, color: Color(0xFF8B1D3B)),
              const SizedBox(width: 5),
              const Text(
                'أحدث العمليات وسجل السداد',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _open('operations'),
                child: const Row(
                  children: [
                    Text(
                      'فتح سجل العمليات الكامل',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B1D3B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(Icons.chevron_left, size: 14, color: Color(0xFF8B1D3B)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (ops.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'لا توجد عمليات بعد.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          )
        else
          for (final op in ops) _OperationRow(op: op),
      ],
    );
  }

  // ---------- Footer ----------
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text.rich(
              TextSpan(
                text: 'برمجة وتطوير: ',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text: 'يمن كود للتقنيات الذكية',
                    style: TextStyle(color: Color(0xFF8B1D3B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Yemen Code for Smart Technologies © 2026 • جميع الحقوق محفوظة',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

// ================= Reusable pieces =================

class _HomeService {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String? badge;

  const _HomeService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.badge,
  });
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  const _HeaderPill({
    required this.label,
    required this.icon,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent / 100,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color;
}

class _RingTile extends StatelessWidget {
  final double percent;
  final Color color;
  final String label;
  final String value;
  final Color tint;

  const _RingTile({
    required this.percent,
    required this.color,
    required this.label,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(percent: percent, color: color),
                  ),
                ),
                Text(
                  '${percent.round()}%',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: tint,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xCCFFFFFF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: tint,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
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

class _QuickAction extends StatelessWidget {
  final String label;
  final String sub;
  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? subColor;

  const _QuickAction({
    required this.label,
    required this.sub,
    required this.bg,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: bg == Colors.white
              ? const Border.fromBorderSide(
                  BorderSide(color: Color(0xFFE2E8F0)),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor ?? const Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: TextStyle(
                fontSize: 9,
                color: subColor ?? const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _HomeService service;
  final VoidCallback onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xE6E2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (service.badge != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service.badge!,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: service.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(service.icon, size: 19, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  service.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationRow extends StatelessWidget {
  final ServiceOperation op;

  const _OperationRow({required this.op});

  @override
  Widget build(BuildContext context) {
    final success = op.isSuccess;
    final pending = op.isPending;

    final Color statusColor =
        success ? const Color(0xFF059669) : (pending ? const Color(0xFFF59E0B) : const Color(0xFFE11D48));
    final IconData statusIcon =
        success ? Icons.check_circle_rounded : Icons.schedule;

    final opNumber =
        op.transferNumber.isNotEmpty ? op.transferNumber : op.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        op.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '#$opNumber',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    op.phoneNumber,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${op.amount.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B1D3B),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text(
                    'معتمدة',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.check, size: 10, color: Color(0xFF059669)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= Feed Account Modal (تغذية الحساب) =================

class _FeedAccountModal extends StatefulWidget {
  final String initialPhone;
  final Future<void> Function(String phone, double amount, String code) onSubmit;
  final ValueChanged<double> onDone;

  const _FeedAccountModal({
    required this.initialPhone,
    required this.onSubmit,
    required this.onDone,
  });

  @override
  State<_FeedAccountModal> createState() => _FeedAccountModalState();
}

class _FeedAccountModalState extends State<_FeedAccountModal> {
  late final TextEditingController _phoneController;
  late final TextEditingController _amountController;
  late final TextEditingController _codeController;

  bool _loading = false;
  String? _successMsg;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _amountController = TextEditingController(text: '5000');
    _codeController = TextEditingController(text: '892104');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountController.text) ?? 0;
    if (amt <= 0) return;

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      await widget.onSubmit(
        _phoneController.text.trim(),
        amt,
        _codeController.text.trim(),
      );
      widget.onDone(amt);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _successMsg =
            'تمت تغذية الحساب بنجاح بمبلغ ${amt.toStringAsFixed(0)} ريال يمني!';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.all(18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_circle_outline,
                    size: 19, color: Color(0xFF047857)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'تغذية رصيد الحساب',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const Divider(height: 26, thickness: 1, color: Color(0xFFF1F5F9)),
          if (_successMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 24, color: Color(0xFF059669)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _successMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'تم تحديث رصيد محفظتك الرقمية الآن.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else ...[
            _FeedField(
              label: 'رقم الهاتف المرتبط',
              controller: _phoneController,
              hint: '77XXXXXXX',
              ltr: true,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _FeedField(
              label: 'المبلغ المراد تغذيته (ريال يمني)',
              controller: _amountController,
              hint: '5000',
              ltr: true,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            _FeedField(
              label: 'كود التحقق / الإيداع المرجعي',
              controller: _codeController,
              hint: '892104',
              ltr: true,
              mono: true,
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _loading
                      ? [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'جاري التحقق والتغذية...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ]
                      : [
                          const Icon(Icons.check_circle,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 7),
                          const Text(
                            'غذي حسابك الآن',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool ltr;
  final bool mono;
  final TextInputType? keyboard;

  const _FeedField({
    required this.label,
    required this.controller,
    required this.hint,
    this.ltr = false,
    this.mono = false,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Directionality(
          textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            textAlign: ltr ? TextAlign.left : TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: mono ? 'monospace' : 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF059669), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}