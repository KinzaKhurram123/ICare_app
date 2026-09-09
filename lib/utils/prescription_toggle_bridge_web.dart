// JS bridge for the real-DOM in-call toggle button(s) used during a walk-in
// call (reception_prescription_screen.dart's _ReceptionCallScreen,
// doctor_call_with_prescription_screen.dart) and a normal appointment-based
// consultation call (doctor_consultation_call_screen.dart). A Flutter FAB
// stacked on top of VideoCall's HtmlElementView(Jitsi iframe) via Positioned
// turned out to be unclickable in practice — Jitsi's live iframe wins
// pointer routing over Flutter's platform-view compositing in this build,
// the same class of problem already solved for the LMS chat toast by
// building the element directly in the parent page's DOM
// (web/index.html's showCallTabButtons/hideCallTabButtons) instead of
// relying on Flutter to draw over it.
// Uses window CustomEvents whose `detail` is a JSON STRING (not a raw JS
// object): interop for plain JS object details proved unreliable, so this
// mirrors the same string+jsonDecode pattern already used for
// icare-recaptcha-result etc.
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:web/web.dart' as web;

// Migrated off dart:html/dart:js to package:web + dart:js_interop: dart:html
// does not exist under dart2wasm, and one file importing it forces the whole
// app onto the slower JS-only build. The behaviour is unchanged — the same
// window CustomEvent carrying a JSON *string* detail, for the reason given
// above — only the interop API is different. window.on[...] has no
// package:web equivalent, so listeners are added and removed explicitly.

const String _toggleEvent = 'icareCallTabToggle';

String? _decodeToggleId(web.Event event) {
  try {
    final detail = (event as web.CustomEvent).detail;
    if (detail == null || !detail.isA<JSString>()) return null;
    final map = jsonDecode((detail as JSString).toDart) as Map;
    return map['id']?.toString();
  } catch (_) {
    return null;
  }
}

class PrescriptionToggleBridge {
  web.EventListener? _listener;

  /// side: 'left' or 'right'. onToggle fires every time the real HTML
  /// button is clicked (Dart owns the open/closed state, JS just reports taps).
  void show({required String side, required VoidCallback onToggle}) {
    try {
      globalContext.callMethod('showPrescriptionToggle'.toJS, side.toJS);
    } catch (_) {}
    _removeListener();
    _listener = ((web.Event event) {
      if (_decodeToggleId(event) == 'prescription') onToggle();
    }).toJS;
    web.window.addEventListener(_toggleEvent, _listener);
  }

  void _removeListener() {
    if (_listener != null) {
      web.window.removeEventListener(_toggleEvent, _listener);
      _listener = null;
    }
  }

  void hide() {
    try {
      globalContext.callMethod('hidePrescriptionToggle'.toJS);
    } catch (_) {}
  }

  void dispose() {
    _removeListener();
    hide();
  }
}

/// Multiple named toggle buttons stacked on one side (e.g. "Prescription"
/// and "Patient History" for a normal in-call consultation) — see
/// showCallTabButtons() in web/index.html. Each button reports its own id
/// back through onToggle so the caller can drive an exclusive tab-selection
/// state (only one panel open at a time) the same way a real tab bar would.
class CallTabButtonsBridge {
  web.EventListener? _listener;

  /// buttons: list of {id, label, side ('left'|'right'), top (optional px
  /// offset for vertical stacking)}. onToggle(id) fires when any button in
  /// the set is clicked.
  void show({
    required List<Map<String, dynamic>> buttons,
    required void Function(String id) onToggle,
  }) {
    try {
      globalContext.callMethod(
        'showCallTabButtons'.toJS,
        buttons.map((b) => b.jsify()).toList().toJS,
      );
    } catch (_) {}
    _removeListener();
    _listener = ((web.Event event) {
      final id = _decodeToggleId(event);
      if (id != null) onToggle(id);
    }).toJS;
    web.window.addEventListener(_toggleEvent, _listener);
  }

  void _removeListener() {
    if (_listener != null) {
      web.window.removeEventListener(_toggleEvent, _listener);
      _listener = null;
    }
  }

  void hide() {
    try {
      globalContext.callMethod('hideCallTabButtons'.toJS);
    } catch (_) {}
  }

  void dispose() {
    _removeListener();
    hide();
  }
}
