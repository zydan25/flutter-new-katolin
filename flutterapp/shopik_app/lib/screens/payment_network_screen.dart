import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/telecom_service.dart';
import '../services/telecom_api.dart';
import '../services/offline_cache.dart';
import '../services/method_channel_bridge.dart';
import '../widgets/web_ui.dart';
import '../widgets/order_confirmation_dialog.dart';
import '../widgets/duplicate_alert_dialog.dart';
import '../widgets/package_detail_sheet.dart';

/// Web-matching denominations (exact arrays from web/src/App.tsx).
class _Denom {
  final int tier;
  final double price;
  final String days;
  const _Denom(this.tier, this.price, this.days);
}

class _NetDenom {
  final String label;
  final double price;
  const _NetDenom(this.label, this.price);
}

const List<_Denom> _ymDenoms = [
  _Denom(200, 242, '8 أيام'),
  _Denom(400, 484, '16 يوم'),
  _Denom(600, 726, '24 يوم'),
  _Denom(800, 968, '32 يوم'),
  _Denom(1000, 1210, '40 يوم'),
  _Denom(1200, 1452, '48 يوم'),
  _Denom(2200, 2662, '88 يوم'),
];

const List<_Denom> _sabafonDenoms = [
  _Denom(22, 273, '5 أيام'),
  _Denom(40, 484, '8 أيام'),
  _Denom(45, 545, '8 أيام'),
  _Denom(60, 726, '14 يوم'),
  _Denom(85, 1029, '40 يوم'),
  _Denom(100, 1210, '50 يوم'),
  _Denom(125, 1513, '60 يوم'),
  _Denom(150, 1815, '60 يوم'),
  _Denom(209, 2529, '180 يوم'),
];

const List<_Denom> _youDenoms = [
  _Denom(410, 496, '7 أيام'),
  _Denom(830, 1004, '30 يوم'),
  _Denom(1000, 1210, '30 يوم'),
  _Denom(1250, 1513, '40 يوم'),
  _Denom(2500, 3025, '60 يوم'),
  _Denom(5000, 6050, '90 يوم'),
  _Denom(7500, 9075, '90 يوم'),
];

const List<_NetDenom> _fourGDenoms = [
  _NetDenom('باقة G 15', 2400),
  _NetDenom('باقة G 25', 4000),
  _NetDenom('باقة G 60', 8000),
  _NetDenom('باقة G 130', 16000),
  _NetDenom('باقة G 250', 26000),
  _NetDenom('باقة G 500', 46000),
];

const List<_NetDenom> _netDenoms = [
  _NetDenom('10G 1M', 1575),
  _NetDenom('24G 1M', 3150),
  _NetDenom('24G 2M', 2520),
  _NetDenom('50G 2M', 4725),
  _NetDenom('66G 4M', 6930),
  _NetDenom('100G 1M', 10500),
];

const List<String> _defaultSubFilters = ['دفع مسبق', 'فوترة', 'شريحة', 'برمجة', '4G'];

class PaymentNetworkScreen extends StatefulWidget {
  final String initialPhone;
  final double walletBalance;
  final String apiToken;
  final String baseUrl;
  final ValueChanged<double>? onBalanceChanged;
  final VoidCallback? onOpenAccount;
  final VoidCallback? onOpenStore;

  const PaymentNetworkScreen({
    Key? key,
    this.initialPhone = '',
    this.walletBalance = 2000,
    this.apiToken = '3241591d9733768e4b5d3226c96b200e04c7ca15',
    this.baseUrl = 'https://shopik.alattab.site',
    this.onBalanceChanged,
    this.onOpenAccount,
    this.onOpenStore,
  }) : super(key: key);

  @override
  State<PaymentNetworkScreen> createState() => _PaymentNetworkScreenState();
}

class _PaymentNetworkScreenState extends State<PaymentNetworkScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _phoneController;
  late TextEditingController _amountController;
  late TextEditingController _unitsController;
  late TelecomApiService _apiService;
  late AnimationController _spinController;

  OperatorConfig _currentOperator = OperatorConfig.yemenMobile;

  bool _isInquiring = false;
  String? _activeMainTab; // null resolves by operator in build

  InquiryResultData? _lastInquiryResult;
  List<PlanType> _planTypes = [];
  List<PackageItem> _allItems = [];
  final Map<String, bool> _accordionState = {};

  bool _userBalanceHidden = true;
  String? _balanceInquiryBanner;
  bool _sabafonRegionNorth = true;
  bool _youSmartCharger = false;

  bool _loadingOpen = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _amountController = TextEditingController(text: '100');
    _unitsController = TextEditingController(text: '10');
    _apiService = TelecomApiService(baseUrl: widget.baseUrl, token: widget.apiToken);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.initialPhone.isNotEmpty) {
      _currentOperator = OperatorConfig.fromPhone(widget.initialPhone);
    }
    _phoneController.addListener(_onPhoneChanged);

    MethodChannelBridge.onContactPicked = (phone) {
      if (mounted) setState(() => _phoneController.text = phone);
    };

    _loadOperatorData(_currentOperator);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _unitsController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading / operator detection
  // ---------------------------------------------------------------------------
  OperatorConfig get operator => _currentOperator;
  Color get headerColor => Color(operator.headerColorValue);
  Color get activeTabColor => Color(operator.activeTabColorValue);

  List<String> get mainTabs {
    final k = operator.kind;
    if (k == OperatorKind.fourG) {
      return const ['باقة يمن 4G', 'رصيد يمن 4G', 'تغيير الباقة', 'فايبر'];
    }
    if (k == OperatorKind.yemenNet) {
      return const ['الانترنت الارضي', 'الهاتف الثابت'];
    }
    if (k == OperatorKind.you) {
      return const ['رصيد', 'فوري', 'باقات', 'جملة', 'فوترة'];
    }
    return const ['رصيد', 'فوري', 'باقات', 'جملة', 'ريال'];
  }

  String get activeTab {
    final t = _activeMainTab;
    if (t != null && mainTabs.contains(t)) return t;
    final def = operator.kind == OperatorKind.fourG
        ? 'باقة يمن 4G'
        : operator.kind == OperatorKind.yemenNet
            ? 'الانترنت الارضي'
            : 'باقات';
    _activeMainTab = def;
    return def;
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    if (text.length >= 2) {
      final detected = OperatorConfig.fromPhone(text);
      if (detected.kind != operator.kind || detected.code != operator.code) {
        setState(() {
          _currentOperator = detected;
          _activeMainTab = null;
          _balanceInquiryBanner = null;
        });
        _activeMainTab = detected.kind == OperatorKind.fourG
            ? 'باقة يمن 4G'
            : detected.kind == OperatorKind.yemenNet
                ? 'الانترنت الارضي'
                : 'باقات';
        _loadOperatorData(detected);
      }
    } else if (operator.kind != OperatorKind.yemenMobile ||
        operator.code != OperatorConfig.yemenMobile.code) {
      setState(() {
        _currentOperator = OperatorConfig.yemenMobile;
        _activeMainTab = 'باقات';
        _balanceInquiryBanner = null;
      });
      _loadOperatorData(OperatorConfig.yemenMobile);
    }
  }

  void _openLoading() {
    if (_loadingOpen) return;
    _loadingOpen = true;
    showWebLoadingModal(context);
  }

  void _closeLoading() {
    if (!_loadingOpen) return;
    _loadingOpen = false;
    hideWebLoadingModal(context);
  }

  Future<void> _loadOperatorData(OperatorConfig operatorConfig,
      {bool forceRefresh = false}) async {
    if (forceRefresh) _spinController.repeat();

    try {
      int targetSvcId = 4;
      if (operatorConfig.kind == OperatorKind.sabafon) {
        targetSvcId = 9;
      } else if (operatorConfig.kind == OperatorKind.you) {
        targetSvcId = 15;
      } else if (operatorConfig.kind == OperatorKind.fourG) {
        targetSvcId = 19;
      }

      final svcData = await _apiService.getServiceDetails(targetSvcId,
          forceRefresh: forceRefresh);

      List<PlanType> plans = [];
      if (svcData['plan_types'] is List) {
        plans = (svcData['plan_types'] as List)
            .map((e) => PlanType.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      List<PackageItem> items = [];
      if (svcData['items'] is List) {
        items = (svcData['items'] as List)
            .map((e) => PackageItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (mounted) {
        setState(() {
          _planTypes = plans;
          _allItems = items;
          _accordionState.clear();
          for (final p in plans) {
            _accordionState[p.name] = false;
          }
          if (plans.isNotEmpty) _accordionState[plans.first.name] = true;
        });
      }
    } catch (e) {
      if (mounted) _toast('ملاحظة: $e');
    } finally {
      _spinController.stop();
      _spinController.reset();
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF475569),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Inquiries
  // ---------------------------------------------------------------------------
  Future<void> _handleRunInquiry(String type) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _toast('يرجى إدخال رقم الهاتف أولاً', error: true);
      return;
    }

    setState(() {
      _isInquiring = true;
    });
    _openLoading();

    try {
      InquiryResultData result;
      if (operator.kind == OperatorKind.yemenMobile) {
        result = type == 'offers'
            ? await _apiService.queryYemenMobileOffers(phone)
            : await _apiService.queryYemenMobileBalance(phone);
      } else if (operator.kind == OperatorKind.fourG) {
        result = await _apiService.queryYemen4G(phone);
      } else if (operator.kind == OperatorKind.yemenNet) {
        final netType = type == 'net_line' ? 'line' : 'adsl';
        result = await _apiService.queryYemenNet(phone, type: netType);
      } else {
        result = InquiryResultData(
          type: type,
          success: false,
          message: 'خدمة الاستعلام غير متاحة حالياً لهذه الشركة.',
        );
      }

      _closeLoading();
      if (!mounted) return;

      if (!result.success) {
        showWebFailure(
          context,
          title: 'فشل الاستعلام من المزود',
          reason: result.message ?? 'تعذر الاستعلام من المزود حالياً',
        );
        return;
      }

      setState(() {
        _lastInquiryResult = result;
        if (operator.kind == OperatorKind.yemenMobile && type == 'balance') {
          _balanceInquiryBanner =
              'الرصيد: ${result.balance ?? '436.04'} . النوع: ${result.mobileType ?? 'دفع مسبق | شريحة'}';
        }
        if (operator.kind == OperatorKind.yemenMobile && type == 'salfa') {
          final loan = double.tryParse(result.loanAmount ?? '') ?? 0.0;
          _balanceInquiryBanner =
              loan > 0 ? 'السلفة الحالية: ${result.loanAmount} ر.ي' : 'غير متسلف';
        }
      });
    } catch (e) {
      _closeLoading();
      if (!mounted) return;
      showWebFailure(
        context,
        title: 'فشل الاستعلام من المزود',
        reason: '$e',
      );
    } finally {
      if (mounted) setState(() => _isInquiring = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Recharge flow
  // ---------------------------------------------------------------------------
  String _getArabicAmountWords(int amt) {
    if (amt == 100) return 'مائة';
    if (amt == 200) return 'مائتان';
    if (amt == 400) return 'أربعمائة';
    if (amt == 500) return 'خمسمائة';
    if (amt == 600) return 'ستمائة';
    if (amt == 1000) return 'ألف';
    if (amt == 1500) return 'ألف وخمسمائة';
    if (amt == 2000) return 'الفين';
    if (amt == 2122) return 'الفين ومائة واثنان وعشرون';
    if (amt == 2400) return 'الفين واربعمائة';
    return '$amt ريال يمني';
  }

  Future<void> _initiateRecharge({
    required String packageName,
    required double amount,
    int? itemId,
  }) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _toast('يرجى إدخال رقم الهاتف', error: true);
      return;
    }

    final arabicWords = _getArabicAmountWords(amount.round());
    final realLastTx = await OfflineCacheService.getLastTransactionForPhone(phone);
    if (!mounted) return;

    await OrderConfirmationDialog.show(
      context: context,
      serviceName: operator.nameAr,
      itemName: packageName,
      phoneNumber: phone,
      amount: amount,
      feeRatio: 1.0,
      totalCost: amount,
      amountArabicWords: arabicWords,
      hasRealLastTx: realLastTx != null,
      lastTxTime: realLastTx?['time'],
      lastTxName: realLastTx?['packageName'],
      lastTxAmount: realLastTx?['amount'],
      lastTxStatus: realLastTx?['status'],
      onConfirm: () async {
        final duplicateInfo = await OfflineCacheService.checkRechargeToday(phone);
        if (duplicateInfo['paid'] == true) {
          if (!mounted) return;
          final shouldContinue = await DuplicatePaymentDialog.show(
            context: context,
            phone: phone,
            amount: amount,
            packageName: packageName,
            previousTime: duplicateInfo['time'] ?? 'اليوم',
            operator: operator,
            onProceed: () => _executeRechargeConfirmed(
              phone: phone,
              packageName: packageName,
              amount: amount,
              itemId: itemId,
            ),
          );
          if (shouldContinue != true) return;
        } else {
          await _executeRechargeConfirmed(
            phone: phone,
            packageName: packageName,
            amount: amount,
            itemId: itemId,
          );
        }
      },
    );
  }

  Future<void> _executeRechargeConfirmed({
    required String phone,
    required String packageName,
    required double amount,
    int? itemId,
  }) async {
    _openLoading();

    try {
      int svcId = 1;
      if (itemId != null) {
        svcId = 4;
      } else if (operator.kind == OperatorKind.sabafon) {
        svcId = 8;
      } else if (operator.kind == OperatorKind.you) {
        svcId = 13;
      } else if (operator.kind == OperatorKind.fourG) {
        svcId = 20;
      } else if (operator.kind == OperatorKind.yemenNet) {
        svcId = 23;
      }

      final res = await _apiService.executeRecharge(
        serviceId: svcId,
        phone: phone,
        amount: amount,
        itemId: itemId,
      );

      await OfflineCacheService.recordRecharge(
        phone: phone,
        amount: amount,
        packageName: packageName,
        operatorName: operator.nameAr,
      );

      _closeLoading();
      if (!mounted) return;

      final refId = res['id'] != null ? 'TX-${res['id']}' : '';
      widget.onBalanceChanged?.call((widget.walletBalance - amount).clamp(0, double.infinity));

      await showWebSuccess(
        context,
        title: 'نجاح العملية',
        message: 'تمت عملية تسديد ($packageName) للرقم ($phone) بمبلغ ${_fmt(amount)} ر.ي بنجاح!',
        referenceId: refId,
      );
    } catch (e) {
      _closeLoading();
      if (!mounted) return;
      await showWebFailure(
        context,
        title: 'فشل اثناء تنفيذ عملية التسديد! السبب/',
        reason: '$e\ncid:${widget.walletBalance.toStringAsFixed(0)}',
      );
    }
  }

  Future<void> _pickContact() async {
    final phone = await MethodChannelBridge.pickContactFromNative();
    if (phone != null && phone.isNotEmpty) {
      if (mounted) setState(() => _phoneController.text = phone);
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WebTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildOperatorsRow(),
              _buildPhoneInputCard(),
              _buildMainTabsBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildTabContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header (operator color)
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _circleBtn(
            size: 40,
            background: Colors.white.withOpacity(0.2),
            onTap: () {
              _spinController.repeat();
              _handleRunInquiry('balance');
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (mounted) {
                  _spinController.stop();
                  _spinController.reset();
                }
              });
            },
            child: RotationTransition(
              turns: _spinController,
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () => setState(() => _userBalanceHidden = !_userBalanceHidden),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userBalanceHidden
                            ? '*****'
                            : '${_fmt(widget.walletBalance)} ر.ي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'رصيدي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.bolt, size: 16, color: Colors.white.withOpacity(0.85)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pillBtn(
            label: 'المتجر',
            background: const Color(0xFF059669),
            icon: Icons.shopping_bag_outlined,
            onTap: widget.onOpenStore,
          ),
          const SizedBox(width: 6),
          _pillBtn(
            label: 'حسابي',
            background: Colors.white.withOpacity(0.25),
            icon: Icons.home_outlined,
            onTap: widget.onOpenAccount,
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required double size,
    required Color background,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Center(child: child)),
      ),
    );
  }

  Widget _pillBtn({
    required String label,
    required Color background,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Operators row
  // ---------------------------------------------------------------------------
  Widget _buildOperatorsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          const Text(
            'تسديد شبكات الاتصالات اليمنية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: OperatorConfig.all.map((op) {
                final selected =
                    op.kind == operator.kind && op.code == operator.code;
                final opColor = Color(op.headerColorValue);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _toast(
                      'الشركات مقيدة: يتم تحديد الشركة تلقائياً بحسب رقم الهاتف ولا يمكن اختيارها يدوياً (يمن موبايل 77/78، سبأفون 71، يو 73)',
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? opColor : Colors.white,
                        border: Border.all(
                          color: opColor,
                          width: selected ? 2 : 1.2,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: opColor.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          op.badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.white : opColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Phone input card
  // ---------------------------------------------------------------------------
  Widget _buildPhoneInputCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: WebCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Contacts picker
            Material(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickContact,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Input
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'رقم الهاتف (9 أرقام مقيدة)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        '+967',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (_phoneController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _phoneController.clear()),
                          child: const Icon(
                            Icons.close,
                            size: 15,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'ادخل 9 أرقام...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Operator badge + heart
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: headerColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    operator.badgeInput,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main tabs bar
  // ---------------------------------------------------------------------------
  Widget _buildMainTabsBar() {
    final k = operator.kind;
    final Color trackColor = k == OperatorKind.fourG
        ? WebTheme.tabTrack4G
        : k == OperatorKind.yemenNet
            ? WebTheme.tabTrackNet
            : WebTheme.tabTrack;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: mainTabs.map((tab) {
            final isActive = activeTab == tab;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {
                  setState(() {
                    _activeMainTab = tab;
                    _balanceInquiryBanner = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? activeTabColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isActive
                        ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                        : null,
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Colors.white
                          : k == OperatorKind.yemenNet
                              ? const Color(0xFF334155)
                              : k == OperatorKind.fourG
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab content
  // ---------------------------------------------------------------------------
  List<Widget> _buildTabContent() {
    final k = operator.kind;
    final tab = activeTab;

    if (k == OperatorKind.fourG) {
      if (tab == 'باقة يمن 4G') return [_buildFourGBundleTab()];
      return [const SizedBox(height: 120)];
    }
    if (k == OperatorKind.yemenNet) {
      if (tab == 'الهاتف الثابت') return [_buildNetTab(kind: 'phone')];
      return [_buildNetTab(kind: 'adsl')];
    }

    switch (tab) {
      case 'باقات':
        return _buildPackagesTab();
      case 'رصيد':
        return [_buildBalanceTab()];
      case 'فوري':
        return [_buildInstantTab()];
      default:
        return [const SizedBox(height: 120)];
    }
  }

  // ---------------------------------------------------------------------------
  // باقات tab
  // ---------------------------------------------------------------------------
  List<Widget> _buildPackagesTab() {
    final k = operator.kind;
    final children = <Widget>[
      // 3-column inquiry row
      _buildInquiryRow(),
      const SizedBox(height: 10),

      // Sub-filter chips
      _buildSubFilterChips(),
      const SizedBox(height: 10),
    ];

    // Subscriptions (Yemen Mobile only when offers exist)
    if (k == OperatorKind.yemenMobile &&
        _lastInquiryResult != null &&
        _lastInquiryResult!.offers.isNotEmpty) {
      children.add(_buildSubscriptionsSection());
      children.add(const SizedBox(height: 10));
    }

    // Accordion categories (grouped by plan type)
    children.add(_buildAccordionCategories());
    return children;
  }

  Widget _buildInquiryRow() {
    final bal = _lastInquiryResult?.balance?.toString() ?? '436.04';
    final type = _lastInquiryResult?.mobileType ?? 'دفع مسبق | شريحة';
    final loan = double.tryParse(_lastInquiryResult?.loanAmount ?? '') ?? 0.0;
    final hasLoan = loan > 0;

    return WebCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Column 1: رصيد الرقم
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'رصيد الرقم',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bal,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: const Color(0xFFF1F5F9)),
            // Column 2: نوع الرقم
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'نوع الرقم',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: const Color(0xFFF1F5F9)),
            // Column 3: فحص السلفة
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: WebTheme.amberPill,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _handleRunInquiry('salfa'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Text(
                          'فحص السلفة',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: WebTheme.amberPillText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLoan ? 'متسلف ${_fmt(loan)} ر.ي ⚠️' : 'غير متسلف 😀',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hasLoan ? WebTheme.rose : WebTheme.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubFilterChips() {
    final labels = _planTypes.isEmpty
        ? _defaultSubFilters
        : _planTypes.map((p) => p.name).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebTheme.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: labels.map((label) {
            final isActive = activeTab == 'باقات' &&
                (_selectedSubFilterName == label ||
                    (_selectedSubFilterName == null &&
                        label == 'دفع مسبق' &&
                        _planTypes.isEmpty));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {
                  setState(() {
                    _selectedSubFilterName = label;
                    // Expand matching plan accordion if present
                    for (final p in _planTypes) {
                      _accordionState[p.name] = p.name == label;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? activeTabColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String? _selectedSubFilterName;

  Widget _buildSubscriptionsSection() {
    final offers = _lastInquiryResult!.offers;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: headerColor,
              child: const Text(
                'الاشتراكات الحالية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: WebTheme.amberSurface,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: offers.map((offer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WebTheme.amberBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.offerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'الإشتراك: ${offer.startDate ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'الإنتهاء: ${offer.endDate ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFBE123C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: const Color(0xFF8B1D3B),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _toast('طلب تجديد: ${offer.offerName}'),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.refresh, size: 16, color: Colors.white),
                                  SizedBox(height: 2),
                                  Text(
                                    'تجديد',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionCategories() {
    if (_planTypes.isEmpty) {
      if (_allItems.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'لا توجد باقات متوفرة لهذا التصنيف حالياً',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
        );
      }
      return _buildAccordion(title: 'الباقات المتوفرة', items: _allItems);
    }

    return Column(
      children: _planTypes.map((plan) {
        var items = _allItems;
        if (plan.planIds.isNotEmpty) {
          final ids = plan.planIds.toSet();
          items = _allItems.where((it) => ids.contains(it.id)).toList();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAccordion(title: plan.name, items: items),
        );
      }).toList(),
    );
  }

  Widget _buildAccordion({required String title, required List<PackageItem> items}) {
    final expanded = _accordionState[title] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // Accordion header
            Material(
              color: headerColor,
              child: InkWell(
                onTap: () =>
                    setState(() => _accordionState[title] = !(expanded)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _categoryBadge(title),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded)
              Container(
                color: WebTheme.accordionBody,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: items.map((item) => _buildWebPackageCard(item)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _categoryBadge(String title) {
    if (title.contains('فورجي') || title.contains('4G')) return '4G';
    if (title.contains('مزايا')) return '3G';
    return 'PKG';
  }

  Widget _buildWebPackageCard(PackageItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WebTheme.amberSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.amberBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          PackageDetailSheet.show(
            context: context,
            package: item,
            operator: operator,
            currentBalance:
                double.tryParse(_lastInquiryResult?.balance ?? '') ?? 436.04,
            loanAmount: double.tryParse(_lastInquiryResult?.loanAmount ?? '') ?? 122.0,
            onProceedPayment: (totalAmount, includeLoan) {
              _initiateRecharge(
                packageName: item.name,
                amount: totalAmount,
                itemId: item.id,
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'دفع مسبق',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: headerColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    operator.badge,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _fmt(item.price),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: WebTheme.amberDivider.withOpacity(0.6)),
            const SizedBox(height: 8),
            Row(
              children: [
                _pkgFooterIcon(Icons.access_time, item.validityDays ?? '-'),
                _pkgFooterIcon(Icons.phone_outlined, item.minutes ?? '-'),
                _pkgFooterIcon(Icons.mail_outline, item.sms ?? '-'),
                _pkgFooterIcon(Icons.public, item.dataAmount ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pkgFooterIcon(IconData icon, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 9, color: Color(0xFF334155), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // رصيد tab
  // ---------------------------------------------------------------------------
  Widget _buildBalanceTab() {
    final isSabafon = operator.kind == OperatorKind.sabafon;
    final elements = <Widget>[];

    if (_balanceInquiryBanner != null) {
      elements.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: WebTheme.cyanBanner,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              _balanceInquiryBanner!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ));
      elements.add(const SizedBox(height: 10));
    }

    if (isSabafon) {
      elements.add(Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: WebTheme.tabTrackSabafon,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: ['دفع مسبق', 'فوترة'].map((s) {
            final act = s == 'دفع مسبق';
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: act ? const Color(0xFF1E88E5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  s,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: act ? Colors.white : const Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ));
      elements.add(const SizedBox(height: 10));
    }

    final units = double.tryParse(_unitsController.text.trim()) ?? 0;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final net = isSabafon ? units * 12.1 : amount;

    elements.add(WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isSabafon ? '*ادخل عدد الوحدات' : '*ادخل المبلغ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() =>
                    (isSabafon ? _unitsController : _amountController).clear()),
                child: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
              ),
              Expanded(
                child: TextField(
                  controller: isSabafon ? _unitsController : _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              Text(
                isSabafon ? 'وحدة' : r'$',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          Divider(height: 16, thickness: 1.6, color: Colors.grey.shade300),
          if (isSabafon) ...[
            const SizedBox(height: 4),
            Text(
              'اجمالي المبلغ: ${(net).toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'صافي الرصيد بعد خصم الضريبه',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: WebTheme.slateMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WebTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r'$', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                  Text(
                    (amount * 0.829).toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ));
    elements.add(const SizedBox(height: 12));

    // Action buttons
    final payBtn = _actionBtn(
      label: 'تسديد',
      color: activeTabColor,
      onTap: () {
        final amt = net <= 0 ? 100.0 : net;
        final itemName = isSabafon ? 'رصيد ${_unitsController.text} وحدة' : 'رصيد ${_fmt(amt)}';
        _initiateRecharge(packageName: itemName, amount: amt);
      },
    );

    if (operator.hasInquiryInBalance) {
      elements.add(Row(
        children: [
          Expanded(child: payBtn),
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              label: 'استعلام',
              color: WebTheme.amberAction,
              textColor: const Color(0xFF0F172A),
              isLoading: _isInquiring,
              onTap: () => _handleRunInquiry('balance'),
            ),
          ),
        ],
      ));
    } else {
      elements.add(payBtn);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: elements);
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    Color textColor = Colors.white,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // فوري tab
  // ---------------------------------------------------------------------------
  Widget _buildInstantTab() {
    final k = operator.kind;
    final children = <Widget>[];

    if (k == OperatorKind.sabafon) {
      children.add(WebCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _radio('شمال', _sabafonRegionNorth, () =>
                    setState(() => _sabafonRegionNorth = true)),
                const SizedBox(width: 14),
                _radio('جنوب', !_sabafonRegionNorth, () =>
                    setState(() => _sabafonRegionNorth = false)),
              ],
            ),
          ],
        ),
      ));
      children.add(const SizedBox(height: 10));
    }

    if (k == OperatorKind.you) {
      children.add(WebCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الشاحن الذكي',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Switch(
              value: _youSmartCharger,
              activeTrackColor: const Color(0xFFF59E0B),
              onChanged: (v) => setState(() => _youSmartCharger = v),
            ),
          ],
        ),
      ));
      children.add(const SizedBox(height: 10));
    }

    final denoms = k == OperatorKind.sabafon
        ? _sabafonDenoms
        : k == OperatorKind.you
            ? _youDenoms
            : _ymDenoms;

    children.add(_denomsGrid(denoms));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 18,
            color: selected ? const Color(0xFF1E88E5) : Colors.grey.shade400,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _denomsGrid(List<_Denom> denoms) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: denoms.map((d) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _initiateRecharge(
            packageName: 'فئة ${d.tier}',
            amount: d.price,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WebTheme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: headerColor,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        Text(
                          'فئة',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${d.tier}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'السعر',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmt(d.price)} ريال',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: WebTheme.amberAction.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      d.days,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // 4G bundle tab
  // ---------------------------------------------------------------------------
  Widget _buildFourGBundleTab() {
    final children = <Widget>[
      _amountInputCard(),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _actionBtn(
              label: 'تسديد',
              color: const Color(0xFF0284C7),
              onTap: () {
                final amt = double.tryParse(_amountController.text) ?? 100.0;
                _initiateRecharge(packageName: 'رصيد يمن 4G', amount: amt);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              label: 'استعلام',
              color: WebTheme.amberAction,
              textColor: const Color(0xFF0F172A),
              isLoading: _isInquiring,
              onTap: () => _handleRunInquiry('4g'),
            ),
          ),
        ],
      ),
    ];

    if (_lastInquiryResult != null) {
      final r = _lastInquiryResult!.rawResult;
      children.add(const SizedBox(height: 12));
      children.add(_inquiryTable([
        ('الرصيد', _lastInquiryResult!.balance ?? r['balance']?.toString() ?? 'GB 14.54'),
        ('قيمة الباقة', r['package_price']?.toString() ?? '2,400'),
        ('الحجم | السرعة', r['speed']?.toString() ?? '4G 15 سرعة: 4G'),
        ('تأريخ الإنتهاء', r['expiry']?.toString() ?? '00:00:00 2026-10-07'),
      ]));
    }

    children.add(const SizedBox(height: 12));
    children.add(_netDenomsGrid(_fourGDenoms, const Color(0xFF0284C7)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  // ---------------------------------------------------------------------------
  // Yemen Net tab
  // ---------------------------------------------------------------------------
  Widget _buildNetTab({required String kind}) {
    final children = <Widget>[];

    if (kind == 'phone') {
      children.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: WebTheme.cyanBanner,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'مبلغ الفاتورة الحالية: -2000',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      children.add(const SizedBox(height: 10));
    }

    children.add(_amountInputCard());
    children.add(const SizedBox(height: 10));
    children.add(Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: 'تسديد',
            color: const Color(0xFF283593),
            onTap: () {
              final amt = double.tryParse(_amountController.text) ?? 100.0;
              _initiateRecharge(
                packageName: kind == 'phone' ? 'فاتورة الهاتف الثابت' : 'رصيد يمن نت',
                amount: amt,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionBtn(
            label: 'استعلام',
            color: WebTheme.amberAction,
            textColor: const Color(0xFF0F172A),
            isLoading: _isInquiring,
            onTap: () =>
                _handleRunInquiry(kind == 'phone' ? 'net_line' : 'net_adsl'),
          ),
        ),
      ],
    ));

    if (kind == 'adsl' && _lastInquiryResult != null) {
      final r = _lastInquiryResult!.rawResult;
      children.add(const SizedBox(height: 12));
      children.add(_inquiryTable([
        ('الرصيد', _lastInquiryResult!.balance ?? r['balance']?.toString() ?? 'Gigabyte(s) 0.00'),
        ('قيمة الباقة', r['package_price']?.toString() ?? '5,100 اقل مبلغ سداد: 250'),
        ('الحجم | السرعة', r['speed']?.toString() ?? '_ سرعة: _'),
        ('تأريخ الإنتهاء', r['expiry']?.toString() ?? '18:43:00 2026-08-15'),
      ]));
    }

    children.add(const SizedBox(height: 12));
    children.add(_netDenomsGrid(_netDenoms, const Color(0xFF283593)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _amountInputCard() {
    return WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '*ادخل المبلغ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _amountController.clear()),
                child: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'المبلغ',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              Text(
                r'$',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          Divider(height: 16, thickness: 1.4, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _inquiryTable(List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    color: const Color(0xFFE0E7FF).withOpacity(0.6),
                    child: Text(
                      e.value.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        e.value.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _netDenomsGrid(List<_NetDenom> denoms, Color accent) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: denoms.map((d) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _initiateRecharge(
            packageName: d.label,
            amount: d.price,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WebTheme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            d.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.wifi_outlined,
                            size: 13, color: Colors.white.withOpacity(0.9)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'السعر',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmt(d.price)} ريال',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}