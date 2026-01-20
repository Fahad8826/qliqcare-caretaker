import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/chat/chatdetailscreen.dart';
import 'package:qlickcare/controllers/chat_controller.dart';
import 'package:qlickcare/View/Drawer/chatdetails.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/View/Drawer/drawer.dart';
import 'package:qlickcare/View/listnotification.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final ChatController controller = Get.put(ChatController());

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
        return DateFormat.jm().format(dt); // 11:09 AM
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "Chats",
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                FontAwesomeIcons.bars,
                color: AppColors.background,
                size: 22,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.bell,
              color: AppColors.background,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notification()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.chatRooms.isEmpty) {
                return const Center(child: Loading());
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
                backgroundColor: AppColors.screenBackground,
                onRefresh: () => controller.fetchChatRooms(),
                color: AppColors.primary,
                child: ListView.builder(
                  
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  itemCount: controller.chatRooms.length,
                  itemBuilder: (_, i) {
                    final chat = controller.chatRooms[i];
                    final last = chat.lastMessage;
                    final preview = last?.content ?? "No messages yet";
                    final displayTime = _formatTime(last?.sentAt);

                    return _buildChatItem(
                      context,
                      name: chat.bookingInfo.patientName,
                      message: preview,
                      time: displayTime,
                      unreadCount: chat.unreadCount > 0 ? chat.unreadCount : null,
                      onTap: () {
                        Get.to(() => ChatDetailScreen(chatId: chat.id));
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    int? unreadCount,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile Image - Letter Avatar
            Container(
              width: isPortrait ? size.width * 0.13 : size.height * 0.15,
              height: isPortrait ? size.width * 0.13 : size.height * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: isPortrait ? size.width * 0.055 : size.height * 0.065,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(width: size.width * 0.035),

            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 16,
                      fontWeight: unreadCount != null ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: size.height * 0.004),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: unreadCount != null ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: unreadCount != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: size.width * 0.025),

            // Time and Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      color: unreadCount != null ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: unreadCount != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                if (unreadCount != null) ...[
                  SizedBox(height: size.height * 0.006),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}