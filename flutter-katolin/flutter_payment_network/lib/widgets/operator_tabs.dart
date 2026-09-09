import 'package:flutter/material.dart';
import '../models/telecom_service.dart';

class OperatorTabsWidget extends StatelessWidget {
  final OperatorConfig selectedOperator;
  final Function(OperatorConfig) onSelect;

  const OperatorTabsWidget({
    Key? key,
    required this.selectedOperator,
    required this.onSelect,
  }) : super(key: key);

  static const List<OperatorConfig> operators = [
    OperatorConfig.yemenMobile,
    OperatorConfig.sabafon,
    OperatorConfig.you,
    OperatorConfig.fourG,
    OperatorConfig.yemenNet,
    OperatorConfig.why,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: operators.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final op = operators[index];
          final isSelected = op.kind == selectedOperator.kind;
          final primaryColor = Color(op.primaryColorValue);

          return InkWell(
            onTap: () => onSelect(op),
            borderRadius: BorderRadius.circular(26),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.Center,
                    child: Text(
                      op.defaultIcon,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    op.nameAr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
