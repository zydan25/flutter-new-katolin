import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/app_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';
import 'widgets/common.dart';

void main(){WidgetsFlutterBinding.ensureInitialized();runApp(ChangeNotifierProvider(create:(_)=>AppController(ApiClient()),child:const ShopikApp()));}
class ShopikApp extends StatefulWidget{const ShopikApp({super.key});@override State<ShopikApp> createState()=>_ShopikAppState();}
class _ShopikAppState extends State<ShopikApp>{bool booting=true;@override void initState(){super.initState();_boot();}Future<void>_boot()async{await context.read<AppController>().restore();if(mounted)setState(()=>booting=false);}@override Widget build(BuildContext context){return MaterialApp(debugShowCheckedModeBanner:false,title:'شبيك | SHOPIK',locale:const Locale('ar'),theme:ThemeData(useMaterial3:true,fontFamily:'Cairo',colorScheme:ColorScheme.fromSeed(seedColor:AppColors.burgundy),scaffoldBackgroundColor:AppColors.page,appBarTheme:const AppBarTheme(centerTitle:true,backgroundColor:AppColors.burgundy,foregroundColor:Colors.white,elevation:0),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:Color(0xFFE2E8F0))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:Color(0xFFE2E8F0))),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:AppColors.burgundy,width:1.5)))),builder:(context,child)=>Directionality(textDirection:TextDirection.rtl,child:child!),home:booting?const _Splash():Consumer<AppController>(builder:(_,app,__)=>(app.isLoggedIn?const HomeShell():const LoginScreen())));}}
class _Splash extends StatelessWidget{const _Splash();@override Widget build(BuildContext context)=>const Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[CircularProgressIndicator(),SizedBox(height:18),Text('شبيك SHOPIK',style:TextStyle(fontWeight:FontWeight.w900,fontSize:18)),SizedBox(height:6),Text('جاري تهيئة التطبيق والاتصال بالخادم')])));}
