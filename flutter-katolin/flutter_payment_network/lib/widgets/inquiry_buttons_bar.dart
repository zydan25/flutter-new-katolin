import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class InquiryButtonsBarWidget extends StatelessWidget {
  final OperatorConfig currentOperator;
  final bool isLoading;
  final String? activeInquiryType;
  final Function(String inquiryType) onRunInquiry;

  const InquiryButtonsBarWidget({
    Key? key,
    required this.currentOperator,
    required this.isLoading,
    this.activeInquiryType,
    required this.onRunInquiry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(currentOperator.primaryColorValue);

    // If operator is Yemen Mobile
    if (currentOperator.kind == OperatorKind.yemenMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'استعلامات وفحص الرقم (يمن موبايل)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInquiryButton(
                    label: 'فحص الرصيد',
                    icon: Icons.account_balance_wallet_outlined,
                    type: 'balance',
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInquiryButton(
                    label: 'فحص السلفة',
                    icon: Icons.monetization_on_outlined,
                    type: 'salfa',
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInquiryButton(
                    label: 'فحص الباقات',
                    icon: Icons.card_giftcard_rounded,
                    type: 'offers',
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInquiryButton(
                    label: 'نوع الخط',
                    icon: Icons.sim_card_outlined,
                    type: 'line_type',
                    primaryColor: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // If operator is Yemen 4G
    if (currentOperator.kind == OperatorKind.fourG) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wifi_tethering_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'استعلام حساب يمن فورجي 4G',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _buildInquiryButton(
                label: 'استعلام الرصيد والصلاحية والرصيد المتبقي',
                icon: Icons.speed_rounded,
                type: '4g',
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    // If operator is Yemen Net
    if (currentOperator.kind == OperatorKind.yemenNet) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.router_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'استعلام يمن نت (ADSL / الخط الثابت)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInquiryButton(
                    label: 'استعلام رصيد ADSL',
                    icon: Icons.language_rounded,
                    type: 'net_adsl',
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInquiryButton(
                    label: 'استعلام الهاتف الثابت',
                    icon: Icons.phone_in_talk_rounded,
                    type: 'net_line',
                    primaryColor: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInquiryButton({
    required String label,
    required IconData icon,
    required String type,
    required Color primaryColor,
  }) {
    final isThisActive = isLoading && activeInquiryType == type;

    return InkWell(
      onTap: isLoading ? null : () => onRunInquiry(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isThisActive ? primaryColor : primaryColor.withOpacity(0.2),
            width: isThisActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isThisActive
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : Icon(icon, size: 18, color: primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
