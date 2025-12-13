import 'package:flutter/material.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomButton(label: 
      "Create Profile",
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CreateProfile()));
      },
      ),
    );
  }
}