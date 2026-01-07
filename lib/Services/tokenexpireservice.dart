import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'tokenservice.dart';

class ApiService {
  /// ---------------------------
  /// NORMAL REQUEST (GET/POST/PATCH)
  /// ---------------------------
  static Future<http.Response> request(
    Future<http.Response> Function(String token) apiCall,
  ) async {
    String? accessToken = await TokenService.getAccessToken();
    print("🔑 Initial access token: $accessToken");

    // Token missing → try refresh
    if (accessToken == null || accessToken.isEmpty) {
      print("⚠️ Access token missing, refreshing...");
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        print("❌ Refresh failed, logging out");
        _forceLogout();
        throw Exception("Unauthorized");
      }
      accessToken = await TokenService.getAccessToken();
      print("✅ New access token: $accessToken");
    }

    http.Response response = await apiCall(accessToken!);
    print("📡 Response status: ${response.statusCode}");

    // Token expired → refresh & retry
    if (response.statusCode == 401) {
      print("⚠️ 401 Unauthorized, refreshing token...");
      final refreshed = await TokenService.refreshAccessToken();

      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        print("✅ Retry with new token: $newToken");
        response = await apiCall(newToken!);
        print("📡 Retry response status: ${response.statusCode}");
      } else {
        print("❌ Refresh failed on 401, logging out");
        _forceLogout();
      }
    }

    print("📦 Response body: ${response.body}");
    return response;
  }

  /// ---------------------------
  /// MULTIPART REQUEST (PATCH/POST with file)
  /// ---------------------------
  static Future<http.Response> multipartRequest(
    Future<http.StreamedResponse> Function(String token) apiCall,
  ) async {
    String? accessToken = await TokenService.getAccessToken();
    print("🔑 Initial access token for multipart: $accessToken");

    if (accessToken == null || accessToken.isEmpty) {
      print("⚠️ Access token missing for multipart, refreshing...");
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        print("❌ Refresh failed, logging out");
        _forceLogout();
        throw Exception("Unauthorized");
      }
      accessToken = await TokenService.getAccessToken();
      print("✅ New access token: $accessToken");
    }

    print("📤 Sending multipart request...");
    http.StreamedResponse streamed = await apiCall(accessToken!);
    http.Response response = await http.Response.fromStream(streamed);
    print("📡 Multipart response status: ${response.statusCode}");

    if (response.statusCode == 401) {
      print("⚠️ Multipart 401 Unauthorized, refreshing token...");
      final refreshed = await TokenService.refreshAccessToken();

      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        print("✅ Retry multipart with new token: $newToken");
        streamed = await apiCall(newToken!);
        response = await http.Response.fromStream(streamed);
        print("📡 Retry multipart response status: ${response.statusCode}");
      } else {
        print("❌ Refresh failed on 401 multipart, logging out");
        _forceLogout();
      }
    }

    print("📦 Multipart response body: ${response.body}");
    return response;
  }

  /// ---------------------------
  /// FORCE LOGOUT
  /// ---------------------------
  static void _forceLogout() async {
    print("🚪 Forcing logout...");
    await TokenService.clearTokens();
    Get.offAllNamed('/login');
  }
}
