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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // Title
              const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Username Label
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
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
              const Text(
                'Password',
                style: TextStyle(
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
                  hintText: 'Password',
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
                child: const Text(
                  'Log In',
                  style: TextStyle(
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
      await getIt<PreferencesHelper>().setLang(userResponse.lang);
      await getIt<PreferencesHelper>().setType(userResponse.type);
      await getIt<PreferencesHelper>().setUserName(userResponse.userName);

      final baseUrl = userResponse.url ?? 'http://web.fina24.ge:8098/';
      //final baseUrl = 'https://localhost:5133/';

      await getIt<PreferencesHelper>().setUrl(baseUrl);

      if (!mounted) return;
      ReportingApp.of(context).setLocale(Locale(userResponse.lang));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SplashScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Username or password is incorrect!'),
        ),
      );
    }
  }
}
