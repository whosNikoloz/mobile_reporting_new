import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_reporting/api/request_models/report_groups_request_model.dart';
import 'package:mobile_reporting/api/response_models/report_group_response_model.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/models/report_group_and_value_model.dart';
import 'package:mobile_reporting/screens/statistics_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

import '../helpers/preferences_helper.dart';

class StatisticsMainScreen extends StatefulWidget {
  const StatisticsMainScreen({super.key});

  @override
  State<StatisticsMainScreen> createState() => _StatisticsMainScreenState();
}

class _StatisticsMainScreenState extends State<StatisticsMainScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReportGroupResponseModel>>(
        future: getStatisticGroups(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<ReportGroupResponseModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => Column(
                children: [
                  InkWell(
                    onTap: () async {
                      ReportGroupAndValueModel res;
                      res = ReportGroupAndValueModel(
                        tag: snapshot.data![index].tag,
                        name: snapshot.data![index].name,
                        type: snapshot.data![index].type,
                        values: [],
                      );
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatisticsScreen(
                            report: res,
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
                        children: [
                          Text(
                            snapshot.data![index].name,
                            style: const TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: AppTheme.primaryBlue,
                            size: 22,
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

  Future<List<ReportGroupResponseModel>> getStatisticGroups() async {
    var body = ReportGroupsRequestModel(
      groupTag: "${await getIt<PreferencesHelper>().getType()}-STATISTICS",
      language: await getIt<PreferencesHelper>().getLang() ?? 'ka',
    );

    Options options = Options(
      contentType: 'application/json',
      headers: {
        'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk',
        'Authorization': 'Bearer ${await getIt<PreferencesHelper>().getUserAuthToken()}',
      },
      validateStatus: (status) {
        return true;
      },
    );
    List<ReportGroupResponseModel> groupsStatistics = List<ReportGroupResponseModel>.from((await Dio().post(
      '${await getIt<PreferencesHelper>().getUrl()}api/report/get_report_groups',
      data: json.encode(body),
      options: options,
    ))
        .data
        .map((e) => ReportGroupResponseModel.fromJson(e as Map<String, dynamic>)));

    return groupsStatistics;
  }
}
