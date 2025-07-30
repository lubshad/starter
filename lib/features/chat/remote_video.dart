import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'agora_rtc_service.dart';

class RemoteVideo extends StatelessWidget {
  const RemoteVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AgoraRtcService.i.isRemoteVideoOn,
      builder: (context, isRemoteVideoOn, child) {
        return Visibility(
          visible: isRemoteVideoOn,
          child: Builder(
            builder: (context) {
              return AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: AgoraRtcService.i.engine!,
                  canvas: VideoCanvas(
                    uid: int.parse(
                      AgoraRtcService.i.callScreenArgs!.user.userId,
                    ),
                  ),
                  connection: RtcConnection(
                    channelId: AgoraRtcService.i.callScreenArgs!.channelName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
