import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currencySymbol = 'Rp ', int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = 'Rp '}) {
    if (amount >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static double? parseCleanDouble(String text) {
    if (text.isEmpty) return null;

    // Remove Rp, $, commas, spaces, etc.
    String cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    if (cleanText.isEmpty) return null;

    // Handle Indonesian format like 150.000,00 or 150,000.00
    if (cleanText.contains('.') && cleanText.contains(',')) {
      if (cleanText.lastIndexOf('.') < cleanText.lastIndexOf(',')) {
        // e.g. 1.500,00 -> 1500.00
        cleanText = cleanText.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // e.g. 1,500.00 -> 1500.00
        cleanText = cleanText.replaceAll(',', '');
      }
    } else if (cleanText.contains('.')) {
      final parts = cleanText.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        // Thousands separator like 150.000
        cleanText = cleanText.replaceAll('.', '');
      }
    } else if (cleanText.contains(',')) {
      final parts = cleanText.split(',');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        // Thousands separator like 150,000
        cleanText = cleanText.replaceAll(',', '');
      } else {
        cleanText = cleanText.replaceAll(',', '.');
      }
    }

    return double.tryParse(cleanText);
  }
}
