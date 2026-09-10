import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'screen_common.dart';
import 'reference_account.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});
  @override State<StoreView> createState() => _StoreViewState();
}
class _StoreViewState extends State<StoreView> {
  final search = TextEditingController();
  final cart = <int, int>{};
  final favorites = <int>{};
  String? category;
  @override void dispose() { search.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final q = search.text.trim().toLowerCase();
    final products = app.products.where((p) {
      final text = '${p.name} ${p.brand} ${p.vendorName} ${p.categories.join(' ')}'.toLowerCase();
      return (q.isEmpty || text.contains(q)) && (category == null || p.categories.contains(category));
    }).toList();
    num total = 0;
    for (final e in cart.entries) {
      final matches = app.products.where((p) => p.id == e.key).toList();
      if (matches.isNotEmpty) total += (matches.first.salePrice ?? matches.first.price) * e.value;
    }
    return ScreenFrame(
      title: 'متجر شبيك | سوق بلس', color: AppColors.emerald,
      actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersDetailView())), icon: const Icon(Icons.receipt_long_rounded)), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())), icon: const Icon(Icons.location_on_outlined))],
      child: RefreshIndicator(color: AppColors.emerald, onRefresh: app.refreshAll, child: ListView(padding: const EdgeInsets.all(12), children: [
        SizedBox(height: 112, child: PageView(children: const [_Banner(title: 'تخفيضات كبرى في سوق شبيك', subtitle: 'خصومات حصرية حتى 40% على الملابس والإلكترونيات', tag: 'عرض اليوم', colors: [AppColors.burgundy, Color(0xFFBE185D)]), _Banner(title: 'شحن سريع لكافة المحافظات', subtitle: 'صنعاء، إب، عدن، تعز • توصيل شبيك', tag: 'توصيل شبيك', colors: [Color(0xFF1D4ED8), Color(0xFF312E81)])])),
        const SizedBox(height: 9),
        PageCard(child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'ابحث في المنتجات والمتاجر...', isDense: true))),
        const SizedBox(height: 8),
        if (app.categories.isNotEmpty) SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: app.categories.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) { final name = '${app.categories[i]['name'] ?? app.categories[i]['title'] ?? ''}'; final active = name == category; return ChoiceChip(selected: active, selectedColor: AppColors.emerald, label: Text(name, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.muted)), onSelected: (_) => setState(() => category = active ? null : name)); })),
        const SizedBox(height: 9),
        RefSection(title: 'منتجات سوق بلس', icon: Icons.shopping_bag_rounded, color: AppColors.emerald, action: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesFlutterScreen())), child: const Text('التصنيفات', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)))),
        const SizedBox(height: 8),
        if (products.isEmpty) const EmptyState(text: 'لا توجد منتجات متاحة من الخادم حالياً.', icon: Icons.inventory_2_outlined),
        if (products.isNotEmpty) GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .69), itemBuilder: (_, i) {
          final p = products[i]; final qty = cart[p.id] ?? 0; final fav = favorites.contains(p.id);
          return StoreProductCard(product: p, quantity: qty, favorite: fav, onFavorite: () => setState(() => fav ? favorites.remove(p.id) : favorites.add(p.id)), onAdd: () => setState(() => cart[p.id] = qty + 1), onRemove: qty == 0 ? null : () => setState(() => qty <= 1 ? cart.remove(p.id) : cart[p.id] = qty - 1), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailView(product: p, onAdd: () => setState(() => cart[p.id] = qty + 1))));
        }),
        if (app.vendors.isNotEmpty) ...[const SizedBox(height: 12), const RefSection(title: 'المتاجر المميزة', icon: Icons.storefront_rounded, color: AppColors.emerald), const SizedBox(height: 7), SizedBox(height: 84, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: app.vendors.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) { final v = app.vendors[i]; return InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreProfileView(vendor: v))), child: PageCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.storefront_rounded, color: AppColors.emerald, size: 24), const SizedBox(height: 4), Text('${v['store_name'] ?? v['name'] ?? 'متجر'}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900))]))); })),],
        const SizedBox(height: 80),
      ])),
      bottomSheet: cart.isEmpty ? null : SafeArea(child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 12)]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${cart.values.fold<int>(0, (a, b) => a + b)} منتج في السلة', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), Text(money(total), style: const TextStyle(fontSize: 10, color: AppColors.burgundy, fontWeight: FontWeight.w900))])), FilledButton(onPressed: () => checkout(context), style: FilledButton.styleFrom(backgroundColor: AppColors.emerald), child: const Text('إتمام الطلب', style: TextStyle(fontWeight: FontWeight.w900)))]))),
    );
  }
  Future<void> checkout(BuildContext context) async {
    final app = context.read<AppController>();
    if (app.addresses.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف عنوان توصيل أولاً.'))); return; }
    try {
      final items = cart.entries.map((e) => <String, dynamic>{'product_id': e.key, 'quantity': e.value}).toList();
      await app.api.cartCalculate(items, cityId: int.tryParse('${app.addresses.first['city_id'] ?? ''}'));
      final order = await app.api.createOrder(items: items, shippingAddress: Map<String, dynamic>.from(app.addresses.first), paymentMethod: 'wallet');
      setState(cart.clear); await app.refreshAll();
      if (context.mounted) showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('تم إنشاء الطلب', textAlign: TextAlign.center), content: Text('رقم الطلب: ${order['order_number'] ?? order['id'] ?? '-'}', textAlign: TextAlign.center), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('تم'))]));
    } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.subtitle, required this.tag, required this.colors});
  final String title, subtitle, tag; final List<Color> colors;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(20)), child: Stack(children: [Positioned(top: 0, left: 0, child: RefPill(tag, color: Colors.white)), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700))])]));
}

