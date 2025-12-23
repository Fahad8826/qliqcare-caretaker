import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/View/Drawer/drawer.dart';
import 'package:qlickcare/View/chat/chatdetailscreen.dart';
import 'package:qlickcare/View/listnotification.dart';

class Chatscreen extends StatelessWidget {
  const Chatscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "Chats", // <-- Reusable AppBar
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
                MaterialPageRoute(builder: (context) =>  notification()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
              children: [
                _buildChatItem(
                  context,
                  name: "Rinas Menon",
                  message: "i'll let you know",
                  time: "11:09 AM",
                  unreadCount: 2,
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "I'll arrange a meeting soon !!",
                  time: "11:09 AM",
                  unreadCount: 1,
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "Ok, fine",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "Thanks",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
                _buildChatItem(
                  context,
                  name: "Tammy Spinka",
                  message: "i'll let you know",
                  time: "11:09 AM",
                ),
              ],
            ),
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
  }) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatDetailScreen(name: name, status: "Online"),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.015,
        ),
        color: AppColors.background,
        child: Row(
          children: [
            // Profile Image
            Container(
              width: isPortrait ? size.width * 0.14 : size.height * 0.16,
              height: isPortrait ? size.width * 0.14 : size.height * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/150?img=47',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: isPortrait ? size.width * 0.08 : size.height * 0.09,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: size.width * 0.03),

            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: isPortrait
                          ? size.width * 0.04
                          : size.height * 0.048,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      fontSize: isPortrait
                          ? size.width * 0.035
                          : size.height * 0.042,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: size.width * 0.03),

            // Time and Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: AppTextStyles.small.copyWith(
                    fontSize: isPortrait
                        ? size.width * 0.03
                        : size.height * 0.036,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (unreadCount != null) ...[
                  SizedBox(height: size.height * 0.005),
                  Container(
                    width: isPortrait ? size.width * 0.06 : size.height * 0.07,
                    height: isPortrait ? size.width * 0.06 : size.height * 0.07,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: AppTextStyles.small.copyWith(
                          fontSize: isPortrait
                              ? size.width * 0.03
                              : size.height * 0.036,
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
