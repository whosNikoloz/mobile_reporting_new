import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/screens/bills_main_screen.dart';
import 'package:mobile_reporting/screens/finances_main_screen.dart';
import 'package:mobile_reporting/screens/main_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_reporting/screens/statistics_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: Column(
          children: [
            DrawerHeader(
              margin: const EdgeInsets.only(bottom: 0),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: SizedBox(
                width: 220,
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(90),
                          ),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureProvider<String?>(
                            create: (_) =>
                                getIt<PreferencesHelper>().getCompanyName(),
                            initialData: '',
                            builder: (_, __) {
                              return Text(
                                _.watch<String?>() ?? '',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: 160,
                            child: FutureProvider<String?>(
                              create: (_) =>
                                  getIt<PreferencesHelper>().getEmail(),
                              initialData: '',
                              builder: (_, __) {
                                return Text(
                                  _.watch<String?>() ?? '',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset(
                      'assets/drawer_icons_changed/მთავარი.svg',
                      height: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'დეშბორდი',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              onTap: () async {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const MainScreen()));
              },
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade500,
              thickness: 1,
              indent: 7,
              endIndent: 7,
            ),
            ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset(
                      'assets/drawer_icons_changed/სტატისტიკა.svg',
                      height: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'სტატისტიკა',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatisticsMainScreen()));
              },
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade500,
              thickness: 1,
              indent: 7,
              endIndent: 7,
            ),
            ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset(
                      'assets/drawer_icons_changed/ჩეკები.svg',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FutureBuilder<String>(
                    future: getType(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Text(
                        snapshot.data! == 'RETAIL' ? 'ფინანსები' : 'ჩეკები',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () async {
                bool isRetail =
                    await getIt<PreferencesHelper>().getType() == 'RETAIL';
                if (!mounted) return;
                if (isRetail) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinancesMainScreen(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BillsMainScreen()));
                }
              },
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade500,
              thickness: 1,
              indent: 7,
              endIndent: 7,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppTheme.primaryBlue,
                  ),
                  color: AppTheme.primaryBlue,
                ),
                child: TextButton(
                  child: const Text(
                    'გასვლა',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await getIt<PreferencesHelper>().clearCompanyName();
                    await getIt<PreferencesHelper>().clearLang();
                    await getIt<PreferencesHelper>().clearType();
                    await getIt<PreferencesHelper>().clearUserAuthToken();
                    await getIt<PreferencesHelper>().clearUserName();
                    await getIt<PreferencesHelper>().clearEmail();
                    await getIt<PreferencesHelper>().clearDatabase();
                    await getIt<PreferencesHelper>().clearUrl();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (Platform.isIOS)
              const SizedBox(
                height: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<String> getType() async {
    return (await getIt<PreferencesHelper>().getType())!;
  }
}
