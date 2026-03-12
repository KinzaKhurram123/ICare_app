import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/bookings_history.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/screens/doctor_schedule_calendar.dart';
import 'package:icare/screens/doctor_analytics.dart';
import 'package:icare/screens/doctor_notifications.dart';
import 'package:icare/screens/doctor_reviews.dart';
import 'package:icare/screens/doctor_availability.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/login.dart';
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
import 'package:icare/screens/prescriptions.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/view_profile.dart';
import 'package:icare/screens/wallet.dart';
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
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
      }),
      _drawerItem('Booking History', Icons.history_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const BookingsScreen()));
      }),
      _drawerItem('Reminders', Icons.alarm_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
      }),
      _drawerItem('Help & Support', Icons.help_outline_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
      }),
      _drawerItem('Wallet', Icons.account_balance_wallet_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const WalletScreen()));
      }),
      _drawerItem('Courses', Icons.school_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const Courses()));
      }),
    ];

    if (selectedRole == "lab_technician") {
      drawerItems = [
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('Report Lab Results', Icons.biotech_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabsListScreen()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyAppointmentsListScreen()));
        }),
        _drawerItem('Payment Invoices', Icons.receipt_long_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PaymentInvoices()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
      ];
    } else if (selectedRole == "patient") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TabsScreen()));
        }),
        _drawerItem('Bookings History', Icons.history_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const BookingsHistoryScreen()));
        }),
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('Report Lab Results', Icons.biotech_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabsListScreen()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyAppointment()));
        }),
        _drawerItem('Pharmacies', Icons.medication_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()));
        }),
        _drawerItem('Reminders', Icons.alarm_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
        }),
        _drawerItem('Courses', Icons.school_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const Courses()));
        }),
      ];
    } else if (selectedRole == "doctor") {
      drawerItems = [
        _drawerItem('My Appointments', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorAppointmentsScreen()));
        }),
        _drawerItem('My Schedule', Icons.schedule_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorScheduleCalendar()));
        }),
        _drawerItem('Patient Records', Icons.folder_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PatientRecordsListScreen()));
        }),
        _drawerItem('Analytics', Icons.analytics_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorAnalytics()));
        }),
        _drawerItem('Reviews', Icons.star_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorReviews()));
        }),
        _drawerItem('Availability', Icons.event_available_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorAvailability()));
        }),
        _drawerItem('Notifications', Icons.notifications_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorNotifications()));
        }),
        _drawerItem('My Profile', Icons.person_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DoctorProfileSetup()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "pharmacy") {
      drawerItems = [
        _drawerItem('Dashboard', Icons.dashboard_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacistDashboard()));
        }),
        _drawerItem('Inventory', Icons.inventory_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyInventory()));
        }),
        _drawerItem('Orders', Icons.shopping_cart_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyOrders()));
        }),
        _drawerItem('Analytics', Icons.analytics_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyAnalytics()));
        }),
        _drawerItem('Tasks', Icons.task_alt_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const TaskScreen()));
        }),
        _drawerItem('My Orders', Icons.shopping_basket_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyOrdersScreen()));
        }),
        _drawerItem('Payment Invoices', Icons.receipt_long_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PaymentInvoices()));
        }),
        _drawerItem('My Appointment', Icons.calendar_month_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MyAppointment()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Prescriptions', Icons.description_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PrescriptionsScreen()));
        }),
        _drawerItem('Reminders', Icons.alarm_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ReminderList()));
        }),
        _drawerItem('Wallet', Icons.account_balance_wallet_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const WalletScreen()));
        }),
        _drawerItem('Courses', Icons.school_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const Courses()));
        }),
        _drawerItem('Pharmacy Management', Icons.admin_panel_settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmacyManagementScreen()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "instructor") {
      drawerItems = [
        _drawerItem('Pharmacies', Icons.medication_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()));
        }),
        _drawerItem('Reports/Lab Results', Icons.biotech_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabsListScreen()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
    } else if (selectedRole == "student") {
      drawerItems = [
        _drawerItem('Pharmacies', Icons.medication_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()));
        }),
        _drawerItem('Reports/Lab Results', Icons.biotech_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LabsListScreen()));
        }),
        _drawerItem('Help & Support', Icons.help_outline_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const HelpAndSupport()));
        }),
        _drawerItem('Settings', Icons.settings_rounded, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
        }),
      ];
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
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ViewProfile()
                          // selectedRole == "patient"
                          //     ? PatientProfile()
                          //     : DoctorProfile(),
                        ),
                      );
                    },
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
                    // bottom: 4,
                    top: ScallingConfig.verticalScale(5),
                    right: ScallingConfig.scale(5),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
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
                    _drawerItem('Home', Icons.home_rounded, () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => const TabsScreen()));
                    }, isActive: true),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: CustomText(
                        text: "QUICK ACTIONS",
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    _drawerActionItem(context, 'Book Appointment', const Color(0xFF6366F1)),
                    _drawerActionItem(context, 'View Lab Reports', const Color(0xFF0EA5E9)),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: CustomText(
                        text: "NAVIGATION",
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.5,
                      ),
                    ),

                    // _drawerItem('Reports/Lab Results', () {}),
                    ...drawerItems,
                  ],
                ),
              ),

              // Logout button
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
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

  Widget _drawerItem(String title, IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isActive ? AppColors.primaryColor.withOpacity(0.08) : null,
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

  Widget _drawerActionItem(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flash_on_rounded, size: 12, color: color),
              ),
              const SizedBox(width: 12),
              CustomText(
                text: title,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
