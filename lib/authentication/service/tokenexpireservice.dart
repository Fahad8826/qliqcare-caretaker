
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
    // Check if token is expired before making request
    if (await TokenService.isAccessTokenExpired()) {
      print("⚠️ Token expired, refreshing preemptively...");
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        print("❌ Preemptive refresh failed, logging out");
        _forceLogout();
        throw Exception("Unauthorized: Token refresh failed");
      }
    }

    String? accessToken = await TokenService.getAccessToken();
    
    if (accessToken == null || accessToken.isEmpty) {
      print("❌ No access token available");
      _forceLogout();
      throw Exception("Unauthorized: No token");
    }

    print("📡 Making API request...");
    http.Response response = await apiCall(accessToken);
    print("📡 Response status: ${response.statusCode}");

    // Handle 401 - token might have expired between check and request
    if (response.statusCode == 401) {
      print("⚠️ 401 Unauthorized, attempting token refresh...");
      final refreshed = await TokenService.refreshAccessToken();

      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        if (newToken != null) {
          print("✅ Retrying with new token");
          response = await apiCall(newToken);
          print("📡 Retry response status: ${response.statusCode}");
          
          // If still 401 after refresh, logout
          if (response.statusCode == 401) {
            print("❌ Still 401 after refresh, logging out");
            _forceLogout();
          }
        } else {
          print("❌ No token after refresh, logging out");
          _forceLogout();
        }
      } else {
        print("❌ Token refresh failed, logging out");
        _forceLogout();
      }
    }

    return response;
  }

  /// ---------------------------
  /// MULTIPART REQUEST (PATCH/POST with file)
  /// ---------------------------
  static Future<http.Response> multipartRequest(
    Future<http.StreamedResponse> Function(String token) apiCall,
  ) async {
    // Check if token is expired before making request
    if (await TokenService.isAccessTokenExpired()) {
      print("⚠️ Token expired, refreshing preemptively...");
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        print("❌ Preemptive refresh failed, logging out");
        _forceLogout();
        throw Exception("Unauthorized: Token refresh failed");
      }
    }

    String? accessToken = await TokenService.getAccessToken();
    
    if (accessToken == null || accessToken.isEmpty) {
      print("❌ No access token available for multipart");
      _forceLogout();
      throw Exception("Unauthorized: No token");
    }

    print("📤 Sending multipart request...");
    http.StreamedResponse streamed = await apiCall(accessToken);
    http.Response response = await http.Response.fromStream(streamed);
    print("📡 Multipart response status: ${response.statusCode}");

    if (response.statusCode == 401) {
      print("⚠️ Multipart 401 Unauthorized, attempting token refresh...");
      final refreshed = await TokenService.refreshAccessToken();

      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        if (newToken != null) {
          print("✅ Retrying multipart with new token");
          streamed = await apiCall(newToken);
          response = await http.Response.fromStream(streamed);
          print("📡 Retry multipart response status: ${response.statusCode}");
          
          // If still 401 after refresh, logout
          if (response.statusCode == 401) {
            print("❌ Still 401 after refresh, logging out");
            _forceLogout();
          }
        } else {
          print("❌ No token after refresh, logging out");
          _forceLogout();
        }
      } else {
        print("❌ Multipart refresh failed, logging out");
        _forceLogout();
      }
    }

    return response;
  }

  /// ---------------------------
  /// FORCE LOGOUT
  /// ---------------------------
  static void _forceLogout() async {
    print("🚪 Forcing logout...");
    await TokenService.clearTokens();
    
    // Use binding to ensure controller is initialized
    Get.offAllNamed('/login');
  }
}