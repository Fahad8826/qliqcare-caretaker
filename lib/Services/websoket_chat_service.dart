import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Services/tokenservice.dart';
import 'package:qlickcare/Model/chat_model.dart';

class WebSocketService {
  WebSocket? _webSocket;
  final _messageController = StreamController<Message>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<Message> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool _isConnected = false;
  int? _currentRoomId;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket for a specific chat room
  Future<void> connect(int roomId) async {
    try {
      // Close existing connection if any
      await disconnect();

      _currentRoomId = roomId;
      
      // Get access token
      String? token = await TokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ WebSocket: No access token available');
        _connectionController.add(false);
        return;
      }

      // Build WebSocket URL
      String baseUrl = dotenv.env['BASE_URL']!;
      
      // Remove protocol and get clean domain
      baseUrl = baseUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .replaceAll('wss://', '')
          .replaceAll('ws://', '');
      
      // Use wss:// for secure WebSocket
      final wsUrl = 'wss://$baseUrl/ws/chat/$roomId/?token=$token';
      
      print('🔌 Connecting to WebSocket: $wsUrl');

      // Create WebSocket connection using dart:io
      _webSocket = await WebSocket.connect(
        wsUrl,
        headers: {
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );

      _isConnected = true;
      _connectionController.add(true);
      print('✅ WebSocket connected to room $roomId');

      // Listen for messages
      _webSocket!.listen(
        (data) {
          print('📨 WebSocket received: $data');
          _handleMessage(data);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
          _connectionController.add(false);
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _isConnected = false;
          _connectionController.add(false);
        },
        cancelOnError: false,
      );

    } catch (e) {
      print('❌ WebSocket connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data);
      print('📩 Decoded message: $decoded');
      print('📩 Message type: ${decoded['type']}');
      print('📩 Message keys: ${decoded.keys.toList()}');

      // Handle different response formats from server
      if (decoded['type'] == 'chat_message') {
        // Check if message is nested
        if (decoded['message'] != null) {
          print('📩 Found nested message object');
          final message = Message.fromJson(decoded['message']);
          _messageController.add(message);
          print('✅ Message added to stream: ${message.id}');
        } 
        // Check if content is at top level
        else if (decoded['content'] != null) {
          print('📩 Found top-level content');
          final message = Message.fromJson(decoded);
          _messageController.add(message);
          print('✅ Message added to stream: ${message.id}');
        }
      } 
      // Sometimes server sends message directly without type wrapper
      else if (decoded['content'] != null || decoded['message_type'] != null) {
        print('📩 Direct message format');
        final message = Message.fromJson(decoded);
        _messageController.add(message);
        print('✅ Message added to stream: ${message.id}');
      }
      else {
        print('⚠️ Unknown message format: $decoded');
      }
    } catch (e, stackTrace) {
      print('❌ Error parsing WebSocket message: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Send a text message with correct payload format
  Future<void> sendMessage(String content) async {
    if (!_isConnected || _webSocket == null) {
      print('❌ Cannot send message: WebSocket not connected');
      throw Exception('WebSocket not connected');
    }

    try {
      // Use the correct payload format: {"type": "chat_message", "content": "message"}
      final payload = jsonEncode({
        'type': 'chat_message',
        'content': content,
      });

      print('📤 Sending message: $payload');
      _webSocket!.add(payload);
      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      throw e;
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    if (_webSocket != null) {
      print('🔌 Disconnecting WebSocket from room $_currentRoomId');
      try {
        await _webSocket!.close();
      } catch (e) {
        print('⚠️ Error closing WebSocket: $e');
      }
      _webSocket = null;
    }
    _isConnected = false;
    _currentRoomId = null;
    _connectionController.add(false);
  }

  /// Dispose streams
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}