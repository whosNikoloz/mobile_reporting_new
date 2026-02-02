import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/response_models/daily_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/hourly_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/weekday_sales_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';

class SalesSummaryScreen extends StatefulWidget {
  final String reportTitle;

  const SalesSummaryScreen({
    super.key,
    required this.reportTitle,
  });

  @override
  State<SalesSummaryScreen> createState() => _SalesSummaryScreenState();
}

enum _ReportFilterType { income, checks, avgCheck }

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  final ReportsService _reportsService = ReportsService();
  final ScrollController _chartScrollController = ScrollController();

  double _scrollProgress = 0.0; // Track scroll progress (0.0 to 1.0)

  bool isLoading = false;
  DateTime startCurrentPeriod = DateTime.now();
  DateTime endCurrentPeriod = DateTime.now();
  DateTime startOldPeriod = DateTime.now().subtract(const Duration(days: 1));
  DateTime endOldPeriod = DateTime.now().subtract(const Duration(days: 1));

  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  _ReportFilterType _selectedFilterType = _ReportFilterType.income;
  List<String> get _filterOptions => [
        S.of(context).income,
        S.of(context).checksFilter,
        S.of(context).averageCheck,
      ];

  String get _selectedFilterDescription {
    if (_isChecksFilter) {
      return 'Checks არის ჩეკების რაოდენობა';
    } else if (_isAvgCheckFilter) {
      return 'AvgCheck არის ჩეკის საშუალო ღირებულება';
    } else {
      return 'Sales არის თანხა';
    }
  }

  // Data from API
  List<DailySalesResponseModel> _dailySalesData = [];
  List<HourlySalesResponseModel> _hourlySalesData = [];
  List<WeekdaySalesResponseModel> _weekdaySalesData = [];

  // Check if we should show monthly aggregation (date range > 31 days)
  bool get _shouldShowMonthlyAggregation {
    final daysDifference =
        endCurrentPeriod.difference(startCurrentPeriod).inDays;
    return daysDifference > 31;
  }

  // Aggregated monthly data from daily data
  List<Map<String, dynamic>> get _monthlyAggregatedData {
    if (_dailySalesData.isEmpty) return [];

    final Map<String, Map<String, dynamic>> monthlyMap = {};

    for (final day in _dailySalesData) {
      final monthKey = DateFormat('yyyy-MM').format(day.date);
      final monthLabel = DateFormat('MMM').format(day.date);

      if (!monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = {
          'label': monthLabel,
          'currentSales': 0.0,
          'previousSales': 0.0,
          'currentChecks': 0,
          'previousChecks': 0,
          'currentAvgCheckSum': 0.0,
          'previousAvgCheckSum': 0.0,
          'dayCount': 0,
        };
      }

      monthlyMap[monthKey]!['currentSales'] += day.currentSales;
      monthlyMap[monthKey]!['previousSales'] += day.previousSales;
      monthlyMap[monthKey]!['currentChecks'] += day.currentChecks;
      monthlyMap[monthKey]!['previousChecks'] += day.previousChecks;
      monthlyMap[monthKey]!['currentAvgCheckSum'] += day.currentAvgCheck;
      monthlyMap[monthKey]!['previousAvgCheckSum'] += day.previousAvgCheck;
      monthlyMap[monthKey]!['dayCount'] += 1;
    }

    // Calculate average check properly
    for (final entry in monthlyMap.values) {
      final dayCount = entry['dayCount'] as int;
      if (dayCount > 0) {
        entry['currentAvgCheck'] =
            (entry['currentAvgCheckSum'] as double) / dayCount;
        entry['previousAvgCheck'] =
            (entry['previousAvgCheckSum'] as double) / dayCount;
      } else {
        entry['currentAvgCheck'] = 0.0;
        entry['previousAvgCheck'] = 0.0;
      }
    }

    return monthlyMap.values.toList();
  }

  // Chart data based on report type
  List<String> get _chartLabels {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData
          .map((e) => _formatHourRangeLabel(e.hourRange))
          .toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData
          .map((e) => _getLocalizedDayName(e.name))
          .toList();
    } else if (widget.reportTitle.contains('Day')) {
      // Use monthly aggregation for large date ranges
      if (_shouldShowMonthlyAggregation) {
        return _monthlyAggregatedData.map((e) => e['label'] as String).toList();
      }
      return _formatDayLabels(_dailySalesData);
    }
    return [];
  }

  // Format day labels to be cleaner - show day number, with month only when it changes
  List<String> _formatDayLabels(List<DailySalesResponseModel> data) {
    if (data.isEmpty) return [];

    // Check if all data is within the same month
    final firstMonth = data.first.date.month;
    final firstYear = data.first.date.year;
    final allSameMonth = data.every(
        (d) => d.date.month == firstMonth && d.date.year == firstYear);

    final labels = <String>[];
    int? lastMonth;

    for (int i = 0; i < data.length; i++) {
      final date = data[i].date;
      final day = date.day;
      final month = date.month;

      if (allSameMonth) {
        // All same month - just show day numbers
        labels.add('$day');
      } else if (lastMonth == null || month != lastMonth) {
        // Month changed - show month name + day
        final monthName = DateFormat('MMM').format(date);
        labels.add('$day $monthName');
      } else {
        // Same month as previous - just show day number
        labels.add('$day');
      }

      lastMonth = month;
    }

    return labels;
  }

  // Check if current filter is Income
  bool get _isIncomeFilter => _selectedFilterType == _ReportFilterType.income;

  // Check if current filter is Checks
  bool get _isChecksFilter => _selectedFilterType == _ReportFilterType.checks;

  // Check if current filter is Average Check
  bool get _isAvgCheckFilter =>
      _selectedFilterType == _ReportFilterType.avgCheck;

  List<double> get _salesData {
    // For income, checks and avg check we show absolute amounts on the Y axis.
    if (_isIncomeFilter || _isChecksFilter || _isAvgCheckFilter) {
      return _currentAbsoluteData;
    }
    return _currentPercentData;
  }

  List<double> get _comparisonData {
    if (_isIncomeFilter || _isChecksFilter || _isAvgCheckFilter) {
      return _previousAbsoluteData;
    }
    return _previousPercentData;
  }

  // Percentage data for chart (current period %)
  List<double> get _currentPercentData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) => e.currentSalesPercent).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) => e.currentSalesPercent).toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData.map((e) => e.currentSalesPercent).toList();
    }
    return [];
  }

  // Percentage data for chart (previous period %)
  List<double> get _previousPercentData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) => e.previousSalesPercent).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) => e.previousSalesPercent).toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData.map((e) => e.previousSalesPercent).toList();
    }
    return [];
  }

  String _formatHourRangeLabel(String hourRange) {
    final parts = hourRange.split('-');
    if (parts.length >= 2) {
      return parts[1].trim();
    }
    return hourRange;
  }

  /// Absolute values for tooltip / list (respecting selected filter)
  List<double> get _currentAbsoluteData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map(_getCurrentValue).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map(_getCurrentValue).toList();
    } else if (widget.reportTitle.contains('Day')) {
      // Use monthly aggregation for large date ranges
      if (_shouldShowMonthlyAggregation) {
        return _monthlyAggregatedData.map((e) {
          if (_isChecksFilter) {
            return (e['currentChecks'] as int).toDouble();
          } else if (_isAvgCheckFilter) {
            return e['currentAvgCheck'] as double;
          }
          return e['currentSales'] as double;
        }).toList();
      }
      return _dailySalesData.map(_getCurrentValue).toList();
    }
    return [];
  }

  List<double> get _previousAbsoluteData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map(_getPreviousValue).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map(_getPreviousValue).toList();
    } else if (widget.reportTitle.contains('Day')) {
      // Use monthly aggregation for large date ranges
      if (_shouldShowMonthlyAggregation) {
        return _monthlyAggregatedData.map((e) {
          if (_isChecksFilter) {
            return (e['previousChecks'] as int).toDouble();
          } else if (_isAvgCheckFilter) {
            return e['previousAvgCheck'] as double;
          }
          return e['previousSales'] as double;
        }).toList();
      }
      return _dailySalesData.map(_getPreviousValue).toList();
    }
    return [];
  }

  bool get _isHourlyReport => widget.reportTitle.contains('Hour');

  /// Indices of hourly buckets where there was actual activity
  /// (either current or previous value > 0). Falls back to all
  /// hours if everything is zero to keep the chart meaningful.
  List<int> get _hourlyActiveIndices {
    if (!_isHourlyReport) return const [];

    final indices = <int>[];
    for (var i = 0; i < _hourlySalesData.length; i++) {
      final row = _hourlySalesData[i];
      final current = _getCurrentValue(row);
      final previous = _getPreviousValue(row);
      if (current > 0 || previous > 0) {
        indices.add(i);
      }
    }

    if (indices.isEmpty) {
      return List<int>.generate(_hourlySalesData.length, (i) => i);
    }
    return indices;
  }

  // Visible data for main chart / list (filters out empty hours for hourly report)
  List<String> get _visibleChartLabels {
    if (!_isHourlyReport) return _chartLabels;
    final indices = _hourlyActiveIndices;
    return indices
        .map((i) => _formatHourRangeLabel(_hourlySalesData[i].hourRange))
        .toList();
  }

  List<double> get _visibleSalesData {
    if (!_isHourlyReport) return _salesData;
    final indices = _hourlyActiveIndices;
    return indices.map((i) => _salesData[i]).toList();
  }

  List<double> get _visibleComparisonData {
    if (!_isHourlyReport) return _comparisonData;
    final indices = _hourlyActiveIndices;
    return indices.map((i) => _comparisonData[i]).toList();
  }

  List<double> get _visibleCurrentAbsoluteData {
    if (!_isHourlyReport) return _currentAbsoluteData;
    final indices = _hourlyActiveIndices;
    final source = _currentAbsoluteData;
    return indices.map((i) => source[i]).toList();
  }

  List<double> get _visiblePreviousAbsoluteData {
    if (!_isHourlyReport) return _previousAbsoluteData;
    final indices = _hourlyActiveIndices;
    final source = _previousAbsoluteData;
    return indices.map((i) => source[i]).toList();
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

  // Georgian Weekdays Map
  final Map<String, String> _geoWeekdays = {
    // English Full
    'Monday': 'ორშ',
    'Tuesday': 'სამ',
    'Wednesday': 'ოთხ',
    'Thursday': 'ხუთ',
    'Friday': 'პარ',
    'Saturday': 'შაბ',
    'Sunday': 'კვი',
    // English Short
    'Mon': 'ორშ',
    'Tue': 'სამ',
    'Wed': 'ოთხ',
    'Thu': 'ხუთ',
    'Fri': 'პარ',
    'Sat': 'შაბ',
    'Sun': 'კვი',
    // Georgian Full
    'ორშაბათი': 'ორშ',
    'სამშაბათი': 'სამ',
    'ოთხშაბათი': 'ოთხ',
    'ხუთშაბათი': 'ხუთ',
    'პარასკევი': 'პარ',
    'შაბათი': 'შაბ',
    'კვირა': 'კვი',
  };

  String _getLocalizedDayName(String? name) {
    if (name == null) return '';
    // Normalize input: trim and match against keys
    final key = name.trim();
    return _geoWeekdays[key] ?? _geoWeekdays[key.split(',')[0].trim()] ?? name;
  }

  String _getLocalizedReportTitle(BuildContext context) {
    final l10n = S.of(context);
    switch (widget.reportTitle) {
      case 'Sales by Days':
        return l10n.salesByDay;
      case 'Sales by Hour':
        return l10n.salesByHours;
      case 'Sales by Weekdays':
        return l10n.salesByWeekday;
      case 'Revenue Report':
        return l10n.revenueReport;
      case 'Expense Report':
        return l10n.expenseReport;
      case 'Profit & Loss':
        return l10n.profitAndLoss;
      case 'Staff Performance':
        return l10n.staffPerformance;
      case 'Attendance Report':
        return l10n.attendanceReport;
      case 'Commission Report':
        return l10n.commissionReport;
      case 'Shift Report':
        return l10n.shiftReport;
      case 'Hours Worked':
        return l10n.hoursWorked;
      case 'Productivity Report':
        return l10n.productivityReport;
      case 'Inventory Report':
        return l10n.inventoryReport;
      case 'Stock Movement':
        return l10n.stockMovement;
      default:
        return widget.reportTitle;
    }
  }

  String get _chartTitle {
    final l10n = S.of(context);
    if (widget.reportTitle.contains('Hour')) {
      return l10n.hourlySalesOverview;
    } else if (widget.reportTitle.contains('Weekday')) {
      return l10n.weekdaySalesOverview;
    } else if (widget.reportTitle.contains('Day')) {
      return l10n.dailySalesOverview;
    } else if (widget.reportTitle.contains('Month')) {
      return l10n.monthlySalesOverview;
    }
    return l10n.salesOverview;
  }

  String get _listHeaderLabel {
    final l10n = S.of(context);
    if (widget.reportTitle.contains('Hour')) {
      return l10n.hourlySalesOverview
          .split(' ')[0]; // Taking "Hour" roughly or just define day
    } else if (widget.reportTitle.contains('Weekday')) {
      return l10n.weekday; // I should add weekday to ARB if not there
    } else if (widget.reportTitle.contains('Month')) {
      return l10n.month;
    }
    return l10n.day;
  }

  // Get the title for the list header based on filter
  String get _filterTitle {
    if (_isChecksFilter) {
      return S.of(context).checksFilter;
    } else if (_isAvgCheckFilter) {
      return S.of(context).averageCheck;
    }
    return S.of(context).income;
  }

  // Helper to get current value based on filter
  double _getCurrentValue(dynamic e) {
    if (_isChecksFilter) {
      return e.currentChecks.toDouble();
    } else if (_isAvgCheckFilter) {
      return e.currentAvgCheck;
    }
    return e.currentSales;
  }

  // Helper to get previous value based on filter
  double _getPreviousValue(dynamic e) {
    if (_isChecksFilter) {
      return e.previousChecks.toDouble();
    } else if (_isAvgCheckFilter) {
      return e.previousAvgCheck;
    }
    return e.previousSales;
  }

  List<Map<String, dynamic>> get _listData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) {
        final current = _getCurrentValue(e);
        final previous = _getPreviousValue(e);
        double percentChange = 0;
        if (previous > 0) {
          percentChange = ((current - previous) / previous) * 100;
        }
        return {
          'label': _formatHourRangeLabel(e.hourRange),
          'value': current,
          'percentChange': percentChange,
        };
      }).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) {
        final current = _getCurrentValue(e);
        final previous = _getPreviousValue(e);
        double percentChange = 0;
        if (previous > 0) {
          percentChange = ((current - previous) / previous) * 100;
        }
        return {
          'label': _getLocalizedDayName(e.name),
          'value': current,
          'percentChange': percentChange,
        };
      }).toList();
    } else if (widget.reportTitle.contains('Day')) {
      // Use monthly aggregation for large date ranges
      if (_shouldShowMonthlyAggregation) {
        return _monthlyAggregatedData.map((e) {
          double current;
          double previous;
          if (_isChecksFilter) {
            current = (e['currentChecks'] as int).toDouble();
            previous = (e['previousChecks'] as int).toDouble();
          } else if (_isAvgCheckFilter) {
            current = e['currentAvgCheck'] as double;
            previous = e['previousAvgCheck'] as double;
          } else {
            current = e['currentSales'] as double;
            previous = e['previousSales'] as double;
          }
          double percentChange = 0;
          if (previous > 0) {
            percentChange = ((current - previous) / previous) * 100;
          }
          return {
            'label': e['label'] as String,
            'value': current,
            'percentChange': percentChange,
          };
        }).toList();
      }
      if (_dailySalesData.isEmpty) return [];

      // Check if all data is within the same month
      final firstMonth = _dailySalesData.first.date.month;
      final firstYear = _dailySalesData.first.date.year;
      final allSameMonth = _dailySalesData.every(
          (d) => d.date.month == firstMonth && d.date.year == firstYear);

      int? lastMonth;
      final result = <Map<String, dynamic>>[];

      for (int i = 0; i < _dailySalesData.length; i++) {
        final e = _dailySalesData[i];
        final current = _getCurrentValue(e);
        final previous = _getPreviousValue(e);
        double percentChange = 0;
        if (previous > 0) {
          percentChange = ((current - previous) / previous) * 100;
        }

        String label;
        if (allSameMonth) {
          // All same month - just show day number
          label = '${e.date.day}';
        } else if (lastMonth == null || e.date.month != lastMonth) {
          // Month changed - show day + month
          label = DateFormat('d MMM').format(e.date);
        } else {
          // Same month - just show day
          label = '${e.date.day}';
        }
        lastMonth = e.date.month;

        result.add({
          'label': label,
          'value': current,
          'percentChange': percentChange,
        });
      }
      return result;
    } else {
      return [];
    }
  }

  List<Map<String, dynamic>> get _visibleListData {
    if (!_isHourlyReport) return _listData;

    final indices = _hourlyActiveIndices;
    return indices.map((i) {
      final e = _hourlySalesData[i];
      final current = _getCurrentValue(e);
      final previous = _getPreviousValue(e);
      double percentChange = 0;
      if (previous > 0) {
        percentChange = ((current - previous) / previous) * 100;
      }
      return {
        'label': _formatHourRangeLabel(e.hourRange),
        'value': current,
        'percentChange': percentChange,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
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
              _getLocalizedReportTitle(context),
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
                    child: const Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryBlue,
                      size: 24,
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
      body: Column(
        children: [
          // Date and Store Pickers
          PickerWidget(
            screenType: ScreenType.reportssScreen,
            showCompareDateFilter: true,
            showStoreFilter: true,
            getDate: (DateTime dt1, DateTime dt2, DateTime dt3, DateTime dt4,
                double? minAmount, double? maxAmount, String? billNum) async {
              startCurrentPeriod = dt1;
              endCurrentPeriod = dt2;
              startOldPeriod = dt3;
              endOldPeriod = dt4;
              await _loadData();
            },
            onlyDayPicker: false,
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).displayValue,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: _buildFilterDropdown(
                              Icons.tune,
                              _currentFilterLabel,
                              () => _showFilterSelector(),
                            ),
                          ),
                        ],
                      ),
                      // Chart Section
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    // Left arrow
                                    // GestureDetector(
                                    //   onTap: _scrollChartLeft,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.all(8),
                                    //     decoration: BoxDecoration(
                                    //       color: AppTheme.primaryBlue
                                    //           .withValues(alpha: 0.1),
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //     child: const Icon(
                                    //       Icons.chevron_left,
                                    //       color: AppTheme.primaryBlue,
                                    //       size: 20,
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 8),
                                    // // Right arrow
                                    // GestureDetector(
                                    //   onTap: _scrollChartRight,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.all(8),
                                    //     decoration: BoxDecoration(
                                    //       color: AppTheme.primaryBlue
                                    //           .withValues(alpha: 0.1),
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //     child: const Icon(
                                    //       Icons.chevron_right,
                                    //       color: AppTheme.primaryBlue,
                                    //       size: 20,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(width: 8),
                                    // Fullscreen button
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
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 280,
                              child: _buildScrollableChart(),
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
                                    _listHeaderLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _filterTitle,
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
                            ..._visibleListData.map(
                              (item) => _buildListItem(
                                item['label'],
                                item['value'],
                                item['percentChange'],
                              ),
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
      final storeId = application.selectedStoreId ?? 0;

      if (widget.reportTitle.contains('Hour')) {
        final response = await _reportsService.getHourlySalesReport(
          storeId: storeId,
          startCurrentPeriod: startCurrentPeriod,
          endCurrentPeriod: endCurrentPeriod,
          startPreviousPeriod: startOldPeriod,
          endPreviousPeriod: endOldPeriod,
        );
        if (response != null) {
          _hourlySalesData = response;
        }
      } else if (widget.reportTitle.contains('Weekday')) {
        final response = await _reportsService.getWeekdaySalesReport(
          storeId: storeId,
          startCurrentPeriod: startCurrentPeriod,
          endCurrentPeriod: endCurrentPeriod,
          startPreviousPeriod: startOldPeriod,
          endPreviousPeriod: endOldPeriod,
        );
        if (response != null) {
          _weekdaySalesData = response;
        }
      } else if (widget.reportTitle.contains('Day')) {
        final response = await _reportsService.getDailySalesReport(
          storeId: storeId,
          startCurrentPeriod: startCurrentPeriod,
          endCurrentPeriod: endCurrentPeriod,
          startPreviousPeriod: startOldPeriod,
          endPreviousPeriod: endOldPeriod,
        );
        if (response != null) {
          _dailySalesData = response;
        }
      }
    } catch (err) {
      print('❌ Error loading report data: $err');
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
                    style: TextStyle(
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

  void _scrollChartLeft() {
    final currentOffset = _chartScrollController.offset;
    final newOffset = (currentOffset - 150).clamp(
      0.0,
      _chartScrollController.position.maxScrollExtent,
    );
    _chartScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollChartRight() {
    final currentOffset = _chartScrollController.offset;
    final newOffset = (currentOffset + 150).clamp(
      0.0,
      _chartScrollController.position.maxScrollExtent,
    );
    _chartScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showFullscreenChart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenChartPage(
          title: _chartTitle,
          salesData: _visibleSalesData,
          comparisonData: _visibleComparisonData,
          chartLabels: _visibleChartLabels,
          isIncomeMode: _isIncomeFilter || _isChecksFilter || _isAvgCheckFilter,
          isChecksFilter: _isChecksFilter,
          currentPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startCurrentPeriod)} - ${DateFormat('dd.MM.yy').format(endCurrentPeriod)}',
          previousPeriodLabel:
              '${DateFormat('dd.MM.yy').format(startOldPeriod)} - ${DateFormat('dd.MM.yy').format(endOldPeriod)}',
        ),
      ),
    );
  }

  Widget _buildScrollableChart() {
    if (_visibleSalesData.isEmpty || _visibleComparisonData.isEmpty || _visibleChartLabels.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noDataAvailable,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    // Calculate chart width based on data points - always allow scrolling
    final dataCount = _visibleChartLabels.length;
    // Each bar group needs ~30px minimum to show clearly
    const double minGroupWidth = 30.0;
    final actualContentWidth = dataCount * minGroupWidth;
    final chartWidth = actualContentWidth.clamp(300.0, double.infinity);

    final dataMax = _visibleSalesData.reduce((a, b) => a > b ? a : b);
    final comparisonMax =
        _visibleComparisonData.reduce((a, b) => a > b ? a : b);
    final maxValue = dataMax > comparisonMax ? dataMax : comparisonMax;
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    final screenWidth = MediaQuery.of(context).size.width -
        114; // Account for padding and Y-axis
    // Only show scroll indicator if actual content width exceeds screen width
    final needsScrolling = actualContentWidth > screenWidth;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Fixed Y-axis on the left
              SizedBox(
                width: 50,
                child: _buildYAxis(maxY),
              ),
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
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: _buildSalesChartWithoutYAxis(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scroll indicator dots
        if (needsScrolling)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildScrollIndicator(),
          ),
      ],
    );
  }

  Widget _buildScrollIndicator() {
    const int dotCount = 5;
    final activeDot =
        (_scrollProgress * (dotCount - 1)).round().clamp(0, dotCount - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        final isActive = index == activeDot;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // Calculate nice round interval for Y-axis
  double _calculateNiceInterval(double maxValue) {
    if (maxValue <= 0) return 1;

    // Find the order of magnitude
    final magnitude = (maxValue / 5).abs();
    if (magnitude == 0) return 1;

    final power = (magnitude).toString().split('.')[0].length - 1;
    final base = pow(10, power).toDouble();

    // Find nice interval (1, 2, 5, 10, 20, 50, 100, etc.)
    final normalized = magnitude / base;
    double niceInterval;
    if (normalized <= 1) {
      niceInterval = base;
    } else if (normalized <= 2) {
      niceInterval = base * 2;
    } else if (normalized <= 5) {
      niceInterval = base * 5;
    } else {
      niceInterval = base * 10;
    }

    return niceInterval;
  }

  // Format Y-axis label to be compact (1K, 10K, etc.)
  String _formatYAxisLabel(double value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    String formatted;

    if (absValue >= 1000000) {
      formatted =
          '${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
    } else if (absValue >= 1000) {
      formatted =
          '${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
    } else if (absValue >= 1) {
      formatted = value.toStringAsFixed(0);
    } else {
      formatted = value.toStringAsFixed(1);
    }

    return formatted;
  }

  Widget _buildYAxis(double maxY) {
    // Calculate nice round interval
    final interval = _calculateNiceInterval(maxY);
    final niceMaxY = (maxY / interval).ceil() * interval;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(6, (index) {
              // Generate values from max to 0 in 5 steps
              final value = niceMaxY - (niceMaxY / 5 * index);

              String label;
              if (_isChecksFilter) {
                // For checks: show as integer
                label = _formatYAxisLabel(value);
              } else if (_isIncomeFilter || _isAvgCheckFilter) {
                // For income: show with currency symbol
                label =
                    '${CurrencyHelper.getCurrencySymbol()}${_formatYAxisLabel(value)}';
              } else {
                // For percentage
                label = '${value.toStringAsFixed(0)}%';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24), // Space for bottom labels
      ],
    );
  }

  Widget _buildSalesChartWithoutYAxis() {
    final dataMax = _visibleSalesData.reduce((a, b) => a > b ? a : b);
    final comparisonMax =
        _visibleComparisonData.reduce((a, b) => a > b ? a : b);
    final maxValue = dataMax > comparisonMax ? dataMax : comparisonMax;
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;
    final labels = _visibleChartLabels;
    final peakIndex = _visibleSalesData.indexOf(dataMax);
    final baseComparisonColor = const Color(0xFFFFA726);
    final baseCurrentColor = AppTheme.primaryBlue;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            direction: TooltipDirection.top,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              final value = rodIndex == 0
                  ? _visibleComparisonData[index]
                  : _visibleSalesData[index];
              final periodLabel = rodIndex == 0 ? 'Previous' : 'Current';
              return BarTooltipItem(
                '${labels[index]} ($periodLabel)\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(
                    text: _formatValue(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Y-axis is separate
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(labels.length, (index) {
          final isPeak = index == peakIndex;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _visibleComparisonData[index],
                width: 6,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(2)),
                color: isPeak
                    ? baseComparisonColor
                    : baseComparisonColor.withValues(alpha: 0.5),
              ),
              BarChartRodData(
                toY: _visibleSalesData[index],
                width: 6,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(2)),
                color: isPeak
                    ? baseCurrentColor
                    : baseCurrentColor.withValues(alpha: 0.5),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Format value based on the selected filter
  String _formatValue(double value) {
    if (_isChecksFilter) {
      // Checks: show as integer without currency
      return NumberFormat('#,##0', 'en_US').format(value.toInt());
    } else {
      // Income and Average Check: show with currency
      return '${CurrencyHelper.getCurrencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';
    }
  }

  Widget _buildListItem(String day, double value, double percentChange) {
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
          Text(
            day,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatValue(value),
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
}

class _FullscreenChartPage extends StatefulWidget {
  final String title;
  final List<double> salesData;
  final List<double> comparisonData;
  final List<String> chartLabels;
  final bool isIncomeMode;
  final bool isChecksFilter;
  final String currentPeriodLabel;
  final String previousPeriodLabel;

  const _FullscreenChartPage({
    required this.title,
    required this.salesData,
    required this.comparisonData,
    required this.chartLabels,
    required this.isIncomeMode,
    required this.isChecksFilter,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
  });

  @override
  State<_FullscreenChartPage> createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends State<_FullscreenChartPage> {
  final ScrollController _fullscreenScrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _fullscreenScrollController.dispose();
    // Restore portrait orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.isChecksFilter) {
      return NumberFormat('#,##0', 'en_US').format(value.toInt());
    } else {
      return '${CurrencyHelper.getCurrencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataMax = widget.salesData.isNotEmpty
        ? widget.salesData.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final comparisonMax = widget.comparisonData.isNotEmpty
        ? widget.comparisonData.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxValue = dataMax > comparisonMax ? dataMax : comparisonMax;
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;
    final peakIndex =
        widget.salesData.isNotEmpty ? widget.salesData.indexOf(dataMax) : -1;

    // Calculate chart width for scrolling - ensure enough space for all labels
    final dataCount = widget.chartLabels.length;
    final screenWidth = MediaQuery.of(context).size.width -
        100; // Account for padding and Y-axis
    // Each bar group needs ~30px minimum to show label clearly
    const double minGroupWidth = 30.0;
    final actualContentWidth = dataCount * minGroupWidth;
    final chartWidth = actualContentWidth.clamp(screenWidth, double.infinity);
    // Only show scroll indicator if actual content width exceeds screen width
    final needsScrolling = actualContentWidth > screenWidth;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend showing which color is which period
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(8),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withValues(alpha: 0.05),
              //         blurRadius: 4,
              //         offset: const Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       // Previous period (Orange)
              //       Container(
              //         width: 12,
              //         height: 12,
              //         decoration: BoxDecoration(
              //           color: const Color(0xFFFFA726),
              //           borderRadius: BorderRadius.circular(2),
              //         ),
              //       ),
              //       const SizedBox(width: 6),
              //       Text(
              //         widget.previousPeriodLabel,
              //         style: const TextStyle(
              //           fontSize: 11,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.black54,
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       // Current period (Blue)
              //       Container(
              //         width: 12,
              //         height: 12,
              //         decoration: BoxDecoration(
              //           color: AppTheme.primaryBlue,
              //           borderRadius: BorderRadius.circular(2),
              //         ),
              //       ),
              //       const SizedBox(width: 6),
              //       Text(
              //         widget.currentPeriodLabel,
              //         style: const TextStyle(
              //           fontSize: 11,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.black54,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                          children: [
                            // Fixed Y-axis on the left
                            SizedBox(
                              width: 55,
                              child: _buildYAxis(maxY),
                            ),
                            // Scrollable chart area
                            Expanded(
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification
                                      is ScrollUpdateNotification) {
                                    final maxExtent =
                                        notification.metrics.maxScrollExtent;
                                    if (maxExtent > 0) {
                                      setState(() {
                                        _scrollProgress =
                                            notification.metrics.pixels /
                                                maxExtent;
                                      });
                                    }
                                  }
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  controller: _fullscreenScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: chartWidth,
                                    child: _buildChartWithoutYAxis(
                                        maxY, peakIndex),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scroll indicator dots
                      if (needsScrolling)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildScrollIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate nice round interval for Y-axis
  double _calculateNiceInterval(double maxValue) {
    if (maxValue <= 0) return 1;

    final magnitude = (maxValue / 5).abs();
    if (magnitude == 0) return 1;

    final power = (magnitude).toString().split('.')[0].length - 1;
    final base = pow(10, power).toDouble();

    final normalized = magnitude / base;
    double niceInterval;
    if (normalized <= 1) {
      niceInterval = base;
    } else if (normalized <= 2) {
      niceInterval = base * 2;
    } else if (normalized <= 5) {
      niceInterval = base * 5;
    } else {
      niceInterval = base * 10;
    }

    return niceInterval;
  }

  // Format Y-axis label to be compact
  String _formatYAxisLabel(double value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    String formatted;

    if (absValue >= 1000000) {
      formatted =
          '${(value / 1000000).toStringAsFixed(absValue % 1000000 == 0 ? 0 : 1)}M';
    } else if (absValue >= 1000) {
      formatted =
          '${(value / 1000).toStringAsFixed(absValue % 1000 == 0 ? 0 : 1)}K';
    } else if (absValue >= 1) {
      formatted = value.toStringAsFixed(0);
    } else {
      formatted = value.toStringAsFixed(1);
    }

    return formatted;
  }

  Widget _buildYAxis(double maxY) {
    final interval = _calculateNiceInterval(maxY);
    final niceMaxY = (maxY / interval).ceil() * interval;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(6, (index) {
              final value = niceMaxY - (niceMaxY / 5 * index);

              String label;
              if (widget.isChecksFilter) {
                label = _formatYAxisLabel(value);
              } else if (widget.isIncomeMode) {
                label =
                    '${CurrencyHelper.getCurrencySymbol()}${_formatYAxisLabel(value)}';
              } else {
                label = '${value.toStringAsFixed(0)}%';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24), // Space for bottom labels
      ],
    );
  }

  Widget _buildScrollIndicator() {
    const int dotCount = 5;
    final activeDot =
        (_scrollProgress * (dotCount - 1)).round().clamp(0, dotCount - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        final isActive = index == activeDot;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildChartWithoutYAxis(double maxY, int peakIndex) {
    final baseComparisonColor = const Color(0xFFFFA726);
    final baseCurrentColor = AppTheme.primaryBlue;
    final labels = widget.chartLabels;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            direction: TooltipDirection.top,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              final value = rodIndex == 0
                  ? widget.comparisonData[index]
                  : widget.salesData[index];
              final periodLabel = rodIndex == 0
                  ? widget.previousPeriodLabel
                  : widget.currentPeriodLabel;
              return BarTooltipItem(
                '${labels[index]}\n$periodLabel\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: widget.isIncomeMode
                        ? _formatValue(value)
                        : '${value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Y-axis is separate
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(labels.length, (index) {
          final isPeak = index == peakIndex;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: widget.comparisonData[index],
                width: 6,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
                color: isPeak
                    ? baseComparisonColor
                    : baseComparisonColor.withValues(alpha: 0.5),
              ),
              BarChartRodData(
                toY: widget.salesData[index],
                width: 6,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
                color: isPeak
                    ? baseCurrentColor
                    : baseCurrentColor.withValues(alpha: 0.5),
              ),
            ],
          );
        }),
      ),
    );
  }
}
