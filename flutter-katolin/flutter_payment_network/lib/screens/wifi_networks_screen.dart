import 'dart:math';
import 'package:flutter/material.dart';

class WifiNetworksScreen extends StatefulWidget {
  final String apiToken;
  final String baseUrl;
  final VoidCallback? onBackToMain;

  const WifiNetworksScreen({
    Key? key,
    required this.apiToken,
    required this.baseUrl,
    this.onBackToMain,
  }) : super(key: key);

  @override
  State<WifiNetworksScreen> createState() => _WifiNetworksScreenState();
}

class _WifiNetworksScreenState extends State<WifiNetworksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _networks = [
    {
      'id': 0,
      'name': 'العطاب اكسبرس',
      'location': 'ذمار - حي السكنية - الشارع العام',
      'owner': 'زيدان العطاب',
      'phone': '774952665',
      'isFavorite': true,
      'denominations': [
        {'name': 'كرت 100', 'price': 80.0, 'validity': '1 ساعة (500 MB)'},
        {'name': 'كرت 200', 'price': 170.0, 'validity': '3 ساعات (2 GB)'},
        {'name': 'كرت 300', 'price': 270.0, 'validity': '6 ساعات (4 GB)'},
        {'name': 'كرت 500', 'price': 450.0, 'validity': 'يومي 24 ساعة (7 GB)'},
      ],
    },
    {
      'id': 1,
      'name': 'شبكة زين نت( بعدان_المخادر)',
      'location': 'إب - بعدان - سوق الجبجب',
      'owner': 'مهندس زين',
      'phone': '771234567',
      'isFavorite': true,
      'denominations': [
        {'name': 'كرت 100', 'price': 80.0, 'validity': '1 ساعة (500 MB)'},
        {'name': 'كرت 200', 'price': 170.0, 'validity': '3 ساعات (1.5 GB)'},
        {'name': 'كرت 300', 'price': 270.0, 'validity': '5 ساعات (3 GB)'},
        {'name': 'كرت 500', 'price': 450.0, 'validity': 'يومي 24 ساعة (6 GB)'},
      ],
    },
    {
      'id': 2,
      'name': 'شبكة سوبر نت',
      'location': 'صنعاء - التحرير - جوار البريد',
      'owner': 'محمد الحيمي',
      'phone': '772223344',
      'isFavorite': false,
      'denominations': [
        {'name': 'كرت 100', 'price': 85.0, 'validity': '1 ساعة (500 MB)'},
        {'name': 'كرت 200', 'price': 175.0, 'validity': '3 ساعات (2 GB)'},
        {'name': 'كرت 500', 'price': 460.0, 'validity': 'يومي (6 GB)'},
      ],
    },
    {
      'id': 3,
      'name': 'شبكة الاسطورة نت',
      'location': 'تعز - شارع جمال - مجمع الشروق',
      'owner': 'فؤاد القدسي',
      'phone': '733334455',
      'isFavorite': false,
      'denominations': [
        {'name': 'كرت 150', 'price': 130.0, 'validity': '2 ساعة (1 GB)'},
        {'name': 'كرت 300', 'price': 270.0, 'validity': '5 ساعات (3 GB)'},
        {'name': 'كرت 600', 'price': 520.0, 'validity': 'يومي (8 GB)'},
      ],
    },
    {
      'id': 4,
      'name': 'شبكة الامبراطور نت',
      'location': 'الحديدة - الحوك - شارع صنعاء',
      'owner': 'أحمد التهامي',
      'phone': '711122334',
      'isFavorite': false,
      'denominations': [
        {'name': 'كرت 100', 'price': 80.0, 'validity': '1 ساعة'},
        {'name': 'كرت 200', 'price': 170.0, 'validity': '3 ساعات'},
        {'name': 'كرت 500', 'price': 450.0, 'validity': '24 ساعة'},
      ],
    },
    {
      'id': 5,
      'name': 'شبكة ون نت اللاسلكية',
      'location': 'ذمار - الدائري الغربي - جولة الجمارك',
      'owner': 'صالح العمري',
      'phone': '778899001',
      'isFavorite': true,
      'denominations': [
        {'name': 'كرت 100', 'price': 80.0, 'validity': '1 ساعة'},
        {'name': 'كرت 200', 'price': 170.0, 'validity': '3 ساعات'},
        {'name': 'كرت 500', 'price': 450.0, 'validity': '24 ساعة'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openPurchaseBottomSheet(Map<String, dynamic> net) {
    int quantity = 1;
    Map<String, dynamic> selectedDenom = (net['denominations'] as List).first as Map<String, dynamic>;
    final phoneCtrl = TextEditingController(text: '774952665');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final total = selectedDenom['price'] * quantity;

          return Directionality(
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
                  // Header (Matches Screenshot 4)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      Text(
                        net['name'],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const Divider(),

                  // Phone Input Row (Matches Screenshot 4)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.contacts, color: Color(0xFFC62828), size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 9,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'رقم هاتف الزبون (لإرسال الكود SMS)',
                            labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity Selector Row (Matches Screenshot 4: - [ 1 ] +)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الكمية المطلوبة:',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFC62828)),
                            onPressed: () {
                              if (quantity > 1) {
                                setSheetState(() => quantity--);
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC62828)),
                            onPressed: () {
                              setSheetState(() => quantity++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Denominations Grid (Matches Screenshot 4)
                  const Text(
                    'اختر فئة الكرت:',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (net['denominations'] as List).map((d) {
                      final isSelected = d['name'] == selectedDenom['name'];
                      return InkWell(
                        onTap: () => setSheetState(() => selectedDenom = d as Map<String, dynamic>),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: (MediaQuery.of(ctx).size.width - 48) / 2,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFC62828).withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC62828) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['name'],
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? const Color(0xFFC62828) : Colors.black87,
                                ),
                              ),
                              Text(
                                '${d['price']} ريال',
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
                              ),
                              Text(
                                d['validity'],
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Total & Buy Button (Matches Screenshot 4)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي المطلوب:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        Text(
                          '$total ر.ي',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC62828)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showPurchaseSuccessDialog(net['name'], selectedDenom['name'], quantity, total, phoneCtrl.text);
                    },
                    child: const Text(
                      'شراء الكرت الآن',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseSuccessDialog(String netName, String denomName, int quantity, double total, String phone) {
    final randNum = 10000000 + Random().nextInt(90000000);
    final cardCode = 'WF-$randNum';
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
              SizedBox(width: 8),
              Text('تم شراء الكرت بنجاح!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('الشبكة: $netName', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              Text('الفئة: $denomName ($quantity كرت)'),
              Text('المبلغ المخصوم: $total ر.ي', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
              if (phone.isNotEmpty) Text('تم إرسال الكود لهاتف الزبون: $phone'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  children: [
                    const Text('كود الكرت / PIN:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      cardCode,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ كود الكرت للحافظة', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.white, size: 16),
              label: const Text('نسخ الكود', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _networks.where((n) {
      if (_searchQuery.isEmpty) return true;
      return n['name'].toString().contains(_searchQuery) ||
          n['location'].toString().contains(_searchQuery);
    }).toList();

    final favorites = filtered.where((n) => n['isFavorite'] == true).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828), // Deep Red matching screenshot 3
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
            'كبينة WIFI',
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
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'كل الشبكات'),
              Tab(text: 'المفضلة'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Input Bar (Matches Screenshot 3)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'بحث بإسم الشبكة او رقمها...',
                  hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFC62828)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Tabs Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNetworksList(filtered),
                  _buildNetworksList(favorites),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworksList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('لا توجد شبكات مطابقة للبحث', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final net = list[i];
        final id = net['id'];
        final isFav = net['isFavorite'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            // Index Circle (0, 1, 2... matches Screenshot 3)
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFC62828).withOpacity(0.1),
              child: Text(
                '$id',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              net['name'],
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              net['location'],
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      net['isFavorite'] = !isFav;
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openPurchaseBottomSheet(net),
                  child: const Text('شراء كرت', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension _RandomRange on int {
  int random() => this + (DateTime.now().microsecondsSinceEpoch % 1000);
}
