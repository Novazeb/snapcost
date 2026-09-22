import 'package:flutter_test/flutter_test.dart';
import 'package:snapcost/core/utils/currency_formatter.dart';
import 'package:snapcost/core/utils/receipt_parser.dart';

void main() {
  group('ReceiptParser Tests', () {
    test('Should correctly parse Alfamart receipt OCR text', () {
      final sampleOcr = '''
ALFAMART MERUYA
JL. MERUYA ILIR NO. 45, JAKARTA BARAT
TELP: 021-58901234
========================================
ALFA MILK 1L               1   24,500
ROTI TAWAR PREMIUM         1   16,000
CHITATO LITE 68G           2   22,000
MINERAL WATER 600ML        2    6,000
========================================
SUBTOTAL                       68,500
TAX 10%                         7,000
GRAND TOTAL                    75,500
CASH                           100,000
KEMBALI                        24,500
----------------------------------------
TGL: 09/08/2026 14:32  KASIR: ANDI
      ''';

      final result = ReceiptParser.parse(sampleOcr);

      expect(result.merchantName, equals('Alfamart Meruya'));
      expect(result.amount, equals(75500.0));
      expect(result.date.year, equals(2026));
      expect(result.date.month, equals(8));
      expect(result.date.day, equals(9));
      expect(result.categoryId, equals('groceries'));
    });

    test('Should correctly parse Starbucks receipt OCR text', () {
      final sampleOcr = '''
STARBUCKS RESERVE
PACIFIC PLACE JAKARTA
========================================
1 GR ICED AMERICANO           58,000
1 BLUEBERRY MUFFIN            35,000
========================================
TOTAL BELANJA                 93,000
BAYAR QRIS                    93,000
TGL: 15/07/2026
      ''';

      final result = ReceiptParser.parse(sampleOcr);

      expect(result.merchantName, equals('Starbucks Reserve'));
      expect(result.amount, equals(93000.0));
      expect(result.categoryId, equals('food'));
    });

    test('Should correctly parse currency strings', () {
      expect(CurrencyFormatter.parseCleanDouble('Rp 150.000'), equals(150000.0));
      expect(CurrencyFormatter.parseCleanDouble('75,500'), equals(75500.0));
      expect(CurrencyFormatter.parseCleanDouble('\$45.90'), equals(45.90));
    });
  });
}
