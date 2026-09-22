import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isAtSameMomentAs(today)) {
      return 'Hari Ini';
    } else if (targetDate.isAtSameMomentAs(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    }
  }

  static DateTime? parseDateString(String input) {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) return null;

    final formats = [
      'dd/MM/yyyy',
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'dd.MM.yyyy',
      'dd.MM.yy',
      'dd/MM/yy',
      'd MMM yyyy',
      'dd MMM yyyy',
    ];

    for (final fmt in formats) {
      try {
        final parsed = DateFormat(fmt, 'id_ID').parseStrict(cleanInput);
        return parsed;
      } catch (_) {
        try {
          final parsedEn = DateFormat(fmt, 'en_US').parseStrict(cleanInput);
          return parsedEn;
        } catch (_) {}
      }
    }
    return null;
  }
}
