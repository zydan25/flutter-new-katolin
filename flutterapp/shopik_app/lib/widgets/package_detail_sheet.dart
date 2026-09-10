import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class PackageDetailSheet extends StatefulWidget {
  final PackageItem package;
  final OperatorConfig operator;
  final double currentBalance;
  final double loanAmount;
  final Function(double totalAmount, bool includeLoan) onProceedPayment;

  const PackageDetailSheet({
    Key? key,
    required this.package,
    required this.operator,
    this.currentBalance = 436.04,
    this.loanAmount = 122.0,
    required this.onProceedPayment,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required PackageItem package,
    required OperatorConfig operator,
    double currentBalance = 436.04,
    double loanAmount = 122.0,
    required Function(double totalAmount, bool includeLoan) onProceedPayment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PackageDetailSheet(
        package: package,
        operator: operator,
        currentBalance: currentBalance,
        loanAmount: loanAmount,
        onProceedPayment: onProceedPayment,
      ),
    );
  }

  @override
  State<PackageDetailSheet> createState() => _PackageDetailSheetState();
}

class _PackageDetailSheetState extends State<PackageDetailSheet> {
  bool _includeLoan = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(widget.operator.primaryColorValue);
    final basePrice = widget.package.price;
    final totalPrice = basePrice + (_includeLoan ? widget.loanAmount : 0);
    final netPrice = (basePrice * 0.826).toStringAsFixed(2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Close Button and Package Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.package.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Checkbox: تسديد مبلغ السلفة
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تسديد مبلغ السلفة ${widget.loanAmount.toStringAsFixed(1)} ريال',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                  ),
                  Checkbox(
                    value: _includeLoan,
                    activeColor: const Color(0xFF0284C7),
                    onChanged: (val) {
                      setState(() {
                        _includeLoan = val ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Package Price Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('سعر الباقة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${totalPrice.toStringAsFixed(0)} ريال',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Net price and current balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الصافي بعد خصم الضريبة الحكومية:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(netPrice, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رصيد الرقم الحالي:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text('${widget.currentBalance} ر.ي', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons:
            // 1. تفعيل من الرصيد
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                foregroundColor: const Color(0xFF0284C7),
                side: const BorderSide(color: Color(0xFF0284C7)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
              label: const Text('تفعيل من الرصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طلب تفعيل الباقة من الرصيد مباشرة')),
                );
              },
            ),
            const SizedBox(height: 6),

            // 2. حذف الباقة
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('حذف الباقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طلب حذف أو إلغاء الباقة')),
                );
              },
            ),
            const SizedBox(height: 6),

            // 3. تسديد + تفعيل
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
              label: const Text('تسديد + تفعيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                Navigator.pop(context);
                widget.onProceedPayment(totalPrice, _includeLoan);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
