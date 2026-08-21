import 'package:flutter/material.dart';
import 'package:loanpal/logic/emi_calculator.dart';
import 'package:loanpal/ui/theme.dart';
import 'package:loanpal/widgets/input_slider.dart';
import 'package:loanpal/widgets/result_card.dart';
import 'package:loanpal/widgets/principal_interest_bar.dart';
import 'package:loanpal/widgets/burden_indicator.dart';
import 'package:loanpal/widgets/amortization_table.dart';
import 'package:loanpal/logic/app_config.dart';
import 'package:loanpal/ui/admin_dashboard_screen.dart';

enum TenureType { months, years }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _principal = 300000;
  double _apr = 8.5;

  // INFO: Tenure is always stored as months internally. Years/months is a
  // display-only toggle; switching units does not reset the loan tenure.
  int _tenureMonths = 180;
  TenureType _tenureType = TenureType.years;

  late EMICalculationModel _model;

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();

  final AppConfig _config = AppConfig();

  @override
  void initState() {
    super.initState();
    _config.addListener(_onConfigChanged);
    _syncTenureWithConfig();
    _calculate();
  }

  void _onConfigChanged() {
    setState(() {
      _syncTenureWithConfig();
      // Ensure values don't exceed new max limits
      if (_principal > _config.maxPrincipal) _principal = _config.maxPrincipal;
      if (_apr > _config.maxApr) _apr = _config.maxApr;
      _calculate();
    });
  }

  void _syncTenureWithConfig() {
    if (_config.allowedTenure == AllowedTenure.monthsOnly) {
      _tenureType = TenureType.months;
    } else if (_config.allowedTenure == AllowedTenure.yearsOnly) {
      _tenureType = TenureType.years;
    }
  }

  @override
  void dispose() {
    _config.removeListener(_onConfigChanged);
    _mainScrollController.dispose();
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _model = EMICalculationModel(
        principal: _principal,
        annualRate: _apr,
        tenureMonths: _tenureMonths,
      );
    });
  }

  double get _displayTenure {
    if (_tenureType == TenureType.years) {
      return _tenureMonths / 12.0;
    }
    return _tenureMonths.toDouble();
  }

  void _updateTenure(double value) {
    if (_tenureType == TenureType.years) {
      _tenureMonths = (value * 12).round();
    } else {
      _tenureMonths = value.round();
    }
    _calculate();
  }

  void _toggleTenureType(Set<TenureType> newSelection) {
    if (newSelection.isNotEmpty) {
      setState(() {
        _tenureType = newSelection.first;
      });
      // INFO: Switching tenure units only changes the display; _tenureMonths is
      // unchanged, so no recalculation is needed.
    }
  }

  void _showPinDialog() {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Access'),
          content: TextField(
            controller: pinController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter PIN'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (pinController.text == '1234') {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect PIN')),
                  );
                }
              },
              child: const Text('LOGIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double tenureMax = _tenureType == TenureType.years ? 30.0 : 360.0;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _showPinDialog,
          child: const Text('LoanPal', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: LoanPalTheme.primaryNavy,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 800;

            final Widget inputSection = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputSlider(
                  label: 'Principal Amount',
                  value: _principal,
                  min: 1000,
                  max: _config.maxPrincipal,
                  prefix: '₹',
                  onChanged: (val) {
                    _principal = val;
                    _calculate();
                  },
                ),
                const SizedBox(height: 16),
                InputSlider(
                  label: 'Interest Rate (APR)',
                  value: _apr,
                  min: 0,
                  max: _config.maxApr,
                  divisions: (_config.maxApr * 10).toInt(),
                  suffix: '%',
                  isPercentage: true,
                  onChanged: (val) {
                    _apr = val;
                    _calculate();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tenure',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (_config.allowedTenure == AllowedTenure.both)
                      SegmentedButton<TenureType>(
                        segments: const [
                          ButtonSegment(value: TenureType.months, label: Text('Months')),
                          ButtonSegment(value: TenureType.years, label: Text('Years')),
                        ],
                        selected: {_tenureType},
                        onSelectionChanged: _toggleTenureType,
                        style: SegmentedButton.styleFrom(
                          selectedForegroundColor: Colors.white,
                          selectedBackgroundColor: LoanPalTheme.primaryNavy,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                InputSlider(
                  label: '',
                  value: _displayTenure,
                  min: 1,
                  max: tenureMax,
                  suffix: _tenureType == TenureType.years ? ' Yrs' : ' Mos',
                  onChanged: _updateTenure,
                ),
              ],
            );

            final Widget resultSection = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultCard(
                  emi: _model.emi,
                  totalPayable: _model.totalPayable,
                  totalInterest: _model.totalInterest,
                ),
                const SizedBox(height: 8),
                PrincipalInterestBar(
                  principalPercentage: _model.principalPercentage,
                  interestPercentage: _model.interestPercentage,
                ),
                const SizedBox(height: 24),
                BurdenIndicator(
                  burdenLevel: _model.burdenLevel,
                  interestPercentage: _model.interestPercentage,
                ),
              ],
            );

            final Widget content = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _leftScrollController,
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              inputSection,
                              const SizedBox(height: 32),
                              resultSection,
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _rightScrollController,
                          padding: const EdgeInsets.all(24.0),
                          child: AmortizationTable(rows: _model.amortizationRows),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    controller: _mainScrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        inputSection,
                        const SizedBox(height: 24),
                        resultSection,
                        const SizedBox(height: 32),
                        AmortizationTable(rows: _model.amortizationRows),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}
