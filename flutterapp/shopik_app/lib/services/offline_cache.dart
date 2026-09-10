import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/telecom_service.dart';

/// Offline-First Cache and Duplicate Payment Manager
class OfflineCacheService {
  static const String _catalogKey = 'cached_telecom_catalog_v2';
  static const String _servicePrefix = 'cached_service_details_';
  static const String _paymentsKey = 'recharge_transactions_history';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save catalog data locally
  static Future<void> saveCatalog(Map<String, dynamic> catalogData) async {
    final prefs = await _getPrefs();
    await prefs.setString(_catalogKey, jsonEncode(catalogData));
  }

  /// Load catalog data from local cache
  static Future<Map<String, dynamic>?> loadCatalog() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_catalogKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Save specific service items and plan types (e.g. Svc 4 Yemen Mobile)
  static Future<void> saveServiceDetails(int serviceId, Map<String, dynamic> serviceData) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_servicePrefix$serviceId', jsonEncode(serviceData));
  }

  /// Load service details from local cache
  static Future<Map<String, dynamic>?> loadServiceDetails(int serviceId) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_servicePrefix$serviceId');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if a phone number was already recharged today
  /// Returns a map with { 'paid': bool, 'amount': double, 'time': String }
  static Future<Map<String, dynamic>> checkRechargeToday(String phone) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_paymentsKey);
    if (raw == null) return {'paid': false};

    try {
      final List<dynamic> list = jsonDecode(raw);
      final todayStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final itemPhone = item['phone']?.toString().replaceAll(RegExp(r'[^0-9]'), '');
          final itemDate = item['date']?.toString().substring(0, 10);
          if (itemPhone == cleanPhone && itemDate == todayStr) {
            return {
              'paid': true,
              'amount': item['amount'],
              'time': item['time'] ?? 'اليوم',
              'package': item['packageName'] ?? 'رصيد/باقة',
            };
          }
        }
      }
    } catch (_) {}

    return {'paid': false};
  }

  /// Record a new recharge transaction locally
  static Future<void> recordRecharge({
    required String phone,
    required double amount,
    required String packageName,
    required String operatorName,
  }) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_paymentsKey);
    List<dynamic> list = [];
    if (raw != null) {
      try {
        list = jsonDecode(raw) as List<dynamic>;
      } catch (_) {}
    }

    final now = DateTime.now();
    list.insert(0, {
      'phone': phone,
      'amount': amount,
      'packageName': packageName,
      'operatorName': operatorName,
      'date': now.toIso8601String(),
      'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    });

    // Keep up to 100 recent transactions
    if (list.length > 100) {
      list = list.sublist(0, 100);
    }

    await prefs.setString(_paymentsKey, jsonEncode(list));
  }

  /// Get verified real last transaction for a specific phone number
  static Future<Map<String, dynamic>?> getLastTransactionForPhone(String phone) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_paymentsKey);
    if (raw == null) return null;

    try {
      final List<dynamic> list = jsonDecode(raw);
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final itemPhone = item['phone']?.toString().replaceAll(RegExp(r'[^0-9]'), '');
          if (itemPhone == cleanPhone) {
            final dateStr = item['date']?.toString();
            String formattedTime = item['time'] ?? '';
            if (dateStr != null && dateStr.length >= 10) {
              formattedTime = '${dateStr.substring(0, 10)} (${item['time'] ?? ''})';
            }
            return {
              'hasRealTx': true,
              'time': formattedTime,
              'packageName': item['packageName'] ?? 'تسديد رصيد',
              'amount': '${item['amount']} ر.ي',
              'status': 'جاهز / ناجحة',
              'isReal': true,
            };
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Clear all cache if needed
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_catalogKey);
  }
}
