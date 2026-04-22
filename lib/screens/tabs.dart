import 'dart:convert';
import 'package:icare/screens/public_home.dart';
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
import 'package:icare/screens/patient_medical_records.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/patient_lab_orders.dart';
import 'package:icare/providers/navigation_provider.dart';
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
import 'package:icare/screens/prescription_templates.dart';
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
import 'package:icare/screens/privacy_policy.dart';
import 'package:icare/screens/admin_home_screen.dart';
import 'package:icare/screens/admin_pharmacy_orders_screen.dart';
import 'package:icare/screens/admin_students_screen.dart';
import 'package:icare/screens/admin_student_detail_screen.dart';

class TabsScreen extends ConsumerStatefulWidget {
  final String? initialAdminTab;
  const TabsScreen({super.key, this.initialAdminTab});
  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  var currentIndex = 0;
  int _profileKey = 0; // increments each time profile tab is selected → forces fresh rebuild

  // null  → show AdminHomeScreen
  // 'Pending' / 'Student' / etc. → show AdminDashboard with that tab
  String? _adminManagementTab;
  String? _selectedStudentName;

  @override
  void initState() {
    super.initState();
    _adminManagementTab = widget.initialAdminTab;
  }

  void _selectPage(int index) {
    ref.read(navigationProvider.notifier).setIndex(index);
    setState(() {
      if (index == 3 && ref.read(navigationProvider) != 3) {
        _profileKey++; // force ProfileScreen to rebuild when switching to profile tab
      }
      // Clicking Home (index 0) from the admin sidebar always returns to HomeScreen
      if (index == 0) {
        _adminManagementTab = null;
      }
      if (index != 15) {
        _selectedStudentName = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = ref.watch(navigationProvider);
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
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      }
    } else if (role == "Laboratory") {
      if (currentIndex == 0) {
        activePage = const LaboratoryDashboard();
      } else if (currentIndex == 1) {
        activePage = const LabBookingsManagement();
      } else if (currentIndex == 2) {
        activePage = const LabReportsScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      }
    } else if (role == "Doctor") {
      if (currentIndex == 0) {
        activePage = const DoctorDashboard();
      } else if (currentIndex == 1) {
        activePage = const DoctorAppointmentsScreen();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      }
    } else if (role == "Instructor") {
      if (currentIndex == 0) {
        activePage = const InstructorDashboardScreen();
      } else if (currentIndex == 1) {
        activePage = InstructorCoursesManagementScreen();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      }
    } else if (role == "Student") {
      if (currentIndex == 0) {
        activePage = StudentDashboard();
      } else if (currentIndex == 1) {
        activePage = Courses();
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      }
    } else if (role == "Admin") {
      if (_selectedStudentName != null) {
        activePage = AdminStudentDetailScreen(
          name: _selectedStudentName!,
          onBack: () => setState(() => _selectedStudentName = null),
        );
      } else if (_adminManagementTab != null) {
        if (_adminManagementTab == 'Student') {
          activePage = AdminStudentsScreen(
            onViewProfile: (name) => setState(() => _selectedStudentName = name),
          );
        } else if (_adminManagementTab == 'Pharmacy') {
          activePage = const AdminPharmacyOrdersScreen();
        } else {
          // A management tab was explicitly selected → show the admin panel
          activePage = AdminDashboard(initialTab: _adminManagementTab!);
        }
      } else if (currentIndex == 0) {
        // Home selected (or first load with no management tab) → show home screen
        activePage = const AdminHomeScreen();
      } else if (currentIndex == 10) {
        activePage = const AdminPharmacyOrdersScreen();
      } else if (currentIndex == 15) {
        activePage = AdminStudentsScreen(
          onViewProfile: (name) => setState(() => _selectedStudentName = name),
        );
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      } else {
        activePage = const AdminHomeScreen();
      }
    } else {
      // Default to Patient dashboard
      if (currentIndex == 0) {
        activePage = const HomeScreen();
      } else if (currentIndex == 1) {
        activePage = BookingsScreen(tabs: true);
      } else if (currentIndex == 2) {
        activePage = ChatListScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen(key: ValueKey(_profileKey));
      } else if (currentIndex == 4) {
        activePage = const Courses(myPurchased: true);
      } else if (currentIndex == 5) {
        activePage = PatientMedicalRecords();
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
      items = [
        _SidebarItem(icon: Icons.home_rounded, label: 'Home', index: 0),
        _SidebarItem(icon: Icons.local_pharmacy_outlined, label: 'Pharmacy Order', index: 10),
        _SidebarItem(icon: Icons.biotech_outlined, label: 'Lab Orders', index: 11),
        _SidebarItem(icon: Icons.medical_services_outlined, label: "Doctor's Appointments", index: 12),
        _SidebarItem(icon: Icons.school_outlined, label: 'Courses', index: 13),
        _SidebarItem(icon: Icons.cast_for_education_rounded, label: 'Instructor', index: 14),
        _SidebarItem(icon: Icons.person_outline_rounded, label: 'Student', index: 15),
        _SidebarItem(icon: Icons.policy_outlined, label: 'Privacy Policy', index: 16),
      ];
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
        _SidebarItem(icon: Icons.folder_shared_rounded, label: 'Medical Records', index: 5), // Added index 5 for Records
        _SidebarItem(icon: Icons.calendar_month_rounded, label: 'My Appointments', index: 1),
        _SidebarItem(icon: Icons.health_and_safety_rounded, label: 'Health Programs', index: 4),
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

    final bool isLight = role == 'Admin';

    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : null,
        gradient: isLight ? null : _gradient,
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(4, 0),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // ── Brand logo ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (role == 'Patient' || role == 'Doctor') ...[
                  // iCare logo image — white bg so colors show correctly
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      ImagePaths.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_hospital_rounded,
                        color: Color(0xFF0B2D6E),
                        size: 24,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isLight ? const Color(0xFF1CB0F6).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: isLight ? const Color(0xFF1CB0F6) : Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'iCare',
                    style: TextStyle(
                      color: isLight ? const Color(0xFF2D3748) : Colors.white,
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
                      color: isLight ? const Color(0xFF1CB0F6).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Quick Action Buttons (Show for all roles except Admin, Patient and Doctor) ───────────
          if (role.isNotEmpty && role != 'Admin' && role != 'Patient' && role != 'Doctor') ...[
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF718096) : Colors.white.withValues(alpha: 0.45),
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
                      } else if (role == 'Instructor') {
                        onSelect(1); // Go to Manage Courses
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
                                    : role == 'Instructor'
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF0EA5E9))
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              (role == 'Student'
                                      ? AppColors.secondaryColor
                                      : role == 'Laboratory'
                                      ? const Color(0xFF0EA5E9)
                                      : role == 'Instructor'
                                      ? const Color(0xFF8B5CF6)
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
                                  : role == 'Instructor'
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              role == 'Student'
                                  ? Icons.explore_rounded
                                  : role == 'Laboratory'
                                  ? Icons.list_alt_rounded
                                  : role == 'Instructor'
                                  ? Icons.school_rounded
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
                                  : role == 'Instructor'
                                  ? 'Manage Courses'
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
                role == 'Patient' || role == 'Doctor' ? 'MY ACCOUNT' : 'NAVIGATION',
                style: TextStyle(
                  color: isLight ? const Color(0xFF718096) : Colors.white.withValues(alpha: 0.45),
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
                            ? (isLight ? const Color(0xFF1CB0F6).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.18))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: isLight ? const Color(0xFF1CB0F6).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.25),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? (isLight ? const Color(0xFF1CB0F6) : Colors.white)
                                : (isLight ? const Color(0xFF718096) : Colors.white.withValues(alpha: 0.55)),
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
                                  ? (role == 'Admin' ? const Color(0xFF2D3748) : Colors.white)
                                  : (role == 'Admin' ? const Color(0xFF4A5568) : Colors.white.withValues(alpha: 0.6)),
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isLight ? const Color(0xFF1CB0F6) : Colors.white,
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
                    Icons.family_restroom_rounded,
                    'Emergency Contacts',
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
                    Icons.science_rounded,
                    'Book a Lab Test',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => LabsListScreen()),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.biotech_rounded,
                    'Lab Results/Reports',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => LabReportsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.calendar_month_rounded,
                    'Booking Details',
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
                    'Order Medicines',
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
                  // Lifestyle Tracker — coming soon
                  _buildComingSoonNavItem(
                    context,
                    Icons.monitor_heart_rounded,
                    'Lifestyle Tracker',
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
                          builder: (ctx) => const PrescriptionTemplates(),
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
                    () => onSelect(1),
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



                if (role == 'Student') ...[
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  _buildExtraNavItem(
                    context,
                    Icons.verified_user_rounded,
                    'Verify Applications',
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              const TabsScreen(initialAdminTab: 'Pending'),
                        ),
                      );
                    },
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
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
                    isLight: isLight,
                  ),
                ],
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: isLight ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.15)),
          ),

          if (role == 'Admin')
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE4E6)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref.read(authProvider.notifier).setUserLogout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (ctx) => const PublicHome()),
                        (route) => false,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFFE11D48),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Color(0xFFFDA4AF), size: 18),
                        ],
                      ),
                    ),
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
    VoidCallback onTap, {
    bool isLight = false,
  }) {
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
            Icon(icon,
                size: 20,
                color: isLight ? const Color(0xFF718096) : Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isLight ? const Color(0xFF4A5568) : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildComingSoonNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isLight = false,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF6366F1), size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('Coming Soon!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text('$label is under development.\nWe\'ll notify you when it\'s ready.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Opacity(
        opacity: 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: isLight ? const Color(0xFF718096) : Colors.white.withValues(alpha: 0.55)),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isLight ? const Color(0xFF4A5568) : Colors.white.withValues(alpha: 0.6))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Soon', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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
          if (role == 'Admin')
            Container(
              width: 400,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else
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
          // Avatar + greeting — dropdown with Edit Profile & Logout
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(authProvider).user;
              final pic = user?.profilePicture;

              Widget avatar;
              if (pic != null && pic.isNotEmpty) {
                try {
                  final bytes = pic.contains(',')
                      ? base64Decode(pic.split(',').last)
                      : base64Decode(pic);
                  avatar = CircleAvatar(
                    radius: 20,
                    backgroundImage: MemoryImage(bytes),
                  );
                } catch (_) {
                  avatar = _defaultAvatar(user?.name);
                }
              } else {
                avatar = _defaultAvatar(user?.name);
              }

              return PopupMenuButton<String>(
                offset: const Offset(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    final role = ref.read(authProvider).userRole;
                    if (role == 'Doctor') {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorProfileSetup()));
                    } else if (role == 'Laboratory') {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabProfileSetup()));
                    } else if (role == 'Pharmacy') {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyProfileSetup()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ProfileEditScreen()));
                    }
                  } else if (value == 'logout') {
                    ref.read(authProvider.notifier).setUserLogout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (ctx) => const PublicHome()),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18,
                            color: Color(0xFF0B2D6E)),
                        SizedBox(width: 10),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18,
                            color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text('Logout',
                            style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E),
                          ),
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
                    avatar,
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF888888), size: 18),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _defaultAvatar(String? name) => CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
            fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
      ),
    );

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
