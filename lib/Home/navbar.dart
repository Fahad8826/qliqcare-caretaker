import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/profile/view/p_view.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/notification/service/notification_services.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Home/homepage.dart';

import 'package:qlickcare/chat/view/chatscreen.dart';
import 'package:qlickcare/bookings/view/todo.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int selectedIndex = 0;
  late PageController pageController;

  // Pages initialized inline → avoids LateInitializationError
  final List<Widget> pages = [HomePage(), todo(), Chatscreen(), PView()];
  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Ensure P_Controller is initialized
    Get.put(P_Controller());
    initFCM();
    printAuthTokens();
    _checkAndRequestPermissions();
    // fetchLocation();
  }

  Future<void> _checkPermissions() async {
  bool hasLocation = await LocationService.hasLocationPermission();

  if (!hasLocation) {
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.toNamed('/all-permission'); // or your route
      // OR
      // Get.to(() => AllPermissionPage());
    });
  }
}


  Future<void> printAuthTokens() async {
    final access = await TokenService.getAccessToken();
    final refresh = await TokenService.getRefreshToken();

    print("**********************");
    print("🔑 ACCESS TOKEN: $access");
    print("♻ REFRESH TOKEN: $refresh");
  }

  Future<void> initFCM() async {
    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      await notificationService.initialize();
      await notificationService.registerTokenToBackend(token);

      print("✅ FCM token registered for current user");
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    // Check if permission is already granted
    bool hasPermission = await LocationService.hasLocationPermission();

    if (!hasPermission) {
      // Show dialog explaining why you need permission
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Location Permission Required"),
        content: Text(
          "QlickCare needs your location to track attendance and provide location-based services.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await LocationService.requestLocationPermission();
            },
            child: Text("Grant Permission"),
          ),
        ],
      ),
    );
  }

  void _refreshPage(int index) {
    switch (index) {
      case 0:
        // Use controller fetch for HomePage if using GetX
        // Get.find<HomePageController>().fetchData();
        break;
      case 1:
        // Get.find<TodoController>().fetchData();
        break;
      case 2:
        // Get.find<ChatController>().fetchData();
        break;
      case 3:
        // Call refresh method instead of onInit
        Get.find<P_Controller>().fetchAll();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final double navHeight = orientation == Orientation.portrait
        ? size.height * 0.095
        : 70;
    final double iconSize = orientation == Orientation.portrait
        ? size.width * 0.055
        : 22;

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() => selectedIndex = index);
          _refreshPage(index); // refresh page on swipe
        },
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: navHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, -4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              navItem(FontAwesomeIcons.house, "Home", 0, iconSize),
              navItem(FontAwesomeIcons.listCheck, "Tasks", 1, iconSize),
              navItem(FontAwesomeIcons.message, "Chats", 2, iconSize),
              navItem(FontAwesomeIcons.user, "Profile", 3, iconSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index, double iconSize) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedIndex = index);
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          _refreshPage(index); // refresh page on tab tap
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: isSelected ? 36 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedScale(
              scale: isSelected ? 1.17 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: FaIcon(
                icon,
                size: iconSize,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: iconSize * 0.40,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
