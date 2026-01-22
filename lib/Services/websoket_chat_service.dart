
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:qlickcare/Model/chat_model.dart';
import 'package:qlickcare/Services/tokenservice.dart';

class WebSocketService {
  WebSocket? _webSocket;

  final _messageController = StreamController<Message>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _callController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;

  bool _isConnected = false;
  int? _currentRoomId;

  bool get isConnected => _isConnected;

  // =====================================================
  // CONNECT
  // =====================================================
  Future<void> connect(int roomId) async {
    await disconnect();

    _currentRoomId = roomId;

    final token = await TokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      print('❌ WebSocket: No access token available');
      _connectionController.add(false);
      return;
    }

    String baseUrl = dotenv.env['BASE_URL']!
        .replaceAll(RegExp(r'https?://|wss?://'), '');

    final wsUrl = 'wss://$baseUrl/ws/chat/$roomId/?token=$token';
    print('🔌 Connecting to WebSocket: $wsUrl');

    try {
      _webSocket = await WebSocket.connect(wsUrl);
      _isConnected = true;
      _connectionController.add(true);
      print('✅ WebSocket connected to room $roomId');

      _webSocket!.listen(
        _handleMessage,
        onDone: _handleDisconnect,
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleDisconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  void _handleDisconnect() {
    print('🔌 WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
  }

  // =====================================================
  // RECEIVE
  // =====================================================
  void _handleMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data);
      final type = decoded['type'];
      print('📩 Received WS message: $type');

      // CHAT MESSAGE
      if (type == 'chat_message') {
        final message = decoded['message'] != null
            ? Message.fromJson(decoded['message'])
            : Message.fromJson(decoded);

        _messageController.add(message);
      }
      // FILE MESSAGE
      else if (decoded['content'] != null || decoded['message_type'] != null) {
        _messageController.add(Message.fromJson(decoded));
      }
      // CALL SIGNALING
      else if (_isCallType(type)) {
        _callController.add(decoded);
      }
    } catch (e) {
      print('❌ WebSocket parse error: $e');
      print('Raw data: $data');
    }
  }

  bool _isCallType(String? type) {
    return [
      'call_offer',
      'call_answer',
      'ice_candidate',
      'call_end',
      'call_ended',
      'call_decline',
      'call_mute',
      'peer_muted',
      'call_video_toggle',
      'peer_video_toggle',
    ].contains(type);
  }

  // =====================================================
  // CHAT SEND
  // =====================================================
  void sendMessage(String content) {
    send({
      'type': 'chat_message',
      'content': content,
    });
  }

  // =====================================================
  // FILE SEND
  // =====================================================
  Future<void> sendFileMessage({
    required String filePath,
    required String fileName,
    required String messageType,
    String? content,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    send({
      'type': 'file_upload',
      'message_type': messageType,
      'file_name': fileName,
      'file_type': lookupMimeType(filePath),
      'file_data': base64Encode(bytes),
      'content': content ?? fileName,
    });
  }

  // =====================================================
  // CALL SEND METHODS (CARETAKER)
  // =====================================================

  /// Accept call
  void sendCallAnswer({
    required int callLogId,
    required Map<String, dynamic> answer,
  }) {
    send({
      'type': 'call_answer',
      'call_log_id': callLogId,
      'answer': answer,
    });
  }

  /// Decline call
  void declineCall(int callLogId) {
    send({
      'type': 'call_decline',
      'call_log_id': callLogId,
    });
  }

  /// Send ICE candidate
  void sendIceCandidate({
    required int callLogId,
    required Map<String, dynamic> candidate,
  }) {
    send({
      'type': 'ice_candidate',
      'call_log_id': callLogId,
      'candidate': candidate,
    });
  }

  /// End call
  void endCall(int callLogId) {
    send({
      'type': 'call_end',
      'call_log_id': callLogId,
    });
  }

  /// Mute / Unmute
  void muteAudio({
    required int callLogId,
    required bool muted,
  }) {
    send({
      'type': 'call_mute',
      'call_log_id': callLogId,
      'audio_muted': muted,
    });
  }

  /// Video ON / OFF
  void toggleVideo({
    required int callLogId,
    required bool enabled,
  }) {
    send({
      'type': 'call_video_toggle',
      'call_log_id': callLogId,
      'video_enabled': enabled,
    });
  }

  // =====================================================
  // SEND HELPER - PUBLIC for CallController
  // =====================================================
  void send(Map<String, dynamic> payload) {
    if (!_isConnected || _webSocket == null) {
      print('⚠️ Cannot send: WebSocket not connected');
      return;
    }
    
    final message = jsonEncode(payload);
    print('📤 Sending: ${payload['type']}');
    _webSocket!.add(message);
  }

  // =====================================================
  // DISCONNECT
  // =====================================================
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

  // =====================================================
  // DISPOSE
  // =====================================================
  void dispose() {
    print('🗑️ Disposing WebSocketService');
    disconnect();
    _messageController.close();
    _callController.close();
    _connectionController.close();
  }
}