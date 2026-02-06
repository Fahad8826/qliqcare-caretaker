import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'tokenservice.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Ensures only ONE refresh happens at a time
  static Future<bool>? _refreshingFuture;

  /// ---------------------------
  /// NORMAL REQUEST
  /// ---------------------------
 static Future<http.Response> request(
  Future<http.Response> Function(String token) apiCall,
) async {
  try {
    if (await TokenService.isAccessTokenExpired()) {
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        _forceLogout();
        throw Exception("Unauthorized");
      }
    }

    final token = await TokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      _forceLogout();
      throw Exception("No token");
    }

    final response = await apiCall(token)
        .timeout(const Duration(seconds: 25)); // ⭐ IMPORTANT

    if (response.statusCode == 401) {
      final refreshed = await TokenService.refreshAccessToken();
      if (!refreshed) {
        _forceLogout();
        throw Exception("Unauthorized");
      }

      final newToken = await TokenService.getAccessToken();
      return await apiCall(newToken!)
          .timeout(const Duration(seconds: 15));
    }

    return response;
  } on TimeoutException {
    throw Exception("⏱️ Request timed out");
  }
}

  /// ---------------------------
  /// MULTIPART REQUEST
  /// ---------------------------
  static Future<http.Response> multipartRequest(
    Future<http.StreamedResponse> Function(String token) apiCall,
  ) async {
    await _ensureValidToken();

    final token = await _getTokenOrLogout();

    try {
      print("📤 Sending multipart request...");
      final streamed = await apiCall(token)
          .timeout(_timeout);

      http.Response response = await http.Response.fromStream(streamed);
      print("📡 Multipart response status: ${response.statusCode}");

      if (response.statusCode == 401) {
        return await _handleMultipart401(apiCall);
      }

      return response;
    } on TimeoutException {
      throw Exception("⏱️ Multipart request timed out");
    } on SocketException {
      throw Exception("🌐 Network error");
    }
  }

  /// ---------------------------
  /// TOKEN VALIDATION
  /// ---------------------------
  static Future<void> _ensureValidToken() async {
    if (await TokenService.isAccessTokenExpired()) {
      print("⚠️ Token expired, refreshing...");
      await _refreshTokenSingleFlight();
    }
  }

  static Future<void> _refreshTokenSingleFlight() async {
    _refreshingFuture ??= () async {
      final success = await TokenService.refreshAccessToken();
      if (!success) {
        print("❌ Token refresh failed");
        _forceLogout();
        throw Exception("Unauthorized");
      }
      print("✅ Token refreshed");
      return true;
    }();

    await _refreshingFuture;
    _refreshingFuture = null;
  }

  static Future<String> _getTokenOrLogout() async {
    final token = await TokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      print("❌ No access token");
      _forceLogout();
      throw Exception("Unauthorized");
    }
    return token;
  }



  static Future<http.Response> _handleMultipart401(
    Future<http.StreamedResponse> Function(String token) apiCall,
  ) async {
    print("⚠️ Multipart 401 received, refreshing token...");
    await _refreshTokenSingleFlight();

    final newToken = await _getTokenOrLogout();
    final streamed = await apiCall(newToken).timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401) {
      print("❌ Still unauthorized after refresh");
      _forceLogout();
    }

    return response;
  }

  /// ---------------------------
  /// FORCE LOGOUT
  /// ---------------------------
  static Future<void> _forceLogout() async {
    print("🚪 Forcing logout...");
    await TokenService.clearTokens();
    // Get.offAllNamed('/login');
  }
}
