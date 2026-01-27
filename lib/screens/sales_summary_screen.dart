import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/response_models/daily_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/hourly_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/weekday_sales_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';

class SalesSummaryScreen extends StatefulWidget {
  final String reportTitle;

  const SalesSummaryScreen({
    super.key,
    required this.reportTitle,
  });

  @override
  State<SalesSummaryScreen> createState() => _SalesSummaryScreenState();
}

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  final ReportsService _reportsService = ReportsService();

  bool isLoading = false;
  DateTime startCurrentPeriod = DateTime.now();
  DateTime endCurrentPeriod = DateTime.now();
  DateTime startOldPeriod = DateTime.now().subtract(const Duration(days: 1));
  DateTime endOldPeriod = DateTime.now().subtract(const Duration(days: 1));

  String? _companyName;
  String? _email;

  String? _selectedFilter;
  List<String> get _filterOptions => [
    S.of(context).income,
    S.of(context).checksFilter,
    S.of(context).averageCheck,
  ];

  // Data from API
  List<DailySalesResponseModel> _dailySalesData = [];
  List<HourlySalesResponseModel> _hourlySalesData = [];
  List<WeekdaySalesResponseModel> _weekdaySalesData = [];

  // Chart data based on report type
  List<String> get _chartLabels {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) => e.hourRange).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData
          .map((e) => _getLocalizedDayName(e.name))
          .toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData
          .map((e) => DateFormat('dd.MM').format(e.date))
          .toList();
    }
    return [];
  }

  List<double> get _salesData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) => e.currentSalesPercent).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) => e.currentSalesPercent).toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData.map((e) => e.currentSalesPercent).toList();
    }
    return [];
  }

  List<double> get _comparisonData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) => e.previousSalesPercent).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) => e.previousSalesPercent).toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData.map((e) => e.previousSalesPercent).toList();
    }
    return [];
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
      return l10n.hourlySalesOverview.split(' ')[0]; // Taking "Hour" roughly or just define day
    } else if (widget.reportTitle.contains('Weekday')) {
      return l10n.weekday; // I should add weekday to ARB if not there
    } else if (widget.reportTitle.contains('Month')) {
      return l10n.month;
    }
    return l10n.day;
  }

  List<Map<String, dynamic>> get _listData {
    if (widget.reportTitle.contains('Hour')) {
      return _hourlySalesData.map((e) {
        double percentChange = 0;
        if (e.previousSales > 0) {
          percentChange =
              ((e.currentSales - e.previousSales) / e.previousSales) * 100;
        }
        return {
          'label': e.hourRange,
          'value': e.currentSales,
          'percentChange': percentChange,
        };
      }).toList();
    } else if (widget.reportTitle.contains('Weekday')) {
      return _weekdaySalesData.map((e) {
        double percentChange = 0;
        if (e.previousSales > 0) {
          percentChange =
              ((e.currentSales - e.previousSales) / e.previousSales) * 100;
        }
        return {
          'label': _getLocalizedDayName(e.name),
          'value': e.currentSales,
          'percentChange': percentChange,
        };
      }).toList();
    } else if (widget.reportTitle.contains('Day')) {
      return _dailySalesData.map((e) {
        double percentChange = 0;
        if (e.previousSales > 0) {
          percentChange =
              ((e.currentSales - e.previousSales) / e.previousSales) * 100;
        }
        return {
          'label': _getLocalizedDayName(DateFormat('EEEE').format(e.date)),
          'value': e.currentSales,
          'percentChange': percentChange,
        };
      }).toList();
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    setState(() {});
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
                color: Colors.black.withValues(alpha: 0.1),
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
                  color: AppTheme.primaryBlue.withValues(alpha: 0.05),
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
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
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
                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              S.of(context).profileInfo,
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
                            child: Text(
                              S.of(context).close,
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
                            icon: const Icon(Icons.logout, size: 18),
                            label: Text(
                              S.of(context).logout,
                              style: const TextStyle(
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
              widget.reportTitle,
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
                  onPressed: _showProfileDialog,
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
                      // Filter Dropdown
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildFilterDropdown(
                          Icons.tune,
                          _selectedFilter ?? S.of(context).income,
                          () => _showFilterSelector(),
                        ),
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
                            SizedBox(
                              height: 280,
                              child: _buildSalesChart(),
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
                                    S.of(context).income,
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
                            ..._listData.map((item) => _buildListItem(
                                  item['label'],
                                  item['value'],
                                  item['percentChange'],
                                )),
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
                    S.of(context).selectFilter,
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
              ..._filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
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
                        _selectedFilter = filter;
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
                            Icons.attach_money,
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              filter,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
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

  Widget _buildSalesChart() {
    if (_salesData.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noDataAvailable,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final dataMax = _salesData.reduce((a, b) => a > b ? a : b);
    final comparisonMax = _comparisonData.reduce((a, b) => a > b ? a : b);
    final maxValue = dataMax > comparisonMax ? dataMax : comparisonMax;
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;
    final labels = _chartLabels;

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
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${labels[group.x]}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: rodIndex == 0
                        ? '${_salesData[group.x].toStringAsFixed(1)}%'
                        : '${_comparisonData[group.x].toStringAsFixed(1)}%',
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
                  // Label skipping logic to prevent overlap
                  int interval = 1;
                  if (labels.length > 15) {
                    interval = 5;
                  } else if (labels.length > 10) {
                    interval = 2;
                  }

                  if (value.toInt() % interval != 0) {
                    return const Text('');
                  }

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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                );
              },
            ),
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
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _salesData[index],
                width: 12, // Adjusted for better fitting
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                color: AppTheme.primaryBlue, // User requested primary blue
              ),
              BarChartRodData(
                toY: _comparisonData[index],
                width: 12, // Adjusted for better fitting
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                color: const Color(0xFFFFA726), // User requested Orange
              ),
            ],
          );
        }),
      ),
    );
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
                '${value.toStringAsFixed(2)}₾',
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
