import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/attendance/controller/attendancecontroller.dart';
import 'package:qlickcare/bookings/controller/bookingcontroller.dart';
import 'package:qlickcare/bookings/controller/bookingdetailscontroller.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';
import 'package:qlickcare/chat/view/chatscreen.dart';
import 'package:qlickcare/bookings/view/todo.dart';
import 'package:qlickcare/profile/view/p_view.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/Home/homepage.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/notification/service/notification_services.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int selectedIndex = 0;
  late final PageController pageController;

  final List<Widget> pages = [
    const HomePage(),
    const todo(),
    const Chatscreen(),
    PView(),
  ];

  final NotificationService notificationService = NotificationService();

  bool _permissionDialogShown = false;
  bool _fcmInitialized = false;
  bool _controllersInitialized = false;

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: selectedIndex);

    // ✅ Initialize controllers AND fetch critical data
    _initializeControllers();

    _initFCM();
    _printAuthTokens();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });


    
  }

  // =========================
  // INITIALIZE CONTROLLERS + PRE-LOAD DATA
  // =========================
  Future<void> _initializeControllers() async {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    print("⏱️ Controller initialization started");
    final startTime = DateTime.now();

    // Step 1: Initialize all controllers
    Get.put(P_Controller(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(BookingController(), permanent: true);
    Get.put(BookingDetailsController(), permanent: true);
    Get.put(AttendanceController(), permanent: true);

    print(
      "✅ Controllers created in: ${DateTime.now().difference(startTime).inMilliseconds}ms",
    );

    // Step 2: Pre-fetch critical data for HomePage (parallel loading)
    final dataStartTime = DateTime.now();

    await Future.wait([
      // ✅ Most critical: Homepage data
      Get.find<BookingController>().fetchOngoingBookings(),

      // ✅ Also critical: Profile data
      Get.find<P_Controller>().fetchAll(),

      // ⏳ Less critical: Chat rooms (can load in background)
      Get.find<ChatController>().fetchChatRooms(),
    ]).catchError((e) {
      print("❌ Error pre-loading data: $e");
    });

    print(
      "✅ Data pre-loaded in: ${DateTime.now().difference(dataStartTime).inMilliseconds}ms",
    );
    print(
      "✅ Total initialization: ${DateTime.now().difference(startTime).inMilliseconds}ms",
    );
  }

  // =========================
  // FCM INIT (SAFE)
  // =========================
  Future<void> _initFCM() async {
    if (_fcmInitialized) return;
    _fcmInitialized = true;

    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      await notificationService.initialize();
      await notificationService.registerTokenToBackend(token);
      debugPrint("✅ FCM token registered for current user");
    }
  }

  // =========================
  // TOKEN LOG (DEBUG)
  // =========================
  Future<void> _printAuthTokens() async {
    final access = await TokenService.getAccessToken();
    final refresh = await TokenService.getRefreshToken();

    debugPrint("**********************");
    debugPrint("🔑 ACCESS TOKEN: $access");
    debugPrint("♻ REFRESH TOKEN: $refresh");
  }

  // =========================
  // PERMISSION CHECK (SAFE)
  // =========================
  Future<void> _checkAndRequestPermissions() async {
    if (_permissionDialogShown) return;

    final hasPermission = await LocationService.hasLocationPermission();

    if (!hasPermission && mounted) {
      _permissionDialogShown = true;
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
          "QlickCare needs your location to track attendance and provide location-based services.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await LocationService.requestLocationPermission();
            },
            child: const Text("Grant Permission"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // =========================
  // PAGE REFRESH
  // =========================
  void _refreshPage(int index) {
    switch (index) {
      case 0:
        // ✅ Refresh home page bookings
        if (Get.isRegistered<BookingController>()) {
          Get.find<BookingController>().fetchOngoingBookings();
        }
        break;
      case 2:
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().fetchChatRooms();
        }
        break;
      case 3:
        if (Get.isRegistered<P_Controller>()) {
          Get.find<P_Controller>().fetchAll();
        }
        break;
      default:
        break;
    }
  }

  // =========================
  // UI
  // =========================
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
      backgroundColor: Colors.white,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          selectedIndex = index;
          _refreshPage(index);
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
              ),
            ],
          ),
          child: Row(
            children: [
              _navItem(FontAwesomeIcons.house, "Home", 0, iconSize),
              _navItem(FontAwesomeIcons.listCheck, "Tasks", 1, iconSize),
              _navItem(FontAwesomeIcons.message, "Chats", 2, iconSize),
              _navItem(FontAwesomeIcons.user, "Profile", 3, iconSize),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // NAV ITEM
  // =========================
  Widget _navItem(IconData icon, String label, int index, double iconSize) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (selectedIndex == index) return;

          setState(() => selectedIndex = index);
          pageController.jumpToPage(index);
          _refreshPage(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: isSelected ? 36 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: iconSize,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: iconSize * 0.4,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
