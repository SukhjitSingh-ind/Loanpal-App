import 'package:flutter/foundation.dart';

enum AllowedTenure { both, monthsOnly, yearsOnly }

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  AllowedTenure _allowedTenure = AllowedTenure.both;
  double _maxPrincipal = 10000000;
  double _maxApr = 35.0;

  AllowedTenure get allowedTenure => _allowedTenure;
  double get maxPrincipal => _maxPrincipal;
  double get maxApr => _maxApr;

  void updateConfig({
    AllowedTenure? allowedTenure,
    double? maxPrincipal,
    double? maxApr,
  }) {
    if (allowedTenure != null) _allowedTenure = allowedTenure;
    if (maxPrincipal != null) _maxPrincipal = maxPrincipal;
    if (maxApr != null) _maxApr = maxApr;

    notifyListeners();
  }
}
