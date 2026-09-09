import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// v2 checkbox widget — bridges to the icare-recaptcha-* CustomEvents set up
/// in web/index.html (same mechanism as the icare-reminder events already
/// used elsewhere) — avoids Promise/js_util interop, which isn't stable
/// across the Dart SDK version this project is pinned to.
const String recaptchaContainerId = 'icare-recaptcha-container';
const String _recaptchaViewType = 'icare-recaptcha-view';
bool _viewFactoryRegistered = false;

// Bumped once per registerRecaptchaView() call (i.e. once per widget
// instance's initState). Flutter Web can recycle the SAME underlying DOM
// element across a HtmlElementView being disposed and a new one created
// right after (confirmed live: navigating Login -> Signup sometimes handed
// the JS side the identical container node Login had already rendered
// into) — so element-identity checks on the JS side are not a reliable way
// to tell "this is a genuinely new screen's checkbox" from "the same one
// re-firing its mount timer". A monotonic generation number from the Dart
// side is unambiguous: JS always renders fresh for a new generation.
int _recaptchaGeneration = 0;

/// Registers the platform view that hosts the checkbox <div>, and asks the
/// JS side to render the widget into it once the container exists in the
/// DOM and grecaptcha has loaded. Safe to call multiple times — the view
/// *factory* is only registered once (Flutter throws if you register the
/// same viewType twice), but the mount request is re-dispatched on every
/// call, since this is a SPA where a fresh screen instance (and a fresh
/// container element) can appear later in the same page load without
/// index.html's onload callback ever firing again.
void registerRecaptchaView() {
  final generation = ++_recaptchaGeneration;

  if (!_viewFactoryRegistered) {
    _viewFactoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_recaptchaViewType, (
      int viewId,
    ) {
      final container = web.document.createElement('div') as web.HTMLDivElement
        ..id = recaptchaContainerId
        ..style.width = '304px'
        ..style.height = '78px';
      return container;
    });
  }

  void mount() {
    web.window.dispatchEvent(
      web.CustomEvent(
        'icare-recaptcha-mount',
        web.CustomEventInit(
          detail: jsonEncode({
            'containerId': recaptchaContainerId,
            'generation': generation,
          }).toJS,
        ),
      ),
    );
  }

  // grecaptcha may already be loaded (fast reload) or may still be loading.
  web.window.addEventListener(
    'icare-recaptcha-ready',
    ((web.Event _) => mount()).toJS,
  );
  Timer(const Duration(milliseconds: 300), mount);
}

String get recaptchaViewType => _recaptchaViewType;

/// Reads whatever the user has currently checked (or null if not checked /
/// widget not ready / expired). Does not force a re-render.
Future<String?> getRecaptchaResponse() async {
  final completer = Completer<String?>();
  const eventName = 'icare-recaptcha-result';
  late final web.EventListener listener;
  var removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    web.window.removeEventListener(eventName, listener);
  }

  listener = ((web.Event event) {
    try {
      final raw = (event as web.CustomEvent).detail;
      if (raw == null || !raw.isA<JSString>()) return;
      final map = jsonDecode((raw as JSString).toDart) as Map;
      final token = map['token']?.toString();
      remove();
      if (!completer.isCompleted) completer.complete(token);
    } catch (_) {
      remove();
      if (!completer.isCompleted) completer.complete(null);
    }
  }).toJS;
  web.window.addEventListener(eventName, listener);

  try {
    web.window.dispatchEvent(web.CustomEvent('icare-recaptcha-request'));
  } catch (_) {
    remove();
    return null;
  }

  return completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      remove();
      return null;
    },
  );
}

void resetRecaptcha() {
  try {
    web.window.dispatchEvent(web.CustomEvent('icare-recaptcha-reset'));
  } catch (_) {}
}
