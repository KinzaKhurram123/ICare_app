import 'package:flutter/material.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/course_card.dart';

class CoursesList extends StatefulWidget {
  const CoursesList({
    super.key,
    this.numOfCourses,
    this.constraintHeight,
    this.mypurchased = false,
    this.searchQuery = "",
  });

  final String searchQuery;
  final bool mypurchased;
  final double? constraintHeight;
  final int? numOfCourses;

  @override
  State<CoursesList> createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  final CourseService _courseService = CourseService();
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  String _extractInstructorName(dynamic instructor) {
    if (instructor == null) return 'Instructor';

    if (instructor is String) return instructor;

    if (instructor is Map) {
      // Try to get name from nested user object
      final user = instructor['user'];
      if (user is Map && user['name'] is String) {
        return user['name'] as String;
      }

      // Try to get name directly from instructor object
      if (instructor['name'] is String) {
        return instructor['name'] as String;
      }
    }

    return 'Instructor';
  }

  Future<void> _fetchCourses() async {
    try {
      final List<dynamic> data;
      if (widget.mypurchased) {
        data = await _courseService.myPurchases();
      } else {
        data = await _courseService.listPublicCourses();
      }

      if (mounted) {
        setState(() {
          _courses = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching courses list: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<dynamic> filteredCourses = _courses.where((item) {
      if (item == null) return false;
      final course = widget.mypurchased ? item['course'] : item;
      if (course == null) return false;

      if (widget.searchQuery.isEmpty) return true;

      final Map<String, dynamic> courseData =
          course is Map ? Map<String, dynamic>.from(course) : {};

      final title = (courseData["title"] ?? courseData["name"] ?? "")
          .toString()
          .toLowerCase();
      final desc = (courseData["caption"] ?? courseData["desc"] ?? "")
          .toString()
          .toLowerCase();
      final query = widget.searchQuery.toLowerCase();

      return title.contains(query) || desc.contains(query);
    }).toList();

    if (filteredCourses.isEmpty) {
      return const Center(child: Text("No health programs found"));
    }

    final displayCount = widget.numOfCourses != null
        ? (widget.numOfCourses! < filteredCourses.length
              ? widget.numOfCourses!
              : filteredCourses.length)
        : filteredCourses.length;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.constraintHeight ?? Utils.windowHeight(context) * 0.7,
      ),
      child: GridView.builder(
        itemCount: displayCount,
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: Utils.windowHeight(context) * 0.35,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (ctx, i) {
          final item = filteredCourses[i];
          final course = widget.mypurchased ? item['course'] : item;
          final Map<String, dynamic> courseData =
              course is Map ? Map<String, dynamic>.from(course) : {};

          if (widget.mypurchased) {
            courseData['isPurchased'] = true;
          }

          return CourseCard(
            image: (courseData["image"] is String)
                ? (courseData["image"] as String)
                : ImagePaths.course1,
            title: (courseData["title"] is String)
                ? (courseData["title"] as String)
                : ((courseData["name"] is String)
                      ? (courseData["name"] as String)
                      : 'Untitled Program'),
            desc: (courseData["caption"] is String)
                ? (courseData["caption"] as String)
                : ((courseData["desc"] is String)
                      ? (courseData["desc"] as String)
                      : 'No description available'),
            instructor: _extractInstructorName(courseData["instructor"]),
            courseData: courseData,
          );
        },
      ),
    );
  }
}
