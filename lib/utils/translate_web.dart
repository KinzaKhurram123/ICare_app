// package:web rather than dart:html — dart:html does not exist under
// dart2wasm, and one file importing it forces the whole app onto the JS build.
import 'package:web/web.dart' as web;

void activateLanguage(String lang) {
  try {
    if (lang == 'Urdu') {
      web.document.cookie = 'googtrans=/en/ur; path=/';
      web.document.cookie =
          'googtrans=/en/ur; path=/; domain=.${web.window.location.hostname}';
    } else {
      web.document.cookie =
          'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/';
      web.document.cookie =
          'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; domain=.${web.window.location.hostname}';
    }
    web.window.location.reload();
  } catch (_) {}
}
