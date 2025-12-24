import 'package:get_it/get_it.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';

final getIt = GetIt.instance;

void registerModules() {
  getIt.registerSingleton<PreferencesHelper>(PreferencesHelper());
}
