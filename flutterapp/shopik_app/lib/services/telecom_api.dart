import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/telecom_service.dart';
import 'offline_cache.dart';

/// Django API Client for Telecom Catalog, Inquiries & Recharges
class TelecomApiService {
  final String baseUrl;
  final String token;

  TelecomApiService({
    this.baseUrl = 'https://shopik.alattab.site',
    required this.token,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch Full Catalog (Offline-first: returns local cache if available and not forced)
  Future<Map<String, dynamic>> getCatalog({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await OfflineCacheService.loadCatalog();
      if (cached != null) {
        return cached;
      }
    }

    final url = Uri.parse('$baseUrl/api/v2/services/catalog/');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      await OfflineCacheService.saveCatalog(data);
      return data;
    } else {
      throw Exception('فشل جلب كتالوج الخدمات (كود: ${response.statusCode})');
    }
  }

  /// Fetch specific service details with items & plan_types (e.g. Svc 4 Yemen Mobile)
  Future<Map<String, dynamic>> getServiceDetails(int serviceId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await OfflineCacheService.loadServiceDetails(serviceId);
      if (cached != null) {
        return cached;
      }
    }

    final url = Uri.parse('$baseUrl/api/v2/services/services/$serviceId/');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      await OfflineCacheService.saveServiceDetails(serviceId, data);
      return data;
    } else {
      throw Exception('فشل جلب تفاصيل الخدمة $serviceId (كود: ${response.statusCode})');
    }
  }

  /// Submit an inquiry or recharge and poll until finished
  Future<Map<String, dynamic>> submitAndPoll({
    required int serviceId,
    required Map<String, dynamic> payload,
    String? itemType,
    int? itemId,
    int maxPolls = 10,
    Duration pollInterval = const Duration(milliseconds: 1400),
  }) async {
    final url = Uri.parse('$baseUrl/api/v2/services/requests/');
    final body = jsonEncode({
      'service_id': serviceId,
      'payload': payload,
      if (itemType != null) 'item_type': itemType,
      if (itemId != null) 'item_id': itemId,
    });

    final postResponse = await http.post(url, headers: _headers, body: body);
    if (postResponse.statusCode != 200 && postResponse.statusCode != 201) {
      final errBody = jsonDecode(utf8.decode(postResponse.bodyBytes));
      final msg = errBody['detail'] ?? errBody['message'] ?? 'فشل إرسال الطلب (كود: ${postResponse.statusCode})';
      throw Exception(msg);
    }

    final initialTx = jsonDecode(utf8.decode(postResponse.bodyBytes)) as Map<String, dynamic>;
    final txId = initialTx['id']?.toString();
    if (txId == null) return initialTx;

    // Polling loop
    Map<String, dynamic> latest = initialTx;
    for (int i = 0; i < maxPolls; i++) {
      if (latest['status'] == 'success' ||
          latest['status'] == 'failed' ||
          (latest['result'] is Map && (latest['result'] as Map).isNotEmpty)) {
        return latest;
      }
      await Future.delayed(pollInterval);
      final pollUrl = Uri.parse('$baseUrl/api/v2/services/requests/$txId/');
      final pollResp = await http.get(pollUrl, headers: _headers);
      if (pollResp.statusCode == 200) {
        latest = jsonDecode(utf8.decode(pollResp.bodyBytes)) as Map<String, dynamic>;
      }
    }
    return latest;
  }

  /// Specialized Inquiries:
  /// 1. Yemen Mobile Balance Inquiry (Svc 6)
  Future<InquiryResultData> queryYemenMobileBalance(String phone) async {
    final tx = await submitAndPoll(
      serviceId: 6,
      payload: {'mobile': phone},
    );
    return InquiryResultData.fromTransaction('balance', tx);
  }

  /// 2. Yemen Mobile Offers/Packages Inquiry (Svc 7)
  Future<InquiryResultData> queryYemenMobileOffers(String phone) async {
    final tx = await submitAndPoll(
      serviceId: 7,
      payload: {'mobile': phone},
    );
    return InquiryResultData.fromTransaction('offers', tx);
  }

  /// 3. Yemen 4G Inquiry (Svc 22)
  Future<InquiryResultData> queryYemen4G(String phone) async {
    final tx = await submitAndPoll(
      serviceId: 22,
      payload: {'mobile': phone},
    );
    return InquiryResultData.fromTransaction('4g', tx);
  }

  /// 4. Yemen Net ADSL Inquiry (Svc 25)
  Future<InquiryResultData> queryYemenNet(String phone, {String type = 'adsl'}) async {
    final tx = await submitAndPoll(
      serviceId: 25,
      payload: {'mobile': phone, 'type': type},
    );
    return InquiryResultData.fromTransaction('net', tx);
  }

  /// 5. Submit Recharge (Balance or Package)
  Future<Map<String, dynamic>> executeRecharge({
    required int serviceId,
    required String phone,
    required double amount,
    String? itemType,
    int? itemId,
  }) async {
    return await submitAndPoll(
      serviceId: serviceId,
      payload: {
        'mobile': phone,
        'amount': amount.toStringAsFixed(2),
      },
      itemType: itemType,
      itemId: itemId,
      maxPolls: 15,
    );
  }

  /// 6. Wallet Self-Feed (matches web submitLiveFeedAccount, service_id=1)
  Future<Map<String, dynamic>> feedAccount({
    required String phone,
    required double amount,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/api/v2/services/requests/');
    final body = jsonEncode({
      'service_id': 1,
      'payload': {
        'mobile': phone,
        'amount': amount,
        'code': code,
        'type': 'self_feed',
      },
    });

    final response = await http.post(url, headers: _headers, body: body);
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    final msg = data['detail'] ?? data['message'] ?? 'فشل تغذية الحساب (كود: ${response.statusCode})';
    throw Exception(msg);
  }
}
