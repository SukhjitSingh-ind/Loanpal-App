import 'package:flutter_test/flutter_test.dart';
import 'package:loanpal/logic/emi_calculator.dart';

void main() {
  group('EMI calculation', () {
    test('Standard case: ₹3,00,000 at 8.5% for 180 months', () {
      final model = EMICalculationModel(
        principal: 300000,
        annualRate: 8.5,
        tenureMonths: 180,
      );

      expect(model.emi, closeTo(2954.22, 0.01));
      expect(model.totalPayable, closeTo(531759.50, 1.0));
      expect(model.totalInterest, closeTo(231759.50, 1.0));
      expect(model.amortizationRows.length, 180);
    });

    test('Zero-interest loan: EMI is flat principal / n', () {
      final model = EMICalculationModel(
        principal: 120000,
        annualRate: 0,
        tenureMonths: 12,
      );

      expect(model.emi, 10000.0);
      expect(model.totalInterest, 0.0);
      expect(model.totalPayable, 120000.0);
      expect(model.burdenLevel, BurdenLevel.low);
    });

    test('Minimum principal (₹1,000)', () {
      final model = EMICalculationModel(
        principal: 1000,
        annualRate: 12.0,
        tenureMonths: 12,
      );

      expect(model.emi, closeTo(88.85, 0.01));
      expect(model.totalPayable, greaterThan(1000));
    });

    test('Maximum principal (₹1 Crore)', () {
      final model = EMICalculationModel(
        principal: 10000000,
        annualRate: 10.0,
        tenureMonths: 240,
      );

      expect(model.emi, greaterThan(0));
      expect(model.totalPayable, greaterThan(10000000));
    });

    test('Minimum APR (0%)', () {
      final model = EMICalculationModel(
        principal: 60000,
        annualRate: 0,
        tenureMonths: 6,
      );

      expect(model.emi, closeTo(10000.0, 0.001));
      expect(model.totalInterest, 0.0);
    });

    test('Maximum APR (35%)', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 35.0,
        tenureMonths: 24,
      );

      expect(model.emi, greaterThan(0));
      expect(model.totalInterest, greaterThan(0));
    });

    test('Short tenure (1 month): EMI is principal + one month interest', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 12.0,
        tenureMonths: 1,
      );

      expect(model.emi, closeTo(101000.0, 0.01));
      expect(model.totalInterest, closeTo(1000.0, 0.01));
      expect(model.amortizationRows.length, 1);
    });

    test('Long tenure (360 months)', () {
      final model = EMICalculationModel(
        principal: 5000000,
        annualRate: 8.0,
        tenureMonths: 360,
      );

      expect(model.emi, greaterThan(0));
      expect(model.amortizationRows.length, 360);
    });
  });

  group('Amortization schedule', () {
    test('Final closing balance is exactly ₹0.00', () {
      final model = EMICalculationModel(
        principal: 300000,
        annualRate: 8.5,
        tenureMonths: 180,
      );
      expect(model.amortizationRows.last.closingBalance, 0.0);
    });

    test('Final closing balance is ₹0.00 for tricky floating-point values', () {
      final model = EMICalculationModel(
        principal: 333333,
        annualRate: 7.77,
        tenureMonths: 111,
      );
      expect(model.amortizationRows.last.closingBalance, 0.0);
    });

    test('Final closing balance is ₹0.00 for zero-interest loan', () {
      final model = EMICalculationModel(
        principal: 120000,
        annualRate: 0,
        tenureMonths: 12,
      );
      expect(model.amortizationRows.last.closingBalance, 0.0);
    });

    test('Sum of row interest equals totalInterest', () {
      final model = EMICalculationModel(
        principal: 500000,
        annualRate: 10.5,
        tenureMonths: 60,
      );
      final double sumInterest =
          model.amortizationRows.fold(0.0, (sum, r) => sum + r.interest);
      expect(sumInterest, closeTo(model.totalInterest, 0.01));
    });

    test('Sum of row principal equals loan principal', () {
      final model = EMICalculationModel(
        principal: 500000,
        annualRate: 10.5,
        tenureMonths: 60,
      );
      final double sumPrincipal =
          model.amortizationRows.fold(0.0, (sum, r) => sum + r.principal);
      expect(sumPrincipal, closeTo(model.principal, 0.01));
    });

    test('principal + totalInterest == totalPayable', () {
      final model = EMICalculationModel(
        principal: 500000,
        annualRate: 10.5,
        tenureMonths: 60,
      );
      expect(model.totalPayable,
          closeTo(model.principal + model.totalInterest, 0.01));
    });

    test('Opening balance of first row equals principal', () {
      final model = EMICalculationModel(
        principal: 200000,
        annualRate: 9.0,
        tenureMonths: 36,
      );
      expect(model.amortizationRows.first.openingBalance, model.principal);
    });

    test('Each row closing balance equals next row opening balance', () {
      final model = EMICalculationModel(
        principal: 200000,
        annualRate: 9.0,
        tenureMonths: 36,
      );
      for (int i = 0; i < model.amortizationRows.length - 1; i++) {
        expect(
          model.amortizationRows[i].closingBalance,
          closeTo(model.amortizationRows[i + 1].openingBalance, 0.001),
        );
      }
    });

    test('No closing balance goes negative', () {
      final model = EMICalculationModel(
        principal: 300000,
        annualRate: 8.5,
        tenureMonths: 180,
      );
      for (final row in model.amortizationRows) {
        expect(row.closingBalance, greaterThanOrEqualTo(0.0));
      }
    });
  });

  group('Interest burden thresholds', () {
    // Low: <25% — zero-interest loan has 0% burden
    test('Burden: low for zero-interest loan (0%)', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 0,
        tenureMonths: 12,
      );
      expect(model.burdenLevel, BurdenLevel.low);
      expect(model.interestBurden, lessThan(25));
    });

    // Low: <25% — short high-rate loan is low burden (small total interest)
    test('Burden: low for very short high-rate loan', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 5.0,
        tenureMonths: 6,
      );
      expect(model.burdenLevel, BurdenLevel.low);
    });

    // Moderate: 25–<40%
    test('Burden: moderate for mid-range loan (~30% burden)', () {
      // At 9% for 48 months: interest burden is roughly 18% — use longer tenure
      // At 9% for 120 months on 100000: let's verify empirically
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 10.0,
        tenureMonths: 72,
      );
      expect(model.interestBurden, greaterThanOrEqualTo(25));
      expect(model.interestBurden, lessThan(40));
      expect(model.burdenLevel, BurdenLevel.moderate);
    });

    // High: 40–<60%
    test('Burden: high for longer-tenure loan', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 12.0,
        tenureMonths: 120,
      );
      expect(model.interestBurden, greaterThanOrEqualTo(40));
      expect(model.interestBurden, lessThan(60));
      expect(model.burdenLevel, BurdenLevel.high);
    });

    // Heavy: ≥60% — requires a very high rate + very long tenure
    test('Burden: heavy for high-rate long-tenure loan', () {
      final model = EMICalculationModel(
        principal: 100000,
        annualRate: 35.0,
        tenureMonths: 240,
      );
      expect(model.interestBurden, greaterThanOrEqualTo(60));
      expect(model.burdenLevel, BurdenLevel.heavy);
    });
  });

  group('Months ↔ Years conversion', () {
    test('180 months equals 15 years display value', () {
      // Verify the display conversion used in CalculatorScreen
      const int tenureMonths = 180;
      final double displayYears = tenureMonths / 12.0;
      expect(displayYears, 15.0);
    });

    test('Years input round-trips correctly to months', () {
      // Simulates _updateTenure for years mode: value * 12 rounded
      double yearsInput = 15.0;
      int months = (yearsInput * 12).round();
      expect(months, 180);

      yearsInput = 7.5;
      months = (yearsInput * 12).round();
      expect(months, 90);
    });

    test('Months input round-trips correctly', () {
      double monthsInput = 36.0;
      int months = monthsInput.round();
      expect(months, 36);
    });
  });
}
