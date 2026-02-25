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

  static String format(
    double value, {
    bool showSymbol = true,
    bool showDecimals = true,
  }) {
    final symbol = getCurrencySymbol();

    final formatPattern = showDecimals ? '#,##0.00' : '#,##0';

    final formatted = NumberFormat(formatPattern, 'en_US').format(value);

    return showSymbol ? '$symbol$formatted' : formatted;
  }
}