class StoreProductCard extends StatelessWidget {
  const StoreProductCard({super.key, required this.product, required this.quantity, required this.favorite, required this.onFavorite, required this.onAdd, required this.onRemove, required this.onTap});
  final Product product; final int quantity; final bool favorite; final VoidCallback onFavorite, onAdd, onTap; final VoidCallback? onRemove;
  @override Widget build(BuildContext context) { final image = absoluteUrl(product.image); return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Stack(children: [AspectRatio(aspectRatio: 1.03, child: image.isEmpty ? const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.black26)) : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.black26)))), Positioned(top: 6, left: 6, child: InkWell(onTap: onFavorite, child: CircleAvatar(radius: 14, backgroundColor: Colors.white.withOpacity(.90), child: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.red : AppColors.muted, size: 16))))]), Padding(padding: const EdgeInsets.fromLTRB(8, 7, 8, 1), child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(money(product.salePrice ?? product.price, product.currency), style: const TextStyle(fontSize: 12, color: AppColors.burgundy, fontWeight: FontWeight.w900))), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline_rounded, size: 18)), Text('$quantity', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), IconButton(onPressed: product.stock > 0 ? onAdd : null, icon: const Icon(Icons.add_circle_rounded, size: 18, color: AppColors.emerald))])])); }
}

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key, required this.product, this.onAdd});
  final Product product; final VoidCallback? onAdd;
  @override Widget build(BuildContext context) { final images = <String>[if (product.image != null) product.image!, ...product.gallery].where((x) => x.isNotEmpty).toSet().toList(); return ScreenFrame(title: 'تفاصيل المنتج', color: AppColors.emerald, child: ListView(padding: const EdgeInsets.all(12), children: [if (images.isNotEmpty) SizedBox(height: 250, child: PageView(children: [for (final image in images) ClipRRect(borderRadius: BorderRadius.circular(19), child: Image.network(absoluteUrl(image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 50)))])), const SizedBox(height: 10), PageCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), if (product.brand.isNotEmpty) Text(product.brand, style: const TextStyle(fontSize: 10, color: AppColors.muted)), const SizedBox(height: 7), Row(children: [Text(money(product.salePrice ?? product.price, product.currency), style: const TextStyle(fontSize: 20, color: AppColors.burgundy, fontWeight: FontWeight.w900)), const Spacer(), RefPill('${product.stock} متاح', color: AppColors.emerald)]), const SizedBox(height: 7), Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 18), Text(' ${product.rating} • ${product.reviewsCount} تقييم', style: const TextStyle(fontSize: 10)), const Spacer(), Text('${product.soldCount} مبيع', style: const TextStyle(fontSize: 9, color: AppColors.muted))]), if (product.description.isNotEmpty) ...[const Divider(height: 20), Text(product.description, style: const TextStyle(fontSize: 11, height: 1.55))]])), const SizedBox(height: 9), FilledButton.icon(onPressed: product.stock <= 0 ? null : () { onAdd?.call(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المنتج إلى السلة.'))); }, style: FilledButton.styleFrom(backgroundColor: AppColors.emerald), icon: const Icon(Icons.shopping_cart_outlined), label: const Text('إضافة للسلة', style: TextStyle(fontWeight: FontWeight.w900))) ])); }
}

class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({super.key, this.category});
  final String? category;
  @override Widget build(BuildContext context) { final app = context.watch<AppController>(); final products = app.products.where((p) => category == null || p.categories.contains(category)).toList(); return ScreenFrame(title: category ?? 'تصنيفات المنتجات', color: AppColors.emerald, child: ListView(padding: const EdgeInsets.all(12), children: [if (category == null) for (final c in app.categories) PageCard(margin: const EdgeInsets.only(bottom: 7), child: ListTile(leading: const Icon(Icons.category_outlined, color: AppColors.emerald), title: Text('${c['name'] ?? c['title'] ?? 'تصنيف'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)), trailing: const Icon(Icons.chevron_left_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsView(category: '${c['name'] ?? c['title'] ?? ''}'))))), if (category != null) for (final p in products) PageCard(margin: const EdgeInsets.only(bottom: 7), child: ListTile(leading: SizedBox(width: 50, height: 50, child: p.image == null ? const Icon(Icons.image_outlined) : Image.network(absoluteUrl(p.image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined))), title: Text(p.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), subtitle: Text(money(p.salePrice ?? p.price, p.currency), style: const TextStyle(fontSize: 10, color: AppColors.burgundy, fontWeight: FontWeight.w900)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailView(product: p))))) ])); }
}

class CategoriesFlutterScreen extends StatelessWidget {
  const CategoriesFlutterScreen({super.key});
  @override Widget build(BuildContext context) => const CategoryProductsView();
}

class StoreProfileView extends StatelessWidget {
  const StoreProfileView({super.key, required this.vendor});
  final Map<String,dynamic> vendor;
  @override Widget build(BuildContext context) { final app = context.watch<AppController>(); final id = int.tryParse('${vendor['id'] ?? vendor['vendor_id'] ?? ''}'); final products = id == null ? <Product>[] : app.products.where((p) => p.vendorId == id).toList(); return ScreenFrame(title: '${vendor['store_name'] ?? vendor['name'] ?? 'المتجر'}', color: AppColors.emerald, child: ListView(padding: const EdgeInsets.all(12), children: [PageCard(child: Column(children: [const CircleAvatar(radius: 32, backgroundColor: Color(0xFFECFDF5), child: Icon(Icons.storefront_rounded, color: AppColors.emerald, size: 31)), const SizedBox(height: 8), Text('${vendor['store_name'] ?? vendor['name'] ?? 'متجر'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('${vendor['description'] ?? ''}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.muted))])), const SizedBox(height: 10), const RefSection(title: 'منتجات المتجر', icon: Icons.inventory_2_outlined, color: AppColors.emerald), const SizedBox(height: 7), if (products.isEmpty) const EmptyState(text: 'لا توجد منتجات لهذا المتجر.', icon: Icons.inventory_2_outlined), for (final p in products) PageCard(margin: const EdgeInsets.only(bottom: 7), child: ListTile(title: Text(p.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), trailing: Text(money(p.salePrice ?? p.price), style: const TextStyle(fontSize: 10, color: AppColors.burgundy, fontWeight: FontWeight.w900)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailView(product: p))))) ])); }
}

class OrdersDetailView extends StatelessWidget {
  const OrdersDetailView({super.key});
  @override Widget build(BuildContext context) { final app = context.watch<AppController>(); return ScreenFrame(title:'طلباتي',color:AppColors.blue,actions:[IconButton(onPressed:app.refreshAll,icon:const Icon(Icons.refresh_rounded))],child:ListView(padding:const EdgeInsets.all(12),children:[if(app.orders.isEmpty)const EmptyState(text:'لا توجد طلبات حالياً.',icon:Icons.local_shipping_outlined),for(final o in app.orders)PageCard(margin:const EdgeInsets.only(bottom:8),child:ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.local_shipping_outlined,color:AppColors.blue),title:Text('#${o.number}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900)),subtitle:Text(o.createdAt??'',style:const TextStyle(fontSize:8,color:AppColors.muted)),trailing:TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OrderDetailScreen(orderId:o.id))),child:const Text('التفاصيل',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900))))])); }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final int orderId;
  @override Widget build(BuildContext context) => FutureBuilder<Map<String,dynamic>>(future:context.read<AppController>().api.orderDetail(orderId),builder:(context,s){if(s.connectionState!=ConnectionState.done)return const Scaffold(body:Center(child:CircularProgressIndicator(color:AppColors.blue)));final d=s.data??{};return ScreenFrame(title:'تفاصيل الطلب',color:AppColors.blue,child:ListView(padding:const EdgeInsets.all(12),children:[PageCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text('الطلب #${d['order_number']??orderId}',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),Text('الحالة: ${d['status']??''}',style:const TextStyle(fontSize:10,color:AppColors.muted)),const Divider(height:20),for(final key in ['subtotal','shipping_cost','tax','total'])if(d[key]!=null)Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(key,style:const TextStyle(fontSize:9,color:AppColors.muted)),Text('${d[key]} ${d['currency']??'YER'}',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900))])])),const SizedBox(height:9),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OrderChatScreen(orderId:orderId))),icon:const Icon(Icons.chat_bubble_outline_rounded),label:const Text('محادثة'))),const SizedBox(width:7),Expanded(child:FilledButton.icon(onPressed:()=>_confirm(context),style:FilledButton.styleFrom(backgroundColor:AppColors.emerald),icon:const Icon(Icons.check_circle_outline),label:const Text('استلام')))] )]));});
  Future<void> _confirm(BuildContext context) async { try { await context.read<AppController>().api.confirmReceived(orderId); await context.read<AppController>().refreshAll(); if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تأكيد الاستلام.'))); } catch(e) { if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString()))); } }
}

class OrderChatScreen extends StatefulWidget { const OrderChatScreen({super.key,required this.orderId}); final int orderId; @override State<OrderChatScreen>createState()=>_OrderChatScreenState(); }
class _OrderChatScreenState extends State<OrderChatScreen>{
  final controller=TextEditingController(); List<Map<String,dynamic>> messages=[]; int? chatId; bool loading=true;
  @override void initState(){super.initState();load();}
  @override void dispose(){controller.dispose();super.dispose();}
  Future<void> load()async{try{final api=context.read<AppController>().api;final chats=await api.ensureOrderChats(widget.orderId);if(chats.isNotEmpty)chatId=int.tryParse('${chats.first['id']??''}');if(chatId!=null){final data=await api.orderChat(chatId!);final raw=data['messages'];messages=raw is List?raw.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList():[];}}catch(_){}if(mounted)setState(()=>loading=false);}
  Future<void>send()async{if(chatId==null||controller.text.trim().isEmpty)return;try{await context.read<AppController>().api.sendOrderChatMessage(chatId!,controller.text.trim());controller.clear();setState(()=>loading=true);await load();}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}}
  @override Widget build(BuildContext context)=>ScreenFrame(title:'محادثة الطلب',color:AppColors.blue,child:Column(children:[Expanded(child:loading?const Center(child:CircularProgressIndicator(color:AppColors.blue)):ListView(padding:const EdgeInsets.all(12),children:[for(final m in messages)Align(alignment:m['sender_role']=='customer'?Alignment.centerRight:Alignment.centerLeft,child:Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:m['sender_role']=='customer'?AppColors.burgundy:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:AppColors.border)),child:Text('${m['body']??''}',style:TextStyle(fontSize:10,color:m['sender_role']=='customer'?Colors.white:Color(0xFF0F172A)))))])),SafeArea(child(Container(padding:const EdgeInsets.all(9),color:Colors.white,child:Row(children:[Expanded(child:TextField(controller:controller,decoration:const InputDecoration(hintText:'اكتب رسالتك...',isDense:true))),IconButton(onPressed:send,style:IconButton.styleFrom(backgroundColor:AppColors.blue,foregroundColor:Colors.white),icon:const Icon(Icons.send_rounded))]))))]));
}
