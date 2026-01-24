// ChatController.dart - WITH CALL SUPPORT
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/chat/model/chat_model.dart';
import 'package:qlickcare/chat/service/websoket_chat_service.dart';


class ChatController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMessages = false.obs;
  var isSendingMessage = false.obs;

  var chatRooms = <ChatRoom>[].obs;
  var selectedChat = Rxn<ChatRoom>();
  var messages = <Message>[].obs;

  final WebSocketService _wsService = WebSocketService();
  int? _activeRoomId;

  // Store current user info
  int? currentUserId;
  String currentUserType = "caretaker";

  // ✅ NEW: Store extracted user IDs from messages
  int? _extractedCustomerId;
  int? _extractedCaretakerId;

  WebSocketService get wsService => _wsService;

  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 ChatController INIT');

    _getCurrentUserInfo();

    _wsService.messageStream.listen(
      (message) {
        print('📩 WS message received: ${message.id} - ${message.content}');
        
        // ✅ EXTRACT USER IDs FROM WEBSOCKET MESSAGES
        _extractUserIdsFromMessage(message);
        
        _addNewMessage(message);
        _updateChatRoomWithNewMessage(message);
      },
      onError: (error) {
        print('❌ Error in message stream: $error');
      },
    );

    _wsService.connectionStream.listen((isConnected) {
      print('📶 WS Status: ${isConnected ? "Connected" : "Disconnected"}');
    });
  }

  Future<void> _getCurrentUserInfo() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> payloadMap = json.decode(decoded);

          currentUserId = int.tryParse(payloadMap['user_id']?.toString() ?? '');
          print('👤 Current user ID: $currentUserId (Type: $currentUserType)');
        }
      }
    } catch (e) {
      print('⚠️ Could not get user info: $e');
    }
  }

  // ✅ NEW: Extract customer and caretaker IDs from incoming messages
  void _extractUserIdsFromMessage(Message message) {
    // Your backend sends customer_id and caretaker_id in WebSocket messages
    if (message.customerId != null) {
      _extractedCustomerId = message.customerId;
      print('📝 Extracted customer ID: $_extractedCustomerId');
    }
    
    if (message.caretakerId != null) {
      _extractedCaretakerId = message.caretakerId;
      print('📝 Extracted caretaker ID: $_extractedCaretakerId');
    }

    // If IDs aren't in the message but we can infer from sender info
    if (message.senderType == 'customer' && message.senderId != 0) {
      _extractedCustomerId ??= message.senderId;
      print('📝 Inferred customer ID from sender: $_extractedCustomerId');
    } else if (message.senderType == 'caretaker' && message.senderId != 0) {
      _extractedCaretakerId ??= message.senderId;
      print('📝 Inferred caretaker ID from sender: $_extractedCaretakerId');
    }
  }

  // ✅ NEW: Get the receiver's user ID for calls
  int? getReceiverIdForCall() {
    print('🔍 Getting receiver ID for call...');
    print('   Current user ID: $currentUserId');
    print('   Current user type: $currentUserType');
    print('   Extracted customer ID: $_extractedCustomerId');
    print('   Extracted caretaker ID: $_extractedCaretakerId');

    // If we're the caretaker, call the customer
    if (currentUserType == "caretaker") {
      if (_extractedCustomerId != null) {
        print('✅ Returning customer ID: $_extractedCustomerId');
        return _extractedCustomerId;
      }
    }
    // If we're the customer, call the caretaker
    else if (currentUserType == "customer") {
      if (_extractedCaretakerId != null) {
        print('✅ Returning caretaker ID: $_extractedCaretakerId');
        return _extractedCaretakerId;
      }
    }

    // Fallback: Try to get from selected chat room
    if (selectedChat.value != null) {
      final chat = selectedChat.value!;
      
      if (chat.customerId != null && chat.customerId != currentUserId) {
        print('✅ Returning customer ID from chat room: ${chat.customerId}');
        return chat.customerId;
      }
      
      if (chat.caretakerId != null && chat.caretakerId != currentUserId) {
        print('✅ Returning caretaker ID from chat room: ${chat.caretakerId}');
        return chat.caretakerId;
      }
    }

    // Last resort: Infer from last message
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      if (lastMsg.senderId != currentUserId && lastMsg.senderId != 0) {
        print('✅ Returning sender ID from last message: ${lastMsg.senderId}');
        return lastMsg.senderId;
      }
    }

    print('❌ Could not determine receiver ID');
    return null;
  }

  // ✅ NEW: Get caller name for incoming calls
  String getCallerName() {
    final chat = selectedChat.value;
    if (chat == null) return 'Unknown';

    // If we're caretaker, caller is customer
    if (currentUserType == "caretaker") {
      return chat.customerName.isNotEmpty ? chat.customerName : 'Customer';
    } else {
      return chat.caretakerName.isNotEmpty ? chat.caretakerName : 'Caretaker';
    }
  }

  void _addNewMessage(Message message) {
    final isOwnMessage = message.senderId == currentUserId;
    final recentTime = DateTime.now().subtract(const Duration(seconds: 5));

    Message? optimisticMatch;
    if (isOwnMessage) {
      try {
        optimisticMatch = messages.firstWhere(
          (m) =>
              m.content == message.content &&
              m.senderId == currentUserId &&
              m.id >
                  DateTime.now()
                      .subtract(const Duration(seconds: 10))
                      .millisecondsSinceEpoch &&
              DateTime.parse(m.sentAt).isAfter(recentTime),
        );
      } catch (e) {
        // No match found
      }
    }

    if (optimisticMatch != null) {
      final index = messages.indexOf(optimisticMatch);
      messages[index] = message;
      print(
        '🔄 Replaced optimistic message with server message: ${message.id}',
      );
    } else {
      final existingIndex = messages.indexWhere((m) => m.id == message.id);

      Message finalMessage = message;
      if (message.senderType.isEmpty && currentUserId != null) {
        finalMessage = Message(
          id: message.id,
          content: message.content,
          senderId: message.senderId,
          senderName: message.senderName,
          senderType: message.senderId == currentUserId
              ? currentUserType
              : (currentUserType == "caretaker" ? "customer" : "caretaker"),
          messageType: message.messageType,
          sentAt: message.sentAt,
          fileUrl: message.fileUrl,
          file: message.file,
          isRead: message.isRead,
          readAt: message.readAt,
          customerId: message.customerId,
          caretakerId: message.caretakerId,
        );
        print('🔧 Fixed sender_type: ${finalMessage.senderType}');
      }

      if (existingIndex == -1) {
        messages.add(finalMessage);
        print(
          '➕ Added message: ${finalMessage.id} (Total: ${messages.length})',
        );
      } else {
        messages[existingIndex] = finalMessage;
        print('🔄 Updated message: ${finalMessage.id}');
      }
    }

    messages.refresh();
  }

  void _updateChatRoomWithNewMessage(Message message) {
    final roomIndex = chatRooms.indexWhere((room) => room.id == _activeRoomId);

    if (roomIndex != -1) {
      final room = chatRooms[roomIndex];

      final updatedRoom = ChatRoom(
        id: room.id,
        booking: room.booking,
        customerName: room.customerName,
        caretakerName: room.caretakerName,
        customerId: room.customerId ?? message.customerId,
        caretakerId: room.caretakerId ?? message.caretakerId,
        lastMessage: message,
        unreadCount: message.senderType != "caretaker"
            ? room.unreadCount + 1
            : room.unreadCount,
        bookingInfo: room.bookingInfo,
        createdAt: room.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      chatRooms.removeAt(roomIndex);
      chatRooms.insert(0, updatedRoom);

      print('📝 Updated chat room list with new message');
    }
  }

  Future<void> fetchChatRooms() async {
    try {
      print('📥 Fetch chat rooms');
      isLoading.value = true;

      final url = Uri.parse("${dotenv.env['BASE_URL']}/api/chat/rooms/");
      final response = await ApiService.request((token) {
        return http.get(url, headers: {"Authorization": "Bearer $token"});
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        chatRooms.value = (decoded['results'] ?? [])
            .map<ChatRoom>((e) => ChatRoom.fromJson(e))
            .toList();

        print('📦 Rooms loaded: ${chatRooms.length}');
      }
    } catch (e) {
      print('🔥 fetchChatRooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChatDetail(int id) async {
    try {
      print('📥 Fetch details of room $id');

      final url = Uri.parse("${dotenv.env['BASE_URL']}/api/chat/rooms/$id/");
      final response = await ApiService.request((token) {
        return http.get(url, headers: {"Authorization": "Bearer $token"});
      });

      if (response.statusCode == 200) {
        selectedChat.value = ChatRoom.fromJson(jsonDecode(response.body));
        
        // ✅ Try to extract user IDs from chat room
        if (selectedChat.value?.customerId != null) {
          _extractedCustomerId = selectedChat.value!.customerId;
        }
        if (selectedChat.value?.caretakerId != null) {
          _extractedCaretakerId = selectedChat.value!.caretakerId;
        }
        
        print('📌 Loaded room $id');
      }
    } catch (e) {
      print('🔥 fetchChatDetail error: $e');
    }
  }

  Future<void> fetchMessages(int roomId, {bool loadMore = false}) async {
    if (loadMore && (!hasMore.value || isLoadingMore.value)) {
      print('⚠️ Already loading or no more messages');
      return;
    }

    if (!loadMore) {
      print('📥 Fetch messages page 1 for $roomId');
      currentPage = 1;
      hasMore.value = true;
      messages.clear();
      isLoadingMessages.value = true;
    } else {
      print('📥 Load more messages page $currentPage for $roomId');
      isLoadingMore.value = true;
    }

    try {
      final url = Uri.parse(
        "${dotenv.env['BASE_URL']}/api/chat/rooms/$roomId/messages/?page=$currentPage",
      );

      final response = await ApiService.request(
        (token) => http.get(url, headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded['results'] ?? [];

        if (results.isEmpty) {
          print('📭 No more pages');
          hasMore.value = false;
          return;
        }

        final newMsgs = results
            .map<Message>((e) => Message.fromJson(e))
            .toList()
            .reversed
            .toList();

        // ✅ Extract user IDs from historical messages
        for (var msg in newMsgs) {
          _extractUserIdsFromMessage(msg);
        }

        if (loadMore) {
          messages.insertAll(0, newMsgs);
          print(
            '📄 Loaded ${newMsgs.length} more messages (${messages.length} total)',
          );
        } else {
          messages.value = newMsgs;
          print('📄 Loaded ${newMsgs.length} initial messages');
        }

        currentPage++;

        final next = decoded['next'];
        if (next == null) {
          hasMore.value = false;
          print('📭 Reached last page');
        }
      } else {
        print('❌ Failed to load messages: ${response.statusCode}');
        if (loadMore) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      print('🔥 fetchMessages error: $e');
      if (loadMore) {
        hasMore.value = false;
      }
    } finally {
      isLoadingMessages.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreMessages(int roomId) async {
    if (isLoadingMore.value || !hasMore.value) {
      print(
        '⏸️ Skip loading: isLoading=${isLoadingMore.value}, hasMore=${hasMore.value}',
      );
      return;
    }

    await fetchMessages(roomId, loadMore: true);
  }

  Future<void> sendMessage(int roomId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      isSendingMessage.value = true;

      if (_wsService.isConnected) {
        print('✉️ WS send: $content');

        final optimisticMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          content: content,
          senderId: currentUserId ?? 0,
          senderName: 'You',
          senderType: currentUserType,
          messageType: 'text',
          sentAt: DateTime.now().toIso8601String(),
          isRead: false,
          customerId: _extractedCustomerId,
          caretakerId: _extractedCaretakerId,
        );

        _addNewMessage(optimisticMessage);
        _updateChatRoomWithNewMessage(optimisticMessage);
        print('✅ Optimistic message added to UI');

        _wsService.sendMessage(content);
      } else {
        print('❌ WebSocket not connected');
        Get.snackbar(
          'Connection Error',
          'WebSocket is not connected. Please check your connection.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('🔥 sendMessage error: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> sendFileMessage(
    int roomId,
    String filePath,
    String fileName,
  ) async {
    try {
      isSendingMessage.value = true;

      final messageType = _getFileType(fileName);

      final optimisticMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch,
        content: fileName,
        senderId: currentUserId ?? 0,
        senderName: 'You',
        senderType: currentUserType,
        messageType: messageType,
        sentAt: DateTime.now().toIso8601String(),
        isRead: false,
        file: filePath,
        customerId: _extractedCustomerId,
        caretakerId: _extractedCaretakerId,
      );

      _addNewMessage(optimisticMessage);
      _updateChatRoomWithNewMessage(optimisticMessage);
      print('✅ Optimistic file message added to UI');

      if (_wsService.isConnected) {
        await _wsService.sendFileMessage(
          filePath: filePath,
          fileName: fileName,
          messageType: messageType,
          content: fileName,
        );
      } else {
        throw Exception('WebSocket not connected');
      }
    } catch (e) {
      print('🔥 sendFileMessage error: $e');
      messages.removeWhere((m) => m.id == DateTime.now().millisecondsSinceEpoch);

      Get.snackbar(
        'Error',
        'Failed to send file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  String _getFileType(String name) {
    final ext = name.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return 'image';
    if (['mp4', 'mov', 'avi'].contains(ext)) return 'video';
    return 'file';
  }

  Future<void> connectWebSocket(int roomId) async {
    print('🔌 Connect WS room $roomId');
    _activeRoomId = roomId;
    await _wsService.connect(roomId);
  }

  Future<void> disconnectWebSocket() async {
    print('🔌 Disconnect WS');
    _activeRoomId = null;
    await _wsService.disconnect();
  }

  // Add this method in ChatController
int? getChatIdByBooking(int bookingId) {
  try {
    print('🔍 Looking for chat with booking ID: $bookingId');
    
    final chatRoom = chatRooms.firstWhere(
      (room) => room.booking == bookingId,
      orElse: () => throw Exception('Chat not found'),
    );
    
    print('✅ Found chat ID: ${chatRoom.id} for booking: $bookingId');
    return chatRoom.id;
  } catch (e) {
    print('❌ No chat found for booking $bookingId: $e');
    return null;
  }
}

  @override
  void onClose() {
    print('🏁 Controller closed');
    _wsService.dispose();
    super.onClose();
  }
}