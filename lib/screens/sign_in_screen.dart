import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:mobile_reporting/helpers/encryption_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/dashboard_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/auth_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool logInClicked = false;
  String _selectedLanguage = 'ka';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) {
      setState(() {
        _selectedLanguage = savedLang;
      });
      if (mounted) {
        ReportingApp.of(context).setLocale(Locale(_selectedLanguage));
      }
    }
  }

  void _changeLanguage(String langCode) async {
    setState(() {
      _selectedLanguage = langCode;
    });
    await getIt<PreferencesHelper>().setLang(langCode);
    if (mounted) {
      ReportingApp.of(context).setLocale(Locale(langCode));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLanguageOption(String label, String code) {
    bool isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Language Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _buildLanguageOption('English', 'en'),
                   const SizedBox(width: 20),
                   _buildLanguageOption('ქართული', 'ka'),
                ],
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                l10n.logIn,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Username Label
              Text(
                l10n.username,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: l10n.username,
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Label
              Text(
                l10n.password,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.password,
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Log In Button
              ElevatedButton(
                onPressed: () async {
                  if (!logInClicked) {
                    logInClicked = true;
                    await userLogIn();
                    logInClicked = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.logIn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> userLogIn() async {
    final userResponse = await _authService.checkReportingUser(
      login: _usernameController.text,
      password: _passwordController.text,
    );

    if (userResponse != null) {
      final encryptedDatabase =
          EncryptionHelper.encryptConnection(userResponse.database);

      await getIt<PreferencesHelper>().setCompanyName(userResponse.companyName);
      await getIt<PreferencesHelper>().setEmail(_usernameController.text);
      await getIt<PreferencesHelper>().setDatabase(encryptedDatabase);
      await getIt<PreferencesHelper>().setType(userResponse.type);
      await getIt<PreferencesHelper>().setUserName(userResponse.userName);
      await getIt<PreferencesHelper>().setAccountLang(userResponse.lang);

      //final baseUrl = userResponse.url ?? 'http://web.fina24.ge:8098/';
      final baseUrl = 'https://localhost:5133/';

      await getIt<PreferencesHelper>().setUrl(baseUrl);

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SplashScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(S.of(context).incorrectCredentials),
        ),
      );
    }
  }
}
