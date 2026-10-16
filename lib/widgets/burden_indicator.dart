import 'package:flutter/material.dart';
import 'package:loanpal/logic/emi_calculator.dart';
import 'package:loanpal/ui/theme.dart';

class BurdenIndicator extends StatelessWidget {
  final BurdenLevel burdenLevel;
  final double interestPercentage;

  const BurdenIndicator({
    super.key,
    required this.burdenLevel,
    required this.interestPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final Color burdenColor;
    final String label;
    final IconData icon;

    switch (burdenLevel) {
      case BurdenLevel.low:
        burdenColor = LoanPalTheme.burdenLow;
        label = 'LOW INTEREST BURDEN';
        icon = Icons.check_circle_outline;
        break;
      case BurdenLevel.moderate:
        burdenColor = LoanPalTheme.burdenModerate;
        label = 'MODERATE INTEREST BURDEN';
        icon = Icons.info_outline;
        break;
      case BurdenLevel.high:
        burdenColor = LoanPalTheme.burdenHigh;
        label = 'HIGH INTEREST BURDEN';
        icon = Icons.warning_amber_rounded;
        break;
      case BurdenLevel.heavy:
        burdenColor = LoanPalTheme.burdenHeavy;
        label = 'HEAVY INTEREST BURDEN';
        icon = Icons.dangerous_outlined;
        break;
    }

    final Color bgColor = burdenColor.withValues(alpha: 0.15);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: burdenColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: burdenColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label (${interestPercentage.toStringAsFixed(1)}%)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              // INFO: Amber (#F4C430) has poor contrast on its own tinted
              // background, so dark brown is used for the Moderate label text.
              color: burdenColor == LoanPalTheme.burdenModerate
                  ? Colors.brown.shade800
                  : burdenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
