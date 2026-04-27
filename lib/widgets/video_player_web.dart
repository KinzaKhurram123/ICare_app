// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    final embedUrl = _toEmbedUrl(widget.videoUrl);
    // Unique view type per widget instance so re-opening lessons works
    _viewType = 'video-${widget.videoUrl.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int id) {
      return html.IFrameElement()
        ..src = embedUrl
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute(
          'allow',
          'accelerometer; autoplay; clipboard-write; '
          'encrypted-media; gyroscope; picture-in-picture; web-share',
        );
    });
  }

  /// Convert any YouTube URL variant to an embed URL.
  static String _toEmbedUrl(String url) {
    // Already embed
    if (url.contains('youtube.com/embed/')) return url;

    // youtu.be/ID or youtu.be/ID?t=30
    final short = RegExp(r'youtu\.be/([^?&\s]+)').firstMatch(url);
    if (short != null) {
      return 'https://www.youtube.com/embed/${short.group(1)}';
    }

    // youtube.com/watch?v=ID
    final watch = RegExp(r'[?&]v=([^&\s]+)').firstMatch(url);
    if (watch != null) {
      return 'https://www.youtube.com/embed/${watch.group(1)}';
    }

    // youtube.com/shorts/ID
    final shorts = RegExp(r'shorts/([^?&\s]+)').firstMatch(url);
    if (shorts != null) {
      return 'https://www.youtube.com/embed/${shorts.group(1)}';
    }

    // Vimeo: vimeo.com/ID
    final vimeo = RegExp(r'vimeo\.com/(\d+)').firstMatch(url);
    if (vimeo != null) {
      return 'https://player.vimeo.com/video/${vimeo.group(1)}';
    }

    // Direct video URL or anything else — return as-is (browser handles it)
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
