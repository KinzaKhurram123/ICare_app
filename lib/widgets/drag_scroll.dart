import 'package:flutter/material.dart';

/// Wraps a vertical scroll view in a scrollbar the user can actually **drag**.
///
/// The client's complaint — "pakad ke nahi hota... sab ke paas mouse nahi
/// hota" — was not that the scrollbar was invisible. `AppTheme.mainTheme`
/// already sets `thumbVisibility: true`, so the thumb paints fine. The problem
/// is that it was not grabbable, and the reason is this, in Flutter's
/// `RawScrollbar`:
///
/// ```dart
/// bool _canHandleScrollGestures() {
///   return enableGestures &&
///       _effectiveScrollController != null &&
///       _effectiveScrollController!.positions.length == 1 && ...
/// }
/// ```
///
/// with `_effectiveScrollController = widget.controller ?? PrimaryScrollController`.
///
/// Nearly every scroll view in this app passes no controller, so it falls back
/// to the shared `PrimaryScrollController`. On any screen holding more than one
/// vertical scroll view that controller ends up with several attached
/// positions, `positions.length == 1` fails, and Flutter registers **no drag
/// gesture recognizers at all** — silently, while the thumb still paints from
/// scroll notifications. That is exactly "dikhta hai magar pakad mein nahi
/// aata".
///
/// Giving the scroll view its own controller fixes it. This widget exists so
/// that is one line per call site and the controller is always disposed:
///
/// ```dart
/// DragScroll(
///   builder: (context, controller) => SingleChildScrollView(
///     controller: controller,
///     child: ...,
///   ),
/// )
/// ```
///
/// Use it on a screen's **outermost** vertical scroll view — the one the user
/// actually drags. Nested horizontal strips and short inner lists do not need
/// it, and wrapping them adds a second scrollbar for no benefit.
class DragScroll extends StatefulWidget {
  const DragScroll({super.key, required this.builder, this.thumbVisible = true});

  /// Must pass the supplied controller to the scroll view it returns —
  /// otherwise the scroll view falls back to the primary controller again and
  /// nothing is fixed.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  /// Set false for a short list where a permanent bar would be noise; the bar
  /// then fades in only while scrolling, and is still draggable.
  final bool thumbVisible;

  @override
  State<DragScroll> createState() => _DragScrollState();
}

class _DragScrollState extends State<DragScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: widget.thumbVisible,
      trackVisibility: widget.thumbVisible,
      interactive: true,
      child: widget.builder(context, _controller),
    );
  }
}
