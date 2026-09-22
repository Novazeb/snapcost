import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../features/expenses/data/models/expense_model.dart';

class ExportService {
  static String generateCSV(List<ExpenseModel> expenses) {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'ID Transaksi',
      'Tanggal',
      'Waktu',
      'Nama Toko / Merchant',
      'Kategori',
      'Nominal (Rp)',
      'Metode Pembayaran',
      'Catatan',
    ]);

    // Data rows
    for (final exp in expenses) {
      final categoryLabel = exp.getCategory().name;
      final dateStr = DateFormat('yyyy-MM-dd').format(exp.date);
      final timeStr = DateFormat('HH:mm').format(exp.date);

      rows.add([
        exp.id,
        dateStr,
        timeStr,
        exp.merchant,
        categoryLabel,
        exp.amount,
        exp.payment_method,
        exp.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
