// package:web rather than dart:html — dart:html does not exist under
// dart2wasm, and one file importing it forces the whole app onto the JS build.
// window.on[...] has no package:web equivalent, so the listener is added
// explicitly; it is installed once and lives for the life of the page.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

final _controller = StreamController<Map<String, String>>.broadcast();
bool _initialized = false;

Stream<Map<String, String>> get reminderEventStream {
  if (!_initialized) {
    _initialized = true;
    web.window.addEventListener(
      'icare-reminder',
      ((web.Event event) {
        try {
          final detail = (event as web.CustomEvent).detail;
          Map<String, dynamic> map = {};
          if (detail != null && detail.isA<JSString>()) {
            map =
                jsonDecode((detail as JSString).toDart) as Map<String, dynamic>;
          } else if (detail != null) {
            final dartified = detail.dartify();
            if (dartified is Map) {
              map = dartified.map((k, v) => MapEntry(k.toString(), v));
            }
          }
          _controller.add({
            'type': map['type']?.toString() ?? '',
            'title': map['title']?.toString() ?? '',
            'body': map['body']?.toString() ?? '',
          });
        } catch (_) {}
      }).toJS,
    );
  }
  return _controller.stream;
}
