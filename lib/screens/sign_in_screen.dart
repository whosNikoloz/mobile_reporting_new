import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_reporting/helpers/encryption_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/dashboard_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/auth_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';

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

  LanguageOption get _currentLanguage {
    return availableLanguages.firstWhere(
      (lang) => lang.code == _selectedLanguage,
      orElse: () => availableLanguages.first,
    );
  }

  final GlobalKey _langButtonKey = GlobalKey();

  void _showLanguageDropdown() {
    final RenderBox button =
        _langButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height + 4,
        overlay.size.width - buttonPosition.dx - button.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: availableLanguages.map((lang) {
        final isSelected = lang.code == _selectedLanguage;
        return PopupMenuItem<String>(
          value: lang.code,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SvgPicture.asset(
                  lang.svgAsset,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.code == 'en' ? 'English' : 'ქართული',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2F6BFF)
                        : const Color(0xFF111827),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF2F6BFF),
                ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _changeLanguage(value);
      }
    });
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
              const SizedBox(height: 60),

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
              // Text(
              //   l10n.username,
              //   style: const TextStyle(
              //     fontSize: 14,
              //     color: Colors.black54,
              //   ),
              // ),

              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  label: Text(l10n.username),
                  labelStyle: const TextStyle(color: Colors.black54),
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
              // Text(
              //   l10n.password,
              //   style: const TextStyle(
              //     fontSize: 14,
              //     color: Colors.black54,
              //   ),
              // ),

              // const SizedBox(height: 8),

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text(l10n.password),
                  labelStyle: const TextStyle(color: Colors.black54),
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

              // Log In Button (full width)
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

              const SizedBox(height: 16),

              // Language Picker Dropdown (right aligned)
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  key: _langButtonKey,
                  onTap: _showLanguageDropdown,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SvgPicture.asset(
                            _currentLanguage.svgAsset,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentLanguage.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ],
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

      final baseUrl = userResponse.url ?? 'http://web.fina24.ge:8098/';
      //final baseUrl = 'https://localhost:5133/';

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
