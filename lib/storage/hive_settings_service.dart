import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile_reporting/storage/models/user_settings.dart';

class HiveSettingsService {
  static const String _settingsBoxName = 'user_settings';
  static const String _settingsKey = 'settings';
  static const String _storageFolderName = 'hive_storage';

  Box<UserSettings>? _settingsBox;

  Future<void> init() async {
    // Get the application documents directory
    final appDocDir = await getApplicationDocumentsDirectory();

    // Create a custom subdirectory for Hive storage
    final hiveStoragePath = Directory('${appDocDir.path}/$_storageFolderName');

    // Create the directory if it doesn't exist
    if (!await hiveStoragePath.exists()) {
      await hiveStoragePath.create(recursive: true);
    }

    // Initialize Hive with the custom path
    await Hive.initFlutter(_storageFolderName);

    // Register the adapter
    Hive.registerAdapter(UserSettingsAdapter());

    // Open the box
    _settingsBox = await Hive.openBox<UserSettings>(_settingsBoxName);
  }

  /// Returns the full path where Hive data is stored
  String getStoragePath() {
    return _settingsBox?.path ?? 'Not initialized';
  }

  /// Returns the storage folder name
  String getStorageFolderName() {
    return _storageFolderName;
  }

  UserSettings _getSettings() {
    return _settingsBox?.get(_settingsKey) ?? UserSettings();
  }

  Future<void> _saveSettings(UserSettings settings) async {
    await _settingsBox?.put(_settingsKey, settings);
  }

  // Company Name
  Future<void> setCompanyName(String companyName) async {
    final settings = _getSettings();
    settings.companyName = companyName;
    await _saveSettings(settings);
  }

  String? getCompanyName() {
    return _getSettings().companyName;
  }

  Future<void> clearCompanyName() async {
    final settings = _getSettings();
    settings.companyName = null;
    await _saveSettings(settings);
  }

  // Language
  Future<void> setLang(String lang) async {
    final settings = _getSettings();
    settings.lang = lang;
    await _saveSettings(settings);
  }

  String? getLang() {
    return _getSettings().lang;
  }

  Future<void> clearLang() async {
    final settings = _getSettings();
    settings.lang = null;
    await _saveSettings(settings);
  }

  // Type
  Future<void> setType(String type) async {
    final settings = _getSettings();
    settings.type = type;
    await _saveSettings(settings);
  }

  String? getType() {
    return _getSettings().type;
  }

  Future<void> clearType() async {
    final settings = _getSettings();
    settings.type = null;
    await _saveSettings(settings);
  }

  // User Name
  Future<void> setUserName(String userName) async {
    final settings = _getSettings();
    settings.userName = userName;
    await _saveSettings(settings);
  }

  String? getUserName() {
    return _getSettings().userName;
  }

  Future<void> clearUserName() async {
    final settings = _getSettings();
    settings.userName = null;
    await _saveSettings(settings);
  }

  // User Auth Token
  Future<void> setUserAuthToken(String token) async {
    final settings = _getSettings();
    settings.userAuthToken = token;
    await _saveSettings(settings);
  }

  String? getUserAuthToken() {
    return _getSettings().userAuthToken;
  }

  Future<void> clearUserAuthToken() async {
    final settings = _getSettings();
    settings.userAuthToken = null;
    await _saveSettings(settings);
  }

  // Email
  Future<void> setEmail(String email) async {
    final settings = _getSettings();
    settings.email = email;
    await _saveSettings(settings);
  }

  String? getEmail() {
    return _getSettings().email;
  }

  Future<void> clearEmail() async {
    final settings = _getSettings();
    settings.email = null;
    await _saveSettings(settings);
  }

  // URL
  Future<void> setUrl(String url) async {
    final settings = _getSettings();
    settings.url = url;
    await _saveSettings(settings);
  }

  String? getUrl() {
    return _getSettings().url;
  }

  Future<void> clearUrl() async {
    final settings = _getSettings();
    settings.url = null;
    await _saveSettings(settings);
  }

  // Database
  Future<void> setDatabase(String database) async {
    final settings = _getSettings();
    settings.database = database;
    await _saveSettings(settings);
  }

  String? getDatabase() {
    return _getSettings().database;
  }

  Future<void> clearDatabase() async {
    final settings = _getSettings();
    settings.database = null;
    await _saveSettings(settings);
  }

  // Clear all settings
  Future<void> clearAll() async {
    final settings = _getSettings();
    settings.clear();
    await _saveSettings(settings);
  }

  Future<void> dispose() async {
    await _settingsBox?.close();
  }
}
