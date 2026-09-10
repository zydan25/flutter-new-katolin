/// Models for E-Commerce Store, Orders, Products, and Categories
class StoreProduct {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final String? discountText;
  final String? imageUrl;
  final List<String> images;
  final String categoryName;
  final String? customCategoryName;
  final String storeName;
  final int storeId;
  final double rating;
  final int reviewsCount;
  final int stock;
  final String sku;
  final String? brand;
  final String? description;
  final List<String> availableColors;
  final List<String> availableSizes;
  final String? warranty;
  final String? material;
  final String? condition;
  final bool isTrending;

  StoreProduct({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountText,
    this.imageUrl,
    this.images = const [],
    required this.categoryName,
    this.customCategoryName,
    required this.storeName,
    this.storeId = 1,
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.stock = 10,
    this.sku = '1234',
    this.brand,
    this.description,
    this.availableColors = const ['أحمر', 'أخضر', 'برتقالي'],
    this.availableSizes = const ['S', 'XS', 'M', 'L'],
    this.warranty = 'ضمان فحص واستلام',
    this.material = 'جلد',
    this.condition = 'جديد',
    this.isTrending = false,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map ? json['details'] : {};
    final vendor = json['vendor'] is Map ? json['vendor'] : {};
    final gallery = json['gallery'] is List ? json['gallery'] as List : [];
    List<String> imgList = [];
    if (json['main_image_url'] != null) imgList.add(json['main_image_url'].toString());
    for (var g in gallery) {
      if (g is Map && g['url'] != null) imgList.add(g['url'].toString());
    }

    return StoreProduct(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1,
      name: json['name']?.toString() ?? 'منتج',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      originalPrice: json['sale_price'] != null ? double.tryParse(json['price']?.toString() ?? '0') : null,
      discountText: json['sale_price'] != null ? 'وفر 5%' : null,
      imageUrl: json['main_image_url']?.toString() ?? (imgList.isNotEmpty ? imgList.first : null),
      images: imgList,
      categoryName: json['category_name']?.toString() ?? details['custom_category_name']?.toString() ?? 'عام',
      customCategoryName: details['custom_category_name']?.toString() ?? 'رجالي',
      storeName: vendor['store_name']?.toString() ?? 'زيزو',
      storeId: vendor['id'] is int ? vendor['id'] : 1,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      stock: json['stock'] is int ? json['stock'] : 10,
      sku: json['sku']?.toString() ?? '1234',
      brand: json['brand']?.toString() ?? 'Apple',
      description: json['description']?.toString() ?? 'منتج أصلي معتمد متوفر من المتجر بجودة عالية وتوصيل سريع.',
      warranty: details['warranty']?.toString() ?? 'ضمان فحص واستلام',
      material: details['material']?.toString() ?? 'جلد',
      condition: details['condition']?.toString() ?? 'جديد',
      isTrending: json['is_trending'] == true,
    );
  }
}

class OrderItemDetail {
  final int id;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final String categoryName;
  final String? sku;

  OrderItemDetail({
    required this.id,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.categoryName = 'عام',
    this.sku = '1234',
  });

  double get totalPrice => quantity * unitPrice;
}

enum OrderTrackingStep {
  paymentConfirmed, // 1: تم استلام الطلب وتأكيد الدفع
  packaging,        // 2: قيد التجهيز والتغليف بالمتجر
  onTheWay,         // 3: في الطريق مع مندوب التوصيل
  delivered,        // 4: تم تسليم الطلب بنجاح
}

class StoreOrder {
  final String id;
  final String orderNumber;
  final String date;
  final String vendorName;
  final String vendorPhone;
  final double totalAmount;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double heldAmount;
  final String paymentMethod;
  final OrderTrackingStep trackingStep;
  final String statusText;
  final String deliveryAddress;
  final String courierName;
  final String courierPhone;
  final List<OrderItemDetail> items;
  final int rating;
  final String? reviewNote;

  StoreOrder({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.vendorName,
    this.vendorPhone = '777605123',
    required this.totalAmount,
    required this.subtotal,
    this.discount = 0.0,
    this.shippingFee = 0.0,
    this.heldAmount = 1900.0,
    this.paymentMethod = 'wallet',
    this.trackingStep = OrderTrackingStep.paymentConfirmed,
    this.statusText = 'تم استلام الطلب وتأكيد الدفع',
    this.deliveryAddress = 'صنعاء - العنوان المسجل',
    this.courierName = 'مندوب التوصيل',
    this.courierPhone = '771234567',
    required this.items,
    this.rating = 5,
    this.reviewNote,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] is List ? json['items'] as List : [];
    final items = itemsRaw.map((it) {
      return OrderItemDetail(
        id: it['id'] is int ? it['id'] : 1,
        productName: it['product_name']?.toString() ?? 'بنطلون',
        productImage: it['product_image']?.toString(),
        quantity: it['quantity'] is int ? it['quantity'] : 1,
        unitPrice: double.tryParse(it['unit_price']?.toString() ?? '1900') ?? 1900.0,
      );
    }).toList();

    final status = json['status']?.toString() ?? 'pending';
    OrderTrackingStep step = OrderTrackingStep.paymentConfirmed;
    String statusTitle = 'تم استلام الطلب وتأكيد الدفع';

    if (status == 'delivered') {
      step = OrderTrackingStep.delivered;
      statusTitle = 'تم تسليم الطلب بنجاح';
    } else if (status == 'shipped') {
      step = OrderTrackingStep.onTheWay;
      statusTitle = 'في الطريق مع مندوب التوصيل';
    } else if (status == 'processing') {
      step = OrderTrackingStep.packaging;
      statusTitle = 'قيد التجهيز والتغليف بالمتجر';
    }

    final total = double.tryParse(json['total']?.toString() ?? '1900') ?? 1900.0;

    return StoreOrder(
      id: json['id']?.toString() ?? '1',
      orderNumber: json['order_number']?.toString() ?? 'ORD-20260907-7F230C',
      date: json['created_at'] != null ? json['created_at'].toString().split('T').first : '07-09-2026',
      vendorName: itemsRaw.isNotEmpty && itemsRaw.first['vendor_name'] != null
          ? itemsRaw.first['vendor_name'].toString()
          : 'زيزو',
      totalAmount: total,
      subtotal: total,
      items: items.isNotEmpty
          ? items
          : [
              OrderItemDetail(
                id: 1,
                productName: 'بنطلون',
                quantity: 1,
                unitPrice: 1900.0,
                sku: '1234',
              )
            ],
      trackingStep: step,
      statusText: statusTitle,
    );
  }
}

class StoreVendor {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String workingHours;
  final String deliveryEta;
  final double rating;
  final bool isVerified;
  final List<String> categories;
  final int productsCount;

  StoreVendor({
    required this.id,
    required this.name,
    this.phone = '777605123',
    this.address = 'صنعاء - شارع الزبيري',
    this.workingHours = 'دوام: 9:00 ص - 10:00 م',
    this.deliveryEta = 'التوصيل: 30 دقيقة',
    this.rating = 4.8,
    this.isVerified = true,
    this.categories = const ['الإلكترونيات', 'الملابس', 'هواتف', 'نساء'],
    this.productsCount = 4,
  });
}
