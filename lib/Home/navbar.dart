import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qlickcare/Services/locationpermisson.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/attendance/controller/attendancecontroller.dart';
import 'package:qlickcare/bookings/controller/bookingcontroller.dart';
import 'package:qlickcare/bookings/controller/bookingdetailscontroller.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';
import 'package:qlickcare/chat/view/chatscreen.dart';
import 'package:qlickcare/bookings/view/todo.dart';
import 'package:qlickcare/profile/view/p_view.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/Home/homepage.dart';
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

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: selectedIndex);

    // Initialize controllers + FCM
    _initializeControllers();
    _initFCM();
    _printAuthTokens();

    // Delay to ensure context is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initLocationTracking(); // ✅ ONLY PLACE
  });
  }

Future<void> _initLocationTracking() async {
  debugPrint("📍 Initializing location tracking...");

  // ---------- CHECK EXISTING PERMISSIONS ----------
  final fgStatus = await Permission.locationWhenInUse.status;
  final bgStatus = await Permission.locationAlways.status;

  debugPrint("📍 Foreground status: $fgStatus");
  debugPrint("📍 Background status: $bgStatus");

  // ---------- IF ALREADY GRANTED ----------
  if (fgStatus.isGranted && bgStatus.isGranted) {
    debugPrint("✅ Location permissions already granted");
    final started = await LocationService.startBackground(context);
    debugPrint("🚀 Background service started: $started");
    return;
  }

  // ---------- REQUEST FOREGROUND ----------
  final fgGranted =
      await LocationPermissionHandler.requestForeground();
  if (!fgGranted) {
    debugPrint("❌ Foreground permission denied");
    return;
  }

  // ---------- REQUEST BACKGROUND ----------
  final bgGranted =
      await LocationPermissionHandler.requestBackground(context);
  if (!bgGranted) {
    debugPrint("⚠️ Background permission not granted");
    return;
  }

  // ---------- START SERVICE ----------
  final started = await LocationService.startBackground(context);
  debugPrint("🚀 Background service started: $started");
}
  // =========================
  // CONTROLLERS INIT
  // =========================
  Future<void> _initializeControllers() async {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    print("⏱️ Controller initialization started");
    final startTime = DateTime.now();

    Get.put(P_Controller(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(BookingController(), permanent: true);
    Get.put(BookingDetailsController(), permanent: true);
    Get.put(AttendanceController(), permanent: true);

    print(
        "✅ Controllers created in: ${DateTime.now().difference(startTime).inMilliseconds}ms");

    final dataStartTime = DateTime.now();
    await Future.wait([
      Get.find<BookingController>().fetchOngoingBookings(),
      Get.find<P_Controller>().fetchAll(),
      Get.find<ChatController>().fetchChatRooms(),
    ]).catchError((e) {
      print("❌ Error pre-loading data: $e");
    });

    print(
        "✅ Data pre-loaded in: ${DateTime.now().difference(dataStartTime).inMilliseconds}ms");
    print(
        "✅ Total initialization: ${DateTime.now().difference(startTime).inMilliseconds}ms");
  }

  // =========================
  // FCM INIT
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
  // TOKEN LOG
  // =========================
  Future<void> _printAuthTokens() async {
    final access = await TokenService.getAccessToken();
    final refresh = await TokenService.getRefreshToken();

    debugPrint("**********************");
    debugPrint("🔑 ACCESS TOKEN: $access");
    debugPrint("♻ REFRESH TOKEN: $refresh");
  }



 

  // =========================
  // PAGE REFRESH
  // =========================
  void _refreshPage(int index) {
    switch (index) {
      case 0:
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

    final double navHeight =
        orientation == Orientation.portrait ? size.height * 0.095 : 70;
    final double iconSize =
        orientation == Orientation.portrait ? size.width * 0.055 : 22;

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
                  offset: const Offset(0, -4))
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
  Widget _navItem(
      IconData icon, String label, int index, double iconSize) {
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
                  borderRadius: BorderRadius.circular(3)),
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
                  color:
                      isSelected ? AppColors.primary : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}