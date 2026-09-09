import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/store_models.dart';
import 'store_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final StoreProduct product;
  final VoidCallback? onBack;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    this.onBack,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late String _selectedColor;
  late String _selectedSize;
  bool _isFavorite = false;

  final List<String> _productImages = [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600',
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600',
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600',
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.availableColors.isNotEmpty
        ? widget.product.availableColors.first
        : 'أحمر';
    _selectedSize = widget.product.availableSizes.isNotEmpty
        ? widget.product.availableSizes.first
        : 'M';
  }

  void _copySku() {
    Clipboard.setData(ClipboardData(text: widget.product.sku));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ رقم الصنف (${widget.product.sku}) بنجاح!')),
    );
  }

  void _openStoreProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreProfileScreen(
          store: StoreVendor(
            id: widget.product.storeId,
            name: widget.product.storeName,
            address: 'صنعاء - شارع الزبيري',
            phone: '777605123',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
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
          'تفاصيل المنتج',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط المنتج للمشاركة')),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Image Slider with "الأكثر طلباً" & numbered thumbnails
              _buildImageSlider(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumbs
                    Text(
                      'الرئيسية > المنتجات والتصنيفات > ${p.brand ?? 'Apple'}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),

                    // Title & Rating
                    Text(
                      p.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${p.rating} (${p.reviewsCount} تقييم من العملاء) • متوفر في المخزون',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pricing Row
                    Row(
                      children: [
                        Text(
                          '${p.price.toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        if (p.originalPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${p.originalPrice!.toStringAsFixed(0)} ر.ي',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                        if (p.discountText != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.discountText!,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SKU / رقم الصنف with copy button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رقم الصنف: ${p.sku}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          TextButton.icon(
                            onPressed: _copySku,
                            icon: const Icon(Icons.copy, size: 14, color: Color(0xFF2563EB)),
                            label: const Text('اضغط لنسخ رقم الصنف', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available Colors Selector
                    Text('الألوان المتاحة : ($_selectedColor)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: p.availableColors.map((colorName) {
                        final isSel = _selectedColor == colorName;
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ChoiceChip(
                            label: Text(colorName),
                            selected: isSel,
                            onSelected: (val) {
                              setState(() {
                                _selectedColor = colorName;
                              });
                            },
                            selectedColor: primaryNavy,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Available Sizes Selector
                    const Text('المقاسات والخيارات المتاحة :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: p.availableSizes.map((size) {
                        final isSel = _selectedSize == size;
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ChoiceChip(
                            label: Text(size),
                            selected: isSel,
                            onSelected: (val) {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            selectedColor: primaryNavy,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Warranty and Return Policy Card
                    _buildWarrantyCard(p),
                    const SizedBox(height: 16),

                    // Description Card
                    _buildDescriptionCard(p),
                    const SizedBox(height: 16),

                    // Technical Specifications Card
                    _buildTechSpecsCard(p),
                    const SizedBox(height: 16),

                    // Vendor Profile Card
                    _buildVendorCard(p),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              // Quantity control
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Add to cart button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تمت إضافة $_quantity من ${p.name} إلى السلة!')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                  label: const Text('أضف للسلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Buy Now button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري الانتقال للدفع المباشر...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('شراء الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Image.network(
                _productImages[_selectedImageIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'الأكثر طلباً',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_productImages.length, (idx) {
            final isSel = idx == _selectedImageIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = idx),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSel ? const Color(0xFF2563EB) : Colors.grey.shade300,
                    width: isSel ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text('${idx + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSel ? const Color(0xFF2563EB) : Colors.grey.shade600,
                    )),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWarrantyCard(StoreProduct p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.verified_user_outlined, color: Color(0xFF059669), size: 20),
                SizedBox(width: 8),
                Text('الضمان وسياسة الاستبدال :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${p.warranty} • مدة الضمان: ضمان فحص واستبدال معتمد • استبدال فوري أو استرجاع خلال 7 أيام في حال وجود أي عيب مصنعي.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(StoreProduct p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('وصف المنتج والمواصفات :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              p.description ?? 'منتج عالي الجودة معتمد ومضمون متوفر للتوصيل الفوري.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechSpecsCard(StoreProduct p) {
    final specs = [
      {'key': 'الماركة', 'val': p.brand ?? 'Apple'},
      {'key': 'الخامة', 'val': p.material ?? 'جلد'},
      {'key': 'حالة المنتج', 'val': p.condition ?? 'جديد'},
      {'key': 'الضمان', 'val': 'لا'},
      {'key': 'القسم المعتمد', 'val': p.customCategoryName ?? 'رجالي'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المواصفات الفنية المعتمدة للقسم :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...specs.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['key']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    Text(item['val']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(StoreProduct p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFEFF6FF),
              child: const Icon(Icons.storefront, color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.storeName} - تاجر معتمد في سوق بلس',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text('4.8 (تقييم ممتاز)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _openStoreProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('زيارة المتجر', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
