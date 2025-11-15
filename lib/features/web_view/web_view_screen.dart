// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../widgets/custom_appbar.dart';

class WebviewArgs {
  final String title;
  final String url;
  final bool confirmationNeeded;
  WebviewArgs({
    required this.title,
    required this.url,
    this.confirmationNeeded = false,
  });
}

class WebViewScreen extends StatefulWidget {
  static const String path = "/web-view";

  const WebViewScreen({super.key, required this.arguments});

  final WebviewArgs arguments;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  Future<bool> _onWillPop() async {
    if (widget.arguments.confirmationNeeded) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Are you sure you want to leave this page?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final webUri = WebUri(widget.arguments.url);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: (widget.arguments.title)),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: webUri),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            supportZoom: false,
          ),
        ),
      ),
    );
  }
}
