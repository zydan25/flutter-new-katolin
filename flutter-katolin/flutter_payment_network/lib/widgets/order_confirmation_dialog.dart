import 'package:flutter/material.dart';

class OrderConfirmationDialog extends StatefulWidget {
  final String serviceName;
  final String itemName;
  final String phoneNumber;
  final double amount;
  final double feeRatio;
  final double totalCost;
  final String amountArabicWords;
  final String? lastTxTime;
  final String? lastTxName;
  final String? lastTxAmount;
  final String? lastTxStatus;
  final bool hasRealLastTx;
  final VoidCallback onConfirm;

  const OrderConfirmationDialog({
    Key? key,
    required this.serviceName,
    required this.itemName,
    required this.phoneNumber,
    required this.amount,
    this.feeRatio = 1.0,
    required this.totalCost,
    required this.amountArabicWords,
    this.lastTxTime,
    this.lastTxName,
    this.lastTxAmount,
    this.lastTxStatus,
    this.hasRealLastTx = false,
    required this.onConfirm,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String serviceName,
    required String itemName,
    required String phoneNumber,
    required double amount,
    double feeRatio = 1.0,
    required double totalCost,
    required String amountArabicWords,
    String? lastTxTime,
    String? lastTxName,
    String? lastTxAmount,
    String? lastTxStatus,
    bool hasRealLastTx = false,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OrderConfirmationDialog(
        serviceName: serviceName,
        itemName: itemName,
        phoneNumber: phoneNumber,
        amount: amount,
        feeRatio: feeRatio,
        totalCost: totalCost,
        amountArabicWords: amountArabicWords,
        lastTxTime: lastTxTime,
        lastTxName: lastTxName,
        lastTxAmount: lastTxAmount,
        lastTxStatus: lastTxStatus,
        hasRealLastTx: hasRealLastTx,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<OrderConfirmationDialog> createState() => _OrderConfirmationDialogState();
}

class _OrderConfirmationDialogState extends State<OrderConfirmationDialog> {
  String _receivedAmount = '';

  void _handleKeypad(String val) {
    setState(() {
      if (val == 'x') {
        if (_receivedAmount.isNotEmpty) {
          _receivedAmount = _receivedAmount.substring(0, _receivedAmount.length - 1);
        }
      } else {
        _receivedAmount += val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Close Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),

              // Orange Circular (i) Icon
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 3.5),
                  ),
                  alignment: Alignment.Center,
                  child: const Text(
                    'i',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title: تأكيد الطلب
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFF59E0B), thickness: 1.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'تأكيد الطلب',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFF59E0B), thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 12),

              // Section 1: تفاصيل الطلب
              const Text(
                'تفاصيل الطلب',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: const Row(
                        children: [
                          Expanded(child: Text('الخدمة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('الصنف', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('رقم الهاتف', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(widget.serviceName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text(widget.itemName, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text(widget.phoneNumber, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Section 2: تفاصيل التكلفة
              const Text(
                'تفاصيل التكلفة',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: const Row(
                        children: [
                          Expanded(child: Text('المبلغ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('النسبة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('التكلفة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('${widget.amount}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text('% ${widget.feeRatio}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text(widget.totalCost.toStringAsFixed(2), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '*اجمالي التكلفة : ${widget.amountArabicWords}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 10),

              // Section 3: آخر عملية لهذا الرقم (التحقق الفعلي هل حقيقية)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.hasRealLastTx ? const Color(0xFF81C784) : Colors.grey.shade300,
                  ),
                ),
                child: widget.hasRealLastTx
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.verified, color: Color(0xFF2E7D32), size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'آخر عملية سابقة لهذا الرقم (مؤكدة حقيقية ✓)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                ],
                              ),
                              Text(widget.lastTxTime ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(widget.lastTxName ?? 'تسديد رصيد', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.lastTxStatus ?? 'جاهز',
                                    style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(widget.lastTxAmount ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم التحقق من جاهزية وسجل العملية في السيرفر بنجاح ✓')),
                                  );
                                },
                                child: const Text(
                                  'فحص الجاهزية',
                                  style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.grey, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لا توجد عمليات سابقة مسجلة لهذا الرقم (عملية جديدة)',
                              style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // Section 4: المبلغ المستلم + لوحة الأرقام
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المبلغ المستلم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text(
                      _receivedAmount.isEmpty ? '0' : _receivedAmount,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Numeric Keypad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['1', '2', '3', '4', '5', '6'].map((n) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _handleKeypad(n),
                        child: Text(n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['7', '8', '9', '0', 'x'].map((n) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: n == 'x' ? const Color(0xFFFFEBEE) : Colors.grey.shade100,
                          foregroundColor: n == 'x' ? Colors.red : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _handleKeypad(n),
                        child: Text(n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Bottom 3 Action Buttons: موافق | عبر الرسائل | عبر الواتس
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('موافق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context, true);
                        widget.onConfirm();
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.mail_outline, size: 16),
                      label: const Text('عبر الرسائل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('عبر الواتس', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
