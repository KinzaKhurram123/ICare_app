// package:web rather than dart:html — dart:html does not exist under
// dart2wasm, and one file importing it forces the whole app onto the JS build.
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void downloadPdfBytes(Uint8List bytes, String filename) {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href = url
    ..setAttribute('download', filename)
    ..click();
  web.URL.revokeObjectURL(url);
}
