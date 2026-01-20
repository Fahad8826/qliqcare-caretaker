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
import 'package:url_launcher/url_launcher.dart';

class ChatDetailScreen extends StatefulWidget {
  final int chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatController _controller;
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
    
    // Initialize data loading
    _initializeChat();
  }

  /// Initializes chat with proper loading sequence
  Future<void> _initializeChat() async {
    if (_isInitialized) return;
    
    setState(() => _isLoadingInitialData = true);
    
    try {
      // STEP 1: Load messages first (most important data)
      await _controller.fetchMessages(widget.chatId);
      
      // STEP 2: Load chat details (can fail without breaking chat)
      _controller.fetchChatDetail(widget.chatId).catchError((e) {
        print('⚠️ Failed to load chat details: $e');
        // Don't throw, chat can still work
      });
      
      // STEP 3: Setup message listener BEFORE connecting WebSocket
      _setupMessageListener();
      
      // STEP 4: Connect WebSocket (now listener is ready)
      await _controller.connectWebSocket(widget.chatId);
      
      _isInitialized = true;
      
      // STEP 5: Scroll to bottom after messages are rendered
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
        // Auto-scroll when new message arrives
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
    return (maxScroll - currentScroll) < 100; // Within 100 pixels of bottom
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

    // Clear input immediately for better UX
    _messageController.clear();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    try {
      await _controller.sendMessage(widget.chatId, text);
      
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('❌ Error sending message: $e');
      // Optionally restore the message text on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick file')),
        );
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
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
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
          // Header
          _buildHeader(size, isPortrait),

          // Messages List
          Expanded(
            child: _isLoadingInitialData
                ? const Center(child: Loading())
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
                        // Detect when user is scrolling up and approaching the top
                        if (scrollInfo is ScrollUpdateNotification) {
                          final position = _scrollController.position;
                          
                          // When user reaches top 300 pixels, start loading
                          if (position.pixels <= position.minScrollExtent + 300) {
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
                          // Loading indicator at top
                          if (index == 0) {
                            return Obx(
                              () => _controller.isLoadingMore.value
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
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

          // Input Area
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

                // Avatar
                Container(
                  width: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  height: isPortrait ? size.width * 0.11 : size.height * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.buttonText.withOpacity(0.2),
                    border: Border.all(color: AppColors.buttonText, width: 2),
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
                        stream: _controller.wsService.connectionStream,
                        builder: (context, snapshot) {
                          final connected = snapshot.data ?? false;
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
              // Image message
              if (msg.messageType == 'image' && url != null)
                GestureDetector(
                  onTap: () => _showFullImage(url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: size.width * 0.6,
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

              // File message
              if (msg.messageType == 'file' && url != null)
                _buildFileMessage(msg, isMe, url),

              // Text message
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
              
              // Time
              Text(
                _formatTime(msg.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe 
                      ? AppColors.buttonText.withOpacity(0.7) 
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
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open file: $e')),
          );
        }
      }
    },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe 
              ? AppColors.buttonText.withOpacity(0.2) 
              : AppColors.screenBackground,
          borderRadius: BorderRadius.circular(8),
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

            // Send Button
            Obx(() {
              return _controller.isSendingMessage.value
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
                          child: Loading(),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _sendMessage,
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

  String _formatTime(String sent) {
    try {
      final dt = DateTime.parse(sent);
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      return "";
    }
  }
}