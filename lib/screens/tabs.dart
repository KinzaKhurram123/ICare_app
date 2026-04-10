import 'package:flutter/material.dart';
import 'package:icare/widgets/whatsapp_button.dart';
import 'package:icare/screens/admin_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/navigators/bottom_tab_bar.dart';
import 'package:icare/navigators/bottom_tabs.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/bookings_history.dart';
import 'package:icare/screens/chat_list_screen.dart';
import 'package:icare/screens/home.dart';
import 'package:icare/screens/my_cart.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/screens/order_tracking.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/profile.dart';
import 'package:icare/screens/profile_edit.dart';
import 'package:icare/screens/upload_prescription.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/available_badge.dart';
import 'package:icare/widgets/custom_tab_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/navigators/drawer.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/screens/doctor_dashboard.dart';
import 'package:icare/screens/doctor_schedule_calendar.dart';
import 'package:icare/screens/doctor_analytics.dart';
import 'package:icare/screens/doctor_reviews.dart';
import 'package:icare/screens/doctor_availability.dart';
import 'package:icare/screens/patient_dashboard.dart';
import 'package:icare/screens/pharmacist_dashboard.dart';
import 'package:icare/screens/laboratory_dashboard.dart';
import 'package:icare/screens/lab_bookings_management.dart';
import 'package:icare/screens/lab_tests_management.dart';
import 'package:icare/screens/lab_analytics.dart';
import 'package:icare/screens/lab_profile_setup.dart';
import 'package:icare/screens/lab_supplies_management.dart';
import 'package:icare/screens/pharmacy_inventory.dart';
import 'package:icare/screens/pharmacy_orders.dart';
import 'package:icare/screens/pharmacy_analytics.dart';
import 'package:icare/screens/pharmacy_profile_setup.dart';
import 'package:icare/screens/doctor_notifications.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/analytics_dashboard_screen.dart';
import 'package:icare/screens/community_forum_screen.dart';
import 'package:icare/screens/health_journey_screen.dart';
import 'package:icare/screens/lifestyle_tracker_screen.dart';
import 'package:icare/screens/manage_dependents_screen.dart';
import 'package:icare/screens/prescription_templates_screen.dart';
import 'package:icare/screens/security_audit_log_screen.dart';
import 'package:icare/screens/certificates_screen.dart';
import 'package:icare/screens/resource_library_screen.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/health_community.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/screens/my_appointment.dart';
import 'package:icare/screens/my_appointments_list.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/payment_invoices.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/pharmacy_management.dart';
import 'package:icare/screens/prescriptions.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/student_dashboard.dart';
import 'package:icare/screens/student_profile_setup.dart';
import 'package:icare/screens/view_profile.dart';
import 'package:icare/screens/wallet.dart';
import 'package:icare/screens/instructor_dashboard.dart';
import 'package:icare/screens/instructor_courses_management.dart';
import 'package:icare/screens/instructor_learners_screen.dart';
import 'package:icare/screens/instructor_precautions_management.dart';
import 'package:icare/screens/instructor_analytics.dart';
import 'package:icare/screens/instructor_profile_setup.dart';

