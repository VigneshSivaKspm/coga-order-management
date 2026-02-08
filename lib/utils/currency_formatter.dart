import 'package:intl/intl.dart';

/// Utility class for formatting currency in the application
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Indian Rupee symbol
  static const String rupeeSymbol = '₹';

  /// Number format for Indian currency with commas
  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: rupeeSymbol,
    decimalDigits: 2,
  );

  /// Number format without decimal places
  static final NumberFormat _indianFormatNoDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: rupeeSymbol,
    decimalDigits: 0,
  );

  /// Compact number format for large values
  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: rupeeSymbol,
  );

  /// Formats a number to Indian Rupee format: ₹1,234.56
  static String format(num? amount) {
    if (amount == null) return '${rupeeSymbol}0.00';
    return _indianFormat.format(amount);
  }

  /// Formats a number to Indian Rupee format without decimals: ₹1,234
  static String formatNoDecimal(num? amount) {
    if (amount == null) return '${rupeeSymbol}0';
    return _indianFormatNoDecimal.format(amount);
  }

  /// Formats a number to compact format: ₹1.2K, ₹1.5L
  static String formatCompact(num? amount) {
    if (amount == null) return '${rupeeSymbol}0';
    return _compactFormat.format(amount);
  }

  /// Formats a string price to Indian Rupee format
  /// Handles strings like "1234.56", "₹1234", "1,234.56"
  static String formatString(String? price) {
    if (price == null || price.isEmpty) return '${rupeeSymbol}0.00';

    // Remove any existing currency symbols and commas
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleanPrice);

    if (amount == null) return '${rupeeSymbol}0.00';
    return format(amount);
  }

  /// Parses a formatted price string to double
  /// Handles strings like "₹1,234.56", "1234.56", "1,234"
  static double parse(String? price) {
    if (price == null || price.isEmpty) return 0.0;

    // Remove any currency symbols, spaces, and commas
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Formats amount with custom decimal places
  static String formatWithDecimals(num? amount, int decimalDigits) {
    if (amount == null) return '${rupeeSymbol}0';

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: rupeeSymbol,
      decimalDigits: decimalDigits,
    );

    return format.format(amount);
  }

  /// Formats amount without the rupee symbol
  static String formatWithoutSymbol(num? amount) {
    if (amount == null) return '0.00';

    final format = NumberFormat('#,##,##0.00', 'en_IN');
    return format.format(amount);
  }

  /// Adds commas to a number for Indian format (lakhs, crores)
  static String addIndianCommas(num? amount) {
    if (amount == null) return '0';

    final format = NumberFormat('#,##,##0', 'en_IN');
    return format.format(amount);
  }

  /// Calculates and formats percentage
  static String formatPercentage(num? value, num? total) {
    if (value == null || total == null || total == 0) return '0%';

    final percentage = (value / total) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Formats price with quantity: "₹100 × 2 = ₹200"
  static String formatWithQuantity(num price, int quantity) {
    final total = price * quantity;
    return '$rupeeSymbol${price.toStringAsFixed(0)} × $quantity = ${format(total)}';
  }

  /// Gets price from various formats (String, int, double)
  static double getPrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return parse(value);
    return 0.0;
  }
}
