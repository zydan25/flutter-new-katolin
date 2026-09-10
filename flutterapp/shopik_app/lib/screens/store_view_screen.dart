import 'package:flutter/material.dart';
import '../models/store_models.dart';
import 'cart_screen.dart';
import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'store_profile_screen.dart';

class StoreViewScreen extends StatefulWidget {
  final VoidCallback? onBackToMain;

  const StoreViewScreen({
    Key? key,
    this.onBackToMain,
  }) : super(key: key);

  @override
  State<StoreViewScreen> createState() => _StoreViewScreenState();
}

class _StoreViewScreenState extends State<StoreViewScreen> {
  static const Color _crimson = Color(0xFF8B1D3B);
  static const Color _bg = Color(0xFFF8FAFC);

  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _loading = false;

  final Set<int> _favorites = {};
  final List<Map<String, dynamic>> _cart = [];

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'الكل'},
    {'id': 'رجالي', 'name': 'رجالي'},
    {'id': 'الملابس', 'name': 'الملابس'},
    {'id': 'الإلكترونيات', 'name': 'الإلكترونيات'},
    {'id': 'هواتف', 'name': 'هواتف'},
    {'id': 'عطور', 'name': 'عطور'},
    {'id': 'ألعاب أطفال', 'name': 'ألعاب'},
  ];

  final List<Map<String, dynamic>> _vendors = [
    {'id': 3, 'name': 'متجر زيزو', 'badge': 'موثق ⭐', 'rating': 4.9},
    {'id': 1, 'name': 'متجر الأناقات', 'badge': 'مميز 🌟', 'rating': 4.8},
  ];

  final List<Map<String, String>> _banners = [
    {
      'title': 'تخفيضات كبرى في سوق شبيك',
      'subtitle': 'خصومات حصرية حتى 40% على الملابس والإلكترونيات',
      'tag': 'عرض اليوم',
      'bgStart': '0xFF8B1D3B',
      'bgEnd': '0xFFBE185D',
    },
    {
      'title': 'شحن سريع لكافة المحافظات',
      'subtitle': 'صنعاء، إب، عدن، تعز - توصيل خلال 24 ساعة',
      'tag': 'توصيل شبيك',
      'bgStart': '0xFF1E40AF',
      'bgEnd': '0xFF1E3A8A',
    },
  ];

  final List<StoreProduct> _products = [
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
      sku: 'SAM-S23',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    ),
    StoreProduct(
      id: 2,
      name: 'بنطلون جينز كلاسيك',
      price: 1900.0,
      originalPrice: 2000.0,
      discountText: 'وفر 5%',
      categoryName: 'الملابس',
      storeName: 'زيزو',
      brand: 'Apple',
      stock: 40,
      sku: '1234',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    ),
    StoreProduct(
      id: 3,
      name: 'قميص شبابي فاخر',
      price: 4500.0,
      originalPrice: 5000.0,
      discountText: 'وفر 10%',
      categoryName: 'الملابس',
      storeName: 'زيزو',
      brand: 'Zara',
      stock: 15,
      sku: 'SH-09',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400',
    ),
    StoreProduct(
      id: 4,
      name: 'ساعة ذكية ألترا',
      price: 18000.0,
      originalPrice: 22000.0,
      discountText: 'خصم 18%',
      categoryName: 'الإلكترونيات',
      storeName: 'زيزو',
      brand: 'Apple',
      stock: 9,
      sku: 'SW-01',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    ),
    StoreProduct(
      id: 5,
      name: 'سماعة بلوتوث لاسلكية',
      price: 8500.0,
      categoryName: 'الإلكترونيات',
      storeName: 'الاناقات',
      brand: 'Sony',
      stock: 20,
      sku: 'EAR-01',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    ),
    StoreProduct(
      id: 6,
      name: 'جهاز لوحي تاب 11',
      price: 95000.0,
      categoryName: 'الإلكترونيات',
      storeName: 'سوق بلس',
      brand: 'Lenovo',
      stock: 8,
      sku: 'TAB-11',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
    ),
  ];

  List<StoreProduct> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.contains(_searchQuery) ||
          p.storeName.contains(_searchQuery) ||
          (p.categoryName.contains(_searchQuery));
      final matchesCat = _selectedCategory == 'all' ||
          p.categoryName == _selectedCategory ||
          (_selectedCategory == 'رجالي' && p.name.contains('بنطلون')) ||
          (_selectedCategory == 'الإلكترونيات' && (p.name.contains('سامسونج') || p.categoryName == 'الإلكترونيات'));
      return matchesSearch && matchesCat;
    }).toList();
  }

  int get _cartCount => _cart.fold(0, (s, e) => s + (e['quantity'] as int));

  void _addToCart(StoreProduct p, {int qty = 1}) {
    setState(() {
      final idx = _cart.indexWhere((e) => e['id'] == p.id);
      if (idx >= 0) {
        _cart[idx]['quantity'] = (_cart[idx]['quantity'] as int) + qty;
      } else {
        _cart.add({
          'id': p.id,
          'name': p.name,
          'price': p.originalPrice != null && p.originalPrice! < p.price ? p.price : p.price,
          'imageUrl': p.imageUrl,
          'quantity': qty,
          'storeName': p.storeName,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${p.name} إلى السلة!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openProduct(StoreProduct p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
  }

  void _openStoreProfile(String name) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => StoreProfileScreen(
        store: StoreVendor(id: 1, name: name),
      ),
    ));
  }

  void _openCategory(String catName) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CategoryProductsScreen(initialCategory: catName),
    ));
  }

  void _openCart() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // Top Header Bar
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 2)],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Banners
                  _buildBanners(),
                  const SizedBox(height: 16),

                  // Categories
                  _buildCategoriesSection(),
                  const SizedBox(height: 16),

                  // Vendors
                  _buildVendorsSection(),
                  const SizedBox(height: 16),

                  // Products Header
                  _buildProductsHeader(),
                  const SizedBox(height: 10),

                  // Products Grid
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(color: _crimson)),
                    )
                  else if (_filteredProducts.isEmpty)
                    _buildEmptyState()
                  else
                    _buildProductsGrid(),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _crimson,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x1A8B1D3B), blurRadius: 4)],
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سوق شبيك بلس', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                Text('المتجر الإلكتروني المعتمد', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          // Account button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFEF3C7).withOpacity(0.8)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 14, color: Color(0xFF8B1D3B)),
                SizedBox(width: 4),
                Text('حسابي', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B))),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Orders button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF475569)),
              ),
              if (_cartCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: _crimson, shape: BoxShape.circle),
                    child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
          // Cart button
          GestureDetector(
            onTap: _openCart,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, size: 18, color: Color(0xFF475569)),
                ),
                if (_cartCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF047857), shape: BoxShape.circle),
                      child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج، متجر، أو صنف...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        itemCount: _banners.length,
        onPageChanged: (i) {},
        itemBuilder: (ctx, idx) {
          final b = _banners[idx];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(int.parse(b['bgStart']!)), Color(int.parse(b['bgEnd']!))],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(b['tag']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                    const Text('متجر شبيك المعتمد', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Spacer(),
                Text(b['title']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(b['subtitle']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Text('تصفح المنتجات ←', style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                    const Text('تطبيق شبيك وسوق بلس', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('أقسام المتجر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const SizedBox(width: 6),
                Text('(${_filteredProducts.length} منتج)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, idx) {
              final cat = _categories[idx];
              final isSel = _selectedCategory == cat['id'];
              return GestureDetector(
                onTap: () {
                  if (cat['id'] != 'all') {
                    _openCategory(cat['name']!);
                  } else {
                    setState(() => _selectedCategory = 'all');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSel ? _crimson : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? _crimson : const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat['name']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.storefront, size: 16, color: Color(0xFF8B1D3B)),
            SizedBox(width: 6),
            Text('متاجر شبيك المعتمدة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
          ),
          itemCount: _vendors.length,
          itemBuilder: (ctx, idx) {
            final v = _vendors[idx];
            return GestureDetector(
              onTap: () => _openStoreProfile(v['name'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 2)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${(v['name'] as String)[5]}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(v['name'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(v['badge'] as String, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text('${v['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: Color(0xFF8B1D3B)),
            SizedBox(width: 6),
            Text('منتجات المتجر الحقيقية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() {}),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 14, color: _loading ? const Color(0xFF8B1D3B) : const Color(0xFF8B1D3B)),
              const SizedBox(width: 4),
              const Text('تحديث', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B1D3B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10),
            Text('لا توجد منتجات تطابق البحث', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
            SizedBox(height: 4),
            Text('جرب إزالة معايير البحث أو اختيار قسم آخر', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (ctx, idx) {
        final p = _filteredProducts[idx];
        final isFav = _favorites.contains(p.id);
        final salePrice = p.originalPrice != null && p.originalPrice! > p.price ? p.price : p.price;
        final hasDiscount = p.originalPrice != null && p.originalPrice! > p.price;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => _openProduct(p),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: p.imageUrl != null
                              ? Image.network(p.imageUrl!, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: Color(0xFFCBD5E1))))
                              : const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      // Store badge
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(p.storeName, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      // Favorite button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (isFav) _favorites.remove(p.id);
                            else _favorites.add(p.id);
                          }),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isFav ? Colors.red : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      // Discount badge
                      if (hasDiscount)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('خصم', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _openProduct(p),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(p.categoryName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${salePrice.toStringAsFixed(0)} ر.ي',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B))),
                                if (hasDiscount)
                                  Text('${p.originalPrice!.toStringAsFixed(0)} ر.ي',
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _addToCart(p),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _crimson,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Color(0x1A8B1D3B), blurRadius: 4)],
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
