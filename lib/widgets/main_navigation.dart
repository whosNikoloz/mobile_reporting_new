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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppTheme.primaryBlue.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppTheme.primaryBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _companyName ?? '',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'თქვენი პროფილის ინფორმაცია',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'დახურვა',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await getIt<PreferencesHelper>()
                                  .clearCompanyName();
                              await getIt<PreferencesHelper>().clearLang();
                              await getIt<PreferencesHelper>().clearType();
                              await getIt<PreferencesHelper>()
                                  .clearUserAuthToken();
                              await getIt<PreferencesHelper>().clearUserName();
                              await getIt<PreferencesHelper>().clearEmail();
                              await getIt<PreferencesHelper>().clearDatabase();
                              await getIt<PreferencesHelper>().clearUrl();
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SplashScreen()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text(
                              'გასვლა',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              _getCurrentTitle(),
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 24, // Increased from 20
                fontWeight: FontWeight.w600,
                fontFamily: 'Bold',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    width: 42, // Increased from 36
                    height: 42, // Increased from 36
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21), // Half of 42
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryBlue,
                      size: 24, // Increased from 20
                    ),
                  ),
                  onPressed: _showProfileDialog,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'დეშბორდი',
                index: 0,
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'სტატისტიკა',
                index: 1,
                isSelected: _currentIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.receipt_outlined,
                activeIcon: Icons.receipt,
                label: _userType == 'RETAIL' ? 'ფინანსები' : 'ჩეკები',
                index: 2,
                isSelected: _currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
