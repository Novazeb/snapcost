import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../core/utils/receipt_parser.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<ParsedReceiptData> processImage(String imagePath) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final inputImage = InputImage.fromFilePath(imagePath);
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
        final String fullText = recognizedText.text;

        if (fullText.trim().isNotEmpty) {
          return ReceiptParser.parse(fullText);
        }
      }
    } catch (e) {
      debugPrint('ML Kit OCR error: $e');
    }

    // Interactive Demo Sample Receipt Text if on web, desktop, or fallback
    final mockOcrText = '''
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
KODE STRUK: ALFA-99218274
TERIMA KASIH TELAH BERBELANJA
    ''';

    return ReceiptParser.parse(mockOcrText);
  }

  static Future<ParsedReceiptData> processMockSample({
    required String merchant,
    required double totalAmount,
    required String category,
  }) async {
    final now = DateTime.now();
    final mockOcrText = '''
$merchant
JL. FINTECH BOULEVARD NO. 88
----------------------------------------
DESKRIPSI BELANJA
TOTAL BELANJA: Rp ${totalAmount.toStringAsFixed(0)}
----------------------------------------
TOTAL BAYAR                  ${totalAmount.toStringAsFixed(0)}
TGL: ${now.day}/${now.month}/${now.year}
TERIMA KASIH
    ''';

    return ReceiptParser.parse(mockOcrText);
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
