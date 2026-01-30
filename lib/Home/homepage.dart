import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qlickcare/bookings/controller/bookingcontroller.dart';
import 'package:qlickcare/bookings/view/Details/bookingdetailedview.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Drawer/drawer.dart';
import 'package:qlickcare/chat/view/chatdetailscreen.dart';
import 'package:qlickcare/notification/views/listnotification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  String locationName = "Getting location...";
  final Map<int, bool> _expandedStates = {};

  final P_Controller profileController = Get.find();
  final ChatController chatController = Get.find();
  final BookingController ongoingBookingController = Get.find();

  // ✅ Keep page alive to prevent re-initialization
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    print("🏠 HomePage initState");
    
    // ✅ Data is already loaded from MainHome
    // Only fetch if somehow missing
    if (ongoingBookingController.bookings.isEmpty && 
        !ongoingBookingController.isLoading.value) {
      print("⚠️ Bookings empty, fetching...");
      ongoingBookingController.fetchOngoingBookings();
    }
    
    // Load location in background (non-blocking)
    _fetchLocationName();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Future<void> _fetchLocationName() async {
    try {
      final coords = await LocationService.getCurrentCoordinates();
      if (coords != null) {
        final name = await LocationService.getLocationName(
          coords['lat']!,
          coords['lng']!,
        );
        if (mounted) {
          setState(() => locationName = name);
        }
      } else {
        if (mounted) {
          setState(() => locationName = "Location unavailable");
        }
      }
    } catch (e) {
      print("❌ Error fetching location: $e");
      if (mounted) {
        setState(() => locationName = "Location unavailable");
      }
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      _expandedStates[index] = !(_expandedStates[index] ?? false);
    });
  }

  String _formatWorkType(String workType) {
    return workType.replaceAll('_', ' ').capitalize ?? workType;
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${parsedDate.day.toString().padLeft(2, '0')} ${months[parsedDate.month - 1]} ${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "Home",
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(FontAwesomeIcons.bars, color: AppColors.background, size: 22),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.bell, color: AppColors.background, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => notification()),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(child: _buildProfileCard()),
          
          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                "My Patients",
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
          // Patient List
          Obx(() => _buildPatientsList()),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final profile = profileController.profile.value;
      final fullName = profile?.fullName ?? "User";
      final profilePicture = profile?.profilePicture;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${getGreeting()},",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullName,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          locationName,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildProfileAvatar(profilePicture),
          ],
        ),
      );
    });
  }

  Widget _buildProfileAvatar(String? profilePicture) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: ClipOval(
        child: (profilePicture != null && profilePicture.trim().isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: profilePicture.trim(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 32, color: AppColors.textSecondary),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              )
            : const Icon(Icons.person, size: 32, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildPatientsList() {
    if (ongoingBookingController.isLoading.value) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSkeletonCard(),
          childCount: 3,
        ),
      );
    }

    if (ongoingBookingController.bookings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                "No Patients Found",
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final booking = ongoingBookingController.bookings[index];
          return _buildPatientCard(context, booking, index);
        },
        childCount: ongoingBookingController.bookings.length,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, dynamic booking, int index) {
    final isExpanded = _expandedStates[index] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${booking.patientName}, ${booking.age}",
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.booking_status,
                      style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleExpansion(index),
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Basic Info
          Row(
            children: [
              Icon(
                booking.gender.toLowerCase() == "male" ? Icons.male : Icons.female,
                color: AppColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(booking.gender, style: AppTextStyles.small),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: AppColors.secondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatWorkType(booking.workType),
                  style: AppTextStyles.small,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${booking.address}, ${booking.pincode}",
                  style: AppTextStyles.small,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Reassignment Banner
          if (booking.isCurrentlyReassigned) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🔁 Reassigned Booking",
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (booking.reassignmentStatus?.reassignedTo != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Caretaker: ${booking.reassignmentStatus.reassignedTo}",
                      style: AppTextStyles.small.copyWith(color: AppColors.primary),
                    ),
                  ],
                  if (booking.reassignmentStatus?.startDate != null &&
                      booking.reassignmentStatus?.endDate != null) ...[
                    Text(
                      "Duration: ${booking.reassignmentStatus.startDate} → ${booking.reassignmentStatus.endDate}",
                      style: AppTextStyles.small.copyWith(color: AppColors.primary),
                    ),
                  ],
                  if (booking.reassignmentStatus?.completionPercentage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Progress: ${booking.reassignmentStatus.completionPercentage.toStringAsFixed(0)}%",
                      style: AppTextStyles.small.copyWith(color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Expanded Content
          if (isExpanded) _buildExpandedContent(booking),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(dynamic booking) {
    final patientDetails = {
      "ID": booking.id.toString(),
      "Gender": booking.gender,
      "Age": booking.age.toString(),
      "Status": booking.booking_status,
      "Customer": booking.customerName,
    };

    final serviceDetails = {
      "Work Type": _formatWorkType(booking.workType),
      "Location": "${booking.address}, ${booking.pincode}",
      "Start Date": _formatDate(booking.startDate),
      "End Date": _formatDate(booking.endDate),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 16),

        // Patient Details
        Text(
          "Patient Details",
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...patientDetails.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${entry.key}:",
                    style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                  ),
                  Flexible(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 16),

        // Service Details
        Text(
          "Service Details",
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...serviceDetails.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.key}:",
                    style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 16),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => BookingDetailsPage(bookingId: booking.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.buttonText,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Attendance & Tasks",
              style: AppTextStyles.button.copyWith(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => _handleChatNavigation(booking.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Chat with Patient",
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleChatNavigation(int bookingId) async {
    // Ensure chat rooms are loaded
    if (chatController.chatRooms.isEmpty) {
      await chatController.fetchChatRooms();
    }

    final chatId = chatController.getChatIdByBooking(bookingId);
    
    if (chatId == null) {
      Get.snackbar(
        "Chat Not Available",
        "No chat room found for this booking",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Set selected chat for immediate header name display
    chatController.selectedChat.value =
        chatController.chatRooms.firstWhere((e) => e.id == chatId);

    Get.to(() => ChatDetailScreen(chatId: chatId));
  }
}