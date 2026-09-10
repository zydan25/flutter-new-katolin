import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class PackageCardWidget extends StatelessWidget {
  final PackageItem package;
  final OperatorConfig operator;
  final bool isExecuting;
  final VoidCallback onSelect;

  const PackageCardWidget({
    Key? key,
    required this.package,
    required this.operator,
    required this.isExecuting,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(operator.primaryColorValue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header strip with operator color accent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.12))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      operator.defaultIcon,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_formatPrice(package.price)} ر.ي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Benefits and Badges Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (package.validityDays != null)
                    _buildBadge(
                      icon: Icons.access_time_rounded,
                      text: '${package.validityDays} يوم',
                      color: Colors.blue.shade700,
                    ),
                  if (package.dataAmount != null)
                    _buildBadge(
                      icon: Icons.data_usage_rounded,
                      text: package.dataAmount!,
                      color: Colors.purple.shade700,
                    ),
                  if (package.minutes != null)
                    _buildBadge(
                      icon: Icons.call_rounded,
                      text: '${package.minutes} دقيقة',
                      color: const Color(0xFF059669),
                    ),
                  if (package.sms != null)
                    _buildBadge(
                      icon: Icons.chat_bubble_outline_rounded,
                      text: '${package.sms} رسالة',
                      color: Colors.amber.shade800,
                    ),
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isExecuting ? null : onSelect,
                  child: isExecuting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'تفعيل الباقة الآن',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price % 1.0 == 0.0) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }
}

extension on Colors {
  static const Color emeraldPrimary = Color(0xFF059669);
}
