import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/widgets/chart_details_modal.dart';
import 'package:mobile_reporting/api/response_models/staff_sales_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';

class StaffSalesScreen extends StatefulWidget {
  const StaffSalesScreen({super.key});

  @override
  State<StaffSalesScreen> createState() => _StaffSalesScreenState();
}

enum _ReportType { income, checks, avgCheck }

class _StaffSalesScreenState extends State<StaffSalesScreen> {
  final ReportsService _reportsService = ReportsService();
  bool _filtersLoaded = false;
  bool isLoading = false;

  // Filters
  DateTime startCurrentPeriod = DateTime.now();
  DateTime endCurrentPeriod = DateTime.now();
  DateTime startOldPeriod = DateTime.now().subtract(const Duration(days: 1));
  DateTime endOldPeriod = DateTime.now().subtract(const Duration(days: 1));

  int _selectedTop = 0;
  final List<int> _topOptions = [5, 10, 20, 50];

  _ReportType _selectedType = _ReportType.income;

  // Data
  List<StaffSalesResponseModel> _reportData = [];

  // User Data
  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  final ScrollController _chartScrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadUserData();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    await application.loadFilters();
    if (mounted) {
      setState(() {
        startCurrentPeriod = application.startCurrentPeriod ?? DateTime.now();
        endCurrentPeriod = application.endCurrentPeriod ?? DateTime.now();
        startOldPeriod = application.startOldPeriod ??
            DateTime.now().subtract(const Duration(days: 1));
        endOldPeriod = application.endOldPeriod ??
            DateTime.now().subtract(const Duration(days: 1));
        _filtersLoaded = true;
      });
      // Initial load happens via PickerWidget callback
    }
  }

  Future<void> _loadUserData() async {
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) {
      _selectedLanguage = savedLang;
    }
    if (mounted) {
      setState(() {});
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

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _reportsService.getStaffSalesReport(
        storeId: application.selectedStoreId ?? 0,
        top: _selectedTop,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startOldPeriod,
        endPreviousPeriod: endOldPeriod,
      );

      if (response != null) {
        _reportData = response;
      }
    } catch (err) {
      print('❌ Error loading staff report: $err');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get _isChecksFilter => _selectedType == _ReportType.checks;

  String _getReportTypeLabel(_ReportType type) {
    switch (type) {
      case _ReportType.income:
        return S.of(context).income;
      case _ReportType.checks:
        return S.of(context).checksFilter;
      case _ReportType.avgCheck:
        return S.of(context).averageCheck;
    }
  }

  double _getCurrentValue(StaffSalesResponseModel item) {
    switch (_selectedType) {
      case _ReportType.income:
        return item.currentSales;
      case _ReportType.checks:
        return item.currentChecks.toDouble();
      case _ReportType.avgCheck:
        return item.currentAvgCheck;
    }
  }

  double _getPreviousValue(StaffSalesResponseModel item) {
    switch (_selectedType) {
      case _ReportType.income:
        return item.previousSales;
      case _ReportType.checks:
        return item.previousChecks.toDouble();
      case _ReportType.avgCheck:
        return item.previousAvgCheck;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppTheme.primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              S.of(context).salesByStaffs ?? 'Sales by Staffs',
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Bold',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: SvgPicture.asset(
                          'assets/icons/user.svg',
                          colorFilter: ColorFilter.mode(
                            AppTheme.primaryBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showProfilePopover(
                      context: context,
                      name: _companyName ?? "Name",
                      email: _email ?? "Email@gmail.com",
                      currentLangCode: _selectedLanguage,
                      onLanguageChanged: _changeLanguage,
                      onLogout: () async {
                        await getIt<PreferencesHelper>().clearCompanyName();
                        await getIt<PreferencesHelper>().clearLang();
                        await getIt<PreferencesHelper>().clearType();
                        await getIt<PreferencesHelper>().clearUserAuthToken();
                        await getIt<PreferencesHelper>().clearUserName();
                        await getIt<PreferencesHelper>().clearEmail();
                        await getIt<PreferencesHelper>().clearAccountLang();
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: !_filtersLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PickerWidget(
                  screenType: ScreenType.reportssScreen,
                  showCompareDateFilter: true,
                  showStoreFilter: true,
                  getDate: (dt1, dt2, dt3, dt4, min, max, bill) async {
                    startCurrentPeriod = dt1;
                    endCurrentPeriod = dt2;
                    startOldPeriod = dt3;
                    endOldPeriod = dt4;
                    await _loadData();
                  },
                  onlyDayPicker: false,
                ),

                // Filters Row (Top N & Type)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      // Type Dropdown
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).displayValue,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildDropdown(context,
                                icon: Icons.tune,
                                value: _getReportTypeLabel(_selectedType),
                                onTap: _showTypeSelector),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Top N Dropdown
                      // Expanded(
                      //   flex: 2,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text(
                      //         "Top",
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w500,
                      //           color: Colors.black54,
                      //         ),
                      //       ),
                      //       const SizedBox(height: 6),
                      //       _buildDropdown(context,
                      //           icon: Icons.format_list_numbered,
                      //           value: "$_selectedTop",
                      //           onTap: _showTopSelector),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_reportData.isNotEmpty) ...[
                              // Horizontal Bar Chart Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: _showFullscreenChart,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryBlue
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.fullscreen,
                                              color: AppTheme.primaryBlue,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 280,
                                      child: _buildHorizontalBarChart(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // List Section
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            S.of(context).staffMember ??
                                                "Staff Member",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            _getReportTypeLabel(_selectedType),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Items
                                    ...List.generate(_reportData.length,
                                        (index) => _buildListItem(index)),
                                  ],
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bar_chart,
                                          size: 48,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        S.of(context).noDataAvailable,
                                        style: TextStyle(
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      {required IconData icon,
      required String value,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarChart() {
    if (_reportData.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noDataAvailable,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    double maxValue = 0;
    for (final item in _reportData) {
      final current = _getCurrentValue(item);
      final previous = _getPreviousValue(item);
      if (current > maxValue) maxValue = current;
      if (previous > maxValue) maxValue = previous;
    }
    final maxX = maxValue > 0 ? maxValue * 1.2 : 100.0;

    final chartHeight = _reportData.length * 44.0;
    final needsScrolling = chartHeight > 280;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      final maxExtent = notification.metrics.maxScrollExtent;
                      if (maxExtent > 0) {
                        setState(() {
                          _scrollProgress =
                              notification.metrics.pixels / maxExtent;
                        });
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _chartScrollController,
                    child: SizedBox(
                      height: chartHeight,
                      child: _buildHorizontalBarsWithLabels(maxX),
                    ),
                  ),
                ),
              ),
              if (needsScrolling)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildVerticalScrollIndicator(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildXAxisLabels(maxX),
      ],
    );
  }

  Widget _buildHorizontalBarsWithLabels(double maxX) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const labelWidth = 100.0;
        final barAreaWidth = availableWidth - labelWidth - 8;

        return Column(
          children: _reportData.map((item) {
            final currentValue = _getCurrentValue(item);
            final previousValue = _getPreviousValue(item);

            final currentBarWidth =
                maxX > 0 ? (currentValue / maxX) * barAreaWidth : 0.0;
            final previousBarWidth =
                maxX > 0 ? (previousValue / maxX) * barAreaWidth : 0.0;

            return GestureDetector(
              onTap: () => _showDataPointDetails(_reportData.indexOf(item)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 4),
                color: Colors.transparent,
                child: Row(
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 7,
                            width: previousBarWidth.clamp(0.0, double.infinity),
                            color: const Color(0xFFFFA726),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 7,
                            width: currentBarWidth.clamp(0.0, double.infinity),
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildXAxisLabels(double maxX) {
    final labels = <double>[];
    for (int i = 0; i <= 4; i++) {
      labels.add((maxX / 4) * i);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 108),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((value) {
          return Text(
            _formatXAxisLabel(value),
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black45,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatXAxisLabel(double value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    if (_isChecksFilter) {
      if (absValue >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
      } else if (absValue >= 1000) {
        return '${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
      }
      return value.toStringAsFixed(0);
    } else {
      final symbol = CurrencyHelper.getCurrencySymbol();
      if (absValue >= 1000000) {
        return '$symbol${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
      } else if (absValue >= 1000) {
        return '$symbol${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
      }
      return '$symbol${value.toStringAsFixed(0)}';
    }
  }

  Widget _buildVerticalScrollIndicator() {
    const int dotCount = 5;
    final activeDot =
        (_scrollProgress * (dotCount - 1)).round().clamp(0, dotCount - 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        final isActive = index == activeDot;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 3),
          width: 6,
          height: isActive ? 16 : 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  String _formatValue(double value) {
    if (_isChecksFilter) {
      return NumberFormat('#,##0', 'en_US').format(value.toInt());
    } else {
      return '${CurrencyHelper.getCurrencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';
    }
  }

  Widget _buildListItem(int index) {
    final item = _reportData[index];
    final currentValue = _getCurrentValue(item);
    final previousValue = _getPreviousValue(item);

    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    String formattedValue = "";
    String formattedPrevious = "";

    if (_selectedType == _ReportType.income ||
        _selectedType == _ReportType.avgCheck) {
      formattedValue = CurrencyHelper.format(currentValue);
      formattedPrevious = CurrencyHelper.format(previousValue);
    } else {
      formattedValue = currentValue.toStringAsFixed(0);
      formattedPrevious = previousValue.toStringAsFixed(0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Name and percentage change
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      percentChange >= 0
                          ? '+${percentChange.toStringAsFixed(1)}%'
                          : '${percentChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: percentChange >= 0
                            ? const Color(0xFF00BFA5) // Light Teal
                            : const Color(0xFFFF5252), // Light Red
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedPrevious,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Value
          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showTopSelector() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text("Select Top N",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              ..._topOptions.map((top) => _buildTopOption(top)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopOption(int top) {
    final isSelected = _selectedTop == top;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedTop = top);
          Navigator.pop(context);
          _loadData(); // Reload data with new top
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text("Top $top",
                  style: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16)),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(S.of(context).displayValue,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              ..._ReportType.values.map((type) => _buildTypeOption(type)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(_ReportType type) {
    final isSelected = _selectedType == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedType = type);
          Navigator.pop(context);
          // No need to reload data, just setState
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(_getReportTypeLabel(type),
                  style: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16)),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
            ],
          ),
        ),
      ),
    );
  }

  void _showDataPointDetails(int index) {
    final item = _reportData[index];
    final currentValue = _getCurrentValue(item);
    final previousValue = _getPreviousValue(item);
    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    String formattedValue = "";
    String formattedPrevious = "";

    if (_selectedType == _ReportType.income ||
        _selectedType == _ReportType.avgCheck) {
      formattedValue = CurrencyHelper.format(currentValue);
      formattedPrevious = CurrencyHelper.format(previousValue);
    } else {
      formattedValue = currentValue.toStringAsFixed(0);
      formattedPrevious = previousValue.toStringAsFixed(0);
    }

    ChartDetailsModal.show(
      context: context,
      title: item.name,
      currentValueLabel: S.of(context).period,
      currentValueText: formattedValue,
      previousValueLabel: S.of(context).comparisonLabel,
      previousValueText: formattedPrevious,
      changeLabel: S.of(context).change ?? "Change",
      percentChange: percentChange,
      closeLabel: S.of(context).close ?? "Close",
      currentValueColor: AppTheme.primaryBlue,
      previousValueColor: const Color(0xFFFFA726),
    );
  }

  void _showFullscreenChart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenStaffSalesChart(
          reportData: _reportData,
          selectedType: _selectedType,
          currentPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startCurrentPeriod)} - ${DateFormat('dd.MM.yy').format(endCurrentPeriod)}',
          previousPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startOldPeriod)} - ${DateFormat('dd.MM.yy').format(endOldPeriod)}',
        ),
      ),
    );
  }
}

class _FullscreenStaffSalesChart extends StatefulWidget {
  final List<StaffSalesResponseModel> reportData;
  final _ReportType selectedType;
  final String currentPeriodLabel;
  final String previousPeriodLabel;

  const _FullscreenStaffSalesChart({
    required this.reportData,
    required this.selectedType,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
  });

  @override
  State<_FullscreenStaffSalesChart> createState() =>
      _FullscreenStaffSalesChartState();
}

class _FullscreenStaffSalesChartState
    extends State<_FullscreenStaffSalesChart> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool get _isChecksFilter => widget.selectedType == _ReportType.checks;

  double _getCurrentValue(StaffSalesResponseModel item) {
    switch (widget.selectedType) {
      case _ReportType.income:
        return item.currentSales;
      case _ReportType.checks:
        return item.currentChecks.toDouble();
      case _ReportType.avgCheck:
        return item.currentAvgCheck;
    }
  }

  double _getPreviousValue(StaffSalesResponseModel item) {
    switch (widget.selectedType) {
      case _ReportType.income:
        return item.previousSales;
      case _ReportType.checks:
        return item.previousChecks.toDouble();
      case _ReportType.avgCheck:
        return item.previousAvgCheck;
    }
  }

  String _formatXAxisLabel(double value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    if (_isChecksFilter) {
      if (absValue >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
      } else if (absValue >= 1000) {
        return '${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
      }
      return value.toStringAsFixed(0);
    } else {
      final symbol = CurrencyHelper.getCurrencySymbol();
      if (absValue >= 1000000) {
        return '$symbol${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
      } else if (absValue >= 1000) {
        return '$symbol${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
      }
      return '$symbol${value.toStringAsFixed(0)}';
    }
  }

  Widget _buildXAxisLabels(double maxX) {
    final labels = <double>[];
    for (int i = 0; i <= 4; i++) {
      labels.add((maxX / 4) * i);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 128),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((value) {
          return Text(
            _formatXAxisLabel(value),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVerticalScrollIndicator() {
    const int dotCount = 5;
    final activeDot =
        (_scrollProgress * (dotCount - 1)).round().clamp(0, dotCount - 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        final isActive = index == activeDot;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 3),
          width: 6,
          height: isActive ? 16 : 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  void _showStaffDetails(StaffSalesResponseModel item) {
    final currentValue = _getCurrentValue(item);
    final previousValue = _getPreviousValue(item);
    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    String formattedValue = "";
    String formattedPrevious = "";

    if (_isChecksFilter) {
      formattedValue =
          NumberFormat('#,##0', 'en_US').format(currentValue.toInt());
      formattedPrevious =
          NumberFormat('#,##0', 'en_US').format(previousValue.toInt());
    } else {
      formattedValue = CurrencyHelper.format(currentValue);
      formattedPrevious = CurrencyHelper.format(previousValue);
    }

    ChartDetailsModal.show(
      context: context,
      title: item.name,
      currentValueLabel: S.of(context).period,
      currentValueText: formattedValue,
      previousValueLabel: S.of(context).comparisonLabel,
      previousValueText: formattedPrevious,
      changeLabel: S.of(context).change ?? "Change",
      percentChange: percentChange,
      closeLabel: S.of(context).close ?? "Close",
      currentValueColor: AppTheme.primaryBlue,
      previousValueColor: const Color(0xFFFFA726),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.reportData;

    double maxValue = 0;
    for (final item in data) {
      final current = _getCurrentValue(item);
      final previous = _getPreviousValue(item);
      if (current > maxValue) maxValue = current;
      if (previous > maxValue) maxValue = previous;
    }
    final maxX = maxValue > 0 ? maxValue * 1.2 : 100.0;

    final chartHeight = data.length * 36.0;
    final needsScrolling = chartHeight > 200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          S.of(context).salesByStaffs ?? 'Sales by Staffs',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.fullscreen_exit, color: AppTheme.primaryBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollUpdateNotification) {
                              final maxExtent =
                                  notification.metrics.maxScrollExtent;
                              if (maxExtent > 0) {
                                setState(() {
                                  _scrollProgress =
                                      notification.metrics.pixels / maxExtent;
                                });
                              }
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: data.map((item) {
                                final currentValue = _getCurrentValue(item);
                                final previousValue = _getPreviousValue(item);

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableWidth = constraints.maxWidth;
                                    const labelWidth = 120.0;
                                    final barAreaWidth =
                                        availableWidth - labelWidth - 8;

                                    final currentBarWidth = maxX > 0
                                        ? (currentValue / maxX) * barAreaWidth
                                        : 0.0;
                                    final previousBarWidth = maxX > 0
                                        ? (previousValue / maxX) * barAreaWidth
                                        : 0.0;

                                    return GestureDetector(
                                      onTap: () => _showStaffDetails(item),
                                      child: Container(
                                        height: 32,
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: labelWidth,
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    height: 7,
                                                    width:
                                                        previousBarWidth.clamp(
                                                            0.0,
                                                            double.infinity),
                                                    color:
                                                        const Color(0xFFFFA726),
                                                  ),
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    height: 7,
                                                    width:
                                                        currentBarWidth.clamp(
                                                            0.0,
                                                            double.infinity),
                                                    color: AppTheme.primaryBlue,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      if (needsScrolling)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildVerticalScrollIndicator(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildXAxisLabels(maxX),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
