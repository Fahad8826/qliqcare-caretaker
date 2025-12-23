import 'package:flutter/material.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class ChatDetailScreen extends StatelessWidget {
  final String name;
  final String status;

  const ChatDetailScreen({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          // Green Header with Profile Info
          Container(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.buttonText,
                        size: isPortrait
                            ? size.width * 0.06
                            : size.height * 0.07,
                      ),
                    ),

                    SizedBox(width: size.width * 0.02),

                    // Profile Image
                    Container(
                      width: isPortrait
                          ? size.width * 0.11
                          : size.height * 0.13,
                      height: isPortrait
                          ? size.width * 0.11
                          : size.height * 0.13,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.buttonText,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://i.pravatar.cc/150?img=47',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: AppColors.buttonText,
                              size: isPortrait
                                  ? size.width * 0.06
                                  : size.height * 0.07,
                            );
                          },
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
                            name,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.buttonText,
                              fontSize: isPortrait
                                  ? size.width * 0.045
                                  : size.height * 0.055,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.002),
                          Text(
                            status,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.buttonText.withOpacity(0.9),
                              fontSize: isPortrait
                                  ? size.width * 0.032
                                  : size.height * 0.038,
                            ),
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
                        size: isPortrait
                            ? size.width * 0.06
                            : size.height * 0.07,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.videocam,
                        color: AppColors.buttonText,
                        size: isPortrait
                            ? size.width * 0.065
                            : size.height * 0.075,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
              children: [
                // Date Label
                _buildDateLabel(context, "Yesterday"),

                SizedBox(height: size.height * 0.02),

                // Received Message
                _buildReceivedMessage(
                  context,
                  "Hello, can you please check if my father has taken his 2 PM medicine?",
                ),

                SizedBox(height: size.height * 0.015),

                // Sent Message
                _buildSentMessage(
                  context,
                  "Yes, he took it 10 minutes ago along with some water.",
                ),

                SizedBox(height: size.height * 0.015),

                // Received Message
                _buildReceivedMessage(
                  context,
                  "Great. How's his temperature now?",
                ),

                SizedBox(height: size.height * 0.015),

                // Sent Message
                _buildSentMessage(
                  context,
                  "It's normal — 98.5°F. No signs of fever since morning.",
                ),

                SizedBox(height: size.height * 0.015),

                // Received Message
                _buildReceivedMessage(
                  context,
                  "Okay, please inform me if there's any change in his blood pressure or sugar level.",
                ),

                SizedBox(height: size.height * 0.015),

                // Sent Message
                _buildSentMessage(
                  context,
                  "Of course. I'll update you after the evening checkup.",
                ),

                SizedBox(height: size.height * 0.02),

                // Today Label
                _buildDateLabel(context, "Today"),

                SizedBox(height: size.height * 0.02),

                // Voice Message (Sent)
                _buildSentVoiceMessage(context),

                SizedBox(height: size.height * 0.015),

                // Received Message
                _buildReceivedMessage(context, "OMG !! What happened then !!"),

                SizedBox(height: size.height * 0.015),

                // Sent Message
                _buildSentMessage(
                  context,
                  "Nothing to worry, he is alright Now",
                ),

                SizedBox(height: size.height * 0.015),

                // Received Message
                _buildReceivedMessage(context, "Ok, I will come there"),

                SizedBox(height: size.height * 0.015),

                // Voice Message (Sent)
                _buildSentVoiceMessage(context),
              ],
            ),
          ),

          // Message Input
          Container(
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
                        vertical: size.height * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.screenBackground,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Message...",
                              style: AppTextStyles.body.copyWith(
                                fontSize: isPortrait
                                    ? size.width * 0.038
                                    : size.height * 0.045,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.mic,
                            color: AppColors.textSecondary,
                            size: isPortrait
                                ? size.width * 0.06
                                : size.height * 0.07,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: size.width * 0.02),

                  // Send Button
                  Container(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel(BuildContext context, String label) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.008,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.small.copyWith(
            fontSize: isPortrait ? size.width * 0.032 : size.height * 0.038,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, String message) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.75),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            fontSize: isPortrait ? size.width * 0.038 : size.height * 0.045,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String message) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.75),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            fontSize: isPortrait ? size.width * 0.038 : size.height * 0.045,
            color: AppColors.buttonText,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSentVoiceMessage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: size.width * 0.6,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.play_arrow,
              color: AppColors.buttonText,
              size: isPortrait ? size.width * 0.06 : size.height * 0.07,
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: CustomPaint(
                size: Size(double.infinity, size.height * 0.03),
                painter: WaveformPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Waveform painter for voice messages
class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.buttonText
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final bars = 30;
    final spacing = size.width / bars;

    for (int i = 0; i < bars; i++) {
      final height = (i % 3 == 0) ? size.height * 0.8 : size.height * 0.4;
      final x = i * spacing + spacing / 2;
      final startY = (size.height - height) / 2;
      final endY = startY + height;

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
