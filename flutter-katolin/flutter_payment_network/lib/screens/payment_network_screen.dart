import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/telecom_service.dart';
import '../services/telecom_api.dart';
import '../services/offline_cache.dart';
import '../services/method_channel_bridge.dart';
import '../widgets/operator_tabs.dart';
import '../widgets/inquiry_buttons_bar.dart';
import '../widgets/inquiry_modal.dart';
import '../widgets/package_card.dart';
import '../widgets/duplicate_alert_dialog.dart';
import '../widgets/order_confirmation_dialog.dart';
import '../widgets/package_detail_sheet.dart';
import 'operations_screen.dart';
import 'reports_screen.dart';
import 'wifi_networks_screen.dart';
import 'subscriber_transfer_screen.dart';
import 'services_screen.dart';
import 'games_screen.dart';
import 'settings_screen.dart';

class PaymentNetworkScreen extends StatefulWidget {
  final String initialPhone;
  final double walletBalance;
  final String apiToken;
  final String baseUrl;

  const PaymentNetworkScreen({
    Key? key,
    this.initialPhone = '',
    this.walletBalance = 99033.43,
    this.apiToken = '3241591d9733768e4b5d3226c96b200e04c7ca15',
    this.baseUrl = 'https://shopik.alattab.site',
  }) : super(key: key);

  @override
  State<PaymentNetworkScreen> createState() => _PaymentNetworkScreenState();
}

