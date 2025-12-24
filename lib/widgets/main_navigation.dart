import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/screens/bills_main_screen.dart';
import 'package:mobile_reporting/screens/finances_main_screen.dart';
import 'package:mobile_reporting/screens/main_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/screens/statistics_main_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  String? _userType;
  String? _companyName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userType = await getIt<PreferencesHelper>().getType();
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    setState(() {});
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const MainScreen();
      case 1:
        return const StatisticsMainScreen();
      case 2:
        return _userType == 'RETAIL'
            ? const FinancesMainScreen()
            : const BillsMainScreen();
      default:
        return const MainScreen();
    }
  }

  String _getCurrentTitle() {
    switch (_currentIndex) {
      case 0:
        return 'დეშბორდი';
      case 1:
        return 'სტატისტიკა';
      case 2:
        return _userType == 'RETAIL' ? 'ფინანსები' : 'ჩეკები';
      default:
        return 'დეშბორდი';
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('პროფილი'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _companyName ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('გასვლა'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          _getCurrentTitle(),
          style: const TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.secondaryTextColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'დეშბორდი',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'სტატისტიკა',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_outlined),
              activeIcon: const Icon(Icons.receipt),
              label: _userType == 'RETAIL' ? 'ფინანსები' : 'ჩეკები',
            ),
          ],
        ),
      ),
    );
  }
}
