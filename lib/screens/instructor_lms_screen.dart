import 'package:flutter/material.dart';
import 'package:icare/navigators/deferred_route.dart';
import 'package:icare/screens/instructor_lms_dashboard.dart'
    deferred as i_lms_dash;

// This file is the entry point for the LMS from the instructor's main dashboard.
// It simply renders InstructorLmsDashboard (the Google Classroom-style shell).
//
// The import is deferred so the LMS shell — and the whole instructor course
// tree hanging off it — ships as its own JS chunk instead of riding along in
// main.dart.js, which every visitor downloads before the landing page paints.
class InstructorLmsScreen extends StatelessWidget {
  const InstructorLmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredScreen(
      loader: i_lms_dash.loadLibrary,
      builder: () => i_lms_dash.InstructorLmsDashboard(),
    );
  }
}
