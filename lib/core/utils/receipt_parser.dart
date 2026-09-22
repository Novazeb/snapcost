import 'currency_formatter.dart';
import 'date_formatter.dart';

class ParsedReceiptData {
  final String merchantName;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String rawText;

  ParsedReceiptData({
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.rawText,
  });
}

class ReceiptParser {
  static ParsedReceiptData parse(String ocrText) {
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = extractMerchant(lines);
    final amount = extractTotalAmount(lines);
    final date = extractDate(ocrText);
    final category = detectCategory(merchant, ocrText);

    return ParsedReceiptData(
      merchantName: merchant,
      amount: amount,
      date: date,
      categoryId: category,
      rawText: ocrText,
    );
  }

  static String extractMerchant(List<String> lines) {
    if (lines.isEmpty) return 'Toko / Resto';

    final ignoreKeywords = [
      'SELAMAT DATANG', 'WELCOME', 'NOTA', 'STRUK', 'RECEIPT', 'TAX INVOICE',
      'CASHIER', 'KASIR', 'TELP', 'TEL:', 'JL.', 'JALAN', 'SIMPAN STRUK',
      'NPWP', 'BUKTI PEMBAYARAN', 'INVOICE'
    ];

    for (int i = 0; i < lines.length && i < 6; i++) {
      final line = lines[i].toUpperCase();
      bool shouldIgnore = false;

      for (final kw in ignoreKeywords) {
        if (line.contains(kw)) {
          shouldIgnore = true;
          break;
        }
      }

      // Check if line contains digits only or looks like phone number
      if (RegExp(r'^\d+$').hasMatch(line) || RegExp(r'^\+?\d[\d\s-]{6,}$').hasMatch(line)) {
        shouldIgnore = true;
      }

      if (!shouldIgnore && lines[i].length >= 3) {
        return _formatTitleCase(lines[i]);
      }
    }

    return _formatTitleCase(lines.first);
  }

  static double extractTotalAmount(List<String> lines) {
    final totalKeywords = [
      'GRAND TOTAL', 'TOTAL BAYAR', 'TOTAL BELANJA', 'TOTAL DIBAYAR',
      'TOTAL NETTO', 'NET TOTAL', 'TOTAL', 'BAYAR', 'AMOUNT DUE', 'SUM', 'CASH'
    ];

    double highestKeywordAmount = 0.0;
    double maxFallbackAmount = 0.0;

    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final upperLine = line.toUpperCase();

      for (final kw in totalKeywords) {
        if (upperLine.contains(kw)) {
          // Extract amount from this line or next line
          final amount = _parseAmountFromLine(line) ??
              (i + 1 < lines.length ? _parseAmountFromLine(lines[i + 1]) : null);
          if (amount != null && amount > 0) {
            if (amount > highestKeywordAmount) {
              highestKeywordAmount = amount;
            }
          }
        }
      }

      final parsedFallback = _parseAmountFromLine(line);
      if (parsedFallback != null && parsedFallback > maxFallbackAmount) {
        maxFallbackAmount = parsedFallback;
      }
    }

    if (highestKeywordAmount > 0) return highestKeywordAmount;
    if (maxFallbackAmount > 0) return maxFallbackAmount;

    return 0.0;
  }

  static double? _parseAmountFromLine(String line) {
    final regex = RegExp(r'(?:Rp|USD|\$)?\s*([\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?])', caseSensitive: false);
    final matches = regex.allMatches(line);

    for (final match in matches) {
      final matchStr = match.group(1);
      if (matchStr != null) {
        final val = CurrencyFormatter.parseCleanDouble(matchStr);
        if (val != null && val >= 500 && val < 500000000) {
          return val;
        }
      }
    }
    return null;
  }

  static DateTime extractDate(String text) {
    // Regular expressions for various date formats
    final dateRegexes = [
      RegExp(r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b'),
      RegExp(r'\b(\d{4})[/.-](\d{1,2})[/.-](\d{1,2})\b'),
      RegExp(r'\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|Mei|Jun|Jul|Ags|Sep|Okt|Nov|Des)[a-z]*\s+(\d{2,4})\b', caseSensitive: false),
    ];

    for (final regex in dateRegexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final parsed = DateFormatter.parseDateString(match.group(0)!);
        if (parsed != null && parsed.year >= 2000 && parsed.year <= DateTime.now().year + 1) {
          return parsed;
        }
      }
    }

    return DateTime.now();
  }

  static String detectCategory(String merchant, String ocrText) {
    final text = '$merchant $ocrText'.toUpperCase();

    if (text.contains('ALFAMART') ||
        text.contains('INDOMARET') ||
        text.contains('SUPERINDO') ||
        text.contains('HYPERMART') ||
        text.contains('CARREFOUR') ||
        text.contains('LOTTE') ||
        text.contains('MINIMARKET') ||
        text.contains('GROCERY')) {
      return 'groceries';
    } else if (text.contains('STARBUCKS') ||
        text.contains('RESTO') ||
        text.contains('WARUNG') ||
        text.contains('CAFE') ||
        text.contains('KEDAI') ||
        text.contains('COFFEE') ||
        text.contains('MCDONALD') ||
        text.contains('KFC') ||
        text.contains('PIZZA') ||
        text.contains('MAKAN')) {
      return 'food';
    } else if (text.contains('PERTAMINA') ||
        text.contains('SHELL') ||
        text.contains('BP') ||
        text.contains('BENSIN') ||
        text.contains('PARKIR') ||
        text.contains('TOL') ||
        text.contains('GOJEK') ||
        text.contains('GRAB') ||
        text.contains('TRANSPORT')) {
      return 'transport';
    } else if (text.contains('PLN') ||
        text.contains('PDAM') ||
        text.contains('TELKOM') ||
        text.contains('INDIHOME') ||
        text.contains('BIZZ') ||
        text.contains('LISTRIK') ||
        text.contains('PULSA') ||
        text.contains('WATER')) {
      return 'bills';
    } else if (text.contains('CINEMA') ||
        text.contains('CGV') ||
        text.contains('XXI') ||
        text.contains('TIKET') ||
        text.contains('GAME') ||
        text.contains('PLAYSTATION')) {
      return 'entertainment';
    } else if (text.contains('APOTEK') ||
        text.contains('KIMIA FARMA') ||
        text.contains('K-24') ||
        text.contains('HOSPITAL') ||
        text.contains('RUMAH SAKIT') ||
        text.contains('KLINIK') ||
        text.contains('HEALTH')) {
      return 'health';
    }

    return 'shopping';
  }

  static String _formatTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
