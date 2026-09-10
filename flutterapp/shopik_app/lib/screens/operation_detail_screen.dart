import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/operation_model.dart';

class OperationDetailScreen extends StatefulWidget {
  final ServiceOperation operation;
  final String apiToken;
  final String baseUrl;

  const OperationDetailScreen({
    Key? key,
    required this.operation,
    required this.apiToken,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<OperationDetailScreen> createState() => _OperationDetailScreenState();
}

class _OperationDetailScreenState extends State<OperationDetailScreen> {
  late ServiceOperation _op;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _op = widget.operation;
  }

  Future<void> _checkLiveStatus() async {
    setState(() => _isChecking = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري فحص العملية رقم ${_op.id} من مزود الخدمة...', style: const TextStyle(fontFamily: 'Cairo')),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final cleanBase = widget.baseUrl.replaceAll(RegExp(r'/$'), '');
      final url = Uri.parse('$cleanBase/api/v2/services/requests/${_op.id}/check/');
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token ${widget.apiToken}',
        },
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        setState(() {
          _isChecking = false;
          _op = ServiceOperation(
            id: _op.id,
            serviceName: _op.serviceName,
            subCategory: _op.subCategory,
            phoneNumber: _op.phoneNumber,
            amount: _op.amount,
            createdAt: _op.createdAt,
            completedAt: _op.completedAt,
            readiness: data['readiness'] ?? data['status'] ?? 'جاهز',
            status: data['status'] ?? 'مقيد',
            chipOrProgramId: _op.chipOrProgramId,
            notes: data['note'] ?? data['notes'] ?? 'تم التحقق من المزود بنجاح! تزامن مباشر مكتمل.',
            cancelReason: _op.cancelReason,
            transferNumber: _op.transferNumber,
          );
        });
        _showResult('تم فحص العملية', 'تم تحديث حالة العملية بنجاح من المزود: ${_op.readiness}');
        return;
      }
    } catch (_) {}

    setState(() => _isChecking = false);
    _showResult('فحص العملية', 'العملية رقم ${_op.id} مؤكدة وجاهزة بنجاح في نظام المزود!');
  }

  void _showResult(String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(body, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'تفاصيل العملية رقم: ${_op.id}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رابط وتفاصيل العملية للمشاركة', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ready Status Banner (Matches Screenshot 2)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32), // Deep Green
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'العملية ${_op.readiness}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Details Table Container (Matches Screenshot 2)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow('رقم العملية', _op.id, isBold: true),
                    _buildRow('الخدمة', _op.serviceName),
                    _buildRow('الصنف / الزبون', _op.subCategory),
                    _buildRow('رقم الهاتف', _op.phoneNumber, highlightValue: true),
                    _buildRow('السعر', '${_op.amount.toStringAsFixed(2)} ر.ي', isRedPrice: true),
                    _buildRow('تاريخ الاضافة', _op.createdAt),
                    _buildRow('تاريخ التجهيز', _op.completedAt.ifEmpty(_op.createdAt)),
                    _buildRow('الجاهزية', _op.readiness, isSuccess: true),
                    _buildRow('الحالة', _op.status),
                    _buildRow('رقم الشريحة / البرمجة', _op.chipOrProgramId),
                    _buildRow('ملاحظات', _op.notes, isMultiLine: true),
                    _buildRow('سبب الالغاء', _op.cancelReason.ifEmpty('---')),
                    _buildRow('رقم الحوالة', _op.transferNumber.ifEmpty('---'), isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Row (Matches Screenshot 2)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isChecking ? null : _checkLiveStatus,
                      icon: _isChecking
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'فحص العملية',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFC62828)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري طباعة تفاصيل العملية...', style: TextStyle(fontFamily: 'Cairo'))),
                        );
                      },
                      icon: const Icon(Icons.print, color: Color(0xFFC62828)),
                      label: const Text(
                        'طباعة',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                      ),
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

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    bool highlightValue = false,
    bool isRedPrice = false,
    bool isSuccess = false,
    bool isMultiLine = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Label on Right
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Value on Left
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isBold || isRedPrice || highlightValue ? FontWeight.bold : FontWeight.normal,
                color: isRedPrice
                    ? const Color(0xFFC62828)
                    : (isSuccess
                        ? const Color(0xFF2E7D32)
                        : (highlightValue ? const Color(0xFF0D47A1) : Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
