import 'package:flutter/foundation.dart';
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
import 'package:loanpal/services/auth_service.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/user_profile_service.dart';

enum TenureType { months, years }

class CalculatorScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final Future<void> Function()? onSignOut;

  const CalculatorScreen({super.key, this.userProfile, this.onSignOut});

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
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.userProfile ?? UserProfileService().currentProfile;
    if (_profile == null) {
      _loadProfile();
    }
    _config.addListener(_onConfigChanged);
    _syncTenureWithConfig();
    _calculate();
  }

  @override
  void didUpdateWidget(covariant CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userProfile != oldWidget.userProfile &&
        widget.userProfile != null) {
      setState(() {
        _profile = widget.userProfile;
      });
    }
  }

  Future<void> _loadProfile() async {
    final user = AuthService().currentUser;
    if (user != null) {
      try {
        final p = await UserProfileService().getUserProfile(user.uid);
        if (mounted && p != null) {
          setState(() => _profile = p);
        }
      } catch (_) {}
    }
  }

  String get _greetingTitle {
    if (_profile != null && _profile!.firstName.isNotEmpty) {
      return 'Hi, ${_profile!.firstName}!';
    }
    final user = AuthService().currentUser;
    final displayName = user?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return 'Hi, ${displayName.split(' ').first}!';
    }
    if (_profile != null && _profile!.username.isNotEmpty) {
      return 'Hi, ${_profile!.username}!';
    }
    final email = user?.email;
    if (email != null) {
      return 'Welcome, $email';
    }
    return 'Welcome to LoanPal';
  }

  String get _greetingSubtitle => 'Smart EMI & Loan Planner';

  String get _avatarLetter {
    if (_profile != null && _profile!.firstName.isNotEmpty) {
      return _profile!.firstName[0].toUpperCase();
    }
    final user = AuthService().currentUser;
    final displayName = user?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    if (_profile != null && _profile!.username.isNotEmpty) {
      return _profile!.username[0].toUpperCase();
    }
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'L';
  }

  void _onConfigChanged() {
    setState(() {
      _syncTenureWithConfig();
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

  void _openDevDashboard() {
    // INFO: The admin dashboard modifies in-memory AppConfig for local developer
    // testing only. Access is restricted to debug builds (kDebugMode).
    if (!kDebugMode) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Developer Settings'),
          content: const Text(
            'Open local developer configuration to adjust in-memory slider limits? (Debug mode only)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
              child: const Text('OPEN'),
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
          onLongPress: kDebugMode ? _openDevDashboard : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/loanpal_logo.png',
                height: 28,
                width: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text(
                'LoanPal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: LoanPalTheme.primaryNavy,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text(
                    'Are you sure you want to sign out of LoanPal?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('SIGN OUT'),
                    ),
                  ],
                ),
              );
              if (shouldSignOut == true) {
                if (widget.onSignOut != null) {
                  await widget.onSignOut!();
                } else {
                  await AuthService().signOut();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 800;

            final Widget greetingSection = Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: LoanPalTheme.outlineColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: LoanPalTheme.primaryNavy.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      _avatarLetter,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: LoanPalTheme.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _greetingTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: LoanPalTheme.textMain,
                          ),
                        ),
                        if (_greetingSubtitle.isNotEmpty)
                          Text(
                            _greetingSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: LoanPalTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final Widget inputSection = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                greetingSection,
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
                          ButtonSegment(
                            value: TenureType.months,
                            label: Text('Months'),
                          ),
                          ButtonSegment(
                            value: TenureType.years,
                            label: Text('Years'),
                          ),
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
                          child: AmortizationTable(
                            rows: _model.amortizationRows,
                          ),
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
