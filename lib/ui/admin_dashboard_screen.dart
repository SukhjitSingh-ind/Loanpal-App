import 'package:flutter/material.dart';
import 'package:loanpal/logic/app_config.dart';
import 'package:loanpal/ui/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AppConfig _config = AppConfig();

  late AllowedTenure _selectedTenure;
  late double _maxPrincipal;
  late double _maxApr;

  @override
  void initState() {
    super.initState();
    _selectedTenure = _config.allowedTenure;
    _maxPrincipal = _config.maxPrincipal;
    _maxApr = _config.maxApr;
  }

  void _saveConfig() {
    _config.updateConfig(
      allowedTenure: _selectedTenure,
      maxPrincipal: _maxPrincipal,
      maxApr: _maxApr,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin settings saved.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: LoanPalTheme.burdenHeavy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Global Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These settings apply to all users of the calculator.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            const Text(
              'Allowed Tenure Units',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AllowedTenure>(
              initialValue: _selectedTenure,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: AllowedTenure.both,
                  child: Text('Both (User can toggle Months/Years)'),
                ),
                DropdownMenuItem(
                  value: AllowedTenure.monthsOnly,
                  child: Text('Months Only'),
                ),
                DropdownMenuItem(
                  value: AllowedTenure.yearsOnly,
                  child: Text('Years Only'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedTenure = val);
                }
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Maximum Principal Amount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _maxPrincipal.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: '₹ ',
                helperText: 'Default is 10000000 (1 Crore)',
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null && parsed >= 1000) {
                  _maxPrincipal = parsed;
                }
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Maximum Interest Rate (APR)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _maxApr.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: '%',
                helperText: 'Default is 35.0',
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null && parsed > 0 && parsed <= 100) {
                  _maxApr = parsed;
                }
              },
            ),

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoanPalTheme.burdenHeavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAVE SETTINGS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
