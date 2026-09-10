import 'package:flutter/material.dart';

class AddressItem {
  final int id;
  final String title;
  final String fullAddress;
  final String phone;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.phone,
    this.isDefault = false,
  });
}

class AddressesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AddressesScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<AddressItem> _addresses = [
    AddressItem(
      id: 1,
      title: 'المنزل',
      fullAddress: 'صنعاء - حدة - الحي الدبلوماسي - جوار السفارة',
      phone: '774952665',
      isDefault: true,
    ),
    AddressItem(
      id: 2,
      title: 'العمل / المتجر',
      fullAddress: 'صنعاء - شارع الزبيري - عمارة الأمل الدور الثاني',
      phone: '771642093',
      isDefault: false,
    ),
  ];

  void _setDefault(int id) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = AddressItem(
          id: _addresses[i].id,
          title: _addresses[i].title,
          fullAddress: _addresses[i].fullAddress,
          phone: _addresses[i].phone,
          isDefault: _addresses[i].id == id,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعيين العنوان كافتراضي بنجاح')),
    );
  }

  void _deleteAddress(int id) {
    setState(() {
      _addresses.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف العنوان بنجاح')),
    );
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '774952665');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('إضافة عنوان جديد للتوصيل',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'تسمية العنوان (مثلاً: المكتب، الاستراحة)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(hintText: 'تفاصيل العنوان (المدينة، الحي، الشارع)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(hintText: 'رقم الهاتف للتواصل أثناء التوصيل'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && addrCtrl.text.isNotEmpty) {
                    setState(() {
                      _addresses.add(
                        AddressItem(
                          id: DateTime.now().millisecondsSinceEpoch,
                          title: titleCtrl.text,
                          fullAddress: addrCtrl.text,
                          phone: phoneCtrl.text,
                          isDefault: _addresses.isEmpty,
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('حفظ العنوان', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'دفتر العناوين والتوصيل',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top notice banner matching Screenshot 9
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'العنوان الافتراضي يُعتمد تلقائياً لحساب رسوم وتوصيل طلبات المتاجر والطرود.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address Cards
              ..._addresses.map((addr) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: addr.isDefault ? const Color(0xFF2563EB) : Colors.grey.shade200,
                      width: addr.isDefault ? 1.5 : 1,
                    ),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: addr.isDefault ? const Color(0xFF2563EB) : Colors.grey, size: 22),
                                const SizedBox(width: 8),
                                Text(addr.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            if (addr.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('العنوان الافتراضي',
                                    style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(addr.fullAddress, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('هاتف: ${addr.phone}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!addr.isDefault)
                              TextButton.icon(
                                onPressed: () => _setDefault(addr.id),
                                icon: const Icon(Icons.check, size: 16, color: Color(0xFF2563EB)),
                                label: const Text('تعيين كافتراضي', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                              ),
                            TextButton.icon(
                              onPressed: () => _deleteAddress(addr.id),
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              label: const Text('حذف', style: TextStyle(fontSize: 12, color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
                label: const Text('إضافة عنوان جديد',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
