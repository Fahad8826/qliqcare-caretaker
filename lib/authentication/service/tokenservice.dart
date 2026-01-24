// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;

// class TokenService {
//   static final _storage = FlutterSecureStorage(
//     aOptions: AndroidOptions(
//       encryptedSharedPreferences: true, //  PREVENTS CRASH
//     ),
//   );

//   static Future<void> saveTokens(String access, String refresh) async {
//     await _storage.write(key: 'access_token', value: access);
//     await _storage.write(key: 'refresh_token', value: refresh);
//   }

//   static Future<String?> getAccessToken() async {
//     return await _storage.read(key: 'access_token');
//   }

//   static Future<String?> getRefreshToken() async {
//     return await _storage.read(key: 'refresh_token');
//   }

//   static Future<void> getfcmtoken(String token) async {
//     await _storage.write(key: 'fcm_token', value: token);
//   }

//   static Future<void> clearTokens() async {
//     await _storage.delete(key: 'access_token');
//     await _storage.delete(key: 'refresh_token');
//     await _storage.delete(key: 'fcm_token');
//   }


//   /// 🔁 REFRESH ACCESS TOKEN
//   static Future<bool> refreshAccessToken() async {

//     final refreshToken = await getRefreshToken();
//     final baseUrl = dotenv.env['BASE_URL']!; 
//     if (refreshToken == null || refreshToken.isEmpty) {
//       return false;
//     }

//     final response = await http.post(
//       Uri.parse('$baseUrl/api/customer/token/refresh/'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'refresh': refreshToken}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       await saveTokens(data['access'], data['refresh']);
//       return true;
//     }

//     return false;
//   }
// }
// tokenservice.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 🔒 Prevent concurrent refresh attempts
  static bool _isRefreshing = false;
  static List<Function> _refreshCallbacks = [];

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> setFcmToken(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
  }

  static Future<String?> getFcmToken() async {
    return await _storage.read(key: 'fcm_token');
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'fcm_token');
  }

  /// ✅ Check if access token is expired
  static Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return true;
    
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print("❌ Token validation error: $e");
      return true;
    }
  }

  /// 🔁 REFRESH ACCESS TOKEN with mutex
  static Future<bool> refreshAccessToken() async {
    // If already refreshing, wait for the result
    if (_isRefreshing) {
      print("⏳ Refresh already in progress, waiting...");
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();
      final baseUrl = dotenv.env['BASE_URL'];

      if (refreshToken == null || refreshToken.isEmpty) {
        print("❌ No refresh token available");
        _notifyRefreshCallbacks(false);
        return false;
      }

      if (baseUrl == null || baseUrl.isEmpty) {
        print("❌ BASE_URL not configured");
        _notifyRefreshCallbacks(false);
        return false;
      }

      print("🔄 Attempting token refresh...");

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/customer/token/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Token refresh timeout");
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['access'] != null && data['refresh'] != null) {
          await saveTokens(data['access'], data['refresh']);
          print("✅ Token refreshed successfully");
          _notifyRefreshCallbacks(true);
          return true;
        } else {
          print("❌ Invalid token response format");
          _notifyRefreshCallbacks(false);
          return false;
        }
      } else if (response.statusCode == 401) {
        print("❌ Refresh token expired (401)");
        await clearTokens();
        _notifyRefreshCallbacks(false);
        return false;
      } else {
        print("❌ Token refresh failed: ${response.statusCode}");
        _notifyRefreshCallbacks(false);
        return false;
      }
    } catch (e) {
      print("❌ Token refresh exception: $e");
      _notifyRefreshCallbacks(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Wait for ongoing refresh to complete
  static Future<bool> _waitForRefresh() async {
    final completer = Completer<bool>();
    _refreshCallbacks.add(completer.complete);
    return completer.future;
  }

  /// Notify all waiting callbacks
  static void _notifyRefreshCallbacks(bool success) {
    for (var callback in _refreshCallbacks) {
      callback(success);
    }
    _refreshCallbacks.clear();
  }
}