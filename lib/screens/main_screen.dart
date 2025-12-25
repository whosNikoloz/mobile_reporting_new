import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/request_models/report_groups_request_model.dart';
import 'package:mobile_reporting/api/request_models/report_value_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_group_response_model.dart';
import 'package:mobile_reporting/api/response_models/report_list_response_model.dart';
import 'package:mobile_reporting/api/response_models/report_value_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/report_group_and_value_model.dart';
import 'package:mobile_reporting/models/report_value_qty_model.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:collection/collection.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var a = getIt<PreferencesHelper>().getType();

  var numberFormatter = NumberFormat.decimalPattern('en');
  List<ReportGroupAndValueModel> main = [];

  ReportGroupAndValueModel? report;
  bool reportLoading = false;

  int? i;

  bool firstLoad = true;

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
  bool updateReport = true;
  bool isRestaurant = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    if (i == null && main.isNotEmpty) {
      i = main.length - 1;
      setState(() {});
    }
    if (i != null && i! >= 0) {
      i = -1;
      List<Future<void>> l = [];
      cancelToken.cancel();
      cancelToken = CancelToken();
      for (int j = 0; j < main.length; j++) {
        l.add(addElementToMain(main[main.length - 1 - j]));
      }
      if (updateReport) {
        l.add(getStatsByDays(
            dt1: startCurrentPeriod,
            dt2: endCurrentPeriod,
            dt3: startOldPeriod,
            dt4: endOldPeriod));
        updateReport = false;
      }
      Future.wait(l).then((value) {});
    }

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: PickerWidget(
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
                  updateReport = true;
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
                    var body = ReportGroupsRequestModel(
                      groupTag:
                          "${await getIt<PreferencesHelper>().getType()}-MAIN",
                      language:
                          await getIt<PreferencesHelper>().getLang() ?? 'ka',
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

                    main.clear();
                    for (var element in groups) {
                      main.add(
                        ReportGroupAndValueModel(
                          name: element.name,
                          tag: element.tag,
                          type: element.type,
                          values: [],
                        ),
                      );
                    }
                    if (!isRestaurant) {
                      main.removeWhere((element) =>
                          element.tag == 'AVERAGETIME' ||
                          element.tag == 'GUESTS');
                    }
                    firstLoad = false;
                  } else {
                    for (var element in main) {
                      element.values.clear();
                    }
                  }
                  i = null;

                  setState(() {});
                },
                onlyDayPicker: false,
              ),
            ),
            Divider(
              height: 0,
              color: Colors.grey.shade500,
              indent: 7,
              endIndent: 7,
            ),
            ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 0,
                color: Colors.grey.shade500,
                indent: 7,
                endIndent: 7,
              ),
              shrinkWrap: true,
              itemCount: main.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, int index) {
                double? percent;
                bool? currentIsMore;
                if (main[index].values.isNotEmpty) {
                  percent = 100 -
                      (main[index].values.first.currentValue /
                          main[index].values.first.oldValue *
                          100);
                  currentIsMore = main[index].values.first.currentValue >
                      main[index].values.first.oldValue;
                  if (currentIsMore) {
                    percent = percent * -1;
                  }
                }
                return SizedBox(
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          child: SvgPicture.asset(
                            'assets/main_board_changed/${main[index].tag == 'RETAIL_SALES' ? 'რეალიზაცია' : main[index].tag == 'RETAIL_PROFIT' ? 'მოგება' : main[index].tag == 'RETAIL_DISCOUNT_AMOUNT' ? 'ფასდაკლება' : main[index].tag == 'RETAIL_DISCOUNT_PERCENT' ? 'ფასდაკლების პროცენტი' : main[index].tag == 'RETAIL_AVERAGE' ? 'საშუალო ჩეკი' : main[index].tag == 'RETAIL_SALES_CNT' ? 'ჩეკების რაოდენობა' : main[index].tag == 'RETAIL_SERVICE_AMOUNT' ? 'გაწეული მომსახურება' : main[index].tag == 'RETAIL_IN_AMOUNT' ? 'შემოსული თანხა' : main[index].tag == 'RETAIL_OUT_MONEY' ? 'გასული თანხა' : main[index].tag == 'RETAIL_IN_MONEY' ? 'შემოსული თანხა' : main[index].tag == 'SALES' ? 'გაყიდვები' : main[index].tag == 'RECEIPTS' ? 'ჩეკების რაოდენობა' : main[index].tag == 'AVERAGE' ? 'საშუალო ჩეკი' : main[index].tag == 'DISCOUNT' ? 'ფასდაკლება' : main[index].tag == 'GUESTS' ? 'ფასდაკლება' : main[index].tag == 'AVERAGETIME' ? 'საშუალო დრო' : main[index].tag == 'MONEY' ? 'შემოსული თანხა' : main[index].tag == 'RETAIL_PURCHASE' ? 'შესყიდვები' : main[index].tag == 'RETAIL_CUTOFF' ? 'ჩამოწერილი საქონელი' : main[index].tag == 'RETAIL_REST' ? 'საქონელის ნაშთი' : main[index].tag == 'RETAIL_RETURN_CUSTOMER' ? 'დაბრუნება მყიდველისგან' : main[index].tag == 'RETAIL_RETURN_VENDOR' ? 'დაბრუნება მომწოდებლებთან' : main[index].tag == 'RETAIL_DEBT_CUSTOMER' ? 'მყიდველების დავალიანება' : main[index].tag == 'RETAIL_DEBT_VENDOR' ? 'დავალიანება მომწოდებლებთან' : ''}.svg',
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                main[index].name,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                main[index].values.isNotEmpty &&
                                        main[index].values.first.currentValue !=
                                            0 &&
                                        main[index].values.first.oldValue != 0
                                    ? '${currentIsMore == null ? '' : currentIsMore ? '↑' : '↓'}${percent?.round()}%'
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: currentIsMore == null || currentIsMore
                                      ? Colors.green.shade800
                                      : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (main[index].values.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              numberFormatter.format(main[index]
                                  .values
                                  .first
                                  .currentValue
                                  .floor()),
                              textAlign: TextAlign.end,
                              softWrap: false,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        if (main[index].values.isEmpty) const Spacer(),
                        if (main[index].values.isEmpty)
                          const SpinKitRing(
                            color: AppTheme.primaryBlue,
                            size: 15.0,
                            lineWidth: 2,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(
              height: 0,
              color: Colors.grey.shade500,
              indent: 7,
              endIndent: 7,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'გაყიდვები დღეებით',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 18,
                    ),
                  ),
                  if (reportLoading)
                    const SizedBox(
                      width: 10,
                    ),
                  if (reportLoading)
                    const SpinKitRing(
                      color: AppTheme.primaryBlue,
                      size: 30.0,
                      lineWidth: 2,
                    ),
                ],
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(startCurrentPeriod),
              style: const TextStyle(
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (report != null)
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    labelIntersectAction: AxisLabelIntersectAction.rotate45,
                    tickPosition: TickPosition.inside,
                    labelAlignment: LabelAlignment.center,
                    labelStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  enableAxisAnimation: true,
                  tooltipBehavior: TooltipBehavior(
                    enable: false,
                    header: '',
                    tooltipPosition: TooltipPosition.pointer,
                    textStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  series: <ColumnSeries<ReportValueQtyModel, String>>[
                    ColumnSeries<ReportValueQtyModel, String>(
                      animationDuration: 0,
                      dataSource: application.selectedStoreId == null
                          ? report!.values
                          : report!.values
                              .where((element) =>
                                  element.name ==
                                  application.stores
                                      .firstWhere((element) =>
                                          element.id ==
                                          application.selectedStoreId)
                                      .name)
                              .toList(),
                      xValueMapper: (ReportValueQtyModel sales, _) =>
                          '${sales.name.substring(0, sales.name.length > 7 ? 7 : sales.name.length)} ${report!.tag != 'SALES_BY_DAYS' ? '.' : ''}',
                      yValueMapper: (ReportValueQtyModel sales, _) =>
                          sales.currentValue,
                      sortingOrder: report!.tag != 'SALES_BY_DAYS'
                          ? SortingOrder.ascending
                          : SortingOrder.none,
                      sortFieldValueMapper: (ReportValueQtyModel data, _) =>
                          data.currentValue,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: false,
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
  }

  Future<void> addElementToMain(element) async {
    try {
      String? authToken = await getIt<PreferencesHelper>().getUserAuthToken();
      if (authToken == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SplashScreen()));
        return;
      }
      var response = await Dio().post(
        '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_value',
        cancelToken: cancelToken,
        data: json.encode(
          ReportValueRequestModel(
            reportTag: element.tag,
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
      main.where((e) => element == e).firstOrNull?.values = [
        ReportValueQtyModel(
          currentValue: temp.currentValue,
          name: '',
          oldValue: temp.oldValue,
          id: -1,
          currentQuantity: 0,
          oldQuantity: 0,
        )
      ];
      setState(() {});
    } catch (err) {
      return;
    }
  }

  Future<void> getStatsByDays(
      {required DateTime dt1,
      required DateTime dt2,
      required DateTime dt3,
      required DateTime dt4}) async {
    try {
      reportLoading = true;
      setState(() {});
      startCurrentPeriod = dt1;
      endCurrentPeriod = dt2;
      startOldPeriod = dt3;
      endOldPeriod = dt4;
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

      List<ReportListResponseModel>? temp = List<ReportListResponseModel>.from(
          (await Dio().post(
        '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_list',
        cancelToken: cancelToken,
        data: json.encode(
          ReportValueRequestModel(
            reportTag: 'SALES_BY_DAYS',
            paramId: 0,
            startCurrentPeriod:
                DateTime(startCurrentPeriod.year, startCurrentPeriod.month, 1),
            endCurrentPeriod: DateTime(
                startCurrentPeriod.year, startCurrentPeriod.month + 1, 0),
            startOldPeriod:
                DateTime(startCurrentPeriod.year, startCurrentPeriod.month, 1),
            endOldPeriod: DateTime(
                startCurrentPeriod.year, startCurrentPeriod.month + 1, 0),
            paramId2: -1,
          ),
        ),
        options: options,
      ))
              .data
              .map((e) =>
                  ReportListResponseModel.fromJson(e as Map<String, dynamic>)));

      List<ReportValueQtyModel> vals = [];

      for (var e in temp) {
        vals.add(ReportValueQtyModel(
          currentValue: e.currentValue,
          name: e.name,
          oldValue: e.oldValue,
          id: e.id,
          currentQuantity: 0,
          oldQuantity: 0,
        ));
      }
      report = null;

      report = ReportGroupAndValueModel(
        tag: 'SALES_BY_DAYS',
        name: temp.first.name,
        type: '',
        values: vals,
      );
      reportLoading = false;
      setState(() {});
    } catch (err) {
      reportLoading = false;
      setState(() {});
    }
  }
}
