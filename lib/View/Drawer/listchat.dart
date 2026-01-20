import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/controllers/chat_controller.dart';
import 'package:qlickcare/View/Drawer/chatdetails.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // final ChatController controller = Get.put(ChatController());
  final ChatController controller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    // Load chat rooms on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchChatRooms();
    });
  }

  String _formatTime(String? sentAt) {
    if (sentAt == null || sentAt.isEmpty) return "";
    
    try {
      final dt = DateTime.parse(sentAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dt.year, dt.month, dt.day);

      if (messageDate == today) {
        // Today - show time
        return DateFormat.Hm().format(dt); // 15:04
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        // Yesterday
        return "Yesterday";
      } else if (now.difference(dt).inDays < 7) {
        // Within a week - show day name
        return DateFormat.E().format(dt); // Mon, Tue, etc.
      } else {
        // Older - show date
        return DateFormat('dd/MM/yy').format(dt); // 20/01/25
      }
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchChatRooms(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chatRooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No Chats Available",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchChatRooms(),
          child: ListView.separated(
            itemCount: controller.chatRooms.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 72,
              color: Colors.grey.shade300,
            ),
            itemBuilder: (_, i) {
              final chat = controller.chatRooms[i];
              final last = chat.lastMessage;
              final preview = last?.content ?? "No messages yet";
              final displayTime = _formatTime(last?.sentAt);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    chat.bookingInfo.patientName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.bookingInfo.patientName,
                        style: TextStyle(
                          fontWeight: chat.unreadCount > 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (displayTime.isNotEmpty)
                      Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0 
                              ? Colors.blue 
                              : Colors.grey.shade600,
                          fontWeight: chat.unreadCount > 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: chat.unreadCount > 0 
                              ? Colors.black87 
                              : Colors.grey.shade600,
                          fontWeight: chat.unreadCount > 0 
                              ? FontWeight.w500 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Get.to(() => ChatDetailPage(chatId: chat.id));
                },
              );
            },
          ),
        );
      }),
    );
  }
}