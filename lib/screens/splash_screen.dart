import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_reporting/api/response_models/store_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/helpers/encryption_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/http_helper.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/store_model.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final HttpHelper _httpHelper = HttpHelper();

  Future<String> _getServerUrl() async {
    final url = await getIt<PreferencesHelper>().getUrl() ?? '';
    return url
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll(RegExp(r'/$'), '');
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? database = await getIt<PreferencesHelper>().getDatabase();
      if (database == null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        application.stores.clear();
        application.stores = await getStores();
        application.isFastFood = await isFastFood();
        application.lang = await getIt<PreferencesHelper>().getLang() ?? 'ka';
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainNavigation()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'FINA Reporting',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<StoreModel>> getStores() async {
    try {
      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase() ?? '';

      final response = await _httpHelper.fetchGet(
        ck,
        serverUrl,
        'get_stores',
      );

      if (response != null) {
        final data = json.decode(response) as List;
        List<StoreResponseModel> stores = data
            .map((e) => StoreResponseModel.fromJson(e as Map<String, dynamic>))
            .toList();

        List<StoreModel> res = [];
        for (var element in stores) {
          res.add(StoreModel(id: element.id, name: element.name));
        }
        return res;
      }

      return [];
    } catch (err) {
      return [];
    }
  }

  Future<bool> isFastFood() async {
    try {
      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase() ?? '';

      final response = await _httpHelper.fetchGet(
        ck,
        serverUrl,
        'is_fast_food',
      );

      if (response != null) {
        return json.decode(response) as bool;
      }

      return false;
    } catch (err) {
      return false;
    }
  }
}
