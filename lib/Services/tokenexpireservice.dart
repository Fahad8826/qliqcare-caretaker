import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'tokenservice.dart';

class ApiService {
  static Future<http.Response> request(
    Future<http.Response> Function(String token) apiCall,
  ) async {
    String? accessToken = await TokenService.getAccessToken();

    // Token missing → try refresh
    if (accessToken == null || accessToken.isEmpty) {
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        _forceLogout();
        throw Exception("Unauthorized");
      }
      accessToken = await TokenService.getAccessToken();
    }

    http.Response response = await apiCall(accessToken!);

    // Token expired → refresh & retry
    if (response.statusCode == 401) {
      final refreshed = await TokenService.refreshAccessToken();

      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        response = await apiCall(newToken!);
      } else {
        _forceLogout();
      }
    }

    return response;
  }

  static void _forceLogout() async {
    await TokenService.clearTokens();
    Get.offAllNamed('/login');
  }
}
