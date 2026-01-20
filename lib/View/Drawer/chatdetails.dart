import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/controllers/chat_controller.dart';
import 'package:qlickcare/Model/chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final int chatId;
  const ChatDetailPage({super.key, required this.chatId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatData();
    });

    /// Auto-scroll when new message comes
    controller.wsService.messageStream.listen((msg) {
      print('🎯 Detail page received message: ${msg.id} - ${msg.content}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    });

    /// Load more messages when scroll to top
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100) {
        // near top
        controller.loadMoreMessages(widget.chatId);
      }
    });
  }

  Future<void> _loadChatData() async {
    // Start WebSocket connection immediately (non-blocking)
    controller.connectWebSocket(widget.chatId);
    
    // Load chat details and messages in parallel
    await Future.wait([
      controller.fetchChatDetail(widget.chatId),
      controller.fetchMessages(widget.chatId),
    ]);

    // Scroll to bottom after messages loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await controller.sendMessage(widget.chatId, text);
    
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _pickImage(ImageSource src) async {
    final XFile? image = await _picker.pickImage(source: src, imageQuality: 80);

    if (image != null) {
      await controller.sendFileMessage(widget.chatId, image.path, image.name);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await controller.sendFileMessage(
        widget.chatId,
        result.files.single.path!,
        result.files.single.name,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _showAttachmentOptions() {
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
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
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
    controller.disconnectWebSocket();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final chat = controller.selectedChat.value;
          return chat == null
              ? const Text("Chat")
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.bookingInfo.patientName),
                    Text(
                      chat.bookingInfo.status,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
        }),
        actions: [
          /// WS indicator
          StreamBuilder<bool>(
            stream: controller.wsService.connectionStream,
            builder: (_, snap) {
              final ok = snap.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  ok ? Icons.wifi : Icons.wifi_off,
                  color: ok ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// MESSAGES
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value &&
                  controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length + 1, // +1 for loading indicator at top
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
                  return _buildMessage(msg);
                },
              );
            }),
          ),

          /// INPUT
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Message m) {
    final isMe = m.senderType == "caretaker"; // adjust if needed
    final url = m.getFileUrl(dotenv.env['BASE_URL']!);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.messageType == 'image' && url != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade400,
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),

            if (m.messageType != 'image' && m.content.isNotEmpty)
              Text(
                m.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),

            if (m.messageType != 'image' && m.content.isEmpty)
              Text(
                m.messageType.toUpperCase(),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 4),
            Text(
              _format(m.sentAt),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentOptions,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Obx(() {
              return controller.isSendingMessage.value
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
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
      return DateFormat("HH:mm").format(dt);
    } catch (_) {
      return "";
    }
  }
}