import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/call/controller/call_controller.dart';
import 'package:qlickcare/call/view/call_screen.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';

import 'package:qlickcare/chat/model/chat_model.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../call/view/incoming_call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final int chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatController _controller;
  // late final CallController callController;
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Initialize CallController with WebSocketService
    // callController = Get.put(
    //   CallController(_controller.wsService),
    //   permanent: true,
    // );

    _initializeChat();
    // _setupCallListener();
  }

  // void _setupCallListener() {
  //   callController.callState.listen((state) {
  //     if (state == CallState.ringing && mounted) {
  //       final callerName = _controller.getCallerName();

  //       showIncomingCallDialog(
  //         context: context,
  //         callerName: callerName,
  //         callType: callController.callType,
  //         callController: callController,
  //       );
  //     }
  //   });
  // }

  Future<void> _initializeChat() async {
    if (_isInitialized) return;

    setState(() => _isLoadingInitialData = true);

    try {
      await _controller.fetchMessages(widget.chatId);
      _controller.fetchChatDetail(widget.chatId).catchError((e) {
        print('⚠️ Failed to load chat details: $e');
      });

      _setupMessageListener();
      await _controller.connectWebSocket(widget.chatId);

      _isInitialized = true;

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animate: false);
        });
      }

      print('✅ Chat initialized successfully');
    } catch (e) {
      print('❌ Error initializing chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chat: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _isInitialized = false;
                _initializeChat();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }

  void _setupMessageListener() {
    _controller.wsService.messageStream.listen(
      (msg) {
        print('🎯 New message received: ${msg.id} - ${msg.content}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isNearBottom()) {
            _scrollToBottom();
          }
        });
      },
      onError: (error) {
        print('❌ Message stream error: $error');
      },
    );
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) < 100;
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      await _controller.sendMessage(widget.chatId, text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        await _controller.sendFileMessage(
          widget.chatId,
          image.path,
          image.name,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _controller.sendFileMessage(
          widget.chatId,
          result.files.single.path!,
          result.files.single.name,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick file')));
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: AppColors.primary),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _controller.disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          _buildHeader(size, isPortrait),
          Expanded(
            child: _isLoadingInitialData
                ? _buildChatShimmer(size, isPortrait)
                : Obx(() {
                    if (_controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No messages yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Start the conversation!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollUpdateNotification) {
                          final position = _scrollController.position;
                          if (position.pixels <=
                              position.minScrollExtent + 300) {
                            if (!_controller.isLoadingMore.value &&
                                _controller.hasMore.value) {
                              _controller.loadMoreMessages(widget.chatId);
                            }
                          }
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _controller.messages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Obx(
                              () => _controller.isLoadingMore.value
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(height: 8),
                            );
                          }

                          final msg = _controller.messages[index - 1];
                          return _buildMessage(msg, size, isPortrait);
                        },
                      ),
                    );
                  }),
          ),
          _buildInput(size, isPortrait),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size, bool isPortrait) {
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
            final chat = _controller.selectedChat.value;
            final patientName = chat?.bookingInfo.patientName ?? "Chat";

            return Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.buttonText,
                    size: isPortrait ? size.width * 0.06 : size.height * 0.07,
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Container(
                  width: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  height: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.buttonText.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.buttonText, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      patientName.isNotEmpty
                          ? patientName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: isPortrait
                            ? size.width * 0.05
                            : size.height * 0.06,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.buttonText,
                          fontSize: isPortrait
                              ? size.width * 0.045
                              : size.height * 0.055,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: size.height * 0.002),
                      StreamBuilder<bool>(
                        stream: _controller.wsService.connectionStream,
                        builder: (context, snapshot) {
                          final connected = snapshot.data ?? false;
                          return Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: connected
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                size: 8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                connected ? "connected" : "connecting...",
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.buttonText.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: isPortrait
                                      ? size.width * 0.032
                                      : size.height * 0.038,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ==================== Chat Shimmer Loader ====================
  Widget _buildChatShimmer(Size size, bool isPortrait) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      itemCount: 8,
      itemBuilder: (_, index) {
        final isRight = index % 3 == 0; // Mix of left and right messages
        return _ChatMessageShimmer(
          size: size,
          isPortrait: isPortrait,
          isRight: isRight,
        );
      },
    );
  }

  Widget _buildMessage(Message msg, Size size, bool isPortrait) {
    final isMe = msg.senderType == "caretaker";
    final url = msg.getFileUrl(dotenv.env['BASE_URL']!);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: size.width * 0.75),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: isMe
                  ? const Radius.circular(14)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.messageType == 'image' && url != null)
                GestureDetector(
                  onTap: () => _showFullImage(url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      url,
                      width: size.width * 0.3,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: size.width * 0.6,
                          height: size.height * 0.2,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
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
              if (msg.messageType == 'file' && url != null)
                _buildFileMessage(msg, isMe, url),
              if (msg.messageType == 'text' && msg.content.isNotEmpty)
                Text(
                  msg.content,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: isMe ? AppColors.buttonText : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              SizedBox(height: size.height * 0.004),
              Text(
                _formatTime(msg.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe
                      ? AppColors.buttonText.withValues(alpha: 0.7)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileMessage(Message msg, bool isMe, String url) {
    return GestureDetector(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot open this file')),
              );
            }
          }
        } catch (e) {
          print('❌ Error opening file: $e');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to open file: $e')));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.buttonText.withValues(alpha: 0.15)
              : AppColors.screenBackground,
          borderRadius: BorderRadius.circular(6),
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
                msg.content.isNotEmpty ? msg.content : 'File',
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
    );
  }

  void _showFullImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(Size size, bool isPortrait) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
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
                        controller: _messageController,
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
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: _showAttachmentOptions,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Obx(() {
              return _controller.isSendingMessage.value
                  ? Container(
                      width: isPortrait
                          ? size.width * 0.12
                          : size.height * 0.14,
                      height: isPortrait
                          ? size.width * 0.12
                          : size.height * 0.14,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _sendMessage,
                      child: Container(
                        width: isPortrait
                            ? size.width * 0.12
                            : size.height * 0.14,
                        height: isPortrait
                            ? size.width * 0.12
                            : size.height * 0.14,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: AppColors.buttonText,
                          size: isPortrait
                              ? size.width * 0.05
                              : size.height * 0.06,
                        ),
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTime(String sent) {
    try {
      final dt = DateTime.parse(sent);
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      return "";
    }
  }
}

// ==================== Chat Message Shimmer Widget ====================
class _ChatMessageShimmer extends StatefulWidget {
  final Size size;
  final bool isPortrait;
  final bool isRight;

  const _ChatMessageShimmer({
    required this.size,
    required this.isPortrait,
    required this.isRight,
  });

  @override
  State<_ChatMessageShimmer> createState() => _ChatMessageShimmerState();
}

class _ChatMessageShimmerState extends State<_ChatMessageShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: widget.size.height * 0.015),
          child: Align(
            alignment:
                widget.isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: widget.size.width * 0.65),
              padding: EdgeInsets.symmetric(
                horizontal: widget.size.width * 0.03,
                vertical: widget.size.height * 0.012,
              ),
              decoration: BoxDecoration(
                color: widget.isRight
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: widget.isRight
                      ? const Radius.circular(14)
                      : const Radius.circular(4),
                  bottomRight: widget.isRight
                      ? const Radius.circular(4)
                      : const Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text shimmer
                  Opacity(
                    opacity: _shimmerAnimation.value,
                    child: Container(
                      width: widget.size.width * 0.5,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: widget.size.height * 0.006),
                  // Second line shimmer
                  Opacity(
                    opacity: _shimmerAnimation.value,
                    child: Container(
                      width: widget.size.width * 0.35,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: widget.size.height * 0.008),
                  // Time shimmer
                  Opacity(
                    opacity: _shimmerAnimation.value,
                    child: Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}