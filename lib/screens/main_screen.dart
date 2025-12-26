import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/request_models/report_groups_request_model.dart';
import 'package:mobile_reporting/api/request_models/report_value_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_group_response_model.dart';
import 'package:mobile_reporting/api/response_models/report_value_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/mock_data_helper.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/hourly_sales_model.dart';
import 'package:mobile_reporting/models/report_group_and_value_model.dart';
import 'package:mobile_reporting/models/report_value_qty_model.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:collection/collection.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // General metrics data
  List<ReportGroupAndValueModel> generalMetrics = [];
  List<ReportGroupAndValueModel> paymentMetrics = [];
  List<HourlySalesModel> salesByHours = [];

  bool isLoading = false;
  bool firstLoad = true;
  bool isRestaurant = true;

  CancelToken cancelToken = CancelToken();
  DateTime startCurrentPeriod = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    00,
    00,
  );
  DateTime endCurrentPeriod = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    23,
    59,
  );
  DateTime startOldPeriod = DateTime(
      DateTime.now().subtract(const Duration(days: 1)).year,
      DateTime.now().subtract(const Duration(days: 1)).month,
      DateTime.now().subtract(const Duration(days: 1)).day,
      00,
      00);
  DateTime endOldPeriod = DateTime(
    DateTime.now().subtract(const Duration(days: 1)).year,
    DateTime.now().subtract(const Duration(days: 1)).month,
    DateTime.now().subtract(const Duration(days: 1)).day,
    23,
    59,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // TODO: Uncomment for real API data
    // await _loadRealData();

    // Using mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      generalMetrics = MockDataHelper.getGeneralMetrics();
      paymentMetrics = MockDataHelper.getPaymentMetrics();
      salesByHours = MockDataHelper.getSalesByHoursMockData();
      isLoading = false;
    });
  }

  Future<void> _loadRealData() async {
    try {
      if (firstLoad) {
        var body = ReportGroupsRequestModel(
          groupTag: "${await getIt<PreferencesHelper>().getType()}-MAIN",
          language: await getIt<PreferencesHelper>().getLang() ?? 'ka',
        );

        Options options = Options(
          contentType: 'application/json',
          headers: {
            'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
            'Authorization':
                'Bearer ${await getIt<PreferencesHelper>().getUserAuthToken()}',
          },
          validateStatus: (status) {
            return true;
          },
        );

        List<ReportGroupResponseModel> groups =
            List<ReportGroupResponseModel>.from((await Dio().post(
          '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_groups',
          data: json.encode(body),
          options: options,
        ))
                .data
                .map((e) => ReportGroupResponseModel.fromJson(
                    e as Map<String, dynamic>)));

        // Map API data to new design sections
        await _mapApiDataToSections(groups);
        firstLoad = false;
      } else {
        // Reload data for existing metrics
        await _reloadMetrics();
      }

      setState(() => isLoading = false);
    } catch (err) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _mapApiDataToSections(
      List<ReportGroupResponseModel> groups) async {
    generalMetrics.clear();
    paymentMetrics.clear();

    for (var group in groups) {
      var metric = ReportGroupAndValueModel(
        name: group.name,
        tag: group.tag,
        type: group.type,
        values: [],
      );

      // Load value for this metric
      await _loadMetricValue(metric);

      // Categorize into General or Payments
      if (_isPaymentMetric(group.tag)) {
        paymentMetrics.add(metric);
      } else {
        generalMetrics.add(metric);
      }
    }
  }

  Future<void> _loadMetricValue(ReportGroupAndValueModel metric) async {
    try {
      String? authToken = await getIt<PreferencesHelper>().getUserAuthToken();
      if (authToken == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SplashScreen()));
        return;
      }

      var response = await Dio().post(
        '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_value',
        cancelToken: cancelToken,
        data: json.encode(
          ReportValueRequestModel(
            reportTag: metric.tag,
            paramId: application.selectedStoreId ?? 0,
            startCurrentPeriod: startCurrentPeriod,
            endCurrentPeriod: endCurrentPeriod,
            startOldPeriod: startOldPeriod,
            endOldPeriod: endOldPeriod,
            paramId2: -1,
          ),
        ),
        options: Options(
          persistentConnection: false,
          contentType: 'application/json',
          headers: {
            'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
            'Authorization': 'Bearer $authToken',
          },
          validateStatus: (status) {
            return true;
          },
        ),
      );

      ReportValueResponseModel temp =
          ReportValueResponseModel.fromJson(response.data);
      metric.values = [
        ReportValueQtyModel(
          currentValue: temp.currentValue,
          name: '',
          oldValue: temp.oldValue,
          id: -1,
          currentQuantity: 0,
          oldQuantity: 0,
        )
      ];
    } catch (err) {
      return;
    }
  }

  Future<void> _reloadMetrics() async {
    List<Future<void>> futures = [];

    for (var metric in generalMetrics) {
      futures.add(_loadMetricValue(metric));
    }

    for (var metric in paymentMetrics) {
      futures.add(_loadMetricValue(metric));
    }

    await Future.wait(futures);
  }

  bool _isPaymentMetric(String tag) {
    return tag == 'CASH' ||
        tag == 'CARD' ||
        tag == 'CONSIGNATION' ||
        tag == 'LOYALTY' ||
        tag == 'RETAIL_CASH' ||
        tag == 'RETAIL_CARD' ||
        tag == 'RETAIL_CONSIGNATION' ||
        tag == 'RETAIL_LOYALTY';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker and Store Selector Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  PickerWidget(
                    screenType: ScreenType.dashboardScreen,
                    showCompareDateFilter: true,
                    showStoreFilter: true,
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

                      if (firstLoad) {
                        if (await getIt<PreferencesHelper>().getType() ==
                                'RESTAURANT' &&
                            !application.isFastFood!) {
                          isRestaurant = true;
                        } else {
                          isRestaurant = false;
                        }
                        firstLoad = false;
                      }

                      await _loadData();
                    },
                    onlyDayPicker: false,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range & Store Summary Card
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.04),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Icon(
                  //             Icons.calendar_today_outlined,
                  //             size: 16,
                  //             color: AppTheme.primaryBlue,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               '${DateFormat('MMM dd, yyyy').format(startCurrentPeriod)} - ${DateFormat('MMM dd, yyyy').format(endCurrentPeriod)}',
                  //               style: const TextStyle(
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: Color(0xFF2D3748),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Row(
                  //         children: [
                  //           Icon(
                  //             Icons.compare_arrows,
                  //             size: 16,
                  //             color: Colors.grey[600],
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               'vs ${DateFormat('MMM dd, yyyy').format(startOldPeriod)} - ${DateFormat('MMM dd, yyyy').format(endOldPeriod)}',
                  //               style: TextStyle(
                  //                 fontSize: 12,
                  //                 color: Colors.grey[600],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       if (application.selectedStoreId != null) ...[
                  //         const SizedBox(height: 8),
                  //         Row(
                  //           children: [
                  //             Icon(
                  //               Icons.store_outlined,
                  //               size: 16,
                  //               color: Colors.grey[600],
                  //             ),
                  //             const SizedBox(width: 8),
                  //             Expanded(
                  //               child: Text(
                  //                 application.stores
                  //                     .firstWhere((element) =>
                  //                         element.id ==
                  //                         application.selectedStoreId)
                  //                     .name,
                  //                 style: TextStyle(
                  //                   fontSize: 12,
                  //                   color: Colors.grey[600],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // General Section Header
                  const Text(
                    'General',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // General Metrics Grid
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    )
                  else if (generalMetrics.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: generalMetrics.length,
                      itemBuilder: (context, index) {
                        return _buildMetricCard(generalMetrics[index]);
                      },
                    ),

                  const SizedBox(height: 24),

                  // Payments Section Header
                  if (paymentMetrics.isNotEmpty) ...[
                    const Text(
                      'Payments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payments Metrics Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: paymentMetrics.length,
                      itemBuilder: (context, index) {
                        return _buildMetricCard(paymentMetrics[index]);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sales by Hours Chart
                  if (!isLoading && salesByHours.isNotEmpty)
                    _buildSalesByHoursChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(ReportGroupAndValueModel metric) {
    if (metric.values.isEmpty) {
      // Show loading state for this card
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForMetric(metric.tag),
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentValue = metric.values.first.currentValue;
    final oldValue = metric.values.first.oldValue;
    final isPositive = currentValue > oldValue;
    final changePercent =
        oldValue > 0 ? ((currentValue - oldValue) / oldValue * 100).abs() : 0.0;
    final hasChange = oldValue > 0 && oldValue != currentValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForMetric(metric.tag),
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metric.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatValue(currentValue, metric.type),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasChange)
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : '-'}${changePercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSalesByHoursChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales by Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < salesByHours.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              salesByHours[value.toInt()].timeRange,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: salesByHours.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: const Color(0xFF5B7FFF),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildLegendItem('10:00am - 22:00', const Color(0xFF5B7FFF)),
              _buildLegendItem('10:00am - 22:00', const Color(0xFF8E9BAE)),
              _buildLegendItem('10:00am - 22:00', const Color(0xFF8E9BAE)),
              _buildLegendItem('10:00am - 22:00', const Color(0xFF8E9BAE)),
              _buildLegendItem('10:00am - 22:00', const Color(0xFF8E9BAE)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getIconForMetric(String tag) {
    // Map all possible tags from API to icons
    switch (tag) {
      // General metrics
      case 'SALES':
      case 'RETAIL_SALES':
        return Icons.receipt_outlined;
      case 'SELLCOST':
      case 'RETAIL_SELLCOST':
        return Icons.shopping_bag_outlined;
      case 'PROFIT_PERCENT':
      case 'RETAIL_PROFIT_PERCENT':
      case 'RETAIL_DISCOUNT_PERCENT':
        return Icons.percent;
      case 'PROFIT':
      case 'RETAIL_PROFIT':
        return Icons.trending_up;
      case 'BILLS_COUNT':
      case 'RECEIPTS':
      case 'RETAIL_SALES_CNT':
        return Icons.receipt_long_outlined;
      case 'AVG_CHECK':
      case 'AVERAGE':
      case 'RETAIL_AVERAGE':
        return Icons.receipt;
      case 'DISCOUNT':
      case 'RETAIL_DISCOUNT_AMOUNT':
        return Icons.local_offer_outlined;
      case 'REFUND':
      case 'RETAIL_RETURN_CUSTOMER':
      case 'RETAIL_RETURN_VENDOR':
        return Icons.replay;
      case 'GUESTS':
        return Icons.people_outline;
      case 'AVERAGETIME':
        return Icons.access_time;

      // Payment metrics
      case 'CASH':
      case 'RETAIL_CASH':
        return Icons.attach_money;
      case 'CARD':
      case 'RETAIL_CARD':
        return Icons.credit_card;
      case 'CONSIGNATION':
      case 'RETAIL_CONSIGNATION':
        return Icons.handshake_outlined;
      case 'LOYALTY':
      case 'RETAIL_LOYALTY':
        return Icons.favorite_border;
      case 'MONEY':
      case 'RETAIL_IN_MONEY':
      case 'RETAIL_IN_AMOUNT':
        return Icons.account_balance_wallet_outlined;
      case 'RETAIL_OUT_MONEY':
        return Icons.money_off_outlined;

      // Inventory metrics
      case 'RETAIL_PURCHASE':
        return Icons.shopping_cart_outlined;
      case 'RETAIL_CUTOFF':
        return Icons.remove_circle_outline;
      case 'RETAIL_REST':
        return Icons.inventory_2_outlined;
      case 'RETAIL_DEBT_CUSTOMER':
        return Icons.person_outline;
      case 'RETAIL_DEBT_VENDOR':
        return Icons.business_outlined;
      case 'RETAIL_SERVICE_AMOUNT':
        return Icons.room_service_outlined;

      default:
        return Icons.analytics_outlined;
    }
  }

  String _formatValue(double value, String type) {
    if (type == 'PERCENT') {
      return '${value.toStringAsFixed(1)}%';
    } else if (type == 'COUNT') {
      return value.floor().toString();
    } else if (type == 'TIME') {
      // Format time in minutes
      return '${value.floor()}min';
    } else {
      // AMOUNT - use currency symbol based on locale or settings
      return '\$${value.floor()}';
    }
  }

  @override
  void dispose() {
    cancelToken.cancel();
    super.dispose();
  }
}
