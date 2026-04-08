import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class LessonPlayer extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Map<String, dynamic>? nextLesson;

  const LessonPlayer({super.key, required this.lesson, this.nextLesson});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? 'Lesson';
    final content =
        widget.lesson['content'] ?? 'No content available for this lesson.';
    final videoUrl = widget.lesson['videoUrl'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Healthcare Program',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Video Content',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF475569),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            // Actions
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _isCompleted,
                    onChanged: (val) {
                      setState(() => _isCompleted = val ?? false);
                      if (_isCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lesson marked as completed!'),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.nextLesson != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next lesson
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Next Lesson',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
