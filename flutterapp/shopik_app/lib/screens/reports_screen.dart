import 'package:flutter/material.dart';
import 'account_statement_screen.dart';
import 'operations_screen.dart';

class ReportsScreen extends StatefulWidget {
  final String apiToken;
  final String baseUrl;
  final VoidCallback? onBackToMain;

  const ReportsScreen({
    Key? key,
    required this.apiToken,
    required this.baseUrl,
    this.onBackToMain,
  }) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // 'amount' (مبلغ) or 'quantity' (كمية)
  String _activeTab = 'مبلغ';

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
            'تقارير',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث بيانات التقارير', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================================================================
              // Top Card: Circular Indicators (Matches Screenshot 6)
              // =========================================================================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Indicator 1: حصالة ارباحي
                    _buildCircularMetric(
                      title: 'حصالة ارباحي',
                      percent: 0.0,
                      percentText: '0.0%',
                      subText: '0.00 ر.ي',
                      color: const Color(0xFF00897B),
                    ),
                    Container(height: 70, width: 1, color: Colors.grey.shade200),
                    // Indicator 2: رصيدي
                    _buildCircularMetric(
                      title: 'رصيدي',
                      percent: 0.86,
                      percentText: '86.0%',
                      subText: '36,533 ر.ي',
                      color: const Color(0xFFC62828),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // =========================================================================
              // 9 Grid Buttons (Matches Screenshot 6)
              // =========================================================================
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridButton(
                    title: 'كشف حساب',
                    icon: Icons.receipt_long,
                    color: const Color(0xFFC62828),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => AccountStatementScreen(
                            apiToken: widget.apiToken,
                            baseUrl: widget.baseUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    title: 'سجل',
                    icon: Icons.history,
                    color: const Color(0xFF1565C0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => OperationsScreen(
                            apiToken: widget.apiToken,
                            baseUrl: widget.baseUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    title: 'الأرصدة',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF2E7D32),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'التسديدات',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFFEF6C00),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'تسديدات الفروع',
                    icon: Icons.storefront,
                    color: const Color(0xFF6A1B9A),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'الحوالات المالية',
                    icon: Icons.swap_horiz,
                    color: const Color(0xFF00838F),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'كروت الواي فاي',
                    icon: Icons.wifi,
                    color: const Color(0xFF455A64),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'اخرى',
                    icon: Icons.more_horiz,
                    color: const Color(0xFF37474F),
                    onTap: () {},
                  ),
                  _buildGridButton(
                    title: 'عمولة للفروع',
                    icon: Icons.loyalty,
                    color: const Color(0xFF8E24AA),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // =========================================================================
              // Bottom Statistics Section (Matches Screenshot 6)
              // =========================================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Quantity vs Amount Toggle Tabs (كمية / مبلغ)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'مبلغ'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeTab == 'مبلغ' ? const Color(0xFFC62828) : Colors.white,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(14)),
                              ),
                              child: Text(
                                'مبلغ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 'مبلغ' ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'كمية'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeTab == 'كمية' ? const Color(0xFFC62828) : Colors.white,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14)),
                              ),
                              child: Text(
                                'كمية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 'كمية' ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 1),

                    // Metrics List (Exact rows from Screenshot 6)
                    _buildReportRow('التسديدات', _activeTab == 'مبلغ' ? '2,086,110' : '482'),
                    _buildReportRow('الشرائح', '0'),
                    _buildReportRow('الحوالات المرسلة', '0'),
                    _buildReportRow('الحوالات المستلمة', '0'),
                    _buildReportRow('كروت واي فاي', _activeTab == 'مبلغ' ? '3,434' : '15'),
                    _buildReportRow('بنك الارقام', '0'),
                    _buildReportRow('اخرى', '0'),
                    _buildReportRow('سندات قبض', _activeTab == 'مبلغ' ? '6,468,372 (18)' : '18'),
                    _buildReportRow('سندات صرف', _activeTab == 'مبلغ' ? '500 (1)' : '1'),
                    _buildReportRow('لكم تحويلات', _activeTab == 'مبلغ' ? '160 (2)' : '2'),
                    _buildReportRow('عليكم تحويلات', _activeTab == 'مبلغ' ? '30,750 (7)' : '7'),
                    _buildReportRow('عمولاتي', _activeTab == 'مبلغ' ? '0 (0)' : '0', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularMetric({
    required String title,
    required double percent,
    required String percentText,
    required String subText,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 5,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              percentText,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        Text(
          subText,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildGridButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
          ),
        ],
      ),
    );
  }
}
