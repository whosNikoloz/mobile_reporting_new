import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_reporting/api/response_models/store_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/store_model.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? jwt = await getIt<PreferencesHelper>().getUserAuthToken();
      if (jwt == null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        final response = await Dio().post(
          '${await getIt<PreferencesHelper>().getUrl()}api/auth/check_token',
          options: Options(
            contentType: 'application/json',
            headers: {
              'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
              'Authorization': 'Bearer $jwt',
            },
            validateStatus: (status) {
              return true;
            },
          ),
        );
        if (response.statusCode == 200) {
          application.stores.clear();
          application.stores = await getStores();
          application.isFastFood = await isFastFood();
          application.lang = await getIt<PreferencesHelper>().getLang() ?? 'ka';
          if (!mounted) return;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MainNavigation()));
        } else {
          await getIt<PreferencesHelper>().clearCompanyName();
          await getIt<PreferencesHelper>().clearLang();
          await getIt<PreferencesHelper>().clearType();
          await getIt<PreferencesHelper>().clearUserAuthToken();
          await getIt<PreferencesHelper>().clearUserName();
          await getIt<PreferencesHelper>().clearEmail();
          await getIt<PreferencesHelper>().clearDatabase();
          await getIt<PreferencesHelper>().clearUrl();
          if (!mounted) return;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SplashScreen()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/fina_logo.png',
              height: 80,
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 60.0,
              height: 60.0,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<StoreModel>> getStores() async {
    List<StoreResponseModel> stores = List<StoreResponseModel>.from((await Dio()
            .get(
      '${await getIt<PreferencesHelper>().getUrl()}api/report/get_stores',
      options: Options(
        contentType: 'application/json',
        headers: {
          'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
          'Authorization':
              'Bearer ${await getIt<PreferencesHelper>().getUserAuthToken()}',
        },
        validateStatus: (status) {
          return true;
        },
      ),
    ))
        .data
        .map((e) => StoreResponseModel.fromJson(e as Map<String, dynamic>)));
    List<StoreModel> res = [];
    for (var element in stores) {
      res.add(StoreModel(id: element.id, name: element.name));
    }
    return res;
  }

  Future<bool> isFastFood() async {
    bool res = (await Dio().get(
      '${await getIt<PreferencesHelper>().getUrl()}api/report/is_fast_food',
      options: Options(
        contentType: 'application/json',
        headers: {
          'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
          'Authorization':
              'Bearer ${await getIt<PreferencesHelper>().getUserAuthToken()}',
        },
        validateStatus: (status) {
          return true;
        },
      ),
    ))
        .data;
    return res;
  }
}
