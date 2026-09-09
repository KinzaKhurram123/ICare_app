// package:web rather than dart:html — dart:html does not exist under
// dart2wasm, and one file importing it forces the whole app onto the JS build.
import 'package:web/web.dart' as web;

void playNotifyTone() {
  try {
    web.window.dispatchEvent(web.CustomEvent('icare-notify-tone'));
  } catch (_) {}
}
