import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/request_models/report_value_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_list_qty_response_model.dart';
import 'package:mobile_reporting/api/response_models/report_list_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/report_group_and_value_model.dart';
import 'package:mobile_reporting/models/report_value_qty_model.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.report});

  final ReportGroupAndValueModel report;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  var numberFormatter = NumberFormat.decimalPattern();
  late ReportGroupAndValueModel report;

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

    report = widget.report;
  }

  @override
  Widget build(BuildContext context) {
    int count = application.selectedStoreId == null
        ? report.values.length
        : report.values
            .where((element) =>
                element.name ==
                application.stores
                    .firstWhere(
                        (element) => element.id == application.selectedStoreId)
                    .name)
            .toList()
            .length;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: PickerWidget(
              screenType: ScreenType.statisticsScreen,
              showCompareDateFilter: true,
              isDayHidden: report.tag == 'SALES_BY_STORES' ? false : true,
              showStoreFilter: report.tag == 'SALES_BY_STORES' ? false : true,
              getDate: (DateTime dt1, DateTime dt2, DateTime dt3, DateTime dt4,
                  double? minAmount, double? maxAmount, String? billNum) async {
                await onDateChange(dt1: dt1, dt2: dt2, dt3: dt3, dt4: dt4);
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                children: [
                  if (widget.report.type.contains('GRAPH'))
                    SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        isInversed: true,
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
                      enableAxisAnimation: false,
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        header: '',
                        tooltipPosition: TooltipPosition.pointer,
                        textStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      series: report.type.endsWith('_H')
                          ? <BarSeries<ReportValueQtyModel, String>>[
                              BarSeries<ReportValueQtyModel, String>(
                                dataSource: application.selectedStoreId == null
                                    ? report.values
                                        .sublist(0, count > 10 ? 10 : count)
                                    : report.values
                                        .where((element) =>
                                            element.name ==
                                            application.stores
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    application.selectedStoreId)
                                                .name)
                                        .toList()
                                        .sublist(0, count > 10 ? 10 : count),
                                xValueMapper: (ReportValueQtyModel sales, _) =>
                                    '${sales.name.substring(0, sales.name.length > 7 ? 7 : sales.name.length)}.',
                                animationDuration: 0,
                                yValueMapper: (ReportValueQtyModel sales, _) =>
                                    sales.currentValue,
                                sortFieldValueMapper:
                                    (ReportValueQtyModel data, _) =>
                                        data.currentValue,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: false,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ]
                          : <ColumnSeries<ReportValueQtyModel, String>>[
                              ColumnSeries<ReportValueQtyModel, String>(
                                animationDuration: 0,
                                dataSource: application.selectedStoreId == null
                                    ? report.values
                                    : report.values
                                        .where((element) =>
                                            element.name ==
                                            application.stores
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    application.selectedStoreId)
                                                .name)
                                        .toList(),
                                xValueMapper: (ReportValueQtyModel sales, _) =>
                                    sales.name == 'monday'
                                        ? 'ორშ.'
                                        : sales.name == 'tuesday'
                                            ? 'სამშ.'
                                            : sales.name == 'wednesday'
                                                ? 'ოთხშ.'
                                                : sales.name == 'thursday'
                                                    ? 'ხუთშ.'
                                                    : sales.name == 'friday'
                                                        ? 'პარ.'
                                                        : sales.name ==
                                                                'saturday'
                                                            ? 'შაბ.'
                                                            : sales.name ==
                                                                    'sunday'
                                                                ? 'კვირა'
                                                                : '${sales.name.substring(0, sales.name.length > 7 ? 7 : sales.name.length)} ${!report.tag.contains('SALES_BY_DAYS') && sales.name.length > 7 ? '.' : ''}',
                                yValueMapper: (ReportValueQtyModel sales, _) =>
                                    sales.currentValue,
                                sortFieldValueMapper:
                                    (ReportValueQtyModel data, _) =>
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
                  if (widget.report.type.contains('GRAPH'))
                    Divider(
                      height: 10,
                      color: Colors.grey.shade500,
                      indent: 7,
                      endIndent: 7,
                    ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(
                      height: 10,
                      color: Colors.grey.shade500,
                      indent: 7,
                      endIndent: 7,
                    ),
                    shrinkWrap: true,
                    itemCount: application.selectedStoreId == null
                        ? report.values.length
                        : report.values
                            .where((element) =>
                                element.name ==
                                application.stores
                                    .firstWhere((element) =>
                                        element.id ==
                                        application.selectedStoreId)
                                    .name)
                            .length,
                    itemBuilder: (context, index) {
                      ReportValueQtyModel r =
                          application.selectedStoreId == null
                              ? report.values.elementAt(index)
                              : report.values
                                  .where((element) =>
                                      element.name ==
                                      application.stores
                                          .firstWhere((element) =>
                                              element.id ==
                                              application.selectedStoreId)
                                          .name)
                                  .toList()
                                  .elementAt(index);
                      double? percent;
                      bool? currentIsMore;
                      percent = 100 - (r.currentValue / r.oldValue * 100);
                      bool showPercent = true;
                      if (percent == -double.infinity) {
                        showPercent = false;
                      }
                      currentIsMore = r.currentValue > r.oldValue;
                      if (currentIsMore) {
                        percent = percent * -1;
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: showPercent ? 5 : 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.tag == 'SALES_BY_DAYS'
                                        ? DateFormat('dd-MMM-yyyy').format(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(r.name))
                                        : application.lang == 'ka' &&
                                                r.name == 'monday'
                                            ? 'ორშაბათი'
                                            : application.lang == 'ka' &&
                                                    r.name == 'tuesday'
                                                ? 'სამშაბათი'
                                                : application.lang == 'ka' &&
                                                        r.name == 'wednesday'
                                                    ? 'ოთხშაბათი'
                                                    : application.lang ==
                                                                'ka' &&
                                                            r.name == 'thursday'
                                                        ? 'ხუთშაბათი'
                                                        : application.lang ==
                                                                    'ka' &&
                                                                r.name ==
                                                                    'friday'
                                                            ? 'პარასკევი'
                                                            : application.lang ==
                                                                        'ka' &&
                                                                    r.name ==
                                                                        'saturday'
                                                                ? 'შაბათი'
                                                                : application.lang ==
                                                                            'ka' &&
                                                                        r.name ==
                                                                            'sunday'
                                                                    ? 'კვირა'
                                                                    : r.name,
                                    softWrap: false,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if (showPercent)
                                    Text(
                                      showPercent
                                          ? '${currentIsMore ? '↑' : '↓'}${percent.round()}%'
                                          : '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: currentIsMore
                                            ? Colors.green.shade800
                                            : Colors.red.shade900,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (report.type.contains('QTY'))
                              Text(
                                numberFormatter.format(r.currentQuantity),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 17,
                                ),
                              ),
                            if (report.type.contains('QTY'))
                              const SizedBox(
                                width: 10,
                              ),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                numberFormatter.format(r.currentValue.floor()),
                                textAlign: TextAlign.end,
                                softWrap: false,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        titleSpacing: 0,
        leading: IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          report.name,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Future<void> onDateChange(
      {required DateTime dt1,
      required DateTime dt2,
      required DateTime dt3,
      required DateTime dt4}) async {
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
    List<ReportValueQtyModel> vals = [];
    if (report.type.contains('QTY')) {
      List<ReportListQtyResponseModel> temp =
          List<ReportListQtyResponseModel>.from((await Dio().post(
        '${await getIt<PreferencesHelper>().getUrl()}api/report/get_qty_report_list',
        data: json.encode(
          ReportValueRequestModel(
            reportTag: report.tag,
            paramId: 0,
            startCurrentPeriod: startCurrentPeriod,
            endCurrentPeriod: endCurrentPeriod,
            startOldPeriod: startOldPeriod,
            endOldPeriod: endOldPeriod,
            paramId2: -1,
          ),
        ),
        options: options,
      ))
              .data
              .map((e) => ReportListQtyResponseModel.fromJson(
                  e as Map<String, dynamic>)));

      for (var e in temp) {
        vals.add(ReportValueQtyModel(
          currentValue: e.currentValue,
          name: e.name,
          oldValue: e.oldValue,
          id: e.id,
          currentQuantity: e.currentQuantity,
          oldQuantity: e.oldQuantity,
        ));
      }
    } else {
      List<ReportListResponseModel> temp = List<ReportListResponseModel>.from(
          (await Dio().post(
        '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_list',
        data: json.encode(
          ReportValueRequestModel(
            reportTag: report.tag,
            paramId: 0,
            startCurrentPeriod: startCurrentPeriod,
            endCurrentPeriod: endCurrentPeriod,
            startOldPeriod: startOldPeriod,
            endOldPeriod: endOldPeriod,
            paramId2: -1,
          ),
        ),
        options: options,
      ))
              .data
              .map((e) =>
                  ReportListResponseModel.fromJson(e as Map<String, dynamic>)));

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
    }
    report = ReportGroupAndValueModel(
      tag: report.tag,
      name: report.name,
      type: report.type,
      values: vals,
    );
    setState(() {});
  }
}
