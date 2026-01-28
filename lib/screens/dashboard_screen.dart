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
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';
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
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sales Section Header
                  Text(
                    S.of(context).sales,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sales Metrics Grid
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: RotatingLogoLoader(size: 60),
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
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).sales,
                            svgIcon: 'assets/icons/sales/sales.svg',
                            metric: _dashboardData!.current.sales.sales,
                            currency: CurrencyHelper.getCurrencySymbol(),
                            isLarge: false,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).selfcost,
                            svgIcon: 'assets/icons/sales/selfcost.svg',
                            metric: _dashboardData!.current.sales.selfcost,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).profit,
                            svgIcon: 'assets/icons/sales/profit.svg',
                            metric: _dashboardData!.current.sales.profit,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimalPercent(
                            title: S.of(context).profitPercent,
                            svgIcon: 'assets/icons/sales/profit_%.svg',
                            metric: _dashboardData!.current.sales.profitPercent,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Bills Section Header
                  if (_dashboardData != null) ...[
                    Text(
                      S.of(context).bills,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bills Metrics Grid
                    StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).avgCheck,
                            svgIcon: 'assets/icons/bills/avg_check.svg',
                            metric: _dashboardData!.current.bills.avgCheck,
                            currency: CurrencyHelper.getCurrencySymbol(),
                            isLarge: false,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromInt(
                            title: S.of(context).bills,
                            svgIcon: 'assets/icons/bills/bills_count.svg',
                            metric: _dashboardData!.current.bills.billsCount,
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).discount,
                            svgIcon: 'assets/icons/bills/discount.svg',
                            metric: _dashboardData!.current.bills.discount,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).refund,
                            svgIcon: 'assets/icons/bills/refund.svg',
                            metric: _dashboardData!.current.bills.refund,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

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
                    StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).cash,
                            svgIcon: 'assets/icons/payments/cash.svg',
                            metric: _dashboardData!.current.payments.cash,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).card,
                            svgIcon: 'assets/icons/payments/card.svg',
                            metric: _dashboardData!.current.payments.card,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).consignation,
                            svgIcon: 'assets/icons/payments/consignation.svg',
                            metric:
                                _dashboardData!.current.payments.consignation,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 0.55,
                          child: DashboardMetricCard.fromDecimal(
                            title: S.of(context).loyalty,
                            svgIcon: 'assets/icons/payments/loyalty.svg',
                            metric: _dashboardData!.current.payments.loyalty,
                            currency: CurrencyHelper.getCurrencySymbol(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
