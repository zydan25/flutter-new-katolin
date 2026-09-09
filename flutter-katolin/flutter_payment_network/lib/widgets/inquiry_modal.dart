import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class InquiryResultModal extends StatelessWidget {
  final InquiryResultData data;
  final OperatorConfig currentOperator;

  const InquiryResultModal({
    Key? key,
    required this.data,
    required this.currentOperator,
  }) : super(key: key);

  static void show(BuildContext context, InquiryResultData data, OperatorConfig operator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InquiryResultModal(
        data: data,
        currentOperator: operator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(currentOperator.primaryColorValue);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        data.success ? 'تم الاستعلام بنجاح من مزود الخدمة' : 'فشل الاستعلام',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(height: 24),

            // Content based on type
            if (data.type == 'offers')
              _buildOffersList(primaryColor)
            else
              _buildGeneralDetails(primaryColor),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'حسناً، فهمت',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (data.type) {
      case 'balance':
        return 'نتيجة فحص الرصيد';
      case 'offers':
        return 'الباقات والاشتراكات الحالية';
      case 'salfa':
        return 'نتيجة فحص السلفة';
      case 'line_type':
        return 'نوع الرقم ونظام الخط';
      case '4g':
        return 'بيانات حساب يمن فورجي';
      case 'net':
      case 'net_adsl':
      case 'net_line':
        return 'بيانات حساب يمن نت';
      default:
        return 'نتيجة الاستعلام';
    }
  }

  Widget _buildOffersList(Color primaryColor) {
    if (data.offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.Center,
        child: Text(
          'لا توجد باقات أو اشتراكات نشطة حالياً لهذا الرقم.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: data.offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final offer = data.offers[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.offerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.offerId,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ],
                ),
                if (offer.startDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'تاريخ الاشتراك: ${_formatDate(offer.startDate)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
                if (offer.endDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'تاريخ الانتهاء: ${_formatDate(offer.endDate)}',
                    style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralDetails(Color primaryColor) {
    final entries = <MapEntry<String, String>>[];

    if (data.balance != null) {
      entries.add(MapEntry('الرصيد الفعلي', '${data.balance} ر.ي'));
    }
    if (data.availableCredit != null && data.availableCredit != data.balance) {
      entries.add(MapEntry('الرصيد المتاح', '${data.availableCredit} ر.ي'));
    }
    if (data.mobileType != null) {
      entries.add(MapEntry('نوع الرقم', data.mobileType!));
    }
    if (data.loanAmount != null) {
      entries.add(MapEntry('مبلغ السلفة', '${data.loanAmount} ر.ي'));
    }
    if (data.message != null && data.message!.isNotEmpty) {
      entries.add(MapEntry('رسالة النظام', data.message!));
    }

    // Add extra keys from rawResult if available with user-friendly Arabic labels
    final skipped = {'balance', 'availableCredit', 'mobileType', 'loan', 'loanAmount', 'sulfa', 'resultDesc', 'resultCode', 'offers'};
    data.rawResult.forEach((key, value) {
      if (!skipped.contains(key) && value != null && value.toString().isNotEmpty) {
        final label = _getArabicFieldLabel(key);
        entries.add(MapEntry(label, value.toString()));
      }
    });

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.Center,
        child: Text(
          data.message ?? 'لا توجد بيانات متاحة للاستعلام.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: entries.map((entry) {
          final isBalance = entry.key.contains('الرصيد') || entry.key.contains('balance');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: isBalance ? 16 : 13,
                    fontWeight: FontWeight.bold,
                    color: isBalance ? primaryColor : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getArabicFieldLabel(String key) {
    final clean = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    switch (clean) {
      case 'remainamount':
      case 'remainingamount':
      case 'remain':
        return 'الرصيد المتبقي';
      case 'expirydate':
      case 'expdate':
      case 'expiredate':
        return 'تاريخ انتهاء الصلاحية';
      case 'subscribername':
      case 'customername':
      case 'name':
        return 'اسم المشترك';
      case 'billamount':
      case 'dueamount':
      case 'requiredamount':
        return 'المبلغ المطلوب';
      case 'package':
      case 'packagename':
        return 'الباقة الحالية';
      case 'speed':
      case 'linespeed':
        return 'سرعة الخط';
      case 'status':
      case 'accountstatus':
        return 'حالة الحساب';
      case 'gigabytes':
      case 'quota':
      case 'data':
        return 'حجم البيانات المتبقي';
      case 'resultdesc':
      case 'message':
        return 'تفاصيل النتيجة';
      case 'resultcode':
        return 'رمز النتيجة';
      case 'transid':
      case 'sequenceid':
      case 'referenceid':
        return 'رقم المرجع';
      default:
        return key;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.length < 8) return raw ?? '';
    // If YYYYMMDDHHMMSS format
    try {
      final y = raw.substring(0, 4);
      final m = raw.substring(4, 6);
      final d = raw.substring(6, 8);
      return '$y/$m/$d';
    } catch (_) {
      return raw;
    }
  }
}
