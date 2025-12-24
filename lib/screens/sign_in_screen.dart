import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/auth_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/main_navigation.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool logInClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/fina_logo.png',
                height: 65,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: usernameController,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: AppTheme.primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    hintText: 'შესვლის სახელი',
                    hintStyle: const TextStyle(
                      fontSize: 18.0,
                      color: AppTheme.hintTextColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.borderColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: AppTheme.primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.primaryBlue,
                    ),
                    hintText: 'პაროლი',
                    hintStyle: const TextStyle(
                      fontSize: 18.0,
                      color: AppTheme.hintTextColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.borderColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.zero,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    if (!logInClicked) {
                      logInClicked = true;
                      await userLogIn();
                      logInClicked = false;
                    }
                  },
                  child: const Text(
                    'შესვლა',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
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
    print('User Log In Clicked');
    final userResponse = await _authService.checkReportingUser(
      login: usernameController.text,
      password: passwordController.text,
    );

    if (userResponse != null) {
      await getIt<PreferencesHelper>().setCompanyName(userResponse.companyName);
      await getIt<PreferencesHelper>().setEmail(usernameController.text);
      await getIt<PreferencesHelper>().setDatabase(userResponse.database);
      await getIt<PreferencesHelper>().setLang(userResponse.lang);
      await getIt<PreferencesHelper>().setType(userResponse.type);
      await getIt<PreferencesHelper>().setUserName(userResponse.userName);

      //final baseUrl = userResponse.url ?? 'http://web.fina24.ge:8085/';
      final baseUrl = 'https://localhost:44388/';

      await getIt<PreferencesHelper>().setUrl(baseUrl);

      final token = await _authService.generateToken(
        database: userResponse.database,
        baseUrl: baseUrl,
      );

      if (token != null) {
        await getIt<PreferencesHelper>().setUserAuthToken(token);
        if (!mounted) return;
        ReportingApp.of(context).setLocale(Locale(userResponse.lang));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SplashScreen()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('ავტორიზაციის პროცესში შეცდომა მოხდა!'),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('მომხმარებლის სახელი ან პაროლი არ არის სწორი!'),
        ),
      );
    }
  }
}
