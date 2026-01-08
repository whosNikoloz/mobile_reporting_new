import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mobile_reporting/api/response_models/dashboard_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/dashboard_metric_card.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ReportsService _reportsService = ReportsService();

  DashboardResponse? _dashboardData;
  bool isLoading = false;
  bool firstLoad = true;
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
  DateTime startPreviousPeriod = DateTime(
      DateTime.now().subtract(const Duration(days: 1)).year,
      DateTime.now().subtract(const Duration(days: 1)).month,
      DateTime.now().subtract(const Duration(days: 1)).day,
      00,
      00);
  DateTime endPreviousPeriod = DateTime(
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

    try {
      final storeId = application.selectedStoreId ?? 0;

      final response = await _reportsService.getDashboardData(
        storeId: storeId,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startPreviousPeriod,
        endPreviousPeriod: endPreviousPeriod,
      );

      setState(() {
        _dashboardData = response;
        isLoading = false;
      });
    } catch (err) {
      setState(() => isLoading = false);
    }
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
                      startPreviousPeriod = dt3;
                      endPreviousPeriod = dt4;

                      firstLoad = false;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadData();
                      });
                    },
                    onlyDayPicker: false,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Section Header
                  Text(
                    S.of(context).general,
                    style: const TextStyle(
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
                  else if (_dashboardData == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          S.of(context).noDataAvailable,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1.42,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).sales,
                            icon: Icons.receipt_outlined,
                            metric: _dashboardData!.current.general.sales,
                            currency: CurrencyHelper.getCurrencySymbol(),
                            isLarge: true,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).selfcost,
                            icon: Icons.shopping_bag_outlined,
                            metric: _dashboardData!.current.general.selfcost,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).profit,
                            icon: Icons.trending_up,
                            metric: _dashboardData!.current.general.profit,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1.42,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).avgCheck,
                            icon: Icons.receipt,
                            metric: _dashboardData!.current.general.avgCheck,
                            currency: CurrencyHelper.getCurrencySymbol(),
                            isLarge: true,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromDecimalPercent(
                            title: S.of(context).profitPercent,
                            icon: Icons.percent,
                            metric:
                                _dashboardData!.current.general.profitPercent,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromInt(
                            title: S.of(context).bills,
                            icon: Icons.receipt_long_outlined,
                            metric: _dashboardData!.current.general.billsCount,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).discount,
                            icon: Icons.local_offer_outlined,
                            metric: _dashboardData!.current.general.discount,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.7,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).refund,
                            icon: Icons.replay,
                            metric: _dashboardData!.current.general.refund,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Payments Section Header
                  if (_dashboardData != null) ...[
                    Text(
                      S.of(context).payments,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payments Metrics Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        DashboardMetricCard.fromDecimal(
                          title: S.of(context).cash,
                          icon: Icons.attach_money,
                          metric: _dashboardData!.current.payments.cash,
                          currency: CurrencyHelper.getCurrencySymbol(),
                        ),
                        DashboardMetricCard.fromDecimal(
                          title: S.of(context).card,
                          icon: Icons.credit_card,
                          metric: _dashboardData!.current.payments.card,
                          currency: CurrencyHelper.getCurrencySymbol(),
                        ),
                        DashboardMetricCard.fromDecimal(
                          title: S.of(context).consignation,
                          icon: Icons.handshake_outlined,
                          metric: _dashboardData!.current.payments.consignation,
                          currency: CurrencyHelper.getCurrencySymbol(),
                        ),
                        DashboardMetricCard.fromDecimal(
                          title: S.of(context).loyalty,
                          icon: Icons.favorite_border,
                          metric: _dashboardData!.current.payments.loyalty,
                          currency: CurrencyHelper.getCurrencySymbol(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sales by Hours Chart
                  if (!isLoading &&
                      _dashboardData != null &&
                      _dashboardData!.current.salesByHours.isNotEmpty)
                    _buildSalesByHoursChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesByHoursChart() {
    final salesByHours = _dashboardData!.current.salesByHours;
    final maxAmount =
        salesByHours.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

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
              Text(
                S.of(context).salesByHours,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Icon(
                Icons.show_chart,
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
                maxY: maxAmount * 1.2,
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
                              salesByHours[value.toInt()].hour,
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
                        toY: entry.value.amount,
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
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).totalBills,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salesByHours
                          .map((e) => e.billsCount)
                          .reduce((a, b) => a + b)
                          .toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      S.of(context).totalAmount,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${CurrencyHelper.getCurrencySymbol()}${salesByHours.map((e) => e.amount).reduce((a, b) => a + b).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
