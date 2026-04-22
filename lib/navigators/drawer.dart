import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/bookings_history.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/screens/doctor_schedule_calendar.dart';
import 'package:icare/screens/doctor_analytics.dart';
import 'package:icare/screens/doctor_notifications.dart';
import 'package:icare/screens/doctor_reviews.dart';
import 'package:icare/screens/doctor_availability.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/profile_edit.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/health_community.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/lab_bookings_management.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/lab_appointment.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/public_home.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/my_appointment.dart';
import 'package:icare/screens/my_appointments_list.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/payment_invoices.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/pharmacy_management.dart';
import 'package:icare/screens/pharmacist_dashboard.dart';
import 'package:icare/screens/pharmacy_inventory.dart';
import 'package:icare/screens/pharmacy_orders.dart';
import 'package:icare/screens/pharmacy_analytics.dart';
import 'package:icare/screens/pharmacy_profile_setup.dart';
import 'package:icare/screens/laboratory_dashboard.dart';
import 'package:icare/screens/lab_bookings_management.dart';
import 'package:icare/screens/lab_tests_management.dart';
import 'package:icare/screens/lab_analytics.dart';
import 'package:icare/screens/lab_profile_setup.dart';
import 'package:icare/screens/prescriptions.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/view_profile.dart';
import 'package:icare/screens/wallet.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/screens/certificates_screen.dart';
import 'package:icare/screens/resource_library_screen.dart';
import 'package:icare/screens/student_dashboard.dart';
import 'package:icare/screens/student_profile_setup.dart';
import 'package:icare/screens/admin_dashboard.dart';
import 'package:icare/screens/instructor_dashboard.dart';
import 'package:icare/screens/instructor_courses_management.dart';
import 'package:icare/screens/instructor_learners_screen.dart';
import 'package:icare/screens/instructor_precautions_management.dart';
import 'package:icare/screens/instructor_analytics.dart';
import 'package:icare/screens/instructor_profile_setup.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;

    var drawerItems = [
      _drawerItem('Tasks', Icons.task_alt_rounded, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
      }),
      _drawerItem('Booking History', Icons.history_rounded, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const BookingsScreen()));
      }),
      _drawerItem('Reminders', Icons.alarm_rounded, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
      }),
      _drawerItem('Help & Support', Icons.help_outline_rounded, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
      }),
      _drawerItem('Wallet', Icons.account_balance_wallet_rounded, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const WalletScreen()));
      }),
      _drawerItem('Health Programs', Icons.health_and_safety_outlined, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const Courses()));
      }),
    ];

    if (selectedRole == "Laboratory") {
      drawerItems = [
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('Report Lab Results', Icons.biotech_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => LabBookingsManagement()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const MyAppointmentsListScreen(),
            ),
          );
        }),
        _drawerItem('Payment Invoices', Icons.receipt_long_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const PaymentInvoices()));
        }),
        _drawerItem('Notifications', Icons.notifications_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const NotificationScreen()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
      ];
    } else if (selectedRole == "Patient") {
      drawerItems = [
        _drawerItem('Appointment Schedule', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyAppointmentsListScreen()));
        }),
        _drawerItem('Book Appointment', Icons.add_circle_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorsList()));
        }),
        _drawerItem('Book a Lab Test', Icons.science_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabsListScreen()));
        }),
        _drawerItem('Order Medicines', Icons.medication_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()));
        }),
        _drawerItem('Booking History', Icons.history_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const BookingsHistoryScreen()));
        }),
        _drawerItem('Health Programs', Icons.health_and_safety_outlined, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const Courses()));
        }),
        _drawerItem('Health Community', Icons.people_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HealthCommunityScreen()));
        }),
        _drawerItem('Lab Results/Reports', Icons.biotech_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabReportsScreen()));
        }),
        _drawerItem('Reminders', Icons.alarm_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
        }),
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
      ];
    } else if (selectedRole == "Doctor") {
      drawerItems = [
        _drawerItem('My Appointments', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const DoctorAppointmentsScreen(),
            ),
          );
        }),
        _drawerItem('My Schedule', Icons.schedule_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const DoctorScheduleCalendar()),
          );
        }),
        _drawerItem('Patient Records', Icons.folder_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const PatientRecordsListScreen(),
            ),
          );
        }),
        _drawerItem('Analytics', Icons.analytics_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const DoctorAnalytics()));
        }),
        _drawerItem('Reviews', Icons.star_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const DoctorReviews()));
        }),
        _drawerItem('Health Community', Icons.people_outline_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const HealthCommunityScreen()),
          );
        }),
        _drawerItem('Availability', Icons.event_available_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const DoctorAvailability()),
          );
        }),
        _drawerItem('Notifications', Icons.notifications_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const DoctorNotifications()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "Pharmacy") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const PharmacistDashboard()),
          );
        }),
        _drawerItem('Profile Setup', Icons.edit_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const PharmacyProfileSetup()),
          );
        }),
        _drawerItem('Inventory', Icons.inventory_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const PharmacyInventory()),
          );
        }),
        _drawerItem('Orders', Icons.shopping_cart_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const PharmacyOrders()));
        }),
        _drawerItem('Analytics', Icons.analytics_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const PharmacyAnalytics()),
          );
        }),
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('My Orders', Icons.shopping_basket_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const MyOrdersScreen()));
        }),
        _drawerItem('Payment Invoices', Icons.receipt_long_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const PaymentInvoices()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const MyAppointment()));
        }),
        _drawerItem('Notifications', Icons.notifications_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const NotificationScreen()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Prescriptions', Icons.description_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const PrescriptionsScreen()),
          );
        }),
        _drawerItem('Reminders', Icons.alarm_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
        }),
        _drawerItem('Wallet', Icons.account_balance_wallet_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const WalletScreen()));
        }),
        _drawerItem('Courses', Icons.school_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const Courses()));
        }),
        _drawerItem(
          'Pharmacy Management',
          Icons.admin_panel_settings_rounded,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const PharmacyManagementScreen(),
              ),
            );
          },
        ),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "Laboratory") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const LaboratoryDashboard()),
          );
        }),
        _drawerItem('Profile Setup', Icons.edit_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const LabProfileSetup()));
        }),
        _drawerItem('Bookings', Icons.calendar_today_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => LabBookingsManagement()));
        }),
        _drawerItem('Tests Management', Icons.science_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const LabTestsManagement()),
          );
        }),
        _drawerItem('Analytics', Icons.analytics_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const LabAnalytics()));
        }),
        _drawerItem('Payment Invoices', Icons.receipt_long_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const PaymentInvoices()));
        }),
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const MyAppointment()));
        }),
        _drawerItem('Notifications', Icons.notifications_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const NotificationScreen()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "Instructor") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => InstructorDashboardScreen()),
          );
        }),
        _drawerItem('Health Precautions', Icons.health_and_safety_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => InstructorPrecautionsManagementScreen(),
            ),
          );
        }),
        _drawerItem('Educational Analytics', Icons.analytics_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => InstructorAnalytics()));
        }),
        _drawerItem('Profile Setup', Icons.person_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => InstructorProfileSetupScreen()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "Student") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const StudentDashboard()));
        }),
        _drawerItem('My Professional Courses', Icons.school_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const Courses(myPurchased: true),
            ),
          );
        }),
        _drawerItem('Course Catalog', Icons.explore_outlined, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const Courses()));
        }),
        _drawerItem('My Certificates', Icons.workspace_premium_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CertificatesScreen()),
          );
        }),
        _drawerItem('Resource Library', Icons.library_books_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const ResourceLibraryScreen()),
          );
        }),
        _drawerItem('Tasks & Quizzes', Icons.task_alt_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('Health Community', Icons.people_outline_rounded, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const HealthCommunityScreen()),
          );
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == 'Admin') {
      drawerItems = []; // Clear other items for Admin
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(40)),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Close button (top-right)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Profile section with border and edit icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        if (selectedRole == "Laboratory") {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabProfileSetup()));
                        } else if (selectedRole == "Pharmacy") {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyProfileSetup()));
                        } else if (selectedRole == "Student") {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const StudentProfileSetup()));
                        } else if (selectedRole == "Doctor") {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorProfileSetup()));
                        } else if (selectedRole == "Patient") {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ProfileEditScreen()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ViewProfile()));
                        }
                      } else if (value == 'logout') {
                        ref.read(authProvider.notifier).setUserLogout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (ctx) => const PublicHome()),
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: Color(0xFF0F172A)),
                            SizedBox(width: 10),
                            Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 10),
                            Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(ImagePaths.user7),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScallingConfig.verticalScale(5),
                    right: ScallingConfig.scale(5),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, child) {
                  final userName = ref.watch(authProvider).user?.name ?? 'User';
                  return Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final userEmail = ref.watch(authProvider).user?.email ?? '';
                  return Text(
                    userEmail,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 25),

              // Menu list (exact items)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (selectedRole != 'Admin') ...[
                      _drawerItem('Home', Icons.home_rounded, () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const TabsScreen(),
                          ),
                        );
                      }, isActive: true),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Divider(color: Color(0xFFF1F5F9), height: 1),
                      ),

                      if (selectedRole != 'Patient')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: CustomText(
                          text: "QUICK ACTIONS",
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                        ),
                      ),

                      // Role-specific quick actions
                      if (selectedRole == 'Laboratory') ...[
                        _drawerActionItem(
                          context,
                          'Test Requests',
                          const Color(0xFF6366F1),
                          Icons.pending_actions_rounded,
                          () {},
                        ),
                        _drawerActionItem(
                          context,
                          'Upload Reports',
                          const Color(0xFF0EA5E9),
                          Icons.upload_file_rounded,
                          () {},
                        ),
                      ] else if (selectedRole == 'Pharmacy') ...[
                        _drawerActionItem(
                          context,
                          'Incoming Prescriptions',
                          const Color(0xFF10B981),
                          Icons.receipt_long_rounded,
                          () {},
                        ),
                        _drawerActionItem(
                          context,
                          'Manage Inventory',
                          const Color(0xFFF59E0B),
                          Icons.inventory_2_rounded,
                          () {},
                        ),
                      ] else if (selectedRole == 'Instructor') ...[
                        _drawerActionItem(
                          context,
                          'Manage Courses',
                          const Color(0xFF8B5CF6),
                          Icons.school_rounded,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    InstructorCoursesManagementScreen(),
                              ),
                            );
                          },
                        ),
                        _drawerActionItem(
                          context,
                          'My Learners',
                          const Color(0xFF0EA5E9),
                          Icons.people_rounded,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => InstructorLearnersScreen(),
                              ),
                            );
                          },
                        ),
                      ] else if (selectedRole == 'Doctor') ...[
                        _drawerActionItem(
                          context,
                          'My Appointments',
                          const Color(0xFF6366F1),
                          Icons.calendar_month_rounded,
                          () {},
                        ),
                        _drawerActionItem(
                          context,
                          'Patient Records',
                          const Color(0xFF0EA5E9),
                          Icons.folder_shared_rounded,
                          () {},
                        ),
                      ],

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Divider(color: Color(0xFFF1F5F9), height: 1),
                      ),

                      if (selectedRole != 'Patient')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: CustomText(
                          text: "NAVIGATION",
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],

                    if (selectedRole == 'Admin') ...[
                      // ── NAVIGATION section ──────────────────────────────
                      _drawerItem('Home', Icons.home_rounded, () {}),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Divider(color: Color(0xFFF1F5F9), height: 1),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: CustomText(
                          text: "OVERVIEW",
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                        ),
                      ),

                      _drawerItem('Pharmacy Order', Icons.local_pharmacy_outlined, () {}),
                      _drawerItem('Lab Orders', Icons.biotech_outlined, () {}),
                      _drawerItem("Doctor's Appointments", Icons.medical_services_outlined, () {}),
                      _drawerItem('Courses', Icons.school_outlined, () {}),
                      _drawerItem('Instructor', Icons.cast_for_education_rounded, () {}),
                      _drawerItem('Student', Icons.person_outlined, () {}),
                      _drawerItem('Privacy Policy', Icons.policy_outlined, () {}),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Divider(color: Color(0xFFF1F5F9), height: 1),
                      ),

                      // ── ADMIN MANAGEMENT section ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: CustomText(
                          text: "ADMIN MANAGEMENT",
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                        ),
                      ),
                      _drawerActionItem(
                        context,
                        'Verify Applications',
                        const Color(0xFFF59E0B),
                        Icons.verified_user_rounded,
                        () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const TabsScreen(initialAdminTab: 'Pending'),
                            ),
                          );
                        },
                      ),
                      _drawerActionItem(
                        context,
                        'Manage Students',
                        const Color(0xFF6366F1),
                        Icons.school_rounded,
                        () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const TabsScreen(initialAdminTab: 'Student'),
                            ),
                          );
                        },
                      ),
                      _drawerActionItem(
                        context,
                        'Manage Pharmacies',
                        const Color(0xFF10B981),
                        Icons.local_pharmacy_rounded,
                        () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const TabsScreen(initialAdminTab: 'Pharmacy'),
                            ),
                          );
                        },
                      ),
                      _drawerActionItem(
                        context,
                        'Manage Laboratories',
                        const Color(0xFF0EA5E9),
                        Icons.biotech_rounded,
                        () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) => const TabsScreen(
                                initialAdminTab: 'Laboratory',
                              ),
                            ),
                          );
                        },
                      ),
                      _drawerActionItem(
                        context,
                        'Manage Instructors',
                        const Color(0xFF8B5CF6),
                        Icons.person_add_rounded,
                        () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) => const TabsScreen(
                                initialAdminTab: 'Instructor',
                              ),
                            ),
                          );
                        },
                      ),

                      _drawerActionItem(
                        context,
                        'Settings',
                        const Color(0xFF64748B),
                        Icons.settings_rounded,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Divider(color: Color(0xFFF1F5F9), height: 1),
                      ),
                    ],

                    // _drawerItem('Reports/Lab Results', () {}),
                    if (selectedRole != 'Admin') ...drawerItems,
                  ],
                ),
              ),

              // Logout button — only for non-Doctor roles (Doctor uses profile dropdown)
              if (selectedRole != 'Doctor')
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).setUserLogout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (ctx) => const PublicHome()),
                      (route) => false,
                    );
                  },
                  width: Utils.windowWidth(context) * 0.6,
                  borderRadius: 30,
                  label: "Logout",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isActive
            ? AppColors.primaryColor.withValues(alpha: 0.08)
            : null,
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.primaryColor : const Color(0xFF64748B),
        ),
        title: CustomText(
          text: title,
          fontFamily: "Gilroy-Bold",
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
          color: isActive ? AppColors.primaryColor : const Color(0xFF0F172A),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _drawerActionItem(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: title,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
