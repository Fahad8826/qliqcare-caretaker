

class ChatRoom {
  final int id;
  final int booking;
  final String customerName;
  final String caretakerName;
  final int? customerId;      // ✅ ADDED: Optional for now
  final int? caretakerId;     // ✅ ADDED: Optional for now
  final Message? lastMessage;
  final int unreadCount;
  final BookingInfo bookingInfo;
  final String createdAt;
  final String updatedAt;

  ChatRoom({
    required this.id,
    required this.booking,
    required this.customerName,
    required this.caretakerName,
    this.customerId,
    this.caretakerId,
    required this.lastMessage,
    required this.unreadCount,
    required this.bookingInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      booking: json['booking'],
      customerName: json['customer_name'] ?? '',
      caretakerName: json['caretaker_name'] ?? '',
      customerId: json['customer_id'] ?? json['customer'],  // ✅ Parse from API
      caretakerId: json['caretaker_id'] ?? json['caretaker'], // ✅ Parse from API
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      bookingInfo: BookingInfo.fromJson(json['booking_info']),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // ✅ NEW: Helper to get customer ID from either ChatRoom or last message
  int? getCustomerId() {
    if (customerId != null) return customerId;
    // Fallback: Try to get from last message if sender is customer
    if (lastMessage?.senderType == 'customer') {
      return lastMessage?.senderId;
    }
    return null;
  }

  // ✅ NEW: Helper to get caretaker ID
  int? getCaretakerId() {
    if (caretakerId != null) return caretakerId;
    // Fallback: Try to get from last message if sender is caretaker
    if (lastMessage?.senderType == 'caretaker') {
      return lastMessage?.senderId;
    }
    return null;
  }
}

class BookingInfo {
  final int id;
  final String patientName;
  final String status;
  final String startDate;
  final String endDate;

  BookingInfo({
    required this.id,
    required this.patientName,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory BookingInfo.fromJson(Map<String, dynamic> json) {
    return BookingInfo(
      id: json['id'],
      patientName: json['patient_name'],
      status: json['status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class Message {
  final int id;
  final String content;
  final int senderId;
  final String senderName;
  final String senderType;
  final String messageType;
  final String sentAt;
  final String? fileUrl;
  final String? file;
  final bool isRead;
  final String? readAt;
  final int? customerId;    // ✅ ADDED: From WebSocket response
  final int? caretakerId;   // ✅ ADDED: From WebSocket response

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.messageType,
    required this.sentAt,
    this.fileUrl,
    this.file,
    required this.isRead,
    this.readAt,
    this.customerId,
    this.caretakerId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['message_id'] ?? 0;
    final senderId = json['sender'] ?? json['sender_id'] ?? 0;
    final sentAt = json['sent_at'] ?? json['timestamp'] ?? json['created_at'] ?? DateTime.now().toIso8601String();
    String senderType = json['sender_type'] ?? '';
    
    print('🔍 Parsing message - ID: $id, Content: ${json['content']}, Sender: $senderId, SenderType: $senderType');
    
    return Message(
      id: id,
      content: json['content'] ?? '',
      senderId: senderId,
      senderName: json['sender_name'] ?? '',
      senderType: senderType,
      messageType: json['message_type'] ?? 'text',
      sentAt: sentAt,
      fileUrl: json['file_url'],
      file: json['file'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      customerId: json['customer_id'],     // ✅ Parse from WebSocket
      caretakerId: json['caretaker_id'],   // ✅ Parse from WebSocket
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': senderId,
      'sender_name': senderName,
      'sender_type': senderType,
      'message_type': messageType,
      'sent_at': sentAt,
      'file_url': fileUrl,
      'file': file,
      'is_read': isRead,
      'read_at': readAt,
      'customer_id': customerId,
      'caretaker_id': caretakerId,
    };
  }

  String? getFileUrl(String baseUrl) {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      if (fileUrl!.startsWith('http')) return fileUrl;
      return '$baseUrl$fileUrl';
    }

    if (file != null && file!.isNotEmpty) {
      if (file!.startsWith('http')) return file;
      return '$baseUrl$file';
    }
    return null;
  }
}