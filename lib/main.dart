import 'package:flutter/material.dart';
import 'package:loanpal/ui/theme.dart';
import 'package:loanpal/ui/calculator_screen.dart';

void main() {
  runApp(const LoanPalApp());
}

class LoanPalApp extends StatelessWidget {
  const LoanPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoanPal',
      debugShowCheckedModeBanner: false,
      theme: LoanPalTheme.lightTheme,
      home: const CalculatorScreen(),
    );
  }
}
