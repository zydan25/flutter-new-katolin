import 'package:flutter/material.dart';
import '../models/store_models.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(StoreOrder)? onSelectOrder;

  const OrdersListScreen({
    Key? key,
    this.onBack,
    this.onSelectOrder,
  }) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample orders with real data structure matching shopik backend
  final List<StoreOrder> _orders = [
    StoreOrder(
      id: '1',
      orderNumber: 'ORD-20260907-7F230C',
      date: '07-09-2026',
      vendorName: 'زيزو',
      vendorPhone: '777605123',
      totalAmount: 1900.0,
      subtotal: 1900.0,
      discount: 0.0,
      shippingFee: 0.0,
      heldAmount: 1900.0,
      paymentMethod: 'wallet',
      trackingStep: OrderTrackingStep.paymentConfirmed,
      statusText: 'تم استلام الطلب وتأكيد الدفع',
      deliveryAddress: 'صنعاء - العنوان المسجل',
      courierName: 'مندوب التوصيل',
      courierPhone: '771234567',
      items: [
        OrderItemDetail(
          id: 101,
          productName: 'بنطلون',
          quantity: 1,
          unitPrice: 1900.0,
          categoryName: 'عام',
          sku: '1234',
        ),
      ],
    ),
    StoreOrder(
      id: '2',
      orderNumber: 'ORD-20260905-9B112A',
      date: '05-09-2026',
      vendorName: 'الاناقات',
      vendorPhone: '771771771',
      totalAmount: 180000.0,
      subtotal: 200000.0,
      discount: 20000.0,
      shippingFee: 0.0,
      heldAmount: 180000.0,
      paymentMethod: 'wallet',
      trackingStep: OrderTrackingStep.delivered,
      statusText: 'تم تسليم الطلب بنجاح',
      deliveryAddress: 'صنعاء - شارع الزبيري',
      courierName: 'كابتن أحمد النونو',
      courierPhone: '772345678',
      items: [
        OrderItemDetail(
          id: 102,
          productName: 'تلفون سامسونج',
          quantity: 1,
          unitPrice: 180000.0,
          categoryName: 'هواتف',
          sku: '5566',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openOrderDetail(StoreOrder order) {
    if (widget.onSelectOrder != null) {
      widget.onSelectOrder!(order);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order),
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
          'طلباتي',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryNavy,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: primaryNavy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'الطلبات الحالية (1)'),
            Tab(text: 'الطلبات المكتملة (1)'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active orders tab
            _buildOrdersList(_orders.where((o) => o.trackingStep != OrderTrackingStep.delivered).toList()),
            // Completed orders tab
            _buildOrdersList(_orders.where((o) => o.trackingStep == OrderTrackingStep.delivered).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<StoreOrder> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'لا توجد طلبات في هذا القسم حالياً',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final order = list[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(StoreOrder order) {
    final isDelivered = order.trackingStep == OrderTrackingStep.delivered;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openOrderDetail(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long, color: Color(0xFF2563EB), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${order.vendorName} • ${order.date}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDelivered ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        color: isDelivered ? const Color(0xFF047857) : const Color(0xFFB45309),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 22),

              // Items summary
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${item.productName} (×${item.quantity})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('${(item.unitPrice * item.quantity).toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 12),
              // Footer: Total and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المبلغ الإجمالي:', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openOrderDetail(order),
                    icon: const Icon(Icons.visibility_outlined, size: 16, color: Colors.white),
                    label: const Text('تفاصيل الطلب', style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
