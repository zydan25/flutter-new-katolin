import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../widgets/common.dart';
import 'screen_common.dart';
import 'reference_store.dart';
import 'reference_account.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}
class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final pages = const [MainHomeScreen(), PaymentScreen(), StoreView(), OperationsView(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'حسابي'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card_rounded), label: 'السداد'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag_rounded), label: 'المتجر'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'العمليات'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override State<MainHomeScreen> createState() => _MainHomeScreenState();
}
class _MainHomeScreenState extends State<MainHomeScreen> {
  bool hidden = false;
  bool refreshing = false;
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final user = app.user;
    final shortcuts = <_HomeShortcut>[
      const _HomeShortcut('شبكة السداد', 'كل خدمات الاتصالات والباقات', Icons.credit_card_rounded, AppColors.burgundy, 1),
      const _HomeShortcut('متجر شبيك', 'المنتجات والمتاجر والطلبات', Icons.storefront_rounded, AppColors.emerald, 2),
      const _HomeShortcut('سجل العمليات', 'العمليات الحقيقية من الخادم', Icons.receipt_long_rounded, AppColors.blue, 3),
      const _HomeShortcut('كشف الحساب', 'الرصيد والقيود المحاسبية', Icons.account_balance_wallet_rounded, AppColors.teal, 4),
      const _HomeShortcut('التقارير والإحصائيات', 'مبيعات الخدمات والأداء', Icons.bar_chart_rounded, AppColors.indigo, 5),
      const _HomeShortcut('تحويل لمشترك', 'إرسال رصيد لمشترك آخر', Icons.send_rounded, AppColors.amber, 6),
      const _HomeShortcut('كروت الوايفاي', 'الشبكات والكروت', Icons.wifi_rounded, AppColors.teal, 7),
      const _HomeShortcut('الألعاب والبرامج', 'الشحن والخدمات الرقمية', Icons.sports_esports_rounded, AppColors.purple, 8),
      const _HomeShortcut('الإعدادات والبصمة', 'الحساب وأمان الجهاز', Icons.settings_rounded, Color(0xFF475569), 9),
      const _HomeShortcut('عناوين التوصيل', 'إدارة عناوين الشحن', Icons.location_on_rounded, AppColors.blue, 10),
    ];
    final initial = user?.name.trim().isNotEmpty == true ? user!.name.trim().substring(0, 1) : 'ش';
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.burgundy,
        onRefresh: app.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 28),
          children: [
            Row(children: [
              CircleAvatar(radius: 21, backgroundColor: AppColors.burgundy, child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
              const SizedBox(width: 9),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('تطبيق شبيك وسوق بلس', style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
                Row(children: [Flexible(child: Text(user?.name.isNotEmpty == true ? user!.name : 'حسابي الرقمي', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))), const SizedBox(width: 5), const StatusBadge(text: 'موثق ✓')]),
              ])),
              IconButton(onPressed: refreshing ? null : () async { setState(() => refreshing = true); await app.refreshAll(); if (mounted) setState(() => refreshing = false); }, icon: const Icon(Icons.refresh_rounded)),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), border: Border.all(color: const Color(0xFFA7F3D0)), borderRadius: BorderRadius.circular(17)),
              child: Row(children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20)),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.name.isNotEmpty == true ? user!.name : 'العميل المعتمد', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), Text('الهاتف: ${user?.phone ?? ''}  •  المحافظة: ${user?.governorate ?? ''}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF047857), fontWeight: FontWeight.w700))])),
                const StatusBadge(text: 'عميل معتمد', color: AppColors.emerald),
              ]),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.burgundyLight, AppColors.burgundy, AppColors.burgundyDark]), borderRadius: BorderRadius.circular(21), boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 5))]),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.credit_card_rounded, color: Color(0xFFFDE68A), size: 19), const SizedBox(width: 7),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('بطاقة الرصيد الرقمية', style: TextStyle(fontSize: 10, color: Color(0xFFFDE68A), fontWeight: FontWeight.w900)), Text('الرصيد من نظام المحاسبة في الخادم', style: TextStyle(fontSize: 8.5, color: Colors.white70, fontWeight: FontWeight.w700))])),
                  IconButton(onPressed: app.refreshWalletAndReports, icon: const Icon(Icons.sync_rounded, color: Color(0xFFFDE68A))),
                  IconButton(onPressed: () => setState(() => hidden = !hidden), icon: Icon(hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white, size: 18)),
                ]),
                const Divider(color: Colors.white24, height: 17),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('الرصيد المتاح للعمليات', style: TextStyle(fontSize: 9, color: Color(0xFFFDE68A), fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(hidden ? '••••••••' : money(app.walletBalance), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))]),
                  const StatusBadge(text: 'مزامنة نشطة', color: AppColors.emerald),
                ]),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: _WalletMini(title: 'الرصيد الفعلي', value: hidden ? '••••••' : money(app.walletBalance), icon: Icons.account_balance_wallet_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _WalletMini(title: 'نقاط الولاء', value: '${user?.points.toStringAsFixed(0) ?? 0}', icon: Icons.stars_rounded)),
                ]),
              ]),
            ),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(child: _QuickAction(title: 'تغذية الحساب', subtitle: 'إيداع فوري', icon: Icons.add_circle_outline_rounded, color: AppColors.emerald, onTap: () => _showFeed(context))),
              const SizedBox(width: 7),
              Expanded(child: _QuickAction(title: 'تحويل مالي', subtitle: 'بين المشتركين', icon: Icons.send_rounded, color: AppColors.amber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriberTransferScreen())))),
              const SizedBox(width: 7),
              Expanded(child: _QuickAction(title: 'شبكة السداد', subtitle: 'خدمات رقمية', icon: Icons.credit_card_rounded, color: AppColors.burgundy, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())), dark: true)),
            ]),
            const SizedBox(height: 13),
            RefSection(title: 'حسابي في تطبيق شبيك', icon: Icons.apps_rounded),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shortcuts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.36),
              itemBuilder: (_, i) {
                final shortcut = shortcuts[i];
                return InkWell(onTap: () => _open(context, shortcut.screen), borderRadius: BorderRadius.circular(17), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x0C0F172A), blurRadius: 8, offset: Offset(0, 3))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: shortcut.color, borderRadius: BorderRadius.circular(11)), child: Icon(shortcut.icon, color: Colors.white, size: 20)), const Spacer(), Text(shortcut.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(shortcut.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: AppColors.muted, fontWeight: FontWeight.w600))])));
              },
            ),
            const SizedBox(height: 12),
            RefSection(title: 'أحدث العمليات', icon: Icons.history_rounded, action: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OperationsView())), child: const Text('السجل الكامل', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)))),
            const SizedBox(height: 7),
            if (app.operations.isEmpty) const EmptyState(text: 'لا توجد عمليات مسترجعة من الخادم حالياً.', icon: Icons.receipt_long_outlined),
            for (final operation in app.operations.take(5)) RefOperationTile(operation: operation),
            const SizedBox(height: 13),
            const Center(child: Text('برمجة وتطوير: يمن كود للتقنيات الذكية', style: TextStyle(fontSize: 9.5, color: AppColors.muted, fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, int screen) {
    final pages = <int, Widget>{
      1: const PaymentScreen(), 2: const StoreView(), 3: const OperationsView(), 4: const AccountStatementScreen(), 5: const ReportsScreen(),
      6: const SubscriberTransferScreen(), 7: const WifiNetworksScreen(), 8: const GamesServicesScreen(), 9: const FingerprintSettingsScreen(), 10: const AddressesScreen(),
    };
    final page = pages[screen];
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _showFeed(BuildContext context) async {
    await showDialog<void>(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text('تغذية الحساب', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)), content: const Text('هذه الواجهة مطابقة للتصميم المرجعي، لكن لا يوجد عقد إيداع مستقل منشور في خادم Django الحالي، لذلك لا يتم تسجيل حركة وهمية.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, height: 1.5)), actions: [FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: AppColors.emerald), child: const Text('حسناً'))]));
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<PaymentScreen> {
  final phone = TextEditingController();
  String operator = 'yemen_mobile';
  @override void initState() { super.initState(); final app = context.read<AppController>(); phone.text = app.user?.phone ?? ''; if (app.catalogServices.isEmpty) app.refreshCatalog(); }
  @override void dispose() { phone.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final labels = const {'yemen_mobile': 'يمن موبايل', 'you': 'YOU', 'sabafon': 'سبأفون', 'y': 'واي', 'yemen4g': 'يمن 4G', 'yemen_net': 'يمن نت', 'aden_net': 'عدن نت'};
    final keys = labels.keys.toList();
    final services = app.servicesFor(operator);
    final color = serviceColor(operator);
    return ScreenFrame(title: 'شبكة السداد', color: color, actions: [IconButton(onPressed: app.refreshCatalog, icon: const Icon(Icons.sync_rounded))], child: RefreshIndicator(color: color, onRefresh: app.refreshCatalog, child: ListView(padding: const EdgeInsets.all(12), children: [
      SizedBox(height: 46, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: keys.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) { final key = keys[i]; final active = key == operator; return ChoiceChip(selected: active, selectedColor: serviceColor(key), label: Text(labels[key]!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: active ? Colors.white : AppColors.muted)), onSelected: (_) => setState(() => operator = key)); })),
      const SizedBox(height: 8),
      PageCard(child: Row(children: [const Icon(Icons.smartphone_rounded, color: AppColors.burgundy), const SizedBox(width: 7), Expanded(child: TextField(controller: phone, textDirection: TextDirection.ltr, keyboardType: TextInputType.phone, maxLength: 9, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'رقم الهاتف / الاشتراك', counterText: '', border: InputBorder.none, isDense: true)))])),
      const SizedBox(height: 8),
      if (services.isEmpty) const EmptyState(text: 'لا توجد خدمات منشورة لهذا المشغل في كتالوج الخادم.', icon: Icons.cloud_off_outlined),
      for (final service in services) DynamicServiceCard(service: service, color: color, phone: phone),
    ])));
  }
}

class DynamicServiceCard extends StatelessWidget {
  const DynamicServiceCard({super.key, required this.service, required this.color, required this.phone});
  final Map<String, dynamic> service; final Color color; final TextEditingController phone;
  @override Widget build(BuildContext context) {
    final items = service['items'] is List ? (service['items'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String,dynamic>>[];
    return PageCard(margin: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [CircleAvatar(radius: 19, backgroundColor: color, child: const Icon(Icons.bolt_rounded, color: Colors.white)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${service['name'] ?? 'خدمة'}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), Text('${service['description'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: AppColors.muted))]))]),
      const SizedBox(height: 8),
      if (items.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: [for (final item in items) InkWell(onTap: () => _open(context, item), borderRadius: BorderRadius.circular(12), child: Container(width: 112, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(.22))), child: Column(children: [Text('${item['name'] ?? 'عنصر'}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(money(item['price']), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w900))])))])
      else OutlinedButton.icon(onPressed: () => _open(context, null), icon: const Icon(Icons.play_arrow_rounded), label: const Text('تنفيذ الخدمة', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
    ]);
  }
  void _open(BuildContext context, Map<String,dynamic>? item) => showDialog(context: context, builder: (_) => DynamicServiceDialog(service: service, item: item, color: color, phone: phone));
}

class DynamicServiceDialog extends StatefulWidget {
  const DynamicServiceDialog({super.key, required this.service, required this.color, required this.phone, this.item});
  final Map<String,dynamic> service; final Map<String,dynamic>? item; final Color color; final TextEditingController phone;
  @override State<DynamicServiceDialog> createState() => _DynamicServiceDialogState();
}
class _DynamicServiceDialogState extends State<DynamicServiceDialog> {
  final fields = <String,TextEditingController>{}; bool busy = false;
  @override void initState(){super.initState(); final raw=widget.service['fields']; if(raw is List) for(final f in raw.whereType<Map>()){final key='${f['key']??''}'; fields[key]=TextEditingController(text:(key=='mobile'||key=='phone')?widget.phone.text:'${f['default']??''}');} if(widget.item!=null&&fields.containsKey('amount')&&fields['amount']!.text.isEmpty)fields['amount']!.text='${widget.item!['price']??''}';}
  @override void dispose(){for(final c in fields.values)c.dispose();super.dispose();}
  @override Widget build(BuildContext context){final raw=widget.service['fields'];final fs=raw is List?raw.whereType<Map>().toList():<Map>[];return AlertDialog(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(21)),title:Text('${widget.service['name']??'تنفيذ الخدمة'}',textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w900)),content:SizedBox(width:430,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[if(widget.item!=null)Container(width:double.infinity,padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:widget.color.withOpacity(.08),borderRadius:BorderRadius.circular(12)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('${widget.item!['name']??'العنصر'}',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900)),Text(money(widget.item!['price']),style:TextStyle(color:widget.color,fontWeight:FontWeight.w900))])),for(final f in fs)Padding(padding:const EdgeInsets.only(top:8),child:TextField(controller:fields['${f['key']??''}'],obscureText:f['secret']==true,decoration:InputDecoration(labelText:'${f['label']??f['key']}',hintText:f['choices'] is List?((f['choices'] as List).isNotEmpty?'${(f['choices'] as List).join('، ')}':null):null,isDense:true))) ]))),actions:[TextButton(onPressed:busy?null:()=>Navigator.pop(context),child:const Text('إلغاء')),FilledButton(onPressed:busy?null:_submit,style:FilledButton.styleFrom(backgroundColor:widget.color),child:Text(busy?'جاري...':'تنفيذ'))]);}
  Future<void> _submit() async {final payload=<String,dynamic>{for(final e in fields.entries)if(e.value.text.trim().isNotEmpty)e.key:e.value.text.trim()};final id=int.tryParse('${widget.service['id']}');if(id==null)return;setState(()=>busy=true);try{final r=await context.read<AppController>().requestService(serviceId:id,payload:payload,itemId:widget.item==null?null:int.tryParse('${widget.item!['id']}'),itemType:widget.item==null?null:'${widget.item!['type']??''}');if(!mounted)return;Navigator.pop(context);await showDialog(context:context,builder:(_)=>AlertDialog(title:Text('${r['status']=='failed'?'فشل الطلب':'نتيجة العملية'}',textAlign:TextAlign.center),content:Text('${r['result']??r['error_message']??'تم إرسال الطلب'}\nالمرجع: ${r['id']??'-'}',textAlign:TextAlign.center),actions:[FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('تم'))]));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}finally{if(mounted)setState(()=>busy=false);}}
}

class GamesServicesScreen extends StatelessWidget {
  const GamesServicesScreen({super.key});
  @override Widget build(BuildContext context){final app=context.watch<AppController>();final services=app.catalogServices.where((s){final h='${s['code']??''} ${s['name']??''} ${s['description']??''}'.toLowerCase();return h.contains('game')||h.contains('digital')||h.contains('pubg')||h.contains('freefire')||h.contains('لعبة')||h.contains('برنامج');}).toList();return ScreenFrame(title:'الألعاب والبرامج',color:AppColors.purple,actions:[IconButton(onPressed:app.refreshCatalog,icon:const Icon(Icons.sync_rounded))],child:RefreshIndicator(onRefresh:app.refreshCatalog,color:AppColors.purple,child:ListView(padding:const EdgeInsets.all(12),children:[const RefSection(title:'الخدمات الرقمية',icon:Icons.sports_esports_rounded,color:AppColors.purple),const SizedBox(height:8),if(services.isEmpty)const EmptyState(text:'لا توجد خدمات ألعاب أو رقمية منشورة في الكتالوج.',icon:Icons.sports_esports_outlined),for(final s in services)DynamicServiceCard(service:s,color:AppColors.purple,phone:TextEditingController(text:app.user?.phone??''))])));}
}

class _HomeShortcut { const _HomeShortcut(this.title,this.subtitle,this.icon,this.color,this.screen); final String title,subtitle; final IconData icon; final Color color; final int screen; }
class _WalletMini extends StatelessWidget { const _WalletMini({required this.title,required this.value,required this.icon}); final String title,value; final IconData icon; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white.withOpacity(.10),borderRadius:BorderRadius.circular(11)),child:Row(children:[Icon(icon,color:const Color(0xFFFDE68A),size:16),const SizedBox(width:6),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white70,fontSize:7.5)),Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontSize:9.5,fontWeight:FontWeight.w900))]))])); }
class _QuickAction extends StatelessWidget { const _QuickAction({required this.title,required this.subtitle,required this.icon,required this.color,required this.onTap,this.dark=false}); final String title,subtitle; final IconData icon; final Color color; final VoidCallback onTap; final bool dark; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Container(padding:const EdgeInsets.symmetric(vertical:9,horizontal:5),decoration:BoxDecoration(color:dark?color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:dark?color:AppColors.border)),child:Column(children:[Icon(icon,color:dark?Colors.white:color,size:21),const SizedBox(height:5),Text(title,style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900,color:dark?Colors.white:AppColors.page==Colors.white?Colors.black:Color(0xFF0F172A))),Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:7.5,color:dark?Colors.white70:AppColors.muted))]))); }
