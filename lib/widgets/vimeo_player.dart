// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../exporter.dart';
import '../main_local.dart';
import '../mixins/event_listener.dart';

class VimeoVideoModel {
  final String vimeoId;
  VimeoVideoModel({
    required this.vimeoId,
  });
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
  late WebViewController controller;

  late VimeoVideoModel currentVideo;

  String get videoId => (currentVideo.vimeoId).split("/").first;

  bool initialized = false;
  @override
  void initState() {
    super.initState();
    currentVideo = widget.vimeoVideo;
    allowedEvents = [EventType.changeVideo];
    listenForEvents(
      (event) async {
        if (!allowedEvents.contains(event.eventType)) return;
        if (currentVideo == event.data) return;
        currentVideo = event.data as VimeoVideoModel;
        logError(videoId);
        controller.runJavaScript("player.loadVideo($videoId);");
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        String vimeoPlayerHtmlString =
            await rootBundle.loadString(Assets.html.vimeoPlayer);
        vimeoPlayerHtmlString =
            vimeoPlayerHtmlString.replaceAll("\${videoId}", videoId);

        controller = WebViewController(
          onPermissionRequest: (request) {
            logInfo(request);
          },
        )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel("FlutterChannel",
              onMessageReceived: onMessageReceived);

        if (kDebugMode) {
          controller.loadHtmlString(vimeoPlayerHtmlString);
        } else {
          controller.loadRequest(Uri.parse(
              "${AppConfigLocal().domainOnly}/vimeo_player/?video_id=$videoId"));
        }
        initialized = true;
        setState(() {});
      },
    );

    //Screen Recorder For Ios
    if (Platform.isIOS) {
      ScreenProtector.addListener(screenshotListener, screenRecordListener);
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return WebViewWidget(controller: controller);
        },
      ),
    );
  }

  void onMessageReceived(JavaScriptMessage p1) async {
    final data = jsonDecode(p1.message);
    logInfo(data);

        // screen recording for android
    if (data["play"] == true && Platform.isAndroid) {
      await ScreenProtector.preventScreenshotOn();
    } else if (data["play"] == false && Platform.isAndroid) {
      await ScreenProtector.preventScreenshotOff();
    }
    if (data["percent"] == 1) {
      //video end
      EventListener.i.sendEvent(Event(eventType: EventType.videoEnd));
    } else if (data["percent"] == 0) {
      //video start
    } else if (data["percent"] != null) {
      onTimeUpdate(data);
    } else if (data["fullscreen"] != null && Platform.isAndroid) {
      // full screen tougle
      if (data["fullscreen"] == true) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.restoreSystemUIOverlays();
      }
    }
  }

  int lastpercentage = 0;

  onTimeUpdate(data) {
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
      controller.runJavaScript("player.pause();");
    }
  }
}
