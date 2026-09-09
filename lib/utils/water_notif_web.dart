// package:web + dart:js_interop rather than dart:html/dart:js — dart:html does
// not exist under dart2wasm, and one file importing it forces the whole app
// onto the JS build.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

Future<String> requestWaterNotifPermission() async {
  // dart:html had Notification.supported; package:web has no equivalent, and
  // simply touching web.Notification throws on browsers without it (iOS Safari
  // in a normal tab), so probe the global object first.
  if (!globalContext.has('Notification')) return 'unsupported';
  return (await web.Notification.requestPermission().toDart).toDart;
}

void scheduleWaterReminderInterval(int minutes) {
  try {
    globalContext.callMethod(
      'scheduleWaterReminderInterval'.toJS,
      minutes.toJS,
    );
  } catch (_) {}
}
