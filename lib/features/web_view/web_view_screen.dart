// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:starter/widgets/custom_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    return Scaffold(
      appBar: CustomAppBar(title: (widget.arguments.title)),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(widget.arguments.url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
