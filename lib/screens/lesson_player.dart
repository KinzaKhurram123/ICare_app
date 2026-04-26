import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/video_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonPlayer extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Map<String, dynamic>? nextLesson;

  const LessonPlayer({super.key, required this.lesson, this.nextLesson});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  bool _isCompleted = false;

  bool _isYouTubeOrEmbeddable(String url) {
    return url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('vimeo.com') ||
        url.contains('youtube.com/embed');
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? 'Lesson';
    final content =
        widget.lesson['content'] ?? 'No content available for this lesson.';
    final videoUrl = widget.lesson['videoUrl'] as String? ??
        widget.lesson['video_url'] as String?;
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;
    final isEmbeddable = hasVideo && _isYouTubeOrEmbeddable(videoUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // Column layout: video fixed at top, scrollable content below.
      // This prevents the iframe from blocking scroll events on the content.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── VIDEO (fixed, outside scroll view) ────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: hasVideo
                ? (isEmbeddable
                    ? VideoPlayerWidget(videoUrl: videoUrl)
                    : _DirectVideoFallback(
                        videoUrl: videoUrl,
                        onTap: () => _openInBrowser(videoUrl),
                      ))
                : _NoVideoPlaceholder(),
          ),

          // ── SCROLLABLE CONTENT below video ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // ── TITLE ───────────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),

            // ── OPEN IN NEW TAB link (for embedded videos) ──────────────
            if (hasVideo) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openInBrowser(videoUrl),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new,
                        size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Open in new tab',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── CONTENT ─────────────────────────────────────────────────
            if (content.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ── MARK COMPLETE ───────────────────────────────────────────
            CheckboxListTile(
              value: _isCompleted,
              onChanged: (val) {
                setState(() => _isCompleted = val ?? false);
                if (_isCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lesson marked as completed!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              title: const Text(
                'Mark as Completed',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFF0FDF4),
              activeColor: const Color(0xFF10B981),
            ),

            const SizedBox(height: 24),

            // ── NEXT LESSON ─────────────────────────────────────────────
            if (widget.nextLesson != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => LessonPlayer(
                          lesson: widget.nextLesson!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    'Next: ${widget.nextLesson!['title'] ?? 'Next Lesson'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
                ],      // inner Column children end
              ),        // inner Column
            ),          // SingleChildScrollView
          ),            // Expanded
        ],              // outer Column children end
      ),                // outer Column (body)
    );
  }
}

class _DirectVideoFallback extends StatelessWidget {
  final String videoUrl;
  final VoidCallback onTap;
  const _DirectVideoFallback({required this.videoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill_rounded,
                  color: Colors.white, size: 64),
              const SizedBox(height: 12),
              const Text('Tap to watch video',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoVideoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_rounded, color: Colors.white38, size: 48),
            SizedBox(height: 12),
            Text('No video for this lesson',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
