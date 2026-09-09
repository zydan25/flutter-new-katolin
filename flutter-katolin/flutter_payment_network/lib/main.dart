import 'package:flutter/material.dart';
import 'models/store_models.dart';
import 'screens/addresses_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/gift_transfer_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/orders_list_screen.dart';
import 'screens/payment_network_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/store_profile_screen.dart';
import 'services/method_channel_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Kotlin communication bridge
  MethodChannelBridge.initialize();

  // Fetch initial parameters passed from Kotlin
  final initialSession = await MethodChannelBridge.getInitialSession();
  final phone = initialSession['phone']?.toString() ?? '';
  final balance = double.tryParse(initialSession['wallet_balance']?.toString() ?? initialSession['balance']?.toString() ?? '99033.43') ?? 99033.43;
  final token = initialSession['token']?.toString() ?? '3241591d9733768e4b5d3226c96b200e04c7ca15';
  final baseUrl = initialSession['baseUrl']?.toString() ?? 'https://shopik.alattab.site';
  final initialRoute = initialSession['initialRoute']?.toString() ?? 'payment';

  runApp(ShopikFlutterApp(
    initialPhone: phone,
    walletBalance: balance,
    apiToken: token,
    baseUrl: baseUrl,
    initialRoute: initialRoute,
  ));
}

class ShopikFlutterApp extends StatefulWidget {
  final String initialPhone;
  final double walletBalance;
  final String apiToken;
  final String baseUrl;
  final String initialRoute;

  const ShopikFlutterApp({
    Key? key,
    required this.initialPhone,
    required this.walletBalance,
    required this.apiToken,
    required this.baseUrl,
    this.initialRoute = 'payment',
  }) : super(key: key);

  @override
  State<ShopikFlutterApp> createState() => _ShopikFlutterAppState();
}

class _ShopikFlutterAppState extends State<ShopikFlutterApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    MethodChannelBridge.onNavigateToScreen = (route, args) {
      if (_navigatorKey.currentState != null) {
        _navigateToRoute(route, args);
      }
    };
  }

  void _navigateToRoute(String route, Map<String, dynamic> args) {
    Widget target;
    switch (route) {
      case 'orders':
        target = const OrdersListScreen();
        break;
      case 'order_detail':
        target = OrderDetailScreen(
          order: StoreOrder(
            id: args['order_id']?.toString() ?? '1',
            orderNumber: args['order_number']?.toString() ?? 'ORD-20260907-7F230C',
            date: '07-09-2026',
            vendorName: 'زيزو',
            totalAmount: 1900.0,
            subtotal: 1900.0,
            items: [
              OrderItemDetail(
                id: 1,
                productName: 'بنطلون',
                quantity: 1,
                unitPrice: 1900.0,
                categoryName: 'عام',
              )
            ],
          ),
        );
        break;
      case 'category':
        target = CategoryProductsScreen(
          initialCategory: args['category_name']?.toString() ?? 'الإلكترونيات',
        );
        break;
      case 'store':
        target = StoreProfileScreen(
          store: StoreVendor(
            id: int.tryParse(args['store_id']?.toString() ?? '1') ?? 1,
            name: args['store_name']?.toString() ?? 'زيزو',
          ),
        );
        break;
      case 'product':
        target = ProductDetailScreen(
          product: StoreProduct(
            id: int.tryParse(args['product_id']?.toString() ?? '1') ?? 1,
            name: args['product_name']?.toString() ?? 'بنطلون',
            price: 1900.0,
            categoryName: 'الملابس',
            storeName: 'زيزو',
          ),
        );
        break;
      case 'cart':
        target = const CartScreen();
        break;
      case 'gift_transfer':
        target = const GiftTransferScreen();
        break;
      case 'addresses':
        target = const AddressesScreen();
        break;
      default:
        target = PaymentNetworkScreen(
          initialPhone: widget.initialPhone,
          walletBalance: widget.walletBalance,
          apiToken: widget.apiToken,
          baseUrl: widget.baseUrl,
        );
        break;
    }

    _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;
    switch (widget.initialRoute) {
      case 'orders':
        homeScreen = const OrdersListScreen();
        break;
      case 'category':
        homeScreen = const CategoryProductsScreen();
        break;
      case 'cart':
        homeScreen = const CartScreen();
        break;
      case 'gift_transfer':
        homeScreen = const GiftTransferScreen();
        break;
      case 'addresses':
        homeScreen = const AddressesScreen();
        break;
      default:
        homeScreen = PaymentNetworkScreen(
          initialPhone: widget.initialPhone,
          walletBalance: widget.walletBalance,
          apiToken: widget.apiToken,
          baseUrl: widget.baseUrl,
        );
        break;
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'شبيك للخدمات والمتجر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
      ),
      home: homeScreen,
    );
  }
}
