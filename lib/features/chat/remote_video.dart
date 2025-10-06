import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'agora_rtc_service.dart';
import 'local_video.dart';

class RemoteVideo extends StatelessWidget {
  const RemoteVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AgoraRtcService.i.isRemoteVideoOn]),
      builder: (context, child) {
        final isRemoteVideoOn = AgoraRtcService.i.isRemoteVideoOn.value;
        if (!isRemoteVideoOn && AgoraRtcService.i.callScreenArgs != null) {
          return CallerInfoItem(
            userInfo: AgoraRtcService.i.callScreenArgs!.user,
            small: AgoraRtcService.i.isLocalMainView.value ? true : false,
          );
        }
        if (AgoraRtcService.i.callScreenArgs == null) return SizedBox();
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: AgoraRtcService.i.engine!,
            canvas: VideoCanvas(
              uid: int.parse(AgoraRtcService.i.callScreenArgs!.user.id),
            ),
            connection: RtcConnection(
              channelId: AgoraRtcService.i.callScreenArgs!.channelName,
            ),
          ),
        );
      },
    );
  }
}
