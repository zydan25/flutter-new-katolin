import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_client.dart';

class AppController extends ChangeNotifier {
  AppController(this.api);

  final ApiClient api;
  UserProfile? user;
  num walletBalance = 0;
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> operations = [];
  List<Map<String, dynamic>> notifications = [];
  List<Product> products = [];
  List<Map<String, dynamic>> vendors = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> addresses = [];
  List<OrderSummary> orders = [];
  List<Map<String, dynamic>> wifi = [];
  List<Map<String, dynamic>> wifiCards = [];
  List<Map<String, dynamic>> serviceCatalogRoots = [];
  Timer? _poller;

  bool get isLoggedIn => user != null;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('logged_in') != true) return;
    try {
      final profile = await api.me();
      user = UserProfile.fromJson(profile['user'] is Map ? Map<String, dynamic>.from(profile['user']) : profile);
      await refreshAll(quiet: true);
      _startPolling();
      notifyListeners();
    } catch (_) {
      await logout(localOnly: true);
    }
  }

  Future<bool> login(String identifier, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.login(identifier, password);
      final rawUser = data['user'];
      user = UserProfile.fromJson(rawUser is Map ? Map<String, dynamic>.from(rawUser) : <String, dynamic>{});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await refreshAll(quiet: true);
      _startPolling();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout({bool localOnly = false}) async {
    _poller?.cancel();
    if (!localOnly) {
      try {
        await api.logout();
      } catch (_) {}
    }
    user = null;
    walletBalance = 0;
    operations = [];
    notifications = [];
    products = [];
    vendors = [];
    categories = [];
    addresses = [];
    orders = [];
    wifi = [];
    wifiCards = [];
    serviceCatalogRoots = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    notifyListeners();
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        await refreshWalletAndReports();
      } catch (_) {}
    });
  }

  Future<void> refreshWalletAndReports() async {
    final rows = await api.wallets();
    if (rows.isNotEmpty) {
      walletBalance = num.tryParse('${rows.first['balance'] ?? 0}') ?? 0;
    }
    try {
      operations = await api.serviceReports();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    final data = await api.serviceCatalog();
    final raw = data['categories'];
    serviceCatalogRoots = raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : [];
    notifyListeners();
  }

  Future<void> refreshOptional() async {
    Future<void> safe(Future<void> Function() action) async {
      try {
        await action();
      } catch (_) {}
    }

    await Future.wait([
      safe(() async => notifications = await api.notifications()),
      safe(() async => products = (await api.products()).map(Product.fromJson).toList()),
      safe(() async => vendors = await api.vendors()),
      safe(() async => categories = await api.categories()),
      safe(() async => addresses = await api.addresses()),
      safe(() async => orders = (await api.orders()).map(OrderSummary.fromJson).toList()),
      safe(() async => wifi = await api.wifiNetworks()),
      safe(() async => wifiCards = await api.wifiCards()),
      safe(refreshCatalog),
    ]);
    notifyListeners();
  }

  Future<void> refreshAll({bool quiet = false}) async {
    if (!quiet) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      await refreshWalletAndReports();
      await refreshOptional();
    } catch (e) {
      error = e.toString();
    } finally {
      if (!quiet) {
        loading = false;
        notifyListeners();
      }
    }
  }

  List<Map<String, dynamic>> get catalogServices {
    final out = <Map<String, dynamic>>[];
    void walk(dynamic node) {
      if (node is! Map) return;
      final services = node['services'];
      if (services is List) {
        for (final entry in services) {
          if (entry is Map) out.add(Map<String, dynamic>.from(entry));
        }
      }
      final children = node['children'];
      if (children is List) {
        for (final entry in children) walk(entry);
      }
      final categories = node['categories'];
      if (categories is List) {
        for (final entry in categories) walk(entry);
      }
    }
    for (final root in serviceCatalogRoots) walk(root);
    return out;
  }

  List<Map<String, dynamic>> servicesFor(String operatorKey) {
    final keys = <String, List<String>>{
      'yemen_mobile': ['yemen_mobile', 'يمن موبايل'],
      'you': ['you', 'يو'],
      'sabafon': ['sabafon', 'سبأفون'],
      'yemen': [' y ', 'y_', 'واي', 'واي موبايل'],
      'yemen4g': ['4g', 'فورجي', 'يمن 4g'],
      'yemen_net': ['yemen_net', 'يمن نت', 'adsl'],
      'aden_net': ['aden_net', 'عدن نت'],
    };
    final needles = keys[operatorKey] ?? [];
    return catalogServices.where((s) {
      final haystack = '${s['code'] ?? ''} ${s['name'] ?? ''} ${s['description'] ?? ''}'.toLowerCase();
      return needles.any((k) => haystack.contains(k.toLowerCase()));
    }).toList();
  }

  Future<Map<String, dynamic>> requestService({
    required int serviceId,
    required Map<String, dynamic> payload,
    String? itemType,
    int? itemId,
  }) async {
    final tx = await api.serviceRequest(serviceId: serviceId, payload: payload, itemType: itemType, itemId: itemId);
    var latest = tx;
    final id = tx['id']?.toString();
    if (id != null && ['accepted', 'queued', 'pending', 'processing'].contains('${tx['status']}')) {
      for (var i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 1200));
        latest = await api.serviceTransaction(id);
        if (['success', 'failed', 'completed', 'rejected'].contains('${latest['status']}')) break;
      }
    }
    return latest;
  }

  Future<Map<String, dynamic>> recipientLookup(String phone) => api.giftLookup(phone);

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }
}
