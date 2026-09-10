import 'package:flutter/material.dart';

class GamesScreen extends StatefulWidget {
  final String apiToken;
  final String baseUrl;
  final VoidCallback? onBackToMain;

  const GamesScreen({
    Key? key,
    required this.apiToken,
    required this.baseUrl,
    this.onBackToMain,
  }) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'ببجي موبايل PUBG UC',
      'category': 'العاب',
      'icon': Icons.sports_esports,
      'color': const Color(0xFFF57C00),
      'packages': [
        {'name': '60 شدة UC', 'price': 350.0},
        {'name': '325 شدة UC', 'price': 1750.0},
        {'name': '660 شدة UC', 'price': 3450.0},
        {'name': '1800 شدة UC', 'price': 8900.0},
      ],
    },
    {
      'title': 'فري فاير Free Fire',
      'category': 'العاب',
      'icon': Icons.local_fire_department,
      'color': const Color(0xFFE53935),
      'packages': [
        {'name': '100 + 10 جوهرة', 'price': 320.0},
        {'name': '310 + 31 جوهرة', 'price': 950.0},
        {'name': '520 + 52 جوهرة', 'price': 1600.0},
        {'name': '1060 + 106 جوهرة', 'price': 3200.0},
      ],
    },
    {
      'title': 'بطاقات شحن كويتية',
      'category': 'بطائق نت',
      'icon': Icons.sim_card,
      'color': const Color(0xFF1976D2),
      'packages': [
        {'name': 'زين الكويت 1.5 دينار', 'price': 1800.0},
        {'name': 'أوريدو الكويت 3 دينار', 'price': 3600.0},
        {'name': 'STC الكويت 5 دينار', 'price': 6000.0},
      ],
    },
    {
      'title': 'بطاقات إماراتية اتصالات',
      'category': 'بطائق نت',
      'icon': Icons.credit_card,
      'color': const Color(0xFF388E3C),
      'packages': [
        {'name': 'اتصالات 25 درهم', 'price': 2200.0},
        {'name': 'اتصالات 50 درهم', 'price': 4400.0},
        {'name': 'اتصالات 100 درهم', 'price': 8800.0},
      ],
    },
    {
      'title': 'بطاقات شحن إماراتية du',
      'category': 'بطائق نت',
      'icon': Icons.phone_in_talk,
      'color': const Color(0xFF00838F),
      'packages': [
        {'name': 'du دو 20 درهم', 'price': 1750.0},
        {'name': 'du دو 50 درهم', 'price': 4400.0},
      ],
    },
    {
      'title': 'روبلوكس Roblox',
      'category': 'العاب',
      'icon': Icons.videogame_asset,
      'color': const Color(0xFF6A1B9A),
      'packages': [
        {'name': '400 Robux', 'price': 2100.0},
        {'name': '800 Robux', 'price': 4200.0},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openGameRechargeSheet(Map<String, dynamic> game) {
    final idCtrl = TextEditingController();
    Map<String, dynamic> selectedPackage = (game['packages'] as List).first as Map<String, dynamic>;
    String? verifiedPlayerName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    Text(game['title'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC62828))),
                    const SizedBox(width: 40),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: idCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'معرف اللاعب (Player ID)',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFC62828)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onPressed: () {
                        if (idCtrl.text.isNotEmpty) {
                          setSheetState(() {
                            verifiedPlayerName = 'Hero_Player_${idCtrl.text.substring(0, 3)}';
                          });
                        }
                      },
                      child: const Text('استعلام', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (verifiedPlayerName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text('اسم اللاعب المؤكد: $verifiedPlayerName ✓', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 12),
                const Text('اختر الباقة / الفئة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (game['packages'] as List).map((p) {
                    final isSel = p['name'] == selectedPackage['name'];
                    return ChoiceChip(
                      selected: isSel,
                      selectedColor: const Color(0xFFC62828),
                      label: Text('${p['name']} - ${p['price']} ر.ي', style: TextStyle(fontFamily: 'Cairo', color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                      onSelected: (val) => setSheetState(() => selectedPackage = p as Map<String, dynamic>),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إرسال طلب شحن ${selectedPackage['name']} بنجاح!', style: const TextStyle(fontFamily: 'Cairo'))),
                    );
                  },
                  child: Text('شحن فوري (${selectedPackage['price']} ر.ي)', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                ),
              ],
            ),
          ),
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
          backgroundColor: const Color(0xFFC62828),
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
            'خدمات الألعاب والتطبيقات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'العاب'),
              Tab(text: 'تطبيقات'),
              Tab(text: 'بطائق نت'),
              Tab(text: 'تخصيص'),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Promo Banner matching Screenshot 12
            Container(
              height: 90,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.live_tv, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('عيش كل لحظة beIN SPORTS', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('تجديد وتفعيل اشتراكات باقات بي إن سبورت فوري', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Items Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: _games.length,
              itemBuilder: (ctx, i) {
                final g = _games[i];
                final color = g['color'] as Color;
                final icon = g['icon'] as IconData;

                return InkWell(
                  onTap: () => _openGameRechargeSheet(g),
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
                          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          g['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'شحن فوري بالآيدي',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade600),
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
