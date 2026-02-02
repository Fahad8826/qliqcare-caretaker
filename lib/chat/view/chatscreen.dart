import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/Drawer/drawer.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';
import 'package:qlickcare/chat/view/chatdetailscreen.dart';

import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';

import 'package:qlickcare/notification/views/listnotification.dart';

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
                return _buildShimmerLoader(size);
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

  // Shimmer Loader Widget
  Widget _buildShimmerLoader(Size size) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      itemCount: 8,
      itemBuilder: (_, index) {
        return _ShimmerChatItem(size: size);
      },
    );
  }
}

// Shimmer Chat Item Widget
class _ShimmerChatItem extends StatefulWidget {
  final Size size;

  const _ShimmerChatItem({required this.size});

  @override
  State<_ShimmerChatItem> createState() => _ShimmerChatItemState();
}

class _ShimmerChatItemState extends State<_ShimmerChatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size.width * 0.05,
            vertical: widget.size.height * 0.015,
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
              // Avatar Shimmer
              Opacity(
                opacity: _shimmerAnimation.value,
                child: Container(
                  width: isPortrait ? widget.size.width * 0.13 : widget.size.height * 0.15,
                  height: isPortrait ? widget.size.width * 0.13 : widget.size.height * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ),

              SizedBox(width: widget.size.width * 0.035),

              // Content Shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: _shimmerAnimation.value,
                      child: Container(
                        width: widget.size.width * 0.4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.size.height * 0.004),
                    Opacity(
                      opacity: _shimmerAnimation.value,
                      child: Container(
                        width: widget.size.width * 0.6,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: widget.size.width * 0.025),

              // Time Shimmer
              Opacity(
                opacity: _shimmerAnimation.value,
                child: Container(
                  width: 40,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}