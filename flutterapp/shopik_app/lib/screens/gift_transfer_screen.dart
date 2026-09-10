import 'package:flutter/material.dart';

class GiftTransferScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const GiftTransferScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<GiftTransferScreen> createState() => _GiftTransferScreenState();
}

class _GiftTransferScreenState extends State<GiftTransferScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _showConfirmation = false;
  String _recipientName = '';

  void _verifyRecipient() async {
    final phone = _phoneController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم هاتف المستلم بشكل صحيح')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _isLoading = false;
      _recipientName = 'زيدان محمد عبدالله العطاب';
      _showConfirmation = true;
    });
  }

  void _executeFinalTransfer() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.check, color: Color(0xFF059669), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('تم إرسال الهدية بنجاح!',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'تم تحويل ${_amountController.text} ر.ي بنجاح إلى ${_phoneController.text} ($_recipientName).',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _showConfirmation = false;
                  _phoneController.clear();
                  _amountController.clear();
                  _messageController.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              child: const Text('حسناً', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'إرسال هدية / تحويل رصيد',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _showConfirmation
              ? _buildConfirmationView(primaryNavy)
              : _buildFormView(primaryNavy),
        ),
      ),
    );
  }

  Widget _buildFormView(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Notice Card matching Screenshot 16
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.card_giftcard, color: Color(0xFF2563EB), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تحويل رصيد كهدية - نرسل الطلب إلى الخادم أولاً، نتحقق من صاحب الرقم ورصيدك، ثم لا يتم الخصم إلا بعد تأكيدك النهائي.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Phone Input
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رقم هاتف المستلم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '774952665 أو 77xxxxxxx',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('المبلغ بالريال اليمني (ر.ي)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مثال: 1000',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('رسالة الهدية (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'هدية ومفاجأة لك يا غالي...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _verifyRecipient,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'متابعة والتحقق من المستلم',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildConfirmationView(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFFEF3C7),
              child: Icon(Icons.check_circle_outline, color: Color(0xFFD97706), size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'تأكيد تحويل الهدية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'سيتم التحويل إلى الحساب: ${_phoneController.text}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'اسم المستلم المعتمد: $_recipientName',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ النهائي:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${_amountController.text} ر.ي',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'بعد الضغط على تأكيد التحويل سيتم خصم المبلغ وإضافته إلى رصيد المستلم ولا يمكن التراجع عن العملية.',
                style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _executeFinalTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تأكيد التحويل النهائي',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showConfirmation = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('إلغاء وعدم التحويل'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