class TabsScreen extends ConsumerStatefulWidget {
  final String? initialAdminTab;
  const TabsScreen({super.key, this.initialAdminTab});
  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  var currentIndex = 0;
  void _selectPage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).userRole;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isWeb = screenWidth > 600;
    final double maxWidth = 430;

    Widget activePage = const HomeScreen();
    if (role == "Pharmacy") {
      if (currentIndex == 0) {
        activePage = const PharmacistDashboard();
      } else if (currentIndex == 1) {
        activePage = const PharmacyOrders();
      } else if (currentIndex == 2) {
        activePage = const PharmacyInventory();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "Laboratory") {
      if (currentIndex == 0) {
        activePage = const LaboratoryDashboard();
      } else if (currentIndex == 1) {
        activePage = const LabBookingsManagement();
      } else if (currentIndex == 2) {
        activePage = const LabReportsScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "Doctor") {
      if (currentIndex == 0) {
        activePage = const DoctorDashboard();
      } else if (currentIndex == 1) {
        activePage = const DoctorAppointmentsScreen();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "Instructor") {
      if (currentIndex == 0) {
        activePage = const InstructorDashboardScreen();
      } else if (currentIndex == 1) {
        activePage = const InstructorCoursesManagement();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "Student") {
      if (currentIndex == 0) {
        activePage = StudentDashboard();
      } else if (currentIndex == 1) {
        activePage = Courses();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "Admin") {
      if (currentIndex == 0) {
        activePage = AdminDashboard(
          initialTab: widget.initialAdminTab ?? 'Pending',
        );
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else {
        activePage = AdminDashboard(
          initialTab: widget.initialAdminTab ?? 'Pending',
        );
      }
    } else {
      // Default to Patient dashboard
      if (currentIndex == 0) {
        activePage = const PatientDashboard();
      } else if (currentIndex == 1) {
        activePage = BookingsScreen(tabs: true);
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else if (currentIndex == 4) {
        activePage = const Courses(myPurchased: true);
      }
    }

    final tabs = buildTabs(
      role: role,
      context: context,
      currentIndex: currentIndex,
      onSelect: _selectPage,
    );

    // ── Mobile: original layout, zero changes ──────────────────────────────
    if (!isWeb) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(left: ScallingConfig.scale(28.0)),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: SvgWrapper(assetPath: ImagePaths.menu),
                  ),
                ),
              );
            },
          ),
          centerTitle: false,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Hello,",
                fontSize: 14,
                color: AppColors.darkGreyColor,
                fontWeight: FontWeight.w400,
                fontFamily: "Gilroy-Bold",
              ),
              AvailableBadge(),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: ScallingConfig.scale(10)),
              child: GestureDetector(
                onTap: () {
                  if (role == 'Doctor') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const DoctorNotifications(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => NotificationScreen()),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: SvgWrapper(assetPath: ImagePaths.notification),
                ),
              ),
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            activePage,
            const WhatsAppFloatingButton(),
          ],
        ),
        bottomNavigationBar: BottomTabBar(
          tabs: buildTabs(
            role: role,
            context: context,
            currentIndex: currentIndex,
            onSelect: _selectPage,
          ),
          onSelect: (value) {},
        ),
      );
    }

    // ── Web: full dashboard layout ─────────────────────────────────────────
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          Row(
            children: [
              // ── Left Sidebar ────────────────────────────────────────────────
              _WebSidebar(
                currentIndex: currentIndex,
                role: role,
                onSelect: _selectPage,
              ),
              // ── Main content area ─────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Premium top navbar
                    _WebTopBar(role: role),
                    // Content fills remaining space.
                    // ClipRect prevents overflow zebra-stripe warnings from
                    // ScallingConfig scaling elements slightly too large on web.
                    Expanded(
                      child: ClipRect(
                        child: LayoutBuilder(
                          builder: (outerCtx, constraints) {
                            return MediaQuery(
                              // Override size so Utils.windowWidth/Height return
                              // the actual content-pane dimensions.
                              data: MediaQuery.of(outerCtx).copyWith(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                // Zero out view padding so content isn't pushed
                                // up for a bottom-nav bar that doesn't exist on web.
                                viewPadding: EdgeInsets.zero,
                                viewInsets: EdgeInsets.zero,
                              ),
                              child: Builder(
                                builder: (innerCtx) {
                                  // Re-init ScallingConfig with the constrained
                                  // content-pane width so scale() / moderateScale()
                                  // don't use the full browser viewport width.
                                  ScallingConfig().init(innerCtx);
                                  return activePage;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Web Sidebar
// ═══════════════════════════════════════════════════════════════════════════
class _WebSidebar extends ConsumerWidget {
  const _WebSidebar({
    required this.currentIndex,
    required this.role,
    required this.onSelect,
  });
  final int currentIndex;
  final String role;
  final void Function(int) onSelect;

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B2D6E), Color(0xFF1565C0)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<_SidebarItem> items;
    if (role == 'Admin') {
      items = <_SidebarItem>[];
    } else if (role == 'Instructor') {
      items = [
        _SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
        _SidebarItem(icon: Icons.school_rounded, label: 'Courses', index: 1),
        _SidebarItem(icon: Icons.chat_bubble_rounded, label: 'Messages', index: 2),
        _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', index: 3),
      ];
    } else if (role == 'Patient') {
      items = [
        _SidebarItem(icon: Icons.home_rounded, label: 'Home', index: 0),
        _SidebarItem(icon: Icons.calendar_month_rounded, label: 'Appointments', index: 1),
        _SidebarItem(icon: Icons.chat_bubble_rounded, label: 'Messages', index: 2),
        _SidebarItem(icon: Icons.health_and_safety_rounded, label: 'Health Programs', index: 4),
        _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', index: 3),
      ];
    } else {
      items = [
        _SidebarItem(
          icon: Icons.home_rounded,
          label: role == 'Student' ? 'Learning Dashboard' : 'Home',
          index: 0,
        ),
        _SidebarItem(
          icon: role == 'Pharmacy'
              ? Icons.receipt_long_rounded
              : (role == 'Laboratory'
                    ? Icons.list_alt_rounded
                    : (role == 'Student'
                          ? Icons.school_rounded
                          : Icons.calendar_month_rounded)),
          label: role == 'Pharmacy'
              ? 'Prescriptions'
              : (role == 'Laboratory'
                    ? 'Test Requests'
                    : (role == 'Student' ? 'My Programs' : 'Appointments')),
          index: 1,
        ),
        _SidebarItem(
          icon: role == 'Pharmacy'
              ? Icons.inventory_2_rounded
              : (role == 'Laboratory'
                    ? Icons.upload_file_rounded
                    : Icons.chat_bubble_rounded),
          label: role == 'Pharmacy'
              ? 'Inventory'
              : (role == 'Laboratory' ? 'Upload Reports' : 'Messages'),
          index: 2,
        ),
        _SidebarItem(
          icon: Icons.person_rounded,
          label: role == 'Student' ? 'My Account' : 'My Profile',
          index: 3,
        ),
      ];
    }

    List<_SidebarAction> actions = [];
    if (role == 'Student') {
      actions = [
        _SidebarAction(
          'My Certificates',
          Icons.workspace_premium_rounded,
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CertificatesScreen()),
          ),
        ),
        _SidebarAction(
          'Resource Library',
          Icons.library_books_rounded,
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const ResourceLibraryScreen()),
          ),
        ),
      ];
    }

    return Container(
      width: 260,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: _gradient),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // ── Brand logo ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'iCare',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Profile card ───────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ProfileEditScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(ImagePaths.user7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final userName =
                                ref.watch(authProvider).user?.name ?? 'User';
                            return Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.isNotEmpty
                                ? role == 'Laboratory'
                                      ? 'Lab Technician'
                                      : role == 'Pharmacy'
                                      ? 'Pharmacist'
                                      : role[0].toUpperCase() +
                                            role.substring(1)
                                : role,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Quick Action Buttons (Show for all roles except Admin) ───────────
          if (role.isNotEmpty && role != 'Admin') ...[
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Quick Action Button (Role specific)
                  GestureDetector(
                    onTap: () {
                      if (role == 'Student') {
                        onSelect(1); // Go to All Programs
                      } else if (role == 'Laboratory') {
                        // Lab quick action: Go to Test Requests
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => LabBookingsManagement(
                              title: 'Test Requests',
                              initialFilter: 'pending',
                            ),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => role == 'Patient'
                                ? LabReportsScreen()
                                : LabBookingsManagement(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (role == 'Student'
                                    ? AppColors.secondaryColor
                                    : role == 'Laboratory'
                                    ? const Color(0xFF0EA5E9)
                                    : const Color(0xFF0EA5E9))
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              (role == 'Student'
                                      ? AppColors.secondaryColor
                                      : role == 'Laboratory'
                                      ? const Color(0xFF0EA5E9)
                                      : const Color(0xFF0EA5E9))
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: role == 'Student'
                                  ? AppColors.secondaryColor
                                  : role == 'Laboratory'
                                  ? const Color(0xFF0EA5E9)
                                  : const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              role == 'Student'
                                  ? Icons.explore_rounded
                                  : role == 'Laboratory'
                                  ? Icons.list_alt_rounded
                                  : Icons.biotech_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              role == 'Student'
                                  ? 'Browse Programs'
                                  : role == 'Laboratory'
                                  ? 'Manage Test Requests'
                                  : 'View Lab Reports',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Section label ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // ── Nav items ──────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...items.map((item) {
                  final isSelected = currentIndex == item.index;
                  return GestureDetector(
                    onTap: () => onSelect(item.index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // ── Role-specific extra nav items ──────────────────────────
                if (role == 'Patient') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.history_rounded,
                    'Health Journey',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HealthJourneyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.monitor_heart_rounded,
                    'Lifestyle Tracker',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LifestyleTrackerScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.family_restroom_rounded,
                    'Manage Dependents',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ManageDependentsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.task_alt_rounded,
                    'Wellness Goals',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.science_rounded,
                    'Diagnostics Support',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => LabsListScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.biotech_rounded,
                    role == 'Patient'
                        ? 'Lab Results/Reports'
                        : 'Management Dashboard',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => role == 'Patient'
                              ? LabReportsScreen()
                              : LabBookingsManagement(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.calendar_month_rounded,
                    'My Appointment',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const MyAppointmentsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.medication_rounded,
                    'Medication Fulfillment',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmaciesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.alarm_rounded,
                    'Reminders',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ReminderList(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.people_outline_rounded,
                    'Health Community',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HealthCommunityScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.health_and_safety_outlined,
                    'My Care Plans',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const Courses(myPurchased: true),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Doctor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.schedule_rounded,
                    'My Schedule',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorScheduleCalendar(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.analytics_rounded,
                    'Analytics',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorAnalytics(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.description_rounded,
                    'Prescription Templates',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PrescriptionTemplatesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.star_rounded,
                    'Reviews',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorReviews(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.people_outline_rounded,
                    'Health Community',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HealthCommunityScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.event_available_rounded,
                    'Availability',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorAvailability(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.notifications_rounded,
                    'Notifications',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorNotifications(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.person_rounded,
                    'My Profile',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorProfileSetup(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.calendar_month_rounded,
                    'My Appointments',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const DoctorAppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.folder_rounded,
                    'Patient Records',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PatientRecordsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HelpAndSupport(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Instructor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.library_books_rounded,
                    'Manage Courses',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => InstructorCoursesManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.group_rounded,
                    'Assigned Learners',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => InstructorLearnersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.health_and_safety_rounded,
                    'Health Precautions',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              InstructorPrecautionsManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.analytics_rounded,
                    'Educational Analytics',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => InstructorAnalytics(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.person_rounded,
                    'Profile Setup',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => InstructorProfileSetupScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Laboratory') ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'PROFESSIONAL',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.assignment_ind_rounded,
                    'Diagnostic Queue',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabBookingsManagement(
                            title: 'Diagnostic Queue',
                            initialFilter: 'pending',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.biotech_rounded,
                    'Result Entry',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabBookingsManagement(
                            title: 'Result Entry',
                            initialFilter: 'confirmed',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.history_rounded,
                    'Clinical Archive',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabBookingsManagement(
                            title: 'Clinical Archive',
                            initialFilter: 'completed',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.science_outlined,
                    'Test Catalog',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabTestsManagement(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.inventory_2_rounded,
                    'Supplies Management',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabSuppliesManagement(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.analytics_rounded,
                    'Lab Analytics',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabAnalytics(),
                        ),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'PERSONAL',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.calendar_month_rounded,
                    'My Appointments',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const MyAppointmentsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.person_outline_rounded,
                    'Profile Setup',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const LabProfileSetup(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.receipt_long_rounded,
                    'Payment Invoices',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PaymentInvoices(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HelpAndSupport(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Pharmacy') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.edit_rounded,
                    'Profile Setup',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmacyProfileSetup(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.inventory_rounded,
                    'Inventory',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmacyInventory(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.shopping_cart_rounded,
                    'Orders',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmacyOrders(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.analytics_rounded,
                    'Analytics',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmacyAnalytics(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.task_alt_rounded,
                    'Tasks',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.shopping_basket_rounded,
                    'My Orders',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const MyOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HelpAndSupport(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Instructor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.medication_rounded,
                    'Pharmacies',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const PharmaciesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.biotech_rounded,
                    'Reports/Lab Results',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => LabReportsScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.favorite_rounded,
                    'My Health Journey',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const Courses(myPurchased: true),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.assignment_rounded,
                    'My Care Plans',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const Courses(myPurchased: true),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const HelpAndSupport(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Student' || role == 'Instructor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      height: 1,
                    ),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.school_rounded,
                    role == 'Student' ? 'My Courses' : 'Manage Courses',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const Courses(myPurchased: true),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.workspace_premium_rounded,
                    role == 'Student' ? 'My Certificates' : 'Certifications',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CertificatesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.library_books_rounded,
                    'Resource Library',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ResourceLibraryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.task_alt_rounded,
                    'Assessments',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                if (role == 'Admin') ...[
                  const SizedBox(height: 8),
                  _buildExtraNavItem(
                    context,
                    Icons.verified_user_rounded,
                    'Verify Applications',
                    () {
                      onSelect(0); // Trigger reload with tab
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.school_rounded,
                    'Manage Students',
                    () {
                      // Logic to set tab and refresh
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              const TabsScreen(initialAdminTab: 'Student'),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.local_pharmacy_rounded,
                    'Manage Pharmacies',
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              const TabsScreen(initialAdminTab: 'Pharmacy'),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.biotech_rounded,
                    'Manage Laboratories',
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              const TabsScreen(initialAdminTab: 'Laboratory'),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.person_add_rounded,
                    'Manage Instructors',
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              const TabsScreen(initialAdminTab: 'Instructor'),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.analytics_rounded,
                    'Platform Analytics',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AnalyticsDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.security_rounded,
                    'Security Audit Logs',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SecurityAuditLogScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.settings_rounded,
                    'Settings',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withValues(alpha: 0.15)),
          ),

          // ── Logout ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => LoginScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraNavItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Web Top Navbar
// ═══════════════════════════════════════════════════════════════════════════
class _WebTopBar extends ConsumerWidget {
  const _WebTopBar({required this.role});
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Page title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B2D6E),
                ),
              ),
              Text(
                'Welcome back! Here\'s your overview.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          GestureDetector(
            onTap: () {
              if (role == 'Doctor') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const DoctorNotifications(),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NotificationScreen()),
                );
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF0B2D6E),
                    size: 20,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar + greeting
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ProfileEditScreen()),
              );
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final userName =
                            ref.watch(authProvider).user?.name ?? 'User';
                        return Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E),
                          ),
                        );
                      },
                    ),
                    Text(
                      role.isNotEmpty
                          ? role == 'Laboratory'
                                ? 'Lab Technician'
                                : role == 'Pharmacy'
                                ? 'Pharmacist'
                                : role[0].toUpperCase() + role.substring(1)
                          : role,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(ImagePaths.user7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _SidebarAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SidebarAction(this.label, this.icon, this.onTap);
}
