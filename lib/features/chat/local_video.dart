import 'package:agora_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../../widgets/user_avatar.dart';
import 'agora_rtc_service.dart';
import 'agora_rtm_service.dart';

import '../../exporter.dart';
import 'call_screen.dart';

class LocalVideo extends StatelessWidget {
  const LocalVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .8,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AgoraRtcService.i.isVideoMuted,
          AgoraRtcService.i.duration,
          AgoraRtcService.i.isLocalMainView,
          AgoraRtcService.i.callState,
        ]),

        builder: (context, child) {
          final isVideoMuted = AgoraRtcService.i.isVideoMuted.value;

          if (isVideoMuted) {
            return CallerInfoItem(
              small: isVideoMuted && !AgoraRtcService.i.isLocalMainView.value,
              userInfo: AgoraRTMService.i.currentUser!,
            );
          }
          if (AgoraRtcService.i.callScreenArgs == null) return SizedBox();
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
  }
}

// ignore: must_be_immutable
class CallerInfoItem extends StatelessWidget {
  final ChatUIKitProfile userInfo;
  final bool small;
  const CallerInfoItem({super.key, required this.userInfo, this.small = false});
  @override
  Widget build(BuildContext context) {
    if (AgoraRtcService.i.callScreenArgs == null) return SizedBox();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(),
        UserAvatar(
          size: small ? 40.w : 100.w,
          imageUrl: userInfo.avatarUrl ?? '',
          addMediaUrl: false,
        ),
        Text(
          userInfo.nickname,
          style: TextStyle(
            fontSize: small ? 13.sp : 22.sp,
            color: Colors.white,
            height: 1.4,
          ),

          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        Visibility(
          visible: !small,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              AgoraRtcService.i.callState,
              AgoraRtcService.i.duration,
            ]),
            builder: (context, child) => callstatusText(small: small),
          ),
        ),
      ],
    );
  }
}
