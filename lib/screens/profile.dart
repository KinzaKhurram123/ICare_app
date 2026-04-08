import 'package:flutter/material.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/widgets/custom_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return const _WebProfileInitial();
    }

    return Center(
      child: CustomButton(
        label: "Create Profile",
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const CreateProfile()));
        },
      ),
    );
  }
}

class _WebProfileInitial extends StatelessWidget {
  const _WebProfileInitial();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration / Icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.account_circle_rounded,
                    size: 100,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const CustomText(
                text: "Complete Your Profile",
                fontSize: 32,
                fontFamily: "Gilroy-Bold",
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 16),
              const CustomText(
                text:
                    "To get the most out of ICare, please set up your medical profile. This helps us provide personalized recommendations and seamless care.",
                fontSize: 16,
                color: Color(0xFF64748B),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 54),
              SizedBox(
                width: 320,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const CreateProfile(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Create Profile Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Why do I need this?",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
