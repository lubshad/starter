// ignore: depend_on_referenced_packages
import 'package:html/parser.dart';

String? fixHtmlContent(dynamic html) {
  if (html == null) return null;
  return html.toString().replaceAll("&amp;", "&").replaceAll("#", "?");
}

List<String> listStringFromHtml(dynamic html) {
  try {
    if (html == null) return [];
    fixHtmlContent(html);
    final parsedHtml = parse(html);
    final firstChild = parsedHtml.body!.children.first;
    switch (firstChild.localName) {
      case "p":
        return [firstChild.text];
      default:
        return firstChild.children.map((e) => e.text).toList();
    }
  } catch (e) {
    return [html];
  }
}

String stringFromHtml(dynamic html) {
  try {
    if (html == null) return "";
    html = fixHtmlContent(html);
    final parsedHtml = parse(html);
    final children = parsedHtml.body!.children;
    if (children.isEmpty) return html;
    return children.map((e) => e.text).join("\n");
  } catch (e) {
    return html;
  }
}
