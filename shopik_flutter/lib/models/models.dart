class UserProfile {
  UserProfile({required this.id, required this.phone, required this.name, this.governorate = '', this.role = 'customer', this.points = 0});
  final int id;
  final String phone;
  final String name;
  final String governorate;
  final String role;
  final num points;
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: int.tryParse('${j['id'] ?? 0}') ?? 0,
    phone: '${j['phone'] ?? ''}',
    name: ([j['first_name'], j['middle_name'], j['third_name'], j['last_name']].where((e) => '${e ?? ''}'.trim().isNotEmpty).join(' ')).trim().isNotEmpty
        ? [j['first_name'], j['middle_name'], j['third_name'], j['last_name']].where((e) => '${e ?? ''}'.trim().isNotEmpty).join(' ')
        : '${j['name'] ?? j['username'] ?? j['phone'] ?? ''}',
    governorate: '${j['governorate'] ?? ''}', role: '${j['role'] ?? 'customer'}', points: j['points_balance'] ?? 0,
  );
}

class ServiceItem {
  ServiceItem({required this.id, required this.name, this.kind = '', this.type = '', this.price, this.metadata = const {}});
  final int id; final String name; final String kind; final String type; final num? price; final Map<String, dynamic> metadata;
}

class Product {
  Product({required this.id, required this.name, this.slug = '', this.price = 0, this.salePrice, this.currency = 'YER', this.stock = 0, this.image, this.vendorName = ''});
  final int id; final String name; final String slug; final num price; final num? salePrice; final String currency; final num stock; final String? image; final String vendorName;
  factory Product.fromJson(Map<String, dynamic> j) => Product(id: int.tryParse('${j['id'] ?? 0}') ?? 0, name: '${j['name'] ?? ''}', slug: '${j['slug'] ?? ''}', price: num.tryParse('${j['price'] ?? 0}') ?? 0, salePrice: j['sale_price'] == null ? null : num.tryParse('${j['sale_price']}'), currency: '${j['currency'] ?? 'YER'}', stock: num.tryParse('${j['stock'] ?? 0}') ?? 0, image: j['main_image'] ?? j['image'], vendorName: '${j['vendor_name'] ?? ''}');
}

class OrderSummary {
  OrderSummary({required this.id, required this.number, required this.status, required this.total, this.currency = 'YER', this.createdAt});
  final int id; final String number; final String status; final num total; final String currency; final String? createdAt;
  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(id: int.tryParse('${j['id'] ?? 0}') ?? 0, number: '${j['order_number'] ?? j['number'] ?? j['id']}', status: '${j['status'] ?? ''}', total: num.tryParse('${j['total'] ?? 0}') ?? 0, currency: '${j['currency'] ?? 'YER'}', createdAt: '${j['created_at'] ?? ''}'.isEmpty ? null : '${j['created_at']}');
}