class _PaymentNetworkScreenState extends State<PaymentNetworkScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _phoneController;
  late TextEditingController _amountController;
  late TelecomApiService _apiService;
  late AnimationController _syncAnimController;

  OperatorConfig _currentOperator = OperatorConfig.yemenMobile;
  bool _isManualOperatorSelection = false;

  bool _isSyncing = false;
  bool _isInquiring = false;
  String? _activeInquiryType;
  bool _isRecharging = false;
  InquiryResultData? _lastInquiryResult;

  List<PlanType> _planTypes = [];
  PlanType? _selectedPlanType;
  List<PackageItem> _allItems = [];
  List<PackageItem> _filteredItems = [];

  // Active tab: 'balance' (تسديد رصيد) or 'packages' (باقات) or 'categories'
  bool _isBalanceRechargeTab = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _amountController = TextEditingController();
    _apiService = TelecomApiService(baseUrl: widget.baseUrl, token: widget.apiToken);

    _syncAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initial operator detection
    if (widget.initialPhone.isNotEmpty) {
      _currentOperator = OperatorConfig.fromPhone(widget.initialPhone);
    }

    _phoneController.addListener(_onPhoneChanged);

    // Setup MethodChannel callbacks
    MethodChannelBridge.onContactPicked = (phone) {
      setState(() {
        _phoneController.text = phone;
      });
    };

    // Load data with offline-first strategy
    _loadInitialData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _syncAnimController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    if (text.length >= 2) {
      final detected = OperatorConfig.fromPhone(text);
      if (detected.kind != _currentOperator.kind) {
        setState(() {
          _currentOperator = detected;
        });
        _loadOperatorData(detected);
      }
    } else {
      // Default to Yemen Mobile when cleared or unknown prefix
      if (_currentOperator.kind != OperatorKind.yemenMobile) {
        setState(() {
          _currentOperator = OperatorConfig.yemenMobile;
        });
        _loadOperatorData(OperatorConfig.yemenMobile);
      }
    }
  }

  /// Initial load: reads from local storage immediately, fetches if empty
  Future<void> _loadInitialData() async {
    await _loadOperatorData(_currentOperator, forceRefresh: false);
  }

  /// Load catalog and packages for the selected operator
  Future<void> _loadOperatorData(OperatorConfig operator, {bool forceRefresh = false}) async {
    setState(() => _isSyncing = true);
    if (forceRefresh) _syncAnimController.repeat();

    try {
      // Determine service ID based on operator:
      // Yemen Mobile packages: Svc 4 (yem-bill-offer)
      // Sabafon packages: Svc 9 (saba-offer)
      // YOU packages: Svc 15 (you-offer)
      // Yemen 4G packages: Svc 19 (yem4g-package)
      int targetSvcId = 4;
      if (operator.kind == OperatorKind.sabafon) {
        targetSvcId = 9;
      } else if (operator.kind == OperatorKind.you) {
        targetSvcId = 15;
      } else if (operator.kind == OperatorKind.fourG) {
        targetSvcId = 19;
      }

      final svcData = await _apiService.getServiceDetails(targetSvcId, forceRefresh: forceRefresh);

      // Parse plan types
      List<PlanType> plans = [];
      if (svcData['plan_types'] is List) {
        plans = (svcData['plan_types'] as List)
            .map((e) => PlanType.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse items
      List<PackageItem> items = [];
      if (svcData['items'] is List) {
        items = (svcData['items'] as List)
            .map((e) => PackageItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      setState(() {
        _planTypes = plans;
        _allItems = items;
        if (plans.isNotEmpty) {
          _selectedPlanType = plans.first;
          _filterItemsByPlanType(plans.first);
        } else {
          _selectedPlanType = null;
          _filteredItems = items;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ملاحظة: $e', textDirection: TextDirection.rtl),
          backgroundColor: Colors.blueGrey.shade800,
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
      _syncAnimController.stop();
      _syncAnimController.reset();
    }
  }

  void _filterItemsByPlanType(PlanType plan) {
    if (plan.planIds.isEmpty) {
      _filteredItems = _allItems;
    } else {
      final setIds = plan.planIds.toSet();
      _filteredItems = _allItems.where((it) => setIds.contains(it.id)).toList();
    }
  }

  /// Run Inquiry (فحص الرصيد، فحص السلفة، فحص الباقات، نوع الخط)
  Future<void> _handleRunInquiry(String type) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الهاتف أولاً', textDirection: TextDirection.rtl),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isInquiring = true;
      _activeInquiryType = type;
    });

    try {
      InquiryResultData result;
      if (_currentOperator.kind == OperatorKind.yemenMobile) {
        if (type == 'offers') {
          result = await _apiService.queryYemenMobileOffers(phone);
        } else {
          // 'balance', 'salfa', 'line_type' all query Svc 6 which returns balance & mobileType
          result = await _apiService.queryYemenMobileBalance(phone);
        }
      } else if (_currentOperator.kind == OperatorKind.fourG) {
        result = await _apiService.queryYemen4G(phone);
      } else if (_currentOperator.kind == OperatorKind.yemenNet) {
        final netType = type == 'net_line' ? 'line' : 'adsl';
        result = await _apiService.queryYemenNet(phone, type: netType);
      } else {
        result = InquiryResultData(
          type: type,
          success: false,
          message: 'خدمة الاستعلام غير متاحة حالياً لهذه الشركة.',
        );
      }

      if (mounted) {
        setState(() {
          _lastInquiryResult = result;
        });
        // Silent update on success per user instruction ("ماعدا الاستعلامات تجاهلها كلها ماعدا الاستعلامات الفاشله تظهر نتيجتها بنافذة منبثقه")
        if (!result.success) {
          InquiryResultModal.show(context, result, _currentOperator);
        }
      }
    } catch (e) {
      if (mounted) {
        // Show failure dialog for failed inquiry
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text('فشل الاستعلام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Text('فشل اثناء تنفيذ عملية الاستعلام! السبب/\n$e', style: const TextStyle(fontSize: 13)),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('موافق', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInquiring = false;
          _activeInquiryType = null;
        });
      }
    }
  }

  /// Check duplicate recharge today before executing
  Future<void> _initiateRecharge({
    required String packageName,
    required double amount,
    int? itemId,
  }) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الهاتف', textDirection: TextDirection.rtl),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Show Order Confirmation Dialog with verified real previous operation check
    final arabicWords = _getArabicAmountWords(amount.toInt());
    final realLastTx = await OfflineCacheService.getLastTransactionForPhone(phone);

    final confirmed = await OrderConfirmationDialog.show(
      context: context,
      serviceName: _currentOperator.nameAr,
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
        // Step 1: Check duplicate recharge today
        final duplicateInfo = await OfflineCacheService.checkRechargeToday(phone);
        if (duplicateInfo['paid'] == true) {
          if (!mounted) return;
          final shouldContinue = await DuplicatePaymentDialog.show(
            context: context,
            phone: phone,
            amount: amount,
            packageName: packageName,
            previousTime: duplicateInfo['time'] ?? 'اليوم',
            operator: _currentOperator,
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

  /// Confirmed Recharge Execution
  Future<void> _executeRechargeConfirmed({
    required String phone,
    required String packageName,
    required double amount,
    int? itemId,
  }) async {
    setState(() => _isRecharging = true);

    try {
      // Determine service ID
      int svcId = 1; // Svc 1: Yemen Mobile balance
      if (itemId != null) {
        svcId = 4; // Svc 4: Yemen Mobile bill offer
      } else if (_currentOperator.kind == OperatorKind.sabafon) {
        svcId = 8;
      } else if (_currentOperator.kind == OperatorKind.you) {
        svcId = 13;
      } else if (_currentOperator.kind == OperatorKind.fourG) {
        svcId = 20;
      } else if (_currentOperator.kind == OperatorKind.yemenNet) {
        svcId = 23;
      }

      final res = await _apiService.executeRecharge(
        serviceId: svcId,
        phone: phone,
        amount: amount,
        itemId: itemId,
      );

      // Record in local cache to prevent duplicate recharges today
      await OfflineCacheService.recordRecharge(
        phone: phone,
        amount: amount,
        packageName: packageName,
        operatorName: _currentOperator.nameAr,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('نجاح العملية', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                'تمت عملية تسديد ($packageName) للرقم ($phone) بمبلغ $amount ر.ي بنجاح!\nالمرجع: ${res['id'] ?? ''}',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('تم'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'i',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
              content: Text(
                'فشل اثناء تنفيذ عملية التسديد! السبب/\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373), // Coral pink/red matching screenshot 22
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('موافق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecharging = false);
    }
  }

  /// Trigger contact picker via Native Kotlin MethodChannel
  Future<void> _pickContact() async {
    final phone = await MethodChannelBridge.pickContactFromNative();
    if (phone != null && phone.isNotEmpty) {
      setState(() {
        _phoneController.text = phone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(_currentOperator.primaryColorValue);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(primaryColor),
        body: RefreshIndicator(
          onRefresh: () => _loadOperatorData(_currentOperator, forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Operator selector tabs (Strictly locked to phone detection)
                OperatorTabsWidget(
                  selectedOperator: _currentOperator,
                  onSelect: (op) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text(
                          'الشركات مقيدة: يتم التحديد تلقائياً بحسب رقم الهاتف (يمن موبايل 77/78، سبأفون 71، يو 73)',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    );
                  },
                ),

                // 2. Phone input card with Contact Picker button
                _buildPhoneInputCard(primaryColor),

                // 3. Operator Inquiries Bar (Specialized for Yemen Mobile / 4G / Net)
                InquiryButtonsBarWidget(
                  currentOperator: _currentOperator,
                  isLoading: _isInquiring,
                  activeInquiryType: _activeInquiryType,
                  onRunInquiry: _handleRunInquiry,
                ),

                // 4. Plan Types and Categories Tabs
                _buildPlanTypesTabs(primaryColor),

                // 4.5 If in packages tab, show 3-column in-screen inquiry row (matching user screenshots 6, 7, 8, 9)
                if (!_isBalanceRechargeTab && _currentOperator.kind == OperatorKind.yemenMobile) ...[
                  _buildPackagesTopInquiryRow(primaryColor),
                  if (_lastInquiryResult != null && _lastInquiryResult!.offers.isNotEmpty)
                    _buildActiveSubscriptionsSection(primaryColor),
                ],

                // 5. Balance Recharge Input Card (when balance tab is active)
                if (_isBalanceRechargeTab)
                  _buildBalanceRechargeCard(primaryColor)
                else
                  // 6. Packages List
                  _buildPackagesList(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 10),
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OperationsScreen(
                    apiToken: widget.apiToken,
                    baseUrl: widget.baseUrl,
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WifiNetworksScreen(
                    apiToken: widget.apiToken,
                    baseUrl: widget.baseUrl,
                  ),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriberTransferScreen(
                    apiToken: widget.apiToken,
                    baseUrl: widget.baseUrl,
                    currentBalance: widget.walletBalance,
                  ),
                ),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesScreen(
                    apiToken: widget.apiToken,
                    baseUrl: widget.baseUrl,
                  ),
                ),
              );
            } else if (index == 5) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportsScreen(
                    apiToken: widget.apiToken,
                    baseUrl: widget.baseUrl,
                  ),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'السداد'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'العمليات'),
            BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'الوايفاي'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'تحويل'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'الخدمات'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'تقارير'),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        tooltip: 'العودة للواجهة الرئيسية',
        onPressed: () {
          MethodChannelBridge.sendResultToAndroid({'action': 'back_to_main'});
          Navigator.of(context).maybePop();
        },
      ),
      title: const Row(
        children: [
          Icon(Icons.network_cell_rounded, color: Colors.white, size: 22),
          SizedBox(width: 6),
          Text(
            'شبكة السداد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ],
      ),
      actions: [
        // Operations Log Button (سجل العمليات المطلوب)
        IconButton(
          tooltip: 'سجل العمليات',
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OperationsScreen(
                  apiToken: widget.apiToken,
                  baseUrl: widget.baseUrl,
                ),
              ),
            );
          },
        ),

        // Reports Button (تقارير)
        IconButton(
          tooltip: 'التقارير',
          icon: const Icon(Icons.assessment_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportsScreen(
                  apiToken: widget.apiToken,
                  baseUrl: widget.baseUrl,
                ),
              ),
            );
          },
        ),

        // Settings Button (الإعدادات)
        IconButton(
          tooltip: 'الإعدادات',
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  apiToken: widget.apiToken,
                  baseUrl: widget.baseUrl,
                ),
              ),
            );
          },
        ),

        // Manual Sync Button with spinning animation
        IconButton(
          tooltip: 'مزامنة الكتالوج محلياً',
          icon: RotationTransition(
            turns: _syncAnimController,
            child: const Icon(Icons.sync_rounded, color: Colors.white),
          ),
          onPressed: _isSyncing
              ? null
              : () => _loadOperatorData(_currentOperator, forceRefresh: true),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildPhoneInputCard(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم الهاتف (مقيد 9 أرقام)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              // Detection chip (Auto-locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'مزود الخدمة: ${_currentOperator.nameAr}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Country code chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  '+967',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),

              // Phone text field (Strictly restricted to 9 digits: Yemen Mobile, Sabafon, YOU)
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '77XXXXXXX / 71XXXXXXX / 73XXXXXXX',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Contact Picker Button
              Material(
                color: primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _pickContact,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.contacts_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTypesTabs(Color primaryColor) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Fixed "Direct Balance Recharge" tab
          _buildPlanTypeChip(
            title: 'تسديد رصيد',
            isSelected: _isBalanceRechargeTab,
            primaryColor: primaryColor,
            onTap: () {
              setState(() {
                _isBalanceRechargeTab = true;
              });
            },
          ),
          const SizedBox(width: 8),

          // Dynamic Plan Types from backend
          ..._planTypes.map((plan) {
            final isSelected = !_isBalanceRechargeTab && _selectedPlanType?.id == plan.id;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildPlanTypeChip(
                title: plan.name,
                isSelected: isSelected,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() {
                    _isBalanceRechargeTab = false;
                    _selectedPlanType = plan;
                    _filterItemsByPlanType(plan);
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanTypeChip({
    required String title,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceRechargeCard(Color primaryColor) {
    final quickAmounts = [100, 200, 500, 1000, 2000, 5000];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل مبلغ شحن الرصيد المباشر',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            decoration: InputDecoration(
              suffixText: 'ر.ي',
              suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              hintText: '0.00',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quick amounts chips
          Wrap(
            spacing: 8,
            children: quickAmounts.map((amt) {
              return ActionChip(
                label: Text('$amt ر.ي', style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _amountController.text = amt.toString();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isRecharging
                ? null
                : () {
                    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
                    if (amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال مبلغ صحيح', textDirection: TextDirection.rtl),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    _initiateRecharge(
                      packageName: 'رصيد فوري/مباشر',
                      amount: amt,
                    );
                  },
            child: _isRecharging
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'تسديد الرصيد الآن',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد باقات متوفرة لهذا التصنيف حالياً',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return PackageCardWidget(
          package: item,
          operator: _currentOperator,
          isExecuting: _isRecharging,
          onSelect: () {
            PackageDetailSheet.show(
              context: context,
              package: item,
              operator: _currentOperator,
              currentBalance: double.tryParse(_lastInquiryResult?.balance?.toString() ?? '') ?? 436.04,
              loanAmount: double.tryParse(_lastInquiryResult?.loanAmount?.toString() ?? '') ?? 122.0,
              onProceedPayment: (totalAmount, includeLoan) {
                _initiateRecharge(
                  packageName: item.name,
                  amount: totalAmount,
                  itemId: item.id,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPackagesTopInquiryRow(Color primaryColor) {
    final balanceVal = _lastInquiryResult?.balance?.toString() ?? '436.04';
    final lineTypeVal = _lastInquiryResult?.mobileType ?? 'دفع مسبق | شريحة';
    final loanNum = double.tryParse(_lastInquiryResult?.loanAmount?.toString() ?? '') ?? 0.0;
    final hasLoan = loanNum > 0;
    final loanVal = hasLoan ? '$loanNum ر.ي' : '122.0 ر.ي';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Column 1: فحص السلفة
          Expanded(
            child: Column(
              children: [
                InkWell(
                  onTap: () => _handleRunInquiry('salfa'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text('فحص السلفة', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasLoan ? 'متسلف $loanVal ⚠️' : 'غير متسلف 😀',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: hasLoan ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),

          // Column 2: نوع الرقم
          Expanded(
            child: Column(
              children: [
                const Text('نوع الرقم', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  lineTypeVal,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),

          // Column 3: رصيد الرقم
          Expanded(
            child: Column(
              children: [
                const Text('رصيد الرقم', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  '$balanceVal ر.ي',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionsSection(Color primaryColor) {
    final offers = _lastInquiryResult!.offers;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF881337), // Dark red/burgundy
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: const Text(
              'الاشتراكات الحالية',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          // Subscriptions items
          ...offers.map((offer) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(offer.offerName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    if (offer.endDate != null)
                      Text(offer.endDate!, style: const TextStyle(fontSize: 10.5, color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInquiryResultCard(Color primaryColor) {
    final res = _lastInquiryResult!;
    final isOffers = res.type == 'offers';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.18), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      res.success ? Icons.check_circle : Icons.info_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOffers ? 'الاشتراكات والباقات الحالية' : 'نتيجة الاستعلام',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _lastInquiryResult = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isOffers) ...[
                  if (res.offers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'لا توجد اشتراكات أو باقات نشطة حالياً لهذا الرقم.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  else
                    ...res.offers.map((offer) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      offer.offerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      offer.offerId,
                                      style: TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              if (offer.startDate != null) ...[
                                const SizedBox(height: 4),
                                Text('الاشتراك: ${offer.startDate}', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
                              ],
                              if (offer.endDate != null) ...[
                                const SizedBox(height: 2),
                                Text('الانتهاء: ${offer.endDate}', style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                        )),
                ] else ...[
                  // Balance
                  if (res.balance != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الرصيد', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            '${res.balance} ر.ي',
                            style: const TextStyle(color: Color(0xFF176C9D), fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),

                  // Loan / Sulfa
                  if (res.loanAmount != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'السلفة الحالية',
                                style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            '${res.loanAmount} ر.ي',
                            style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ],
                      ),
                    ),

                  // Line Type
                  if (res.mobileType != null && res.mobileType!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('نوع الرقم / الخدمة', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(res.mobileType!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),

                  // Extra fields from rawResult (4G / ADSL details)
                  ...res.rawResult.entries
                      .where((e) => !['balance', 'availableCredit', 'mobileType', 'loan', 'loanAmount', 'sulfa', 'resultDesc', 'resultCode', 'offers'].contains(e.key) && e.value != null && e.value.toString().isNotEmpty)
                      .take(10)
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_getArabicFieldLabel(e.key), style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          )),

                  if (res.message != null && res.message!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        res.message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: res.success ? Colors.green.shade700 : Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getArabicFieldLabel(String key) {
    final clean = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    switch (clean) {
      case 'remainamount':
      case 'remainingamount':
      case 'remain':
        return 'الرصيد المتبقي';
      case 'expirydate':
      case 'expdate':
      case 'expiredate':
        return 'تاريخ انتهاء الصلاحية';
      case 'subscribername':
      case 'customername':
      case 'name':
        return 'اسم المشترك';
      case 'billamount':
      case 'dueamount':
      case 'requiredamount':
        return 'المبلغ المطلوب';
      case 'package':
      case 'packagename':
        return 'الباقة الحالية';
      case 'speed':
      case 'linespeed':
        return 'سرعة الخط';
      case 'status':
      case 'accountstatus':
        return 'حالة الحساب';
      case 'gigabytes':
      case 'quota':
      case 'data':
        return 'حجم البيانات المتبقي';
      default:
        return key;
    }
  }
}
