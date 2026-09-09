// Conditional export:
//   Web            → face_capture_stub.dart   (no camera / ML Kit in the bundle)
//   Mobile/Desktop → face_capture_screen.dart (real camera + face detection)
//
// Same pattern as video_call.dart. Import THIS file, never face_capture_screen
// directly — a direct import drags `camera` and `google_mlkit_face_detection`
// into the web build even though neither works there.
export 'face_capture_stub.dart'
    if (dart.library.io) 'face_capture_screen.dart';
