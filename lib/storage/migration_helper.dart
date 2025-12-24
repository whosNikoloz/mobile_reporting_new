import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_reporting/storage/hive_settings_service.dart';

class MigrationHelper {
  static Future<void> migrateFromSharedPreferences(
    HiveSettingsService hiveSettings,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Migrate company name
    final companyName = prefs.getString('company_name');
    if (companyName != null) {
      await hiveSettings.setCompanyName(companyName);
    }

    // Migrate language
    final lang = prefs.getString('lang');
    if (lang != null) {
      await hiveSettings.setLang(lang);
    }

    // Migrate type
    final type = prefs.getString('type');
    if (type != null) {
      await hiveSettings.setType(type);
    }

    // Migrate user name
    final userName = prefs.getString('user_name');
    if (userName != null) {
      await hiveSettings.setUserName(userName);
    }

    // Migrate auth token
    final authToken = prefs.getString('user_auth_token');
    if (authToken != null) {
      await hiveSettings.setUserAuthToken(authToken);
    }

    // Migrate email
    final email = prefs.getString('email');
    if (email != null) {
      await hiveSettings.setEmail(email);
    }

    // Migrate URL
    final url = prefs.getString('url');
    if (url != null) {
      await hiveSettings.setUrl(url);
    }

    // Migrate database
    final database = prefs.getString('database');
    if (database != null) {
      await hiveSettings.setDatabase(database);
    }

    // Set migration flag to avoid running again
    await prefs.setBool('migrated_to_hive', true);
  }

  static Future<bool> hasMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('migrated_to_hive') ?? false;
  }
}
