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
  List<Map<String, dynamic>> serviceRows = [];
  List<Map<String, dynamic>> operations = [];
  List<Map<String, dynamic>> notifications = [];
  List<Product> products = [];
  List<Map<String, dynamic>> vendors = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> addresses = [];
  List<OrderSummary> orders = [];
  List<Map<String, dynamic>> wifi = [];
  List<Map<String, dynamic>> wifiCards = [];
  Timer? _poller;
  bool get isLoggedIn => user != null;

  Future<void> restore() async { final prefs=await SharedPreferences.getInstance(); if(prefs.getBool('logged_in')!=true)return; try{await refreshAll();}catch(_){await logout(localOnly:true);} }
  Future<bool> login(String identifier,String password) async {loading=true;error=null;notifyListeners();try{final data=await api.login(identifier,password);user=UserProfile.fromJson(Map<String,dynamic>.from(data['user']??{}));final prefs=await SharedPreferences.getInstance();await prefs.setBool('logged_in',true);await refreshAll();_startPolling();return true;}catch(e){error=e.toString();return false;}finally{loading=false;notifyListeners();}}
  Future<void> logout({bool localOnly=false}) async{_poller?.cancel();if(!localOnly)await api.logout();user=null;walletBalance=0;operations=[];orders=[];notifications=[];final prefs=await SharedPreferences.getInstance();await prefs.setBool('logged_in',false);notifyListeners();}
  void _startPolling(){_poller?.cancel();_poller=Timer.periodic(const Duration(seconds:15),(_)async{try{await refreshWalletAndReports();}catch(_){}});}
  Future<void> refreshWalletAndReports() async{final rows=await api.wallets();if(rows.isNotEmpty)walletBalance=num.tryParse('${rows.first['balance']??0}')??0;try{operations=await api.serviceReports();}catch(_){ }notifyListeners();}
  Future<void> refreshAll() async{
    loading=true;error=null;notifyListeners();
    try{
      final results=await Future.wait<dynamic>([api.me(),api.wallets(),api.serviceCatalog(),api.serviceReports(),api.notifications(),api.products(),api.vendors(),api.categories(),api.addresses(),api.orders(),api.wifiNetworks(),api.wifiCards()]);
      user=UserProfile.fromJson(Map<String,dynamic>.from(results[0]));
      final wallets=List<Map<String,dynamic>>.from(results[1]); if(wallets.isNotEmpty)walletBalance=num.tryParse('${wallets.first['balance']??0}')??0;
      operations=List<Map<String,dynamic>>.from(results[3]); notifications=List<Map<String,dynamic>>.from(results[4]);
      products=(results[5] as List).map((e)=>Product.fromJson(Map<String,dynamic>.from(e))).toList();
      vendors=List<Map<String,dynamic>>.from(results[6]); categories=List<Map<String,dynamic>>.from(results[7]); addresses=List<Map<String,dynamic>>.from(results[8]);
      orders=(results[9] as List).map((e)=>OrderSummary.fromJson(Map<String,dynamic>.from(e))).toList();
      wifi=List<Map<String,dynamic>>.from(results[10]); wifiCards=List<Map<String,dynamic>>.from(results[11]);
      _startPolling();
    }catch(e){error=e.toString();rethrow;}finally{loading=false;notifyListeners();}
  }
  Future<Map<String,dynamic>> requestService({required int serviceId,required Map<String,dynamic> payload,String? itemType,int? itemId}) async{final tx=await api.serviceRequest(serviceId:serviceId,payload:payload,itemType:itemType,itemId:itemId);final id=tx['id']?.toString();if(id!=null&&(tx['status']=='pending'||tx['status']=='processing')){for(var i=0;i<15;i++){await Future.delayed(const Duration(milliseconds:1200));final latest=await api.serviceTransaction(id);if(latest['status']=='success'||latest['status']=='failed'||(latest['result'] is Map&&(latest['result'] as Map).isNotEmpty))return latest;}}return tx;}
  Future<Map<String,dynamic>> recipientLookup(String phone)=>api.post('/gifts/lookup/',{'receiver_phone':phone});
  @override void dispose(){_poller?.cancel();super.dispose();}
}
