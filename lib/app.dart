import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/providers/common_provider.dart';
import 'package:icare/screens/active_orders.dart';
import 'package:icare/screens/add_card.dart';
import 'package:icare/screens/appointments.dart';
import 'package:icare/screens/book_lab.dart';
import 'package:icare/screens/booking_categories.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/change_password.dart';
import 'package:icare/screens/chat.dart';
import 'package:icare/screens/chatlist.dart';
import 'package:icare/screens/confirm_details.dart';
import 'package:icare/screens/consultations.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/screens/create_reminder.dart';
import 'package:icare/screens/decline_appointments.dart';
import 'package:icare/screens/doctor_profile.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/fill_lab_form.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/intake_notes.dart';
import 'package:icare/screens/lab_appointment.dart';
import 'package:icare/screens/lab_filters.dart';
import 'package:icare/screens/labb_details.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/my_cart.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/order_tracking.dart';
import 'package:icare/screens/patient_filters.dart';
import 'package:icare/screens/patient_profile.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/pharmacy_details.dart';
import 'package:icare/screens/pharmacy_home.dart';
import 'package:icare/screens/pharmacy_management.dart';
import 'package:icare/screens/privacy_policy.dart';
import 'package:icare/screens/product_details.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/public_home.dart';
import 'package:icare/screens/rating_n_reviews.dart';
import 'package:icare/screens/receipt.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/remove_products.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/screens/select_test.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/soap_notes.dart';
import 'package:icare/screens/splash.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/tasks.dart';
import 'package:icare/screens/upload_course.dart';
import 'package:icare/screens/upload_prescription.dart';
import 'package:icare/screens/verify_code.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/screens/view_course.dart';
import 'package:icare/screens/view_profile.dart';
import 'package:icare/screens/walkthrough.dart';
import 'package:icare/screens/wallet.dart';
import 'package:icare/utils/shared_pref.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Widget content = const PublicHome();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await SharedPref().getToken();

      if (token != null && token.isNotEmpty) {
        ref.read(authProvider.notifier).setUserToken(token);

        final userRole = await SharedPref().getUserRole();
        if (userRole != null) {
          ref.read(authProvider.notifier).setUserRole(userRole);
        }

        final userDataMap = await SharedPref().getUserData();
        if (userDataMap != null) {
          ref.read(authProvider.notifier).setUser(userDataMap);
        }

        if (mounted) {
          setState(() {
            content = const TabsScreen();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
