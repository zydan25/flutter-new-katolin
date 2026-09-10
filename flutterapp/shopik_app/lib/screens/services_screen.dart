import 'package:flutter/material.dart';
import 'wifi_networks_screen.dart';
import 'subscriber_transfer_screen.dart';

class ServicesScreen extends StatelessWidget {
  final String apiToken;
  final String baseUrl;
  final VoidCallback? onBackToMain;
  final VoidCallback? onOpenPaymentNetwork;

  const ServicesScreen({
    Key? key,
    required this.apiToken,
    required this.baseUrl,
    this.onBackToMain,
    this.onOpenPaymentNetwork,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 9 Services grid matching Screenshot 5
    final services = [
      {
        'title': 'كبينة السداد',
        'subtitle': 'تسديد باقات ورصيد الاتصالات',
        'icon': Icons.phone_android,
        'color': const Color(0xFFC62828),
        'action': 'payment',
      },
      {
        'title': 'الشرائح والتفعيل',
        'subtitle': 'تفعيل وطلب شرائح فورجي 4G',
        'icon': Icons.sim_card,
        'color': const Color(0xFF1565C0),
        'action': 'sim',
      },
      {
        'title': 'تحويل الى حساب عميل اخر',
        'subtitle': 'تحويل فوري مباشر بين المشتركين',
        'icon': Icons.send,
        'color': const Color(0xFF2E7D32),
        'action': 'transfer',
      },
      {
        'title': 'غذي حسابك بنفسك',
        'subtitle': 'شحن رصيدك عبر المحافظ والبنوك',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFFEF6C00),
        'action': 'deposit',
      },
      {
        'title': 'فواتير الكهرباء والماء',
        'subtitle': 'سداد فواتير الخدمات الحكومية',
        'icon': Icons.bolt,
        'color': const Color(0xFFF9A825),
        'action': 'utility',
      },
      {
        'title': 'توثيق الحساب',
        'subtitle': 'رفع الهوية وتأكيد بيانات العميل',
        'icon': Icons.verified_user,
        'color': const Color(0xFF6A1B9A),
        'action': 'verify',
      },
      {
        'title': 'تسديد المخالفات المرورية',
        'subtitle': 'استعلام وسداد المخالفات',
        'icon': Icons.directions_car,
        'color': const Color(0xFF00838F),
        'action': 'traffic',
      },
      {
        'title': 'معرض شبكاتي',
        'subtitle': 'إدارة شبكاتك ونقاط البيع',
        'icon': Icons.cell_tower,
        'color': const Color(0xFF455A64),
        'action': 'networks',
      },
      {
        'title': 'كبينة الوايفاي',
        'subtitle': 'شراء كروت شبكات الوايفاي المحلية',
        'icon': Icons.wifi,
        'color': const Color(0xFFAD1457),
        'action': 'wifi',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            tooltip: 'عودة',
            onPressed: () {
              if (onBackToMain != null) {
                onBackToMain!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            'دليل الخدمات الإلكترونية',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Search Box (Matches Screenshot 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'ابحث عن أي خدمة هنا...',
                  hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFC62828)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Services Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: services.length,
              itemBuilder: (ctx, i) {
                final s = services[i];
                final color = s['color'] as Color;
                final icon = s['icon'] as IconData;

                return InkWell(
                  onTap: () {
                    final action = s['action'] as String;
                    if (action == 'payment') {
                      if (onOpenPaymentNetwork != null) {
                        onOpenPaymentNetwork!();
                      } else {
                        Navigator.pop(ctx);
                      }
                    } else if (action == 'wifi') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WifiNetworksScreen(apiToken: apiToken, baseUrl: baseUrl),
                        ),
                      );
                    } else if (action == 'transfer') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubscriberTransferScreen(apiToken: apiToken, baseUrl: baseUrl),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فتح خدمة: ${s['title']}', style: const TextStyle(fontFamily: 'Cairo'))),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['subtitle'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
