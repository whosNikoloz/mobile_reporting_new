import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_reporting/api/request_models/report_groups_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_group_response_model.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/screens/finances_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class FinancesMainScreen extends StatefulWidget {
  const FinancesMainScreen({super.key});

  @override
  State<FinancesMainScreen> createState() => _FinancesMainScreenState();
}

class _FinancesMainScreenState extends State<FinancesMainScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReportGroupResponseModel>>(
        future:
            getFinanceGroups(), // a previously-obtained Future<String> or null
        builder: (BuildContext context,
            AsyncSnapshot<List<ReportGroupResponseModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => Column(
                children: [
                  InkWell(
                    onTap: () async {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FinancesScreen(
                            tag: snapshot.data![index].tag,
                            reportName: snapshot.data![index].name,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 10,
                        top: 17,
                        bottom: 17,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data![index].name,
                              softWrap: false,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: AppTheme.primaryBlue,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: AppTheme.dividerColor,
                    indent: 7,
                    endIndent: 7,
                  ),
                ],
              ),
              itemCount: snapshot.data!.length,
            );
          }
          {
            return Container();
          }
        },
      );
  }

  Future<List<ReportGroupResponseModel>> getFinanceGroups() async {
    var body = ReportGroupsRequestModel(
      groupTag: "${await getIt<PreferencesHelper>().getType()}-REPORTS",
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
    List<ReportGroupResponseModel> groupsStatistics =
        List<ReportGroupResponseModel>.from((await Dio().post(
      '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_groups',
      data: json.encode(body),
      options: options,
    ))
            .data
            .map((e) =>
                ReportGroupResponseModel.fromJson(e as Map<String, dynamic>)));

    return groupsStatistics;
  }
}
