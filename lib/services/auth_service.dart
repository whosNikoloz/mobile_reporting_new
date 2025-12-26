import 'dart:convert';
import 'package:mobile_reporting/api/request_models/user_sign_in_request_model.dart';
import 'package:mobile_reporting/api/response_models/user_response_model.dart';
import 'package:mobile_reporting/helpers/http_helper.dart';

class AuthService {
  final HttpHelper _httpHelper = HttpHelper();
  static const String _authBaseUrl =
      'http://account.fina24.ge/api/users/checkreportinguser';

  Future<UserResponseModel?> checkReportingUser({
    required String login,
    required String password,
  }) async {
    try {
      final requestModel = UserSignInRequestModel(
        password: password,
        login: login,
      );

      final response = await _httpHelper.postExternal(
        _authBaseUrl,
        body: requestModel,
        headers: {'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserResponseModel.fromJson(data);
      }

      return null;
    } catch (err) {
      return null;
    }
  }

}
