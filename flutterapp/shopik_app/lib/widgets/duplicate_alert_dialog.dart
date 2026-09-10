import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class DuplicatePaymentDialog extends StatelessWidget {
  final String phone;
  final double amount;
  final String packageName;
  final String previousTime;
  final OperatorConfig operator;
  final VoidCallback onProceed;

  const DuplicatePaymentDialog({
    Key? key,
    required this.phone,
    required this.amount,
    required this.packageName,
    required this.previousTime,
    required this.operator,
    required this.onProceed,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String phone,
    required double amount,
    required String packageName,
    required String previousTime,
    required OperatorConfig operator,
    required VoidCallback onProceed,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => DuplicatePaymentDialog(
        phone: phone,
        amount: amount,
        packageName: packageName,
        previousTime: previousTime,
        operator: operator,
        onProceed: onProceed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(operator.primaryColorValue);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'تنبيه تكرار السداد اليوم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لقد قمت مسبقاً بالسداد لهذا الرقم ($phone) اليوم في الساعة ($previousTime).',
              style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'العملية الحالية: $packageName بمبلغ $amount ر.ي\nهل أنت متأكد من رغبتك في تكرار العملية لنفس الرقم؟',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء العملية', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context, true);
              onProceed();
            },
            child: const Text(
              'نعم، تابع السداد',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
