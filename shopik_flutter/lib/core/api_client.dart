import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;
  ApiException(this.statusCode, this.message, [this.data]);
  @override String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = (baseUrl ?? 'https://shopik.alattab.site/api').replaceAll(RegExp(r'/$'), '');
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();
  Future<String?> token() => _storage.read(key: 'shopik_access_token');
  Future<void> saveToken(String value) => _storage.write(key: 'shopik_access_token', value: value);
  Future<void> clearToken() => _storage.delete(key: 'shopik_access_token');
  Future<Map<String,String>> _headers({bool json=false}) async{final t=await token();return {'Accept':'application/json',if(json)'Content-Type':'application/json',if(t!=null&&t.isNotEmpty)'Authorization':'Token $t'};}
  Uri _uri(String path,[Map<String,dynamic>? query]){final clean=path.startsWith('/')?path:'/$path';return Uri.parse('$baseUrl$clean').replace(queryParameters:query?.map((k,v)=>MapEntry(k,v.toString())));}
  dynamic _decode(http.Response r){if(r.bodyBytes.isEmpty)return {};try{return jsonDecode(utf8.decode(r.bodyBytes));}catch(_){return {'raw':utf8.decode(r.bodyBytes)};}}
  void _check(http.Response r){if(r.statusCode<200||r.statusCode>=300){final d=_decode(r);final m=d is Map&&d['detail']!=null?d['detail'].toString():d is Map&&d['message']!=null?d['message'].toString():'فشل الطلب (${r.statusCode})';throw ApiException(r.statusCode,m,d);}}
  Future<dynamic> get(String path,{Map<String,dynamic>? query}) async{final r=await _client.get(_uri(path,query),headers:await _headers());_check(r);return _decode(r);}
  Future<dynamic> post(String path,dynamic body,{String? idempotencyKey}) async{final h=await _headers(json:true);if(idempotencyKey!=null&&idempotencyKey.isNotEmpty)h['Idempotency-Key']=idempotencyKey;final r=await _client.post(_uri(path),headers:h,body:jsonEncode(body));_check(r);return _decode(r);}
  Future<dynamic> patch(String path,dynamic body) async{final r=await _client.patch(_uri(path),headers:await _headers(json:true),body:jsonEncode(body));_check(r);return _decode(r);}
  Future<dynamic> delete(String path) async{final r=await _client.delete(_uri(path),headers:await _headers());_check(r);return _decode(r);}
  Future<Map<String,dynamic>> login(String identifier,String password) async{final data=await post('/auth/login/',{'identifier':identifier.trim(),'password':password});if(data is! Map||data['token']==null)throw ApiException(200,'الخادم لم يُرجع رمز دخول صحيحًا',data);await saveToken(data['token'].toString());return Map<String,dynamic>.from(data);}
  Future<void> logout()=>clearToken();
  Future<Map<String,dynamic>> me() async=>Map<String,dynamic>.from(await get('/auth/me/'));
  Future<List<Map<String,dynamic>>> wallets() async=>_results(await get('/wallets/'));
  Future<Map<String,dynamic>> serviceCatalog() async=>Map<String,dynamic>.from(await get('/v2/services/catalog/'));
  Future<Map<String,dynamic>> serviceDetail(int id) async=>Map<String,dynamic>.from(await get('/v2/services/services/$id/'));
  Future<Map<String,dynamic>> serviceRequest({required int serviceId,required Map<String,dynamic> payload,String? itemType,int? itemId}) async{final key='${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1<<30)}';return Map<String,dynamic>.from(await post('/v2/services/requests/',{'service_id':serviceId,'payload':payload,if(itemType!=null)'item_type':itemType,if(itemId!=null)'item_id':itemId},idempotencyKey:key));}
  Future<Map<String,dynamic>> serviceTransaction(String id) async=>Map<String,dynamic>.from(await get('/v2/services/requests/$id/'));
  Future<Map<String,dynamic>> serviceProviderCheck(String id) async=>Map<String,dynamic>.from(await get('/v2/services/requests/$id/provider-check/'));
  Future<List<Map<String,dynamic>>> serviceReports() async=>_results(await get('/v2/services/reports/'));
  Future<List<Map<String,dynamic>>> wifiNetworks() async{final d=await get('/v2/services/wifi/networks/');if(d is Map&&d['networks'] is List)return List<Map<String,dynamic>>.from((d['networks'] as List).map((e)=>Map<String,dynamic>.from(e)));return _results(d);}
  Future<Map<String,dynamic>> wifiPurchase({required int networkId,required int denominationId,required String phone,required double price}) async{final d=await post('/v2/services/wifi/purchase/',{'network_id':networkId,'denomination_id':denominationId,'phone':phone,'amount':price});return Map<String,dynamic>.from(d);}
  Future<List<Map<String,dynamic>>> wifiCards() async{final d=await get('/v2/services/wifi/my-cards/');if(d is Map&&d['cards'] is List)return List<Map<String,dynamic>>.from((d['cards'] as List).map((e)=>Map<String,dynamic>.from(e)));return _results(d);}
  Future<dynamic> home({int? cityId})=>get('/home/',query:cityId==null?null:{'city_id':cityId});
  Future<List<Map<String,dynamic>>> cities() async=>_results(await get('/cities/'));
  Future<List<Map<String,dynamic>>> categories() async=>_results(await get('/categories/'));
  Future<List<Map<String,dynamic>>> products({Map<String,dynamic>? query}) async=>_results(await get('/products/',query:query));
  Future<List<Map<String,dynamic>>> vendors({String? q}) async=>_results(await get('/vendors/',query:q==null?null:{'q':q}));
  Future<List<Map<String,dynamic>>> addresses() async=>_results(await get('/addresses/'));
  Future<Map<String,dynamic>> createAddress(Map<String,dynamic> body) async=>Map<String,dynamic>.from(await post('/addresses/',body));
  Future<Map<String,dynamic>> updateAddress(int id,Map<String,dynamic> body) async=>Map<String,dynamic>.from(await patch('/addresses/$id/',body));
  Future<void> deleteAddress(int id) async{await delete('/addresses/$id/');}
  Future<List<Map<String,dynamic>>> orders() async=>_results(await get('/orders/'));
  Future<Map<String,dynamic>> orderDetail(int id) async=>Map<String,dynamic>.from(await get('/orders/$id/order_view/'));
  Future<Map<String,dynamic>> createOrder({required List<Map<String,dynamic>> items,required Map<String,dynamic> shippingAddress,String currency='YER',String paymentMethod='wallet',String couponCode=''}) async{final key='${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1<<30)}';return Map<String,dynamic>.from(await post('/orders/',{'items':items,'shipping_address':shippingAddress,'currency':currency,'payment_method':paymentMethod,if(couponCode.isNotEmpty)'coupon_code':couponCode},idempotencyKey:key));}
  Future<Map<String,dynamic>> confirmReceived(int orderId) async=>Map<String,dynamic>.from(await post('/orders/$orderId/confirm_received/',{}));
  Future<List<Map<String,dynamic>>> notifications() async=>_results(await get('/notifications/'));
  Future<List<Map<String,dynamic>>> gifts() async=>_results(await get('/gifts/'));
  Future<Map<String,dynamic>> giftLookup(String phone) async=>Map<String,dynamic>.from(await post('/gifts/lookup/',{'receiver_phone':phone}));
  Future<Map<String,dynamic>> createGift({required String receiverPhone,required double amount,String message=''}) async=>Map<String,dynamic>.from(await post('/gifts/',{'receiver_phone':receiverPhone,'amount':amount,'message':message}));
  Future<Map<String,dynamic>> confirmGift(int id) async=>Map<String,dynamic>.from(await post('/gifts/$id/confirm/',{}));
  Future<Map<String,dynamic>> cancelGift(int id) async=>Map<String,dynamic>.from(await post('/gifts/$id/cancel/',{}));
  List<Map<String,dynamic>> _results(dynamic data){if(data is List)return List<Map<String,dynamic>>.from(data.map((e)=>Map<String,dynamic>.from(e)));if(data is Map&&data['results'] is List)return List<Map<String,dynamic>>.from((data['results'] as List).map((e)=>Map<String,dynamic>.from(e)));return [];}
}
