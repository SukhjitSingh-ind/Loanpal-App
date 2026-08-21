class CurrencyUtils {
  // INFO: Indian numbering: last 3 digits form the first group, then groups of 2
  // (e.g., 10,00,000 not 1,000,000). Implemented without the 'intl' package.
  static String formatINR(double amount) {
    final bool isNegative = amount < 0;
    amount = amount.abs();

    final String amountStr = amount.toStringAsFixed(2);
    final List<String> parts = amountStr.split('.');
    String integerPart = parts[0];
    final String decimalPart = parts[1];

    String formattedInteger;
    final int length = integerPart.length;

    if (length <= 3) {
      formattedInteger = integerPart;
    } else {
      final String lastThree = integerPart.substring(length - 3);
      String remaining = integerPart.substring(0, length - 3);

      final List<String> chunks = [];
      while (remaining.length > 2) {
        chunks.add(remaining.substring(remaining.length - 2));
        remaining = remaining.substring(0, remaining.length - 2);
      }
      if (remaining.isNotEmpty) {
        chunks.add(remaining);
      }

      formattedInteger = '${chunks.reversed.join(',')},$lastThree';
    }

    final String sign = isNegative ? '-' : '';
    return '₹$sign$formattedInteger.$decimalPart';
  }

  static String formatINRCompact(double amount) {
    final String formatted = formatINR(amount);
    if (formatted.endsWith('.00')) {
      return formatted.substring(0, formatted.length - 3);
    }
    return formatted;
  }
}
