import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loanpal/ui/calculator_screen.dart';
import 'package:loanpal/ui/theme.dart';

void main() {
  testWidgets('CalculatorScreen renders LoanPal title and sliders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LoanPalTheme.lightTheme,
        home: const CalculatorScreen(),
      ),
    );

    expect(find.text('LoanPal'), findsOneWidget);
    expect(find.text('Principal Amount'), findsOneWidget);
    expect(find.text('Interest Rate (APR)'), findsOneWidget);
  });
}
