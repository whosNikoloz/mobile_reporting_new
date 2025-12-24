import 'dart:io';
import 'package:mobile_reporting/storage/hive_settings_service.dart';
import 'package:path_provider/path_provider.dart';

class StorageDebugHelper {
  /// Prints all storage information to console
  static Future<void> printStorageInfo(HiveSettingsService hiveSettings) async {
    print('=== Hive Storage Information ===');
    print('Storage Path: ${hiveSettings.getStoragePath()}');
    print('Folder Name: ${hiveSettings.getStorageFolderName()}');

    final appDocDir = await getApplicationDocumentsDirectory();
    print('App Documents Directory: ${appDocDir.path}');

    final hiveDir = Directory('${appDocDir.path}/${hiveSettings.getStorageFolderName()}');
    print('Hive Directory Exists: ${await hiveDir.exists()}');

    if (await hiveDir.exists()) {
      print('\nFiles in Hive storage:');
      final files = await hiveDir.list().toList();
      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          print('  - ${file.path.split(Platform.pathSeparator).last} (${stat.size} bytes)');
        }
      }
    }

    print('================================');
  }

  /// Returns the current settings as a formatted string
  static String getSettingsDebugString(HiveSettingsService hiveSettings) {
    final buffer = StringBuffer();
    buffer.writeln('=== Current Settings ===');
    buffer.writeln('Company Name: ${hiveSettings.getCompanyName() ?? "null"}');
    buffer.writeln('Language: ${hiveSettings.getLang() ?? "null"}');
    buffer.writeln('Type: ${hiveSettings.getType() ?? "null"}');
    buffer.writeln('User Name: ${hiveSettings.getUserName() ?? "null"}');
    buffer.writeln('Email: ${hiveSettings.getEmail() ?? "null"}');
    buffer.writeln('URL: ${hiveSettings.getUrl() ?? "null"}');
    buffer.writeln('Database: ${hiveSettings.getDatabase() ?? "null"}');
    buffer.writeln('Auth Token: ${hiveSettings.getUserAuthToken() != null ? "***SET***" : "null"}');
    buffer.writeln('========================');
    return buffer.toString();
  }
}
