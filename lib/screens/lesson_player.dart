import 'package:flutter/material.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = true;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.lesson['videoUrl'] as String?;
    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() => _isVideoLoading = false);
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        showControls: true,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
      );

      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      debugPrint('Video init error: $e');
      setState(() {
        _isVideoLoading = false;
        _videoError = 'Could not load video';
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildVideoContent(hasVideo),
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

  Widget _buildVideoContent(bool hasVideo) {
    if (!hasVideo) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 48),
          SizedBox(height: 12),
          Text('No video available', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      );
    }

    if (_isVideoLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_videoError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(_videoError!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      );
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const SizedBox();
  }
}

