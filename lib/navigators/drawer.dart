import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/booking_categories.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/doctor_profile.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/my_appointment.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/patient_profile.dart';
import 'package:icare/screens/payment_invoices.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/pharmacy_management.dart';
import 'package:icare/screens/prescriptions.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/upload_prescription.dart';
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
      _drawerItem('Tasks', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => TaskScreen()));
      }),
      _drawerItem('Booking History', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => BookingsScreen()));
      }),
      // _drawerItem('Become a Instructor', () {}),
      _drawerItem('Reminders', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => ReminderList()));
      }),
      _drawerItem('Help & Support', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
      }),
      _drawerItem('Wallet', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => WalletScreen()));
      }),
      _drawerItem('Courses', () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => Courses()));
      }),
    ];

    if (selectedRole == "lab_technician") {
      drawerItems = [
        _drawerItem('Tasks', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => TaskScreen()));
        }),
        _drawerItem('Report Lab Results', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
        }),
        _drawerItem('My Appointment', () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ProfileOrAppointmentViewScreen(),
            ),
          );
        }),

        _drawerItem('Payment Invoices', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PaymentInvoices()));
        }),
        _drawerItem('Help & Support', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
        }),
      ];
    } else if (selectedRole == "patient") {
      drawerItems = [
        _drawerItem('Tasks', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => TaskScreen()));
        }),
        _drawerItem('Report Lab Results', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => LabsListScreen()));
        }),
        _drawerItem('My Appointment', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => MyAppointment()));
        }),
        _drawerItem('Help & Support', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
        }),
        _drawerItem('Pharmacies', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PharmaciesScreen()));
        }),
        _drawerItem('Reminders', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ReminderList()));
        }),
        _drawerItem('Courses', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => Courses()));
        }),
      ];
    } else if (selectedRole == "pharmacist") {
      drawerItems = [
        _drawerItem('My Orders', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => MyOrdersScreen()));
        }),
                _drawerItem('Payment Invoices', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PaymentInvoices()));
        }),
        _drawerItem('Help & Support', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
        }),
        _drawerItem('Prescriptions', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PrescriptionsScreen()),
          );
        }),
        _drawerItem('PHarmcy Management', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PharmacyManagementScreen()),
          );
        }),
      ];
    } else if(selectedRole == "instructor"){
      drawerItems = [

        _drawerItem('Pharmacies', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PharmaciesScreen()));
        }),
       
        _drawerItem('Reports/Lab Results', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => LabsListScreen()));
        }),
        _drawerItem('Help & Support', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
        }),
      ];
    } else if(selectedRole == "student"){
      drawerItems = [
       
        _drawerItem('Pharmacies', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PharmaciesScreen()));
        }),
       
        _drawerItem('Reports/Lab Results', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => LabsListScreen()));
        }),
        _drawerItem('Help & Support', () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));
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
              Text(
                selectedRole == "patient"
                    ? 'Emily Jordan'
                    : selectedRole == "lab_technician"
                    ? "Muhammad"
                    : "Aron Smith",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Text(
                selectedRole == "patient"
                    ? 'emily@gmail.com'
                    : selectedRole == "lab_technician"
                    ? "muhamma21@gmail.com"
                    : 'aaron@gmail.com',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),

              // Menu list (exact items)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem('Home', () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => TabsScreen()));
                    }),

                    // _drawerItem('Reports/Lab Results', () {}),
                    ...drawerItems,

                    _drawerItem('Settings', () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => SettingsScreen()),
                      );
                    }),
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

  Widget _drawerItem(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: CustomText(
            text: title,
            fontFamily: "Gilroy-SemiBold",
            fontSize: 14.78,
            color: AppColors.primary500,
          ),

          onTap: onTap,
        ),
      ],
    );
  }
}
