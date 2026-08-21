import 'package:flutter/material.dart';
import 'package:loanpal/utils/currency_utils.dart';
import 'package:loanpal/ui/theme.dart';

class ResultCard extends StatelessWidget {
  final double emi;
  final double totalPayable;
  final double totalInterest;

  const ResultCard({
    super.key,
    required this.emi,
    required this.totalPayable,
    required this.totalInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Monthly EMI',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatINRCompact(emi),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: LoanPalTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: LoanPalTheme.outlineColor, thickness: 0.5),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubMetric(context, 'Total Payable', totalPayable),
                Container(
                  width: 1,
                  height: 40,
                  color: LoanPalTheme.outlineColor.withValues(alpha: 0.5),
                ),
                _buildSubMetric(context, 'Total Interest', totalInterest),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(BuildContext context, String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatINRCompact(value),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
