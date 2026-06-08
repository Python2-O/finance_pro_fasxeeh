import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  static String currency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${AppConstants.currencySymbol} ${formatter.format(amount)}';
  }

  static String currencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.currencySymbol} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${AppConstants.currencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount);
  }

  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String shortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String dayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String monthName(int month) {
    return DateFormat('MMMM').format(DateTime(2025, month));
  }
}
