import 'dart:convert';

/// Model representing a telecom / service operation / transaction
class ServiceOperation {
  final String id;
  final String serviceName;
  final String subCategory;
  final String phoneNumber;
  final double amount;
  final String createdAt;
  final String completedAt;
  final String readiness; // e.g. "جاهز", "قيد الانتظار", "ملغي"
  final String status;    // e.g. "مقيد", "مكتمل", "مرفوض"
  final String chipOrProgramId;
  final String notes;
  final String cancelReason;
  final String transferNumber;
  final String providerTransId;
  final Map<String, dynamic>? rawResult;

  ServiceOperation({
    required this.id,
    required this.serviceName,
    required this.subCategory,
    required this.phoneNumber,
    required this.amount,
    required this.createdAt,
    this.completedAt = '',
    this.readiness = 'جاهز',
    this.status = 'مقيد',
    this.chipOrProgramId = '',
    this.notes = '',
    this.cancelReason = '',
    this.transferNumber = '',
    this.providerTransId = '',
    this.rawResult,
  });

  bool get isSuccess => readiness == 'جاهز' || status == 'مقيد' || status == 'مكتمل' || status == 'completed';
  bool get isPending => readiness.contains('انتظار') || status.contains('انتظار') || status == 'pending';
  bool get isFailed => readiness.contains('ملغي') || status.contains('فشل') || status == 'failed';

  factory ServiceOperation.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map<String, dynamic> ? json['result'] as Map<String, dynamic> : null;
    return ServiceOperation(
      id: json['id']?.toString() ?? 'TX-${DateTime.now().millisecondsSinceEpoch}',
      serviceName: json['service_name']?.toString() ?? json['service']?.toString() ?? 'تسديد رصيد موبايل',
      subCategory: json['item_name']?.toString() ?? json['sub_category']?.toString() ?? 'دفع مسبق',
      phoneNumber: json['phone']?.toString() ?? json['mobile']?.toString() ?? json['recipient_phone']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '2026-09-09 19:53:41',
      completedAt: json['completed_at']?.toString() ?? '2026-09-09 19:55:56',
      readiness: json['readiness']?.toString() ?? (json['status'] == 'completed' ? 'جاهز' : (json['status'] == 'failed' ? 'ملغي' : 'جاهز')),
      status: json['status']?.toString() ?? 'مقيد',
      chipOrProgramId: json['chip_id']?.toString() ?? json['sim_number']?.toString() ?? '7bc188ad33bec2c1',
      notes: json['notes']?.toString() ?? 'تم تجهيز العملية من نظام المزود تزامن مباشر! الرد: تصحيح الجاهزية بعد التاكد',
      cancelReason: json['cancel_reason']?.toString() ?? (json['status'] == 'pending' ? 'under process' : ''),
      transferNumber: json['transfer_number']?.toString() ?? json['reference_code']?.toString() ?? '',
      providerTransId: json['provider_transid']?.toString() ?? json['provider_transaction_id']?.toString() ?? '',
      rawResult: result,
    );
  }
}
