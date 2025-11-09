// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:url_launcher/url_launcher.dart';
import '../exporter.dart';
import '../main_local.dart';
import '../mixins/event_listener.dart';
import 'common_sheet.dart';
import 'loading_button.dart';

class VimeoVideoModel {
  final String vimeoId;
  VimeoVideoModel({required this.vimeoId});
}

class VimeoPlayer extends StatefulWidget {
  const VimeoPlayer({
    super.key,
    required this.vimeoVideo,
    this.aspectRatio = 1920 / 1080,
  });

  final VimeoVideoModel vimeoVideo;
  final double aspectRatio;

  @override
  State<VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> with EventListenerMixin {
  InAppWebViewController? _webViewController;
  InAppWebViewInitialData? _initialData;
  URLRequest? _initialRequest;
  late VimeoVideoModel currentVideo;

  String get videoId => (currentVideo.vimeoId).split("/").first;

  bool initialized = false;
  @override
  void initState() {
    super.initState();
    currentVideo = widget.vimeoVideo;
    allowedEvents = [EventType.changeVideo];
    listenForEvents((event) async {
      if (!allowedEvents.contains(event.eventType)) return;
      if (currentVideo == event.data) return;
      currentVideo = event.data as VimeoVideoModel;
      logError(videoId);
      await _webViewController?.evaluateJavascript(
        source: "player.loadVideo($videoId);",
      );
    });
    _prepareInitialContent();
    //Screen Recorder For Ios
    if (Platform.isIOS) {
      ScreenProtector.addListener(screenshotListener, screenRecordListener);
    }
  }

  Future<void> _prepareInitialContent() async {
    if (kDebugMode) {
      String vimeoPlayerHtmlString = await rootBundle.loadString(
        Assets.html.vimeoPlayer,
      );
      vimeoPlayerHtmlString = vimeoPlayerHtmlString.replaceAll(
        "\${videoId}",
        videoId,
      );
      _initialData = InAppWebViewInitialData(
        data: vimeoPlayerHtmlString,
        encoding: "utf-8",
        baseUrl: WebUri("about:blank"),
      );
    } else {
      _initialRequest = URLRequest(
        url: WebUri(
          "${AppConfigLocal().domainOnly}/vimeo_player/?video_id=$videoId",
        ),
      );
    }
    initialized = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    disposeEventListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Builder(
        builder: (context) {
          if (!initialized) {
            return Center(child: CircularProgressIndicator());
          }
          return InAppWebView(
            initialData: _initialData,
            initialUrlRequest: _initialRequest,
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              transparentBackground: true,
              allowsPictureInPictureMediaPlayback: true,
              useHybridComposition: true,
            ),
            onWebViewCreated: (controller) async {
              _webViewController = controller;
              _registerJavaScriptHandler();
              await _injectFlutterChannelBridge();
            },
            onLoadStop: (controller, url) async {
              await _injectFlutterChannelBridge();
            },
            onPermissionRequest: (controller, request) async {
              logInfo(request);
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
          );
        },
      ),
    );
  }

  void _registerJavaScriptHandler() {
    _webViewController?.addJavaScriptHandler(
      handlerName: "FlutterChannel",
      callback: (args) async {
        if (args.isEmpty) return null;
        final dynamic payload = args.length == 1 ? args.first : args;
        await _handleMessageFromWeb(payload);
        return null;
      },
    );
  }

  Future<void> _injectFlutterChannelBridge() async {
    const script = '''
      try {
        if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
          if (!window.FlutterChannel || typeof window.FlutterChannel.postMessage !== 'function') {
            window.FlutterChannel = {
              postMessage: function(message) {
                window.flutter_inappwebview.callHandler('FlutterChannel', message);
              }
            };
          }
        }
      } catch (error) {
        // ignore
      }
    ''';
    await _webViewController?.evaluateJavascript(source: script);
  }

  Future<void> _handleMessageFromWeb(dynamic payload) async {
    final data = _parsePayload(payload);
    if (data == null) return;
    logInfo(data);

    if (data["play"] == true) {
      await ScreenProtector.preventScreenshotOn();
      if (Platform.isAndroid) {
        return;
      }
      final recording = await ScreenProtector.isRecording();
      if (!recording) {
        return;
      }
      await _webViewController?.evaluateJavascript(source: "player.pause();");
    } else if (data["play"] == false) {
      await ScreenProtector.preventScreenshotOff();
    }
    if (data["percent"] == 1) {
      EventListener.i.sendEvent(Event(eventType: EventType.videoEnd));
    } else if (data["percent"] == 0) {
      // video start
    } else if (data["percent"] != null) {
      onTimeUpdate(data);
    } else if (data["fullscreen"] != null && Platform.isAndroid) {
      if (data["fullscreen"] == true) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]).then((value) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        });
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]).then((value) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        });
      }
    } else if (data["supported"] == false) {
      final response = await showDialog(
        context: context,
        builder: (context) => CommonBottomSheet(
          title: "Video Player Outdated!",
          child: Column(
            children: [
              Text('Please update "Android System  Webview" application'),
              gapLarge,
              LoadingButton(
                buttonLoading: false,
                text: "Update",
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      );
      logError(response);
      if (response == null) return;
      await launchUrl(
        Uri.parse(
          "https://play.google.com/store/apps/details?id=com.google.android.webview&hl=en_IN",
        ),
      ).onError((error, stackTrace) {
        logError(error);
        return Future.error(error!);
      });
    }
  }

  int lastpercentage = 0;

  dynamic _unwrapPayload(dynamic payload) {
    if (payload is List) {
      if (payload.isEmpty) return null;
      return _unwrapPayload(payload.first);
    }
    return payload;
  }

  Map<String, dynamic>? _parsePayload(dynamic payload) {
    try {
      final dynamic message = _unwrapPayload(payload);
      if (message == null) return null;
      if (message is String) {
        return Map<String, dynamic>.from(
          jsonDecode(message) as Map<String, dynamic>,
        );
      }
      if (message is Map) {
        return Map<String, dynamic>.from(message);
      }
      return Map<String, dynamic>.from(
        jsonDecode(jsonEncode(message)) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      logError({
        "parseError": error.toString(),
        "payload": payload,
        "stackTrace": stackTrace.toString(),
      });
      return null;
    }
  }

  void onTimeUpdate(dynamic data) {
    final percentage = (((data["percent"] ?? 0) as num) * 100).toInt();
    if (lastpercentage == percentage) return;
    // DataRepository.i
    //     .updateVideoProgress(
    //   slideId: currentVideo.id.toString(),
    //   progress: percentage,
    // )
    //     .then(
    //   (value) {
    //     lastpercentage = percentage;
    //   },
    // );
  }

  void screenshotListener() {}

  void screenRecordListener(bool recording) {
    if (recording) {
      _webViewController?.evaluateJavascript(source: "player.pause();");
    }
  }
}
