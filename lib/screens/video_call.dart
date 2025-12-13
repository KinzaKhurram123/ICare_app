import 'package:flutter/material.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class VideoCall extends StatelessWidget {
  const VideoCall({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// 👨‍⚕️ Main Doctor Image (Full Screen)
          Positioned.fill(
            
            child: Container(
              color: AppColors.tertiaryColor,
              child: Image.asset(
                ImagePaths.walkthrough1, // replace with your main image
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔙 Back Button (Top Left)
          Positioned(
            top: 40,
            // left: 7,
            child: CustomBackButton()
          ),

          /// 👤 Remote User Thumbnail (Top Right)
          Positioned(
            top: 60,
            right: 15,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/patient.png', // replace with your second image
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.mic_off, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🎛 Bottom Control Panel
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(Icons.call_end, Colors.red),
                    _buildControlButton(Icons.volume_up, Colors.white),
                    _buildControlButton(Icons.mic_off, Colors.white),
                    _buildControlButton(Icons.videocam, Colors.white),
                    _buildControlButton(Icons.menu, Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Reusable button builder
  Widget _buildControlButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      radius: 22,
      child: Icon(icon, color: color, size: 24),
    );
  }
}