
 
 

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/controllers/chat_controller.dart';
import 'package:qlickcare/Model/chat_model.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class ChatDetailScreen extends StatelessWidget {
  final int chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();
    final ImagePicker picker = ImagePicker();
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    // Initialize on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatData(controller, scrollController);
      _setupListeners(controller, scrollController);
    });

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          // Green Header with Profile Info
          _buildHeader(context, controller, size, isPortrait),

          // Chat Messages
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value &&
                  controller.messages.isEmpty) {
                return const Center(child: Loading());
              }

              if (controller.messages.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.02,
                ),
                itemCount: controller.messages.length + 1,
                itemBuilder: (_, i) {
                  // Show loading indicator at the top (index 0)
                  if (i == 0) {
                    return Obx(
                      () => controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }

                  // Adjust index since we added loading at top
                  final msg = controller.messages[i - 1];
                  return _buildMessage(context, msg, size, isPortrait);
                },
              );
            }),
          ),

          // Message Input
          _buildInput(
            context,
            controller,
            messageController,
            scrollController,
            picker,
            size,
            isPortrait,
          ),
        ],
      ),
    );
  }

  void _loadChatData(ChatController controller, ScrollController scrollController) async {
    // Start WebSocket connection immediately (non-blocking)
    controller.connectWebSocket(chatId);

    // Load chat details and messages in parallel
    await Future.wait([
      controller.fetchChatDetail(chatId),
      controller.fetchMessages(chatId),
    ]);

    // Scroll to bottom after messages loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(scrollController);
    });
  }

  void _setupListeners(ChatController controller, ScrollController scrollController) {
    /// Auto-scroll when new message comes
    controller.wsService.messageStream.listen((msg) {
      print('🎯 Detail page received message: ${msg.id} - ${msg.content}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(scrollController);
      });
    });

    /// Load more messages when scroll to top
    scrollController.addListener(() {
      if (scrollController.position.pixels <=
          scrollController.position.minScrollExtent + 100) {
        // near top
        controller.loadMoreMessages(chatId);
      }
    });
  }

  void _scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(
    ChatController controller,
    TextEditingController messageController,
    ScrollController scrollController,
  ) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    await controller.sendMessage(chatId, text);

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(scrollController);
    });
  }

  Future<void> _pickImage(
    ImageSource src,
    ChatController controller,
    ImagePicker picker,
    ScrollController scrollController,
  ) async {
    final XFile? image = await picker.pickImage(source: src, imageQuality: 80);

    if (image != null) {
      await controller.sendFileMessage(chatId, image.path, image.name);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(scrollController);
      });
    }
  }

  Future<void> _pickFile(
    ChatController controller,
    ScrollController scrollController,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await controller.sendFileMessage(
        chatId,
        result.files.single.path!,
        result.files.single.name,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(scrollController);
      });
    }
  }

  void _showAttachmentOptions(
    BuildContext context,
    ChatController controller,
    ImagePicker picker,
    ScrollController scrollController,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, controller, picker, scrollController);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, controller, picker, scrollController);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(controller, scrollController);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ChatController controller,
    Size size,
    bool isPortrait,
  ) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.015,
          ),
          child: Obx(() {
            final chat = controller.selectedChat.value;
            final patientName = chat?.bookingInfo.patientName ?? "Chat";
            final status = chat?.bookingInfo.status ?? "Offline";

            return Row(
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.buttonText,
                    size: isPortrait ? size.width * 0.06 : size.height * 0.07,
                  ),
                ),

                SizedBox(width: size.width * 0.02),

                // Profile Image - Letter Avatar
                Container(
                  width: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  height: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.buttonText.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.buttonText,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: isPortrait ? size.width * 0.05 : size.height * 0.06,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: size.width * 0.03),

                // Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.buttonText,
                          fontSize: isPortrait ? size.width * 0.045 : size.height * 0.055,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: size.height * 0.002),
                      StreamBuilder<bool>(
                        stream: controller.wsService.connectionStream,
                        builder: (_, snap) {
                          final connected = snap.data ?? false;
                          return Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: connected ? Colors.greenAccent : Colors.grey,
                                size: 8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                connected ? "Online" : "Offline",
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.buttonText.withOpacity(0.9),
                                  fontSize: isPortrait ? size.width * 0.032 : size.height * 0.038,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Call Icons
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.phone,
                    color: AppColors.buttonText,
                    size: isPortrait ? size.width * 0.06 : size.height * 0.07,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.videocam,
                    color: AppColors.buttonText,
                    size: isPortrait ? size.width * 0.065 : size.height * 0.075,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Message m, Size size, bool isPortrait) {
    final isMe = m.senderType == "caretaker";
    final url = m.getFileUrl(dotenv.env['BASE_URL']!);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: size.width * 0.75),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.012,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (m.messageType == 'image' && url != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            iconTheme: const IconThemeData(color: Colors.white),
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              child: Image.network(
                                url,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      url,
                      width: size.width * 0.6,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: size.width * 0.6,
                          height: size.height * 0.2,
                          color: Colors.grey.shade400,
                          child: const Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                ),

              if (m.messageType == 'file' && url != null)
                GestureDetector(
                  onTap: () {
                    // You can add file download or preview functionality here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File: ${m.content}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe 
                          ? AppColors.buttonText.withOpacity(0.2) 
                          : AppColors.screenBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: isMe ? AppColors.buttonText : AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            m.content.isNotEmpty ? m.content : 'File',
                            style: TextStyle(
                              color: isMe ? AppColors.buttonText : AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (m.messageType == 'text' && m.content.isNotEmpty)
                Text(
                  m.content,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: isMe ? AppColors.buttonText : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),

              if (m.messageType != 'image' && m.messageType != 'text' && m.messageType != 'file' && m.content.isEmpty)
                Text(
                  m.messageType.toUpperCase(),
                  style: TextStyle(
                    color: isMe ? AppColors.buttonText.withOpacity(0.7) : AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              SizedBox(height: size.height * 0.004),
              Text(
                _format(m.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? AppColors.buttonText.withOpacity(0.7) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    ChatController controller,
    TextEditingController messageController,
    ScrollController scrollController,
    ImagePicker picker,
    Size size,
    bool isPortrait,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text Input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: AppColors.screenBackground,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Message...",
                          hintStyle: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        onSubmitted: (_) => _sendMessage(controller, messageController, scrollController),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () => _showAttachmentOptions(context, controller, picker, scrollController),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: size.width * 0.02),

            // Send Button
            Obx(() {
              return controller.isSendingMessage.value
                  ? Container(
                      width: isPortrait ? size.width * 0.12 : size.height * 0.14,
                      height: isPortrait ? size.width * 0.12 : size.height * 0.14,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:Loading(),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () => _sendMessage(controller, messageController, scrollController),
                      child: Container(
                        width: isPortrait ? size.width * 0.12 : size.height * 0.14,
                        height: isPortrait ? size.width * 0.12 : size.height * 0.14,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: AppColors.buttonText,
                          size: isPortrait ? size.width * 0.05 : size.height * 0.06,
                        ),
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  String _format(String sent) {
    try {
      final dt = DateTime.parse(sent);
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      return "";
    }
  }
}