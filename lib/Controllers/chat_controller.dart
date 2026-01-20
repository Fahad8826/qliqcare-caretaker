// ChatController.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Services/tokenservice.dart';
import '../../Model/chat_model.dart';
import '../Services/tokenexpireservice.dart';
import '../Services/websoket_chat_service.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMessages = false.obs;
  var isSendingMessage = false.obs;

  var chatRooms = <ChatRoom>[].obs;
  var selectedChat = Rxn<ChatRoom>();
  var messages = <Message>[].obs;

  final WebSocketService _wsService = WebSocketService();
  int? _activeRoomId;
  
  // Store current user info - YOU NEED TO SET THIS!
  int? currentUserId;
  String currentUserType = "caretaker"; // or get from your auth service

  WebSocketService get wsService => _wsService;

  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 ChatController INIT');
    
    // Get current user info - IMPORTANT!
    _getCurrentUserInfo();

    _wsService.messageStream.listen((message) {
      print('📩 WS message received in controller: ${message.id} - ${message.content}');
      print('📩 Message sender: ${message.senderType}');
      print('📩 Current messages count: ${messages.length}');
      _addNewMessage(message);
      print('📩 After add messages count: ${messages.length}');
      _updateChatRoomWithNewMessage(message);
    }, onError: (error) {
      print('❌ Error in message stream: $error');
    });

    _wsService.connectionStream.listen((isConnected) {
      print('📶 WS Status: ${isConnected ? "Connected" : "Disconnected"}');
    });
  }
  
  // Get current user info from your auth service or API
  Future<void> _getCurrentUserInfo() async {
    try {
      // Option 1: Get from token service if you have it
      // final userId = await TokenService.getCurrentUserId();
      
      // Option 2: Decode from JWT token
      final token = await TokenService.getAccessToken();
      if (token != null) {
        // Simple JWT decode (you might need to add jwt_decode package)
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> payloadMap = json.decode(decoded);
          
          currentUserId = int.tryParse(payloadMap['user_id']?.toString() ?? '');
          print('👤 Current user ID: $currentUserId');
        }
      }
      
      // Option 3: Make API call to get user profile
      // final response = await http.get(Uri.parse("${dotenv.env['BASE_URL']}/api/profile/"));
      // currentUserId = jsonDecode(response.body)['id'];
      
    } catch (e) {
      print('⚠️ Could not get user info: $e');
    }
  }

  void _addNewMessage(Message message) {
    // Check if this is our own message coming back from server
    // Match by content and sender within last 5 seconds
    final isOwnMessage = message.senderId == currentUserId;
    final recentTime = DateTime.now().subtract(const Duration(seconds: 5));
    
    Message? optimisticMatch;
    if (isOwnMessage) {
      // Try to find matching optimistic message
      try {
        optimisticMatch = messages.firstWhere(
          (m) => m.content == message.content && 
                 m.senderId == currentUserId &&
                 m.id > DateTime.now().subtract(const Duration(seconds: 10)).millisecondsSinceEpoch &&
                 DateTime.parse(m.sentAt).isAfter(recentTime),
        );
      } catch (e) {
        // No match found
      }
    }
    
    if (optimisticMatch != null) {
      // Replace optimistic message with real one
      final index = messages.indexOf(optimisticMatch);
      messages[index] = message;
      print('🔄 Replaced optimistic message with server message: ${message.id}');
    } else {
      // Check for duplicate by ID
      final existingIndex = messages.indexWhere((m) => m.id == message.id);
      
      // Fix sender_type if it's empty (from WebSocket messages)
      Message finalMessage = message;
      if (message.senderType.isEmpty && currentUserId != null) {
        finalMessage = Message(
          id: message.id,
          content: message.content,
          senderId: message.senderId,
          senderName: message.senderName,
          senderType: message.senderId == currentUserId ? currentUserType : (currentUserType == "caretaker" ? "customer" : "caretaker"),
          messageType: message.messageType,
          sentAt: message.sentAt,
          fileUrl: message.fileUrl,
          file: message.file,
          isRead: message.isRead,
          readAt: message.readAt,
        );
        print('🔧 Fixed sender_type: ${finalMessage.senderType}');
      }
      
      if (existingIndex == -1) {
        // Add new message to the end (bottom of chat)
        messages.add(finalMessage);
        print('➕ Added message: ${finalMessage.id} (Total: ${messages.length})');
        print('➕ Message content: ${finalMessage.content}');
      } else {
        // Update existing message
        messages[existingIndex] = finalMessage;
        print('🔄 Updated message: ${finalMessage.id}');
      }
    }
    
    // Force UI update
    messages.refresh();
  }

  void _updateChatRoomWithNewMessage(Message message) {
    // Update the chat room list with the new message
    final roomIndex = chatRooms.indexWhere((room) => room.id == _activeRoomId);
    
    if (roomIndex != -1) {
      final room = chatRooms[roomIndex];
      
      // Create updated room with new last message
      final updatedRoom = ChatRoom(
        id: room.id,
        booking: room.booking,
        customerName: room.customerName,
        caretakerName: room.caretakerName,
        lastMessage: message,
        unreadCount: message.senderType != "caretaker" ? room.unreadCount + 1 : room.unreadCount,
        bookingInfo: room.bookingInfo,
        createdAt: room.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      // Remove old and add updated room at the top
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
      isLoading.value = true;

      final url = Uri.parse("${dotenv.env['BASE_URL']}/api/chat/rooms/$id/");
      final response = await ApiService.request((token) {
        return http.get(url, headers: {"Authorization": "Bearer $token"});
      });

      if (response.statusCode == 200) {
        selectedChat.value = ChatRoom.fromJson(jsonDecode(response.body));
        print('📌 Loaded room $id');
      }
    } catch (e) {
      print('🔥 fetchChatDetail error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMessages(int roomId, {bool loadMore = false}) async {
    if (loadMore && (!hasMore.value || isLoadingMore.value)) return;

    if (!loadMore) {
      print('📥 Fetch messages page 1 for $roomId');
      currentPage = 1;
      hasMore.value = true;
      messages.clear();
      isLoadingMessages.value = true;
    } else {
      print('📥 Load more messages page ${currentPage + 1}');
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

        // API returns newest first, reverse to get oldest first
        final newMsgs = results
            .map<Message>((e) => Message.fromJson(e))
            .toList()
            .reversed
            .toList();

        if (loadMore) {
          // Insert older messages at the beginning
          messages.insertAll(0, newMsgs);
        } else {
          // First load - just assign
          messages.value = newMsgs;
        }
        
        currentPage++;
        print('📄 Loaded page $currentPage (${messages.length} total)');
      }
    } catch (e) {
      print('🔥 fetchMessages error: $e');
    } finally {
      isLoadingMessages.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreMessages(int roomId) =>
      fetchMessages(roomId, loadMore: true);

  Future<void> sendMessage(int roomId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      isSendingMessage.value = true;

      if (_wsService.isConnected) {
        print('✉️ WS send: $content');
        
        // Create optimistic message (add it immediately to UI)
        final optimisticMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          content: content,
          senderId: currentUserId ?? 0,
          senderName: 'You',
          senderType: currentUserType,
          messageType: 'text',
          sentAt: DateTime.now().toIso8601String(),
          isRead: false,
        );
        
        // Add to UI immediately
        _addNewMessage(optimisticMessage);
        _updateChatRoomWithNewMessage(optimisticMessage);
        print('✅ Optimistic message added to UI');
        
        // Send via WebSocket
        await _wsService.sendMessage(content);
      } else {
        print('❌ WebSocket not connected - cannot send message');
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

  Future<void> sendFileMessage(int roomId, String filePath, String fileName) async {
    try {
      isSendingMessage.value = true;

      final url = Uri.parse("${dotenv.env['BASE_URL']}/api/chat/rooms/$roomId/send/");
      final type = _getFileType(fileName);
      print('📤 Upload $fileName as $type');

      final response = await ApiService.multipartRequest((token) async {
        var req = http.MultipartRequest('POST', url);
        req.headers['Authorization'] = 'Bearer $token';
        req.fields['message_type'] = type;
        req.files.add(await http.MultipartFile.fromPath('file', filePath));
        return req.send();
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = Message.fromJson(jsonDecode(response.body));
        _addNewMessage(message);
        _updateChatRoomWithNewMessage(message);
      } else {
        print('❌ File failed ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 sendFileMessage error: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  String _getFileType(String name) {
    final ext = name.toLowerCase().split('.').last;
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) return 'image';
    if (['mp4','mov','avi'].contains(ext)) return 'video';
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

  @override
  void onClose() {
    print('🏁 Controller closed');
    _wsService.dispose();
    super.onClose();
  }
}