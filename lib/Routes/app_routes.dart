import 'package:get/get.dart';
import 'package:qlickcare/all_permisson.dart';
import 'package:qlickcare/authentication/view/login.dart';

import 'package:qlickcare/attendance/view/myleave.dart';
import 'package:qlickcare/Home/navbar.dart';

import 'package:qlickcare/Splash/splashscreen.dart';
import 'package:qlickcare/meeting/view/meeting_list.dart';
import 'package:qlickcare/onboarding/view/onboardingscreens.dart';
import 'package:qlickcare/Home/homepage.dart';

import 'package:qlickcare/chat/view/chatscreen.dart';
import 'package:qlickcare/complaint/views/complaints.dart';
import 'package:qlickcare/attendance/view/attendace.dart';
import 'package:qlickcare/payslip/view/paysliplist.dart';
import 'package:qlickcare/bookings/view/bookingview.dart';

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
  static const String allPermission = '/all-permission';
  static const String meetingList = '/meeting-list';


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
    GetPage(name: allPermission, page: () => AllPermissionPage()), 
    GetPage(name: meetingList, page: () => MeetingsPage()),
     
  ];
}
