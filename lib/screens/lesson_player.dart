import 'package:flutter/material.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonPlayer extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Map<String, dynamic>? nextLesson;
  final String? enrollmentId;
  final int? lessonIndex;
  final int? totalLessons;

  const LessonPlayer({
    super.key,
    required this.lesson,
    this.nextLesson,
    this.enrollmentId,
    this.lessonIndex,
    this.totalLessons,
  });

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  bool _isCompleted = false;
  bool _isSaving = false;

  Future<void> _markComplete() async {
    if (_isCompleted || _isSaving) return;
    setState(() { _isCompleted = true; _isSaving = true; });

    // Update backend progress if enrollmentId is available
    if (widget.enrollmentId != null) {
      try {
        final completedVideos = (widget.lessonIndex ?? 0) + 1;
        final total = widget.totalLessons ?? 1;
        final percent = ((completedVideos / total) * 100).round();
        await CourseService().updateProgress(widget.enrollmentId!, {
          'completedVideos': completedVideos,
          'totalVideos': total,
          'percent': percent,
        });
      } catch (e) {
        debugPrint('Progress update error: $e');
      }
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson marked as completed!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? 'Lesson';
    final content = widget.lesson['content'] ?? 'No content available for this lesson.';
    final videoUrl = widget.lesson['videoUrl'] as String?;
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Healthcare Program',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: hasVideo ? () => _openVideo(videoUrl) : null,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thumbnail background
                      if (hasVideo && videoUrl.contains('youtube'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            _getYoutubeThumbnail(videoUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      // Dark overlay
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Play button
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: hasVideo ? AppColors.primaryColor : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasVideo ? Icons.play_arrow_rounded : Icons.videocam_off_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasVideo ? 'Tap to watch video' : 'No video available',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A), letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.6),
            ),
            const SizedBox(height: 48),
            // Mark complete
            InkWell(
              onTap: _isCompleted ? null : _markComplete,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    _isSaving
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)))
                        : Icon(
                            _isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: _isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            size: 24,
                          ),
                    const SizedBox(width: 12),
                    Text(
                      _isCompleted ? 'Lesson Completed ✓' : 'Mark as Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _isCompleted ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.nextLesson != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCompleted
                      ? () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) => LessonPlayer(
                                lesson: widget.nextLesson!,
                                enrollmentId: widget.enrollmentId,
                                lessonIndex: (widget.lessonIndex ?? 0) + 1,
                                totalLessons: widget.totalLessons,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Next Lesson →',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getYoutubeThumbnail(String url) {
    // Extract video ID from YouTube URL
    final regExp = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/)([^&\n?#]+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      return 'https://img.youtube.com/vi/${match.group(1)}/hqdefault.jpg';
    }
    return '';
  }
}
