import 'dart:convert';

import 'package:dio/dio.dart';

class RequestHelper {
  Future<dynamic> post({required String url, required Object body, required Map<String, dynamic>? headers}) async {
    return await Dio().post(
      url,
      data: json.encode(body),
      options: Options(
        contentType: 'application/json',
        headers: headers,
        validateStatus: (status) {
          return true;
        },
      ),
    );
  }
}
