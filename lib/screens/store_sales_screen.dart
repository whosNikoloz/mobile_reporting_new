import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/widgets/chart_details_modal.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/response_models/store_sales_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class StoreSalesScreen extends StatefulWidget {
  const StoreSalesScreen({super.key});

  @override
  State<StoreSalesScreen> createState() => _StoreSalesScreenState();
}

enum _ReportFilterType { income, checks, avgCheck }

class _StoreSalesScreenState extends State<StoreSalesScreen> {
  final ReportsService _reportsService = ReportsService();
  final ScrollController _chartScrollController = ScrollController();
  bool _filtersLoaded = false;

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
    }
  }

  // ignore: unused_field
  double _scrollProgress = 0.0;

  bool isLoading = false;
  DateTime startCurrentPeriod = DateTime.now();
  DateTime endCurrentPeriod = DateTime.now();
  DateTime startOldPeriod = DateTime.now().subtract(const Duration(days: 1));
  DateTime endOldPeriod = DateTime.now().subtract(const Duration(days: 1));

  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  _ReportFilterType _selectedFilterType = _ReportFilterType.income;

  // Data from API
  List<StoreSalesResponseModel> _storeSalesData = [];

  // Get only stores with sales (current or previous > 0)
  List<StoreSalesResponseModel> get _activeStores {
    return _storeSalesData.where((store) {
      final current = _getCurrentValue(store);
      final previous = _getPreviousValue(store);
      return current > 0 || previous > 0;
    }).toList();
  }

  String get _currentFilterLabel {
    final l10n = S.of(context);
    switch (_selectedFilterType) {
      case _ReportFilterType.income:
        return l10n.income;
      case _ReportFilterType.checks:
        return l10n.checksFilter;
      case _ReportFilterType.avgCheck:
        return l10n.averageCheck;
    }
  }

  // ignore: unused_element
  bool get _isIncomeFilter => _selectedFilterType == _ReportFilterType.income;
  bool get _isChecksFilter => _selectedFilterType == _ReportFilterType.checks;
  bool get _isAvgCheckFilter =>
      _selectedFilterType == _ReportFilterType.avgCheck;

  double _getCurrentValue(StoreSalesResponseModel e) {
    if (_isChecksFilter) {
      return e.currentChecks.toDouble();
    } else if (_isAvgCheckFilter) {
      return e.currentAvgCheck;
    }
    return e.currentSales;
  }

  double _getPreviousValue(StoreSalesResponseModel e) {
    if (_isChecksFilter) {
      return e.previousChecks.toDouble();
    } else if (_isAvgCheckFilter) {
      return e.previousAvgCheck;
    }
    return e.previousSales;
  }

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
              S.of(context).salesByStores,
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
                              builder: (_) => const SignInScreen()),
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
          ? Center(child: RotatingLogoLoader())
          : Column(
              children: [
                // Date Picker only (no store filter)
                PickerWidget(
                  screenType: ScreenType.reportssScreen,
                  showCompareDateFilter: true,
                  showStoreFilter: false, // No store filter for this report
                  getDate: (DateTime dt1,
                      DateTime dt2,
                      DateTime dt3,
                      DateTime dt4,
                      double? minAmount,
                      double? maxAmount,
                      String? billNum) async {
                    startCurrentPeriod = dt1;
                    endCurrentPeriod = dt2;
                    startOldPeriod = dt3;
                    endOldPeriod = dt4;
                    await _loadData();
                  },
                  onlyDayPicker: false,
                ),

                // Display Value Filter
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  color: Colors.grey.shade100,
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
                      _buildFilterDropdown(
                        Icons.tune,
                        _currentFilterLabel,
                        () => _showFilterSelector(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? Center(child: RotatingLogoLoader())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Horizontal Bar Chart Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
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
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // List Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
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
                                          S.of(context).store,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          _currentFilterLabel,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // List Items
                                  ..._activeStores.map(
                                    (store) => _buildListItem(store),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _reportsService.getStoreSalesReport(
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startOldPeriod,
        endPreviousPeriod: endOldPeriod,
      );
      if (response != null) {
        _storeSalesData = response;
      }
    } catch (err) {
      print('❌ Error loading store sales data: $err');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showFilterSelector() {
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    S.of(context).displayValue,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter options
              ...[
                _ReportFilterType.income,
                _ReportFilterType.checks,
                _ReportFilterType.avgCheck,
              ].map((type) {
                final l10n = S.of(context);
                final String label;
                final IconData icon;
                switch (type) {
                  case _ReportFilterType.income:
                    label = l10n.income;
                    icon = Icons.attach_money;
                    break;
                  case _ReportFilterType.checks:
                    label = l10n.checksFilter;
                    icon = Icons.receipt_long;
                    break;
                  case _ReportFilterType.avgCheck:
                    label = l10n.averageCheck;
                    icon = Icons.show_chart;
                    break;
                }
                final isSelected = _selectedFilterType == type;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilterType = type;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(IconData icon, String value, VoidCallback onTap) {
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
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarChart() {
    final stores = _activeStores;

    if (stores.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            S.of(context).noDataAvailable,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Calculate max value for scaling
    double maxValue = 0;
    for (final store in stores) {
      final current = _getCurrentValue(store);
      final previous = _getPreviousValue(store);
      if (current > maxValue) maxValue = current;
      if (previous > maxValue) maxValue = previous;
    }
    final maxX = maxValue > 0 ? maxValue * 1.2 : 100.0;

    // Calculate chart height based on number of stores
    // Each store needs space for name + 2 bars (reduced height per store)
    final chartHeight = stores.length * 44.0;
    final visibleHeight = 300.0;
    final needsScrolling = chartHeight > visibleHeight;

    return Column(
      children: [
        // Chart with vertical scroll
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable chart area
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
                      child: _buildHorizontalBarsWithLabels(stores, maxX),
                    ),
                  ),
                ),
              ),
              // Vertical scroll indicator
              if (needsScrolling)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildVerticalScrollIndicator(),
                ),
            ],
          ),
        ),
        // X-axis labels at bottom
        const SizedBox(height: 8),
        _buildXAxisLabels(maxX),
      ],
    );
  }

  Widget _buildXAxisLabels(double maxX) {
    // Generate 5 evenly spaced labels
    final labels = <double>[];
    for (int i = 0; i <= 4; i++) {
      labels.add((maxX / 4) * i);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 108), // Match label width + spacing
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

  void _showStoreDetails(StoreSalesResponseModel store) {
    final currentValue = _getCurrentValue(store);
    final previousValue = _getPreviousValue(store);
    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    String formattedValue = "";
    String formattedPrevious = "";

    if (_selectedFilterType == _ReportFilterType.checks) {
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
      title: store.name,
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

  Widget _buildHorizontalBarsWithLabels(
      List<StoreSalesResponseModel> stores, double maxX) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Reserve space for store names on the left
        const labelWidth = 100.0;
        final barAreaWidth = availableWidth - labelWidth - 8;

        return Column(
          children: stores.asMap().entries.map((entry) {
            final store = entry.value;
            final currentValue = _getCurrentValue(store);
            final previousValue = _getPreviousValue(store);

            // Calculate bar widths proportionally
            final currentBarWidth =
                maxX > 0 ? (currentValue / maxX) * barAreaWidth : 0.0;
            final previousBarWidth =
                maxX > 0 ? (previousValue / maxX) * barAreaWidth : 0.0;

            return GestureDetector(
              onTap: () => _showStoreDetails(store),
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 4),
                color: Colors.transparent, // Needed for tap detection
                child: Row(
                  children: [
                    // Store name on Y-axis
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        store.name,
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
                    // Bars stacked together (no gap)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Previous period bar (orange) - square, thin
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 7,
                            width: previousBarWidth.clamp(0.0, double.infinity),
                            color: const Color(0xFFFFA726),
                          ),
                          // Current period bar (blue) - square, thin, no gap
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

  String _formatValue(double value) {
    if (_isChecksFilter) {
      return NumberFormat('#,##0', 'en_US').format(value.toInt());
    } else {
      return '${CurrencyHelper.getCurrencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';
    }
  }

  Widget _buildListItem(StoreSalesResponseModel store) {
    final current = _getCurrentValue(store);
    final previous = _getPreviousValue(store);
    double percentChange = 0;
    if (previous > 0) {
      percentChange = ((current - previous) / previous) * 100;
    }

    final isPositive = percentChange >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              store.name,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatValue(current),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullscreenChart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenStoreSalesChart(
          stores: _activeStores,
          selectedFilterType: _selectedFilterType,
          currentPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startCurrentPeriod)} - ${DateFormat('dd.MM.yy').format(endCurrentPeriod)}',
          previousPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startOldPeriod)} - ${DateFormat('dd.MM.yy').format(endOldPeriod)}',
        ),
      ),
    );
  }
}

class _FullscreenStoreSalesChart extends StatefulWidget {
  final List<StoreSalesResponseModel> stores;
  final _ReportFilterType selectedFilterType;
  final String currentPeriodLabel;
  final String previousPeriodLabel;

  const _FullscreenStoreSalesChart({
    required this.stores,
    required this.selectedFilterType,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
  });

  @override
  State<_FullscreenStoreSalesChart> createState() =>
      _FullscreenStoreSalesChartState();
}

class _FullscreenStoreSalesChartState
    extends State<_FullscreenStoreSalesChart> {
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

  bool get _isChecksFilter =>
      widget.selectedFilterType == _ReportFilterType.checks;

  double _getCurrentValue(StoreSalesResponseModel e) {
    switch (widget.selectedFilterType) {
      case _ReportFilterType.income:
        return e.currentSales;
      case _ReportFilterType.checks:
        return e.currentChecks.toDouble();
      case _ReportFilterType.avgCheck:
        return e.currentAvgCheck;
    }
  }

  double _getPreviousValue(StoreSalesResponseModel e) {
    switch (widget.selectedFilterType) {
      case _ReportFilterType.income:
        return e.previousSales;
      case _ReportFilterType.checks:
        return e.previousChecks.toDouble();
      case _ReportFilterType.avgCheck:
        return e.previousAvgCheck;
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

  void _showStoreDetails(StoreSalesResponseModel store) {
    final currentValue = _getCurrentValue(store);
    final previousValue = _getPreviousValue(store);
    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    ChartDetailsModal.show(
      context: context,
      title: store.name,
      currentValueLabel: S.of(context).period,
      currentValueText: _formatValue(currentValue),
      previousValueLabel: S.of(context).comparisonLabel,
      previousValueText: _formatValue(previousValue),
      changeLabel: S.of(context).change ?? "Change",
      percentChange: percentChange,
      closeLabel: S.of(context).close ?? "Close",
      currentValueColor: AppTheme.primaryBlue,
      previousValueColor: const Color(0xFFFFA726),
    );
  }

  String _formatValue(double value) {
    if (_isChecksFilter) {
      return NumberFormat('#,##0', 'en_US').format(value.toInt());
    } else {
      return '${CurrencyHelper.getCurrencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = widget.stores;

    double maxValue = 0;
    for (final store in stores) {
      final current = _getCurrentValue(store);
      final previous = _getPreviousValue(store);
      if (current > maxValue) maxValue = current;
      if (previous > maxValue) maxValue = previous;
    }
    final maxX = maxValue > 0 ? maxValue * 1.2 : 100.0;

    final chartHeight = stores.length * 36.0;
    final needsScrolling = chartHeight > 200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          S.of(context).storeSalesOverview,
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
                // Chart with vertical scroll
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
                              children: stores.map((store) {
                                final currentValue = _getCurrentValue(store);
                                final previousValue = _getPreviousValue(store);

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
                                      onTap: () => _showStoreDetails(store),
                                      child: Container(
                                        height: 32,
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        color: Colors
                                            .transparent, // Needed for tap detection
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: labelWidth,
                                              child: Text(
                                                store.name,
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
                                                  // Previous bar (orange) - square, thin, no gap
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
                                                  // Current bar (blue) - square, thin, no gap
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
                      // Vertical scroll indicator
                      if (needsScrolling)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildVerticalScrollIndicator(),
                        ),
                    ],
                  ),
                ),
                // X-axis labels at bottom
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
