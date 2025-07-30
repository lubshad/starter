import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'agora_rtc_service.dart';

class LocalVideo extends StatelessWidget {
  const LocalVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .8,
      child: ValueListenableBuilder(
        valueListenable: AgoraRtcService.i.isVideoMuted,
        builder: (context, isVideoMuted, child) {
          return Visibility(
            visible: !isVideoMuted,
            child: Builder(
              builder: (context) {
                return AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: AgoraRtcService.i.engine!,
                    canvas: VideoCanvas(
                      uid: 0,
                      renderMode: RenderModeType.renderModeHidden,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
