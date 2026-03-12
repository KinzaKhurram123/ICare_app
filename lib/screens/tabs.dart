import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/navigators/bottom_tab_bar.dart';
import 'package:icare/navigators/bottom_tabs.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/bookings_history.dart';
import 'package:icare/screens/chatlist.dart';
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
import 'package:icare/screens/patient_dashboard.dart';
import 'package:icare/screens/pharmacist_dashboard.dart';
import 'package:icare/screens/pharmacy_inventory.dart';
import 'package:icare/screens/pharmacy_orders.dart';
import 'package:icare/screens/pharmacy_analytics.dart';
import 'package:icare/screens/doctor_notifications.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/my_appointment.dart';
import 'package:icare/screens/my_appointments_list.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/payment_invoices.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/pharmacy_management.dart';
import 'package:icare/screens/prescriptions.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/view_profile.dart';
import 'package:icare/screens/wallet.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});
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
    if (role == "pharmacy") {
      if (currentIndex == 0) {
        activePage = const PharmacistDashboard();
      } else if (currentIndex == 1) {
        activePage = const MyCartScreen();
      } else if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "doctor") {
      if (currentIndex == 0) {
        activePage = const DoctorDashboard();
      } else if (currentIndex == 1) {
        activePage = const DoctorAppointmentsScreen();
      } else if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      }
    } else if (role == "instructor") {
      if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else {
        activePage = const HomeScreen();
      }
    } else if (role == "student") {
      if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else {
        activePage = const HomeScreen();
      }
    } else {
      if (currentIndex == 0) {
        activePage = const PatientDashboard();
      } else if (currentIndex == 1) {
        activePage = BookingsScreen(tabs: true);
      } else if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
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
                  if (role == 'doctor') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const DoctorNotifications()),
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
        body: activePage,
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
      body: Row(
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
    final items = [
      _SidebarItem(icon: Icons.home_rounded, label: 'Home', index: 0),
      _SidebarItem(
          icon: role == 'pharmacy'
              ? Icons.shopping_cart_rounded
              : Icons.calendar_month_rounded,
          label: role == 'pharmacy' ? 'My Cart' : 'Appointments',
          index: 1),
      _SidebarItem(icon: Icons.chat_bubble_rounded, label: 'Messages', index: 2),
      _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', index: 3),
    ];

    List<_SidebarAction> actions = [];

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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 24),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                          final userName = ref.watch(authProvider).user?.name ?? 'User';
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          role.isNotEmpty
                              ? role == 'lab_technician'
                                  ? 'Lab Technician'
                                  : role == 'pharmacy'
                                      ? 'Pharmacist'
                                      : role[0].toUpperCase() + role.substring(1)
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
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white54, size: 18),
              ],
            ),
          ),
          ),

          const SizedBox(height: 24),

          // ── Quick Action Buttons (Show for all roles to match mobile drawer) ───────────
          if (role.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
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
                  // Book Appointment Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => BookingsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Book Appointment',
                              style: TextStyle(
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
                  const SizedBox(height: 12),
                  // View Lab Reports Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => LabsListScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF0EA5E9).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.biotech_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'View Lab Reports',
                              style: TextStyle(
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
                  color: Colors.white.withOpacity(0.45),
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
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: Colors.white.withOpacity(0.25))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
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
                                  : Colors.white.withOpacity(0.6),
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
                if (role == 'patient') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.history_rounded, 'Bookings History', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const BookingsHistoryScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.task_alt_rounded, 'Tasks', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.biotech_rounded, 'Report Lab Results', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const LabsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.calendar_month_rounded, 'My Appointment', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const MyAppointmentsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.medication_rounded, 'Pharmacies', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.alarm_rounded, 'Reminders', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ReminderList()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.school_rounded, 'Courses', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const Courses()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],

                if (role == 'doctor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.calendar_month_rounded, 'My Appointments', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const DoctorAppointmentsScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.folder_rounded, 'Patient Records', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PatientRecordsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HelpAndSupport()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],

                if (role == 'lab_technician') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.task_alt_rounded, 'Tasks', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.biotech_rounded, 'Report Lab Results', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const LabsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.calendar_month_rounded, 'My Appointment', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const MyAppointmentsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.receipt_long_rounded, 'Payment Invoices', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PaymentInvoices()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HelpAndSupport()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],

                if (role == 'pharmacy') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.inventory_rounded, 'Inventory', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmacyInventory()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.shopping_cart_rounded, 'Orders', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmacyOrders()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.analytics_rounded, 'Analytics', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmacyAnalytics()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.task_alt_rounded, 'Tasks', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const TaskScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.shopping_basket_rounded, 'My Orders', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const MyOrdersScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HelpAndSupport()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],

                if (role == 'instructor') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.medication_rounded, 'Pharmacies', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.biotech_rounded, 'Reports/Lab Results', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const LabsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HelpAndSupport()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],

                if (role == 'student') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.15), height: 1),
                  ),
                  _buildExtraNavItem(context, Icons.medication_rounded, 'Pharmacies', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.biotech_rounded, 'Reports/Lab Results', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const LabsListScreen()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HelpAndSupport()),
                    );
                  }),
                  _buildExtraNavItem(context, Icons.settings_rounded, 'Settings', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                    );
                  }),
                ],
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withOpacity(0.15)),
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
                  color: Colors.redAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 18),
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

  Widget _buildExtraNavItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
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
            Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.55),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.6),
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
              if (role == 'doctor') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const DoctorNotifications()),
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
                  const Icon(Icons.notifications_rounded,
                      color: Color(0xFF0B2D6E), size: 20),
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
                      final userName = ref.watch(authProvider).user?.name ?? 'User';
                      return Text(
                        userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E)),
                      );
                    },
                  ),
                    Text(
                      role.isNotEmpty
                          ? role == 'lab_technician'
                              ? 'Lab Technician'
                              : role == 'pharmacist'
                                  ? 'Pharmacist'
                                  : role[0].toUpperCase() + role.substring(1)
                          : role,
                      style:
                          const TextStyle(fontSize: 11, color: Color(0xFF888888)),
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
  const _SidebarItem(
      {required this.icon, required this.label, required this.index});
}

class _SidebarAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SidebarAction(this.label, this.icon, this.onTap);
}
