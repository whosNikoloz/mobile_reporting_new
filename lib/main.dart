import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  registerModules();

  // Set Jiffy to use English locale since Georgian ('ka') is not supported for ordinals
  // This only affects Jiffy's internal date calculations, not the app's UI locale
  await Jiffy.setLocale('en');

  runApp(
    const ReportingApp(),
  );
}

class ReportingApp extends StatefulWidget {
  const ReportingApp({Key? key}) : super(key: key);

  @override
  State<ReportingApp> createState() => ReportingAppState();
  static ReportingAppState of(BuildContext context) => context.findAncestorStateOfType<ReportingAppState>()!;
}

class ReportingAppState extends State<ReportingApp> {
  Locale _locale = const Locale.fromSubtags(languageCode: 'ka');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) {
      setState(() {
        _locale = Locale(savedLang);
      });
    }
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  String getLocale() {
    return _locale.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ka', ''),
        Locale('ru', ''),
        Locale('az', ''),
      ],
      locale: _locale,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
