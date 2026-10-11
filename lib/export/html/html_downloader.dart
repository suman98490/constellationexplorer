import 'dart:convert';
import 'dart:html' as html;

class HtmlDownloader {

  static void download(
      String fileName,
      String htmlContent,
      ) {

    final bytes = utf8.encode(htmlContent);

    final blob = html.Blob(
      [bytes],
      'text/html',
    );

    final url =
    html.Url.createObjectUrlFromBlob(blob);

    final anchor =
    html.AnchorElement(href: url)
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}