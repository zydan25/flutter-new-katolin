import 'package:flutter/material.dart';
import '../models/store_models.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCheckoutSuccess;

  const CartScreen({
    Key? key,
    this.onBack,
    this.onCheckoutSuccess,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<OrderItemDetail> _cartItems = [
    OrderItemDetail(
      id: 1,
      productName: 'بنطلون رجالي جينز أصلي',
      quantity: 1,
      unitPrice: 1900.0,
      categoryName: 'الملابس',
      sku: '1234',
    ),
    OrderItemDetail(
      id: 2,
      productName: 'سماعة بلوتوث لاسلكية',
      quantity: 1,
      unitPrice: 8500.0,
      categoryName: 'إلكترونيات',
      sku: 'EAR-01',
    ),
  ];

  final TextEditingController _couponController = TextEditingController();
  double _discount = 0.0;
  final double _shippingFee = 0.0;

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  double get _total {
    return (_subtotal - _discount + _shippingFee).clamp(0.0, double.infinity);
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code == 'SHOPIK' || code == 'ZIZO') {
      setState(() {
        _discount = 500.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تطبيق كود الخصم بنجاح وفرت 500 ر.ي!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كود الخصم غير صالح أو منتهي الصلاحية')),
      );
    }
  }

  void _confirmCheckout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تأكيد الدفع من المحفظة', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المبلغ الإجمالي المطلوب: ${_total.toStringAsFixed(0)} ر.ي'),
              const SizedBox(height: 8),
              const Text('طريقة الدفع المعتمدة: المحفظة الإلكترونية (Wallet)'),
              const SizedBox(height: 8),
              const Text('سيتم حجز المبلغ مؤقتاً لصالح الطلب حتى الاستلام الفعلي.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _cartItems.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تأكيد الطلب بنجاح وهو الآن قيد التجهيز!')),
                );
                if (widget.onCheckoutSuccess != null) widget.onCheckoutSuccess!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child: const Text('تأكيد الشراء', style: TextStyle(color: Colors.white)),
            ),
          ],
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
        title: Text(
          'سلة المشتريات (${_cartItems.length})',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('سلة المشتريات فارغة حالياً',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('تصفح المنتجات وأضف ما يعجبك إلى سلتك',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cart items list
                    ..._cartItems.map((item) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined, color: primaryNavy, size: 30),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('${item.unitPrice.toStringAsFixed(0)} ر.ي',
                                        style: const TextStyle(
                                            color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          final idx = _cartItems.indexOf(item);
                                          _cartItems[idx] = OrderItemDetail(
                                            id: item.id,
                                            productName: item.productName,
                                            quantity: item.quantity - 1,
                                            unitPrice: item.unitPrice,
                                            categoryName: item.categoryName,
                                            sku: item.sku,
                                          );
                                        } else {
                                          _cartItems.remove(item);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        final idx = _cartItems.indexOf(item);
                                        _cartItems[idx] = OrderItemDetail(
                                          id: item.id,
                                          productName: item.productName,
                                          quantity: item.quantity + 1,
                                          unitPrice: item.unitPrice,
                                          categoryName: item.categoryName,
                                          sku: item.sku,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    // Coupon code input
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponController,
                                decoration: const InputDecoration(
                                  hintText: 'أدخل كود الخصم (مثل: SHOPIK)',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _applyCoupon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryNavy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('تطبيق', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pricing summary card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildRow('المجموع الفرعي', '${_subtotal.toStringAsFixed(0)} ر.ي'),
                            if (_discount > 0)
                              _buildRow('كود الخصم', '- ${_discount.toStringAsFixed(0)} ر.ي', color: Colors.green),
                            _buildRow('رسوم التوصيل', 'مجاناً', color: Colors.green),
                            const Divider(height: 20),
                            _buildRow('الإجمالي النهائي', '${_total.toStringAsFixed(0)} ر.ي',
                                isBold: true, fontSize: 17, color: const Color(0xFFDC2626)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Checkout Button
                    ElevatedButton(
                      onPressed: _confirmCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'تأكيد وإتمام الطلب (${_total.toStringAsFixed(0)} ر.ي)',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
