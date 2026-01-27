import 'package:mobile_reporting/application_store.dart';

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
}
