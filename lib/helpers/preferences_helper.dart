import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  Future<void> setCompanyName(String companyName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('company_name', companyName);
  }

  Future<void> clearCompanyName() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('company_name');
  }

  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('company_name');
  }

  Future<void> setLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lang', lang);
  }

  Future<void> clearLang() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('lang');
  }

  Future<String?> getLang() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('lang');
  }

  Future<void> setType(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('type', lang);
  }

  Future<void> clearType() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('type');
  }

  Future<String?> getType() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('type');
  }

  Future<void> setUserName(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', lang);
  }

  Future<void> clearUserName() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_name');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('user_name');
  }

  // PIN user (authenticated with pin code)
  Future<void> setPinUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pin_user_id', id);
  }

  Future<int?> getPinUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pin_user_id');
  }

  Future<void> clearPinUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_user_id');
  }

  Future<void> setPinUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_user_name', name);
  }

  Future<String?> getPinUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pin_user_name');
  }

  Future<void> clearPinUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_user_name');
  }

  Future<void> setUserAuthToken(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_auth_token', lang);
  }

  Future<void> clearUserAuthToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_auth_token');
  }

  Future<String?> getUserAuthToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('user_auth_token');
  }

  Future<void> setEmail(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', lang);
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('email');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('email');
  }

  Future<void> setUrl(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('url', lang);
  }

  Future<void> clearUrl() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('url');
  }

  Future<String?> getUrl() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('url');
  }

  Future<void> setDatabase(String database) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('database', database);
  }

  Future<void> clearDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('database');
  }

  Future<String?> getDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('database');
  }

  Future<void> setAccountLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_lang', lang);
  }

  Future<void> clearAccountLang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_lang');
  }

  Future<String?> getAccountLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('account_lang');
  }

  // Unified Report Filters

  Future<void> setSelectedStoreId(int? storeId) async {
    final prefs = await SharedPreferences.getInstance();
    if (storeId == null) {
      await prefs.remove('selected_store_id');
    } else {
      await prefs.setInt('selected_store_id', storeId);
    }
  }

  Future<int?> getSelectedStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_store_id');
  }

  Future<void> setReportDateType(String dateType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('report_date_type', dateType);
  }

  Future<String?> getReportDateType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('report_date_type');
  }

  Future<void> setReportPeriod(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('report_start_date', start.toIso8601String());
    await prefs.setString('report_end_date', end.toIso8601String());
  }

  Future<(String?, String?)> getReportPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getString('report_start_date'),
      prefs.getString('report_end_date')
    );
  }

  Future<void> setReportCompareDateType(String dateType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('report_compare_date_type', dateType);
  }

  Future<String?> getReportCompareDateType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('report_compare_date_type');
  }

  Future<void> setReportComparePeriod(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'report_compare_start_date', start.toIso8601String());
    await prefs.setString('report_compare_end_date', end.toIso8601String());
  }

  Future<(String?, String?)> getReportComparePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getString('report_compare_start_date'),
      prefs.getString('report_compare_end_date')
    );
  }
}
