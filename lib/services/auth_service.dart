import 'package:mobile_reporting/api/request_models/user_sign_in_request_model.dart';
import 'package:mobile_reporting/api/response_models/user_response_model.dart';
import 'package:mobile_reporting/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _authBaseUrl =
      'http://account.fina24.ge/api/users/checkreportinguser';

  Future<UserResponseModel?> checkReportingUser({
    required String login,
    required String password,
  }) async {
    final requestModel = UserSignInRequestModel(
      password: password,
      login: login,
    );

    final response = await _apiService.postExternal(
      _authBaseUrl,
      data: requestModel,
      headers: {'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk'},
    );

    if (response.statusCode == 200) {
      return UserResponseModel.fromJson(response.data);
    }

    return null;
  }

  Future<String?> generateToken(
      {required String database, required String baseUrl}) async {
    final response = await _apiService.postExternal(
      '${baseUrl}api/auth/generate_token',
      data: {'database': database},
      headers: {'SecureKey': 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk'},
    );

    if (response.statusCode == 200) {
      return response.data as String;
    }

    return null;
  }
}
