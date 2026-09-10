import 'package:flutter/material.dart';
import '../models/store_models.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String initialCategory;
  final VoidCallback? onBack;
  final Function(StoreProduct)? onProductSelect;

  const CategoryProductsScreen({
    Key? key,
    this.initialCategory = 'الإلكترونيات',
    this.onBack,
    this.onProductSelect,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late String _selectedMainCategory;
  String _selectedSubCategory = 'الكل';
  final Set<int> _favoriteProductIds = {1};

  final List<String> _mainCategories = [
    'الكل',
    'الإلكترونيات',
    'الملابس',
    'المأكولات',
  ];

  final List<String> _subCategories = [
    'الكل',
    'هواتف',
    'أجهزة لوحية',
    'كمبيوترات',
  ];

  final List<StoreProduct> _allProducts = [
    StoreProduct(
      id: 1,
      name: 'تلفون سامسونج',
      price: 180000.0,
      originalPrice: 200000.0,
      discountText: 'خصم 10%',
      categoryName: 'هواتف',
      customCategoryName: 'هواتف ذكية',
      storeName: 'الاناقات',
      brand: 'Samsung',
      stock: 5,
      sku: 'SAM-S23',
      description: 'هاتف سامسونج فائق السرعة مع كاميرا احترافية وشاشة ديناميكية.',
      availableColors: ['أسود', 'فضي', 'أخضر'],
      availableSizes: ['128GB', '256GB', '512GB'],
      warranty: 'ضمان سنة كاملة ضد العيوب المصنعية',
      material: 'زجاج ومعدن تيتانيوم',
      condition: 'جديد بكرتون المصنع',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    ),
    StoreProduct(
      id: 2,
      name: 'بنطلون',
      price: 1900.0,
      originalPrice: 2000.0,
      discountText: 'وفر 5%',
      categoryName: 'الملابس',
      customCategoryName: 'رجالي',
      storeName: 'زيزو',
      brand: 'Apple',
      stock: 40,
      sku: '1234',
      description: 'منتج أصلي معتمد متوفر من زيزو بضمان وجودة عالية وتوصيل سريع.',
      availableColors: ['أحمر', 'أخضر', 'برتقالي'],
      availableSizes: ['S', 'XS', 'M', 'L'],
      warranty: 'ضمان فحص واستلام',
      material: 'جلد',
      condition: 'جديد',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    ),
    StoreProduct(
      id: 3,
      name: 'زيدو',
      price: 10000.0,
      categoryName: 'الملابس',
      customCategoryName: 'شبابي',
      storeName: 'الاناقات',
      brand: 'Zara',
      stock: 15,
      sku: 'ZID-01',
      description: 'طقم رجالي أنيق مناسب لجميع المناسبات.',
      availableColors: ['أبيض', 'كحلي', 'رمادي'],
      availableSizes: ['M', 'L', 'XL'],
      warranty: 'ضمان استبدال خلال 3 أيام',
      material: 'قطن طبيعي',
      condition: 'جديد',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400',
    ),
    StoreProduct(
      id: 4,
      name: 'جهاز لوحي تاب 11',
      price: 95000.0,
      categoryName: 'أجهزة لوحية',
      customCategoryName: 'إلكترونيات',
      storeName: 'سوق بلس',
      brand: 'Lenovo',
      stock: 8,
      sku: 'TAB-11',
      description: 'تابلت عالي الأداء ممتاز للدراسة والعمل وتشغيل الوسائط بدقة عالية.',
      availableColors: ['رمادي فلكي', 'فضي'],
      availableSizes: ['64GB', '128GB'],
      warranty: 'ضمان 6 أشهر فحص واستلام',
      material: 'ألمنيوم مقوى',
      condition: 'جديد',
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
    ),
    StoreProduct(
      id: 5,
      name: 'لابتوب ألترا بوك',
      price: 340000.0,
      originalPrice: 380000.0,
      discountText: 'خصم 10%',
      categoryName: 'كمبيوترات',
      customCategoryName: 'أجهزة حاسوب',
      storeName: 'الاناقات',
      brand: 'Dell',
      stock: 3,
      sku: 'DELL-XPS',
      description: 'كمبيوتر محمول فائق النحافة مع معالج الجيل الحديث وبطارية تدوم طوال اليوم.',
      availableColors: ['فضي بلاتينيوم'],
      availableSizes: ['16GB RAM / 512GB SSD'],
      warranty: 'ضمان رسمي 12 شهر',
      material: 'ألياف الكربون وألمنيوم',
      condition: 'جديد',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMainCategory = widget.initialCategory;
  }

  List<StoreProduct> get _filteredProducts {
    return _allProducts.where((p) {
      if (_selectedMainCategory != 'الكل') {
        if (_selectedMainCategory == 'الإلكترونيات') {
          final isElec = p.categoryName == 'هواتف' ||
              p.categoryName == 'أجهزة لوحية' ||
              p.categoryName == 'كمبيوترات' ||
              p.categoryName == 'الإلكترونيات';
          if (!isElec) return false;
        } else if (_selectedMainCategory == 'الملابس') {
          if (p.categoryName != 'الملابس') return false;
        }
      }

      if (_selectedSubCategory != 'الكل') {
        if (p.categoryName != _selectedSubCategory) return false;
      }

      return true;
    }).toList();
  }

  void _openProduct(StoreProduct product) {
    if (widget.onProductSelect != null) {
      widget.onProductSelect!(product);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
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
          'أقسام وتصنيفات المنتجات',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: primaryNavy),
            onPressed: () {},
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Main Categories Tabs
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: _mainCategories.map((cat) {
                    final isSelected = _selectedMainCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedMainCategory = cat;
                            _selectedSubCategory = 'الكل';
                          });
                        },
                        selectedColor: primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Sub Categories Filter Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _subCategories.map((sub) {
                    final isSelected = _selectedSubCategory == sub;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(sub),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedSubCategory = sub;
                          });
                        },
                        selectedColor: const Color(0xFFEFF6FF),
                        checkmarkColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF93C5FD) : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Category Info Banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.category, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تصفح قسم: $_selectedMainCategory',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_filteredProducts.length} منتج يندرج ضمن هذا القسم',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد منتجات مطابقة لهذا الصنف حالياً',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (ctx, index) {
                        final product = _filteredProducts[index];
                        final isFav = _favoriteProductIds.contains(product.id);

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openProduct(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image & Top Tags
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Container(
                                        height: 140,
                                        width: double.infinity,
                                        color: Colors.grey.shade100,
                                        child: product.imageUrl != null
                                            ? Image.network(
                                                product.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                    Icons.shopping_bag_outlined,
                                                    size: 48,
                                                    color: Colors.grey),
                                              )
                                            : const Icon(Icons.shopping_bag_outlined,
                                                size: 48, color: Colors.grey),
                                      ),
                                    ),
                                    // Favorite button
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white.withOpacity(0.9),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? Colors.red : Colors.grey.shade600,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isFav) {
                                                _favoriteProductIds.remove(product.id);
                                              } else {
                                                _favoriteProductIds.add(product.id);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    // Discount badge
                                    if (product.discountText != null)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDC2626),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.discountText!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              product.categoryName,
                                              style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
                                            ),
                                          ),
                                          if (product.brand != null) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              product.brand!,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ]
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        product.storeName,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${product.price.toStringAsFixed(0)} ر.ي',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: primaryNavy,
                                                ),
                                              ),
                                              if (product.originalPrice != null)
                                                Text(
                                                  '${product.originalPrice!.toStringAsFixed(0)} ر.ي',
                                                  style: TextStyle(
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey.shade400,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('تمت إضافة ${product.name} إلى السلة!')),
                                            );
                                          },
                                          icon: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
                                          label: const Text('أضف للسلة', style: TextStyle(fontSize: 11, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryNavy,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
