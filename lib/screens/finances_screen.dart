import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_reporting/api/request_models/report_value_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_list_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen(
      {super.key, required this.tag, required this.reportName});

  final String tag;
  final String reportName;

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  List<ReportListResponseModel> finances = [];
  double minimumAmount = 0;
  double maximumAmount = 0;
  String billNum = '';
  int? isLoading;

  DateTime date1 = application.startCurrentPeriod ?? DateTime.now();
  DateTime date2 = application.endCurrentPeriod ?? DateTime.now();
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  int numberToLoad = 30;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateFinances(dt1: date1, dt2: date2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        leading: IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.grey.shade900,
        titleSpacing: 0,
        title: Text(
          widget.reportName,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.tag.contains('_PERIOD'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: PickerWidget(
                  screenType: ScreenType.financesScreen,
                  showCompareDateFilter: true,
                  showStoreFilter: false,
                  showOldDate: false,
                  getDate: (DateTime dt1,
                      DateTime dt2,
                      DateTime dt3,
                      DateTime dt4,
                      double? minAmount,
                      double? maxAmount,
                      String? billNum) async {
                    date1 = dt1;
                    date2 = dt2;
                    await updateFinances(
                        dt1: dt1,
                        dt2: dt2,
                        minAmount: minimumAmount,
                        maxAmount: maximumAmount,
                        billNum: billNum);
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
            if (finances.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  ReportListResponseModel bill = finances.elementAt(index);
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade500,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bill.name,
                            maxLines: 2,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            bill.currentValue.toStringAsFixed(0),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: numberToLoad,
              ),
            if (finances.isNotEmpty && numberToLoad < finances.length)
              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    if (numberToLoad + 50 > finances.length &&
                        numberToLoad != finances.length) {
                      numberToLoad = finances.length;
                      setState(() {});
                    } else if (numberToLoad + 50 <= finances.length) {
                      numberToLoad += 50;
                      setState(() {});
                    }
                  },
                  child: const Text(
                    'მეტის ჩვენება ↓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateFinances(
      {required DateTime dt1,
      required DateTime dt2,
      double? minAmount,
      double? maxAmount,
      String? billNum}) async {
    numberToLoad = 30;
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
    List<ReportListResponseModel> billsTemp = [];
    billsTemp = List<ReportListResponseModel>.from((await Dio().post(
      '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_list',
      data: json.encode(
        ReportValueRequestModel(
          reportTag: widget.tag,
          paramId: 0,
          startCurrentPeriod: dt1,
          endCurrentPeriod: dt2,
          startOldPeriod: dt1,
          endOldPeriod: dt2,
          paramId2: -1,
        ),
      ),
      options: options,
    ))
        .data
        .map((e) =>
            ReportListResponseModel.fromJson(e as Map<String, dynamic>)));
    finances.clear();
    for (var e in billsTemp) {
      finances.add(
        ReportListResponseModel(
          currentValue: e.currentValue,
          name: e.name,
          id: e.id,
          oldValue: e.oldValue,
        ),
      );
    }
    if (numberToLoad > finances.length) numberToLoad = finances.length;
    setState(() {});
  }
}
