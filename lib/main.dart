import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  registerModules();

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
