// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../widgets/custom_appbar.dart';

class WebviewArgs {
  final String title;
  final String url;
  WebviewArgs({required this.title, required this.url});
}

class WebViewScreen extends StatefulWidget {
  static const String path = "/web-view";

  const WebViewScreen({super.key, required this.arguments});

  final WebviewArgs arguments;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    final webUri = WebUri(widget.arguments.url);
    return Scaffold(
      appBar: CustomAppBar(title: (widget.arguments.title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: webUri),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: false,
        ),
      ),
    );
  }
}
