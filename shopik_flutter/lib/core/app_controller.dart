import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_client.dart';

class AppController extends ChangeNotifier {
  AppController(this.api);
  final ApiClient api;
  UserProfile? user; num walletBalance=0; bool loading=false; String? error;
  List<Map<String,dynamic>> operations=[]; List<Map<String,dynamic>> notifications=[]; List<Product> products=[]; List<Map<String,dynamic>> vendors=[]; List<Map<String,dynamic>> categories=[]; List<Map<String,dynamic>> addresses=[]; List<OrderSummary> orders=[]; List<Map<String,dynamic>> wifi=[]; List<Map<String,dynamic>> wifiCards=[];
  Timer? _poller;
  bool get isLoggedIn=>user!=null;

  Future<void> restore() async {final prefs=await SharedPreferences.getInstance();if(prefs.getBool('logged_in')!=true)return;try{await refreshAll();}catch(_){await logout(localOnly:true);}}
  Future<bool> login(String identifier,String password) async{loading=true;error=null;notifyListeners();try{final data=await api.login(identifier,password);user=UserProfile.fromJson(Map<String,dynamic>.from(data['user']??{}));final prefs=await SharedPreferences.getInstance();await prefs.setBool('logged_in',true);await refreshWalletAndReports();await refreshOptional();_startPolling();return true;}catch(e){error=e.toString();return false;}finally{loading=false;notifyListeners();}}
  Future<void> logout({bool localOnly=false}) async{_poller?.cancel();if(!localOnly)await api.logout();user=null;walletBalance=0;operations=[];orders=[];notifications=[];final prefs=await SharedPreferences.getInstance();await prefs.setBool('logged_in',false);notifyListeners();}
  void _startPolling(){_poller?.cancel();_poller=Timer.periodic(const Duration(seconds:15),(_)async{try{await refreshWalletAndReports();}catch(_){}});}
  Future<void> refreshWalletAndReports() async{final rows=await api.wallets();if(rows.isNotEmpty)walletBalance=num.tryParse('${rows.first['balance']??0}')??0;try{operations=await api.serviceReports();}catch(_){ }notifyListeners();}
  Future<void> refreshOptional() async{
    Future<void> safe(Future<void> Function() fn)async{try{await fn();}catch(_){}}
    await safe(()async{notifications=await api.notifications();});
    await safe(()async{products=(await api.products()).map((e)=>Product.fromJson(e)).toList();});
    await safe(()async{vendors=await api.vendors();});
    await safe(()async{categories=await api.categories();});
    await safe(()async{addresses=await api.addresses();});
    await safe(()async{orders=(await api.orders()).map((e)=>OrderSummary.fromJson(e)).toList();});
    await safe(()async{wifi=await api.wifiNetworks();});
    await safe(()async{wifiCards=await api.wifiCards();});
    notifyListeners();
  }
  Future<void> refreshAll() async{loading=true;error=null;notifyListeners();try{await refreshWalletAndReports();await refreshOptional();}catch(e){error=e.toString();rethrow;}finally{loading=false;notifyListeners();}}
  Future<Map<String,dynamic>> requestService({required int serviceId,required Map<String,dynamic> payload,String? itemType,int? itemId})async{final tx=await api.serviceRequest(serviceId:serviceId,payload:payload,itemType:itemType,itemId:itemId);final id=tx['id']?.toString();if(id!=null&&(tx['status']=='pending'||tx['status']=='processing')){for(var i=0;i<15;i++){await Future.delayed(const Duration(milliseconds:1200));final latest=await api.serviceTransaction(id);if(latest['status']=='success'||latest['status']=='failed'||(latest['result'] is Map&&(latest['result'] as Map).isNotEmpty))return latest;}}return tx;}
  Future<Map<String,dynamic>> recipientLookup(String phone)=>api.giftLookup(phone);
  @override void dispose(){_poller?.cancel();super.dispose();}
}
