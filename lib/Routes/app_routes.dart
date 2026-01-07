import 'package:get/get.dart';
import 'package:qlickcare/View/Auth/login.dart';
import 'package:qlickcare/View/Drawer/leave&attendance/myleave.dart';
import 'package:qlickcare/View/Home/navbar.dart';

import 'package:qlickcare/View/Splash/splashscreen.dart';
import 'package:qlickcare/View/Onboarding/onboardingscreens.dart';
import 'package:qlickcare/View/Home/homepage.dart';
import 'package:qlickcare/View/Drawer/Booking/bookingview.dart';
import 'package:qlickcare/View/chat/chatscreen.dart';
import 'package:qlickcare/View/Drawer/complaints/complaints.dart';
import 'package:qlickcare/View/Drawer/leave&attendance/attendace.dart';
import 'package:qlickcare/View/Drawer/payment/paysliplist.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const String profile = '/profile';
  static const String mainHome = '/MainHome';
  static const String complaints = '/complaints';
  static const String chat = '/AllChat';
  static const String bookingView = '/bookingView';
  static const String payslipList = '/payslipList';
  static const String leaveAttendance = '/leaveAttendance';
  static const String settings = '/leave';

  static final pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: mainHome, page: () => MainHome()),
    GetPage(name: complaints, page: () => ComplaintsPage()), // Placeholder
    GetPage(name: chat, page: () => Chatscreen()), // Placeholder
    GetPage(name: bookingView, page: () => BookingView()),
    GetPage(name: payslipList, page: () => PayslipListView()),
    GetPage(name: leaveAttendance, page: () => Leaveandattendace()),
    GetPage(name: settings, page: () => LeaveManagementScreen()), // Placeholder
  ];
}
