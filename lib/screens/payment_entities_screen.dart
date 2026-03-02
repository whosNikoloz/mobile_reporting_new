import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/widgets/chart_details_modal.dart';
import 'package:mobile_reporting/api/response_models/payment_entities_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class PaymentEntitiesScreen extends StatefulWidget {
  const PaymentEntitiesScreen({super.key});

  @override
  State<PaymentEntitiesScreen> createState() => _PaymentEntitiesScreenState();
}

enum _ReportType { income, quantity }

class _PaymentEntitiesScreenState extends State<PaymentEntitiesScreen> {
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
  List<PaymentEntitiesResponseModel> _reportData = [];

  // User Data
  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  // Colors for chart
  final List<Color> _chartColors = [
    const Color(0xFF3B5EE8), // Primary Blue
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFF9B5DE5), // Purple
    const Color(0xFF00BBF9), // Light Blue
    const Color(0xFFF15BB5), // Pink
    const Color(0xFF00F5D4), // Mint
    const Color(0xFFFB5607), // Orange
    const Color(0xFF8338EC), // Deep Purple
    const Color(0xFF3A86FF), // Another Blue
    Colors.grey,
    Colors.brown,
    Colors.indigo,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadUserData();
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
      final response = await _reportsService.getPaymentEntitiesReport(
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
      print('❌ Error loading payment entities report: $err');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getColorForIndex(int index) {
    return _chartColors[index % _chartColors.length];
  }

  String _getReportTypeLabel(_ReportType type) {
    switch (type) {
      case _ReportType.income:
        return S.of(context).income;
      case _ReportType.quantity:
        return S.of(context).quantity;
    }
  }

  double _getCurrentValue(PaymentEntitiesResponseModel item) {
    switch (_selectedType) {
      case _ReportType.income:
        return item.currentAmount;
      case _ReportType.quantity:
        return item.currentQnt.toDouble();
    }
  }

  double _getPreviousValue(PaymentEntitiesResponseModel item) {
    switch (_selectedType) {
      case _ReportType.income:
        return item.previousAmount;
      case _ReportType.quantity:
        return item.previousQnt.toDouble();
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
              S.of(context).salesByPaymentMethods,
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
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                //   color: Colors.grey.shade100,
                //   child: Row(
                //     children: [
                //       // Type Dropdown
                //       Expanded(
                //         flex: 3,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               S.of(context).displayValue,
                //               style: const TextStyle(
                //                 fontSize: 12,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.black54,
                //               ),
                //             ),
                //             const SizedBox(height: 6),
                //             _buildDropdown(context,
                //                 icon: Icons.tune,
                //                 value: _getReportTypeLabel(_selectedType),
                //                 onTap: _showTypeSelector),
                //           ],
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       // Top N Dropdown
                //       Expanded(
                //         flex: 2,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Text(
                //               "Top",
                //               style: TextStyle(
                //                 fontSize: 12,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.black54,
                //               ),
                //             ),
                //             const SizedBox(height: 6),
                //             _buildDropdown(context,
                //                 icon: Icons.format_list_numbered,
                //                 value: "$_selectedTop",
                //                 onTap: _showTopSelector),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                Expanded(
                  child: isLoading
                      ? Center(child: RotatingLogoLoader())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_reportData.isNotEmpty) ...[
                              // Pie Chart Section
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
                                    // Text(
                                    //   S.of(context).salesOverview,
                                    //   style: const TextStyle(
                                    //     fontSize: 16,
                                    //     fontWeight: FontWeight.w600,
                                    //     color: Colors.black87,
                                    //   ),
                                    // ),
                                    // const SizedBox(height: 24),
                                    SizedBox(
                                      height: 250,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: _buildPieChartSections(),
                                          pieTouchData: PieTouchData(
                                            enabled: true,
                                            touchCallback: (FlTouchEvent event,
                                                pieTouchResponse) {
                                              if (event is FlTapUpEvent &&
                                                  pieTouchResponse != null &&
                                                  pieTouchResponse
                                                          .touchedSection !=
                                                      null) {
                                                final index = pieTouchResponse
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                                if (index >= 0 &&
                                                    index <
                                                        _reportData.length) {
                                                  _showDataPointDetails(index);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Custom Legend
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: List.generate(
                                          _reportData.length, (index) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: _getColorForIndex(index),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _reportData[index].entityName,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        );
                                      }),
                                    )
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
                                            S.of(context).paymentMethod ??
                                                "Payment Method",
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

  List<PieChartSectionData> _buildPieChartSections() {
    double total =
        _reportData.fold(0, (sum, item) => sum + _getCurrentValue(item));
    if (total == 0) return [];

    return List.generate(_reportData.length, (i) {
      final isTouched = false;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final item = _reportData[i];
      final value = _getCurrentValue(item);
      final percent = (value / total) * 100;

      return PieChartSectionData(
        color: _getColorForIndex(i),
        value: value,
        title: '${percent.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  Widget _buildListItem(int index) {
    final item = _reportData[index];
    final color = _getColorForIndex(index);
    final currentValue = _getCurrentValue(item);
    final previousValue = _getPreviousValue(item);

    double percentChange = 0;
    if (previousValue > 0) {
      percentChange = ((currentValue - previousValue) / previousValue) * 100;
    }

    String formattedValue = "";
    String formattedPrevious = "";

    if (_selectedType == _ReportType.income) {
      formattedValue = CurrencyHelper.format(currentValue, showSymbol: false);
      formattedPrevious =
          CurrencyHelper.format(previousValue, showSymbol: false);
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
          // Color indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Name and percentage change
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.entityName,
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

    if (_selectedType == _ReportType.income) {
      formattedValue = CurrencyHelper.format(currentValue, showSymbol: false);
      formattedPrevious =
          CurrencyHelper.format(previousValue, showSymbol: false);
    } else {
      formattedValue = currentValue.toStringAsFixed(0);
      formattedPrevious = previousValue.toStringAsFixed(0);
    }

    ChartDetailsModal.show(
      context: context,
      title: item.entityName,
      currentValueLabel: S.of(context).currentValue ?? "Current Value",
      currentValueText: formattedValue,
      previousValueLabel: S.of(context).previousValue ?? "Previous Value",
      previousValueText: formattedPrevious,
      changeLabel: S.of(context).change ?? "Change",
      percentChange: percentChange,
      closeLabel: S.of(context).close ?? "Close",
    );
  }
}
