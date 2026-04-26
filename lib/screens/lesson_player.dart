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

  // ── helpers ──────────────────────────────────────────────────────────────

  String? _youtubeId(String url) {
    // youtu.be/ID
    final s = RegExp(r'youtu\.be/([^?&\s]+)').firstMatch(url);
    if (s != null) return s.group(1);
    // watch?v=ID
    final w = RegExp(r'[?&]v=([^&\s]+)').firstMatch(url);
    if (w != null) return w.group(1);
    // shorts/ID
    final sh = RegExp(r'shorts/([^?&\s]+)').firstMatch(url);
    if (sh != null) return sh.group(1);
    return null;
  }

  bool _isEmbeddable(String url) =>
      url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('vimeo.com');

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the YouTube/Vimeo iframe in a full-screen dialog.
  /// The dialog is separate from the scrollable lesson page,
  /// so NO iframe exists in the scrollable tree → scroll works freely.
  void _openVideoDialog(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // ── iframe video ──────────────────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VideoPlayerWidget(videoUrl: videoUrl),
                ),
              ),
              // ── close button ──────────────────────────────────────────
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] as String? ?? 'Lesson';
    final content = widget.lesson['content'] as String? ?? '';
    final videoUrl = widget.lesson['videoUrl'] as String? ??
        widget.lesson['video_url'] as String?;
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;
    final ytId = hasVideo ? _youtubeId(videoUrl) : null;
    final embeddable = hasVideo && _isEmbeddable(videoUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      // ── fully scrollable body — NO iframe here ─────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── VIDEO CARD (thumbnail + play, no iframe) ────────────────
            if (hasVideo)
              _VideoThumbnailCard(
                videoUrl: videoUrl,
                youtubeId: ytId,
                embeddable: embeddable,
                onPlay: embeddable
                    ? () => _openVideoDialog(context, videoUrl)
                    : () => _openExternal(videoUrl),
                onOpenTab: () => _openExternal(videoUrl),
              ),

            const SizedBox(height: 28),

            // ── TITLE ────────────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 20),

            // ── LESSON CONTENT ───────────────────────────────────────────
            if (content.trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.7,
                  ),
                ),
              ),

            const SizedBox(height: 28),

            // ── MARK COMPLETE ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _isCompleted
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCompleted
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: CheckboxListTile(
                value: _isCompleted,
                onChanged: (val) {
                  setState(() => _isCompleted = val ?? false);
                  if (_isCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lesson marked as completed!'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                title: Text(
                  _isCompleted ? 'Completed ✓' : 'Mark as Completed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF0F172A),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // ── NEXT LESSON ──────────────────────────────────────────────
            if (widget.nextLesson != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) =>
                            LessonPlayer(lesson: widget.nextLesson!),
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
                    elevation: 0,
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video thumbnail card — no iframe, fully Flutter-rendered → scroll works
// ─────────────────────────────────────────────────────────────────────────────

class _VideoThumbnailCard extends StatelessWidget {
  final String videoUrl;
  final String? youtubeId;
  final bool embeddable;
  final VoidCallback onPlay;
  final VoidCallback onOpenTab;

  const _VideoThumbnailCard({
    required this.videoUrl,
    required this.youtubeId,
    required this.embeddable,
    required this.onPlay,
    required this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    final thumbUrl = youtubeId != null
        ? 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg'
        : null;

    return GestureDetector(
      onTap: onPlay,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── background: YouTube thumbnail or solid colour ───────────
              if (thumbUrl != null)
                Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF0F172A)),
                )
              else
                Container(color: const Color(0xFF0F172A)),

              // ── dark overlay ─────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),

              // ── play button ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF0F172A),
                    size: 44,
                  ),
                ),
              ),

              // ── "Click to watch" label ────────────────────────────────────
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Click to watch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // ── open in new tab (top-right) ──────────────────────────────
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onOpenTab,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('New tab',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
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
