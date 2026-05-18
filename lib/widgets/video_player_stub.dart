import 'package:flutter/material.dart';

// Stub: returns a "Watch" button on non-web platforms
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('Video not available on this platform',
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
