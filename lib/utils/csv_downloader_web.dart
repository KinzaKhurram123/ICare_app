// Uses package:web + dart:js_interop rather than dart:html. dart:html does
// not exist under dart2wasm, so a single file importing it forces the whole
// app back onto the slower JS-only build.
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Downloads [csvContent] as a file named [filename] in the browser.
bool downloadCsv(String csvContent, String filename) {
  final blob = web.Blob(
    <JSAny>[csvContent.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..setAttribute('download', filename);
  anchor.click();
  web.URL.revokeObjectURL(url);
  return true;
}
