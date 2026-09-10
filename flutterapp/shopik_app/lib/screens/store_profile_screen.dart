import 'package:flutter/material.dart';
import '../models/store_models.dart';
import 'product_detail_screen.dart';

class StoreProfileScreen extends StatefulWidget {
  final StoreVendor store;
  final VoidCallback? onBack;

  const StoreProfileScreen({
    Key? key,
    required this.store,
    this.onBack,
  }) : super(key: key);

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'العروض', 'جديدنا', 'الأكثر طلباً'];

  final List<StoreProduct> _storeProducts = [
    StoreProduct(
      id: 1,
      name: 'تلفون سامسونج',
      price: 180000.0,
      originalPrice: 200000.0,
      discountText: 'خصم 10%',
      categoryName: 'هواتف',
      storeName: 'الاناقات',
      brand: 'Samsung',
      stock: 5,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    ),
    StoreProduct(
      id: 2,
      name: 'بنطلون',
      price: 1900.0,
      originalPrice: 2000.0,
      discountText: 'وفر 5%',
      categoryName: 'الملابس',
      storeName: 'الاناقات',
      brand: 'Apple',
      stock: 40,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    ),
    StoreProduct(
      id: 3,
      name: 'زيدو',
      price: 10000.0,
      categoryName: 'الملابس',
      storeName: 'الاناقات',
      brand: 'Zara',
      stock: 15,
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400',
    ),
    StoreProduct(
      id: 4,
      name: 'سماعة بلوتوث لاسلكية',
      price: 8500.0,
      categoryName: 'إلكترونيات',
      storeName: 'الاناقات',
      brand: 'Sony',
      stock: 20,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    ),
  ];

  void _openProduct(StoreProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
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
        title: Text(
          s.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Header Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: const Icon(Icons.storefront, color: Color(0xFF2563EB), size: 36),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Color(0xFF2563EB), size: 18),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${s.rating} (تقييم ممتاز من العملاء)',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons: Call & WhatsApp / Chat
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('الاتصال بـ ${s.name}: ${s.phone}')),
                                );
                              },
                              icon: const Icon(Icons.call, size: 16, color: Colors.white),
                              label: const Text('اتصال', style: TextStyle(color: Colors.white, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('بدء المحادثة المباشرة مع ${s.name}...')),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                              label: const Text('محادثة المتجر', style: TextStyle(color: Colors.white, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryNavy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Address and working hours info
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                          const SizedBox(width: 6),
                          Text(s.address, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 16),
                          const SizedBox(width: 6),
                          Text(s.workingHours, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          const Spacer(),
                          const Icon(Icons.delivery_dining, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(s.deliveryEta, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSel = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSel,
                        onSelected: (val) => setState(() => _selectedFilter = f),
                        selectedColor: primaryNavy,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Store Products Count Header
              Text(
                'منتجات المتجر (${_storeProducts.length}) :',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),

              // Grid of Products
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _storeProducts.length,
                itemBuilder: (ctx, idx) {
                  final p = _storeProducts[idx];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _openProduct(p),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Container(
                              height: 130,
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              child: p.imageUrl != null
                                  ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.price.toStringAsFixed(0)} ر.ي',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('تمت إضافة ${p.name} إلى السلة!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryNavy,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text('أضف للسلة',
                                        style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
