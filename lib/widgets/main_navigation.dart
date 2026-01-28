import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/dashboard_screen.dart';
import 'package:mobile_reporting/screens/finances_screen.dart';
import 'package:mobile_reporting/screens/reports_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';

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
  String _selectedLanguage = 'ka';

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
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) {
      _selectedLanguage = savedLang;
    }
    setState(() {});
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

  Widget _buildTopLangButton(String label, String code) {
    bool isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ReportsScreen();
      case 2:
        return _userType == 'RETAIL'
            ? const FinancesScreen()
            : const FinancesScreen();
      default:
        return const DashboardScreen();
    }
  }

  String _getCurrentTitle(BuildContext context) {
    final l10n = S.of(context);
    switch (_currentIndex) {
      case 0:
        return l10n.dashboard;
      case 1:
        return l10n.reports;
      case 2:
        return _userType == 'RETAIL' ? l10n.finances : l10n.checks;
      default:
        return l10n.dashboard;
    }
  }

  void _showProfileDialog() {
    showProfilePopover(
      context: context,
      name: _companyName ?? '',
      email: _email ?? '',
      currentLangCode: _selectedLanguage,
      onLanguageChanged: _changeLanguage,
      onLogout: () async {
        await getIt<PreferencesHelper>().clearCompanyName();
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
              _getCurrentTitle(context),
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 24, // Increased from 20
                fontWeight: FontWeight.w600,
                fontFamily: 'Bold',
              ),
            ),
            actions: [
              // Language Toggles
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: Row(
              //     children: [
              //       _buildTopLangButton('EN', 'en'),
              //       const SizedBox(width: 8),
              //       _buildTopLangButton('KA', 'ka'),
              //     ],
              //   ),
              // ),
              //const SizedBox(width: 8),
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
    final l10n = S.of(context);
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
                icon: 'assets/icons/navigation/dashboard.svg',
                label: l10n.dashboard,
                index: 0,
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                icon: 'assets/icons/navigation/reports.svg',
                label: l10n.reports,
                index: 1,
                isSelected: _currentIndex == 1,
              ),
              _buildNavItem(
                icon: 'assets/icons/navigation/orders.svg',
                label: _userType == 'RETAIL' ? l10n.orders : l10n.orders,
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
    required String icon,
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
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: isSelected
                  ? ColorFilter.mode(AppTheme.primaryBlue, BlendMode.srcIn)
                  : ColorFilter.mode(
                      AppTheme.secondaryTextColor, BlendMode.srcIn),
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
