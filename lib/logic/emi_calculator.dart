import 'dart:math';

enum BurdenLevel { low, moderate, high, heavy }

class AmortizationRow {
  final int month;
  final double openingBalance;
  final double emi;
  final double interest;
  final double principal;
  final double closingBalance;

  const AmortizationRow({
    required this.month,
    required this.openingBalance,
    required this.emi,
    required this.interest,
    required this.principal,
    required this.closingBalance,
  });
}

class EMICalculationModel {
  final double principal;
  final double annualRate;
  final int tenureMonths;

  late final double monthlyRate;
  late final double emi;
  late final double totalPayable;
  late final double totalInterest;
  late final double principalPercentage;
  late final double interestPercentage;
  late final double interestBurden;
  late final BurdenLevel burdenLevel;
  late final List<AmortizationRow> amortizationRows;

  EMICalculationModel({
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
  }) {
    _calculate();
  }

  void _calculate() {
    monthlyRate = annualRate / 1200.0;

    if (annualRate == 0) {
      // INFO: Zero-interest case: EMI is a flat equal principal repayment.
      emi = tenureMonths > 0 ? principal / tenureMonths : 0;
    } else {
      if (tenureMonths == 0) {
        emi = 0;
      } else {
        // INFO: Standard EMI formula: [P × r × (1+r)^n] / [(1+r)^n − 1]
        // where r = monthly rate and n = tenure in months.
        final double factor = pow(1 + monthlyRate, tenureMonths).toDouble();
        emi = (principal * monthlyRate * factor) / (factor - 1);
      }
    }

    final List<AmortizationRow> rows = [];
    double balance = principal;
    double accumulatedInterest = 0;

    for (int month = 1; month <= tenureMonths; month++) {
      final double interestForMonth = balance * monthlyRate;
      final double principalForMonth;
      final double finalEmi;
      final double closingBalance;

      if (month == tenureMonths) {
        // INFO: On the final payment, the principal repaid equals the exact
        // remaining balance to guarantee a closing balance of ₹0.00.
        // The last EMI is adjusted slightly to absorb any floating-point drift.
        principalForMonth = balance;
        finalEmi = principalForMonth + interestForMonth;
        closingBalance = 0.0;
      } else {
        principalForMonth = emi - interestForMonth;
        finalEmi = emi;
        // INFO: Guard against tiny negative balances from floating-point drift
        // before the final-month adjustment takes effect.
        closingBalance = (balance - principalForMonth).clamp(0.0, double.infinity);
      }

      accumulatedInterest += interestForMonth;
      rows.add(AmortizationRow(
        month: month,
        openingBalance: balance,
        emi: finalEmi,
        interest: interestForMonth,
        principal: principalForMonth,
        closingBalance: closingBalance,
      ));
      balance = closingBalance;
    }

    amortizationRows = rows;
    totalInterest = accumulatedInterest;
    totalPayable = principal + totalInterest;

    if (totalPayable > 0) {
      principalPercentage = (principal / totalPayable) * 100;
      interestPercentage = (totalInterest / totalPayable) * 100;
    } else {
      principalPercentage = 100;
      interestPercentage = 0;
    }

    // INFO: Interest burden is the fraction of total payable that is interest,
    // expressed as a percentage. Thresholds: Low <25%, Moderate 25–<40%,
    // High 40–<60%, Heavy ≥60%.
    interestBurden = interestPercentage;

    if (interestBurden < 25) {
      burdenLevel = BurdenLevel.low;
    } else if (interestBurden < 40) {
      burdenLevel = BurdenLevel.moderate;
    } else if (interestBurden < 60) {
      burdenLevel = BurdenLevel.high;
    } else {
      burdenLevel = BurdenLevel.heavy;
    }
  }
}
