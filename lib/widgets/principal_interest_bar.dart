import 'package:flutter/material.dart';
import 'package:loanpal/ui/theme.dart';

class PrincipalInterestBar extends StatelessWidget {
  final double principalPercentage;
  final double interestPercentage;

  const PrincipalInterestBar({
    super.key,
    required this.principalPercentage,
    required this.interestPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // INFO: Multiply by 10 before rounding so that flex values have 1-decimal
    // precision (e.g., 33.3% → flex 333), keeping the bar visually accurate.
    int pFlex = (principalPercentage * 10).round().clamp(0, 1000);
    int iFlex = (interestPercentage * 10).round().clamp(0, 1000);

    if (pFlex == 0 && iFlex == 0) {
      pFlex = 1000;
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (pFlex > 0)
                  Expanded(
                    flex: pFlex,
                    child: Container(color: LoanPalTheme.primaryNavy),
                  ),
                if (iFlex > 0)
                  Expanded(
                    flex: iFlex,
                    child: Container(color: LoanPalTheme.burdenHigh),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegend(context, 'Principal', LoanPalTheme.primaryNavy, principalPercentage),
            _buildLegend(context, 'Interest', LoanPalTheme.burdenHigh, interestPercentage),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color, double percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ${percentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
