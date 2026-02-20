import 'package:mobile_reporting/application_store.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  static String getCurrencySymbol() {
    final lang = application.accountLang ?? application.lang;
    switch (lang) {
      case 'ka':
        return '₾';
      case 'en':
        return '\$';
      case 'ru':
        return '₽'; // Russian Ruble
      case 'az':
        return '₼'; // Azerbaijani Manat
      default:
        return '₾';
    }
  }

  static String format(double value) {
    final symbol = getCurrencySymbol();
    final formatted = NumberFormat('#,##0.00', 'en_US').format(value);
    return '$symbol$formatted';
  }
}
