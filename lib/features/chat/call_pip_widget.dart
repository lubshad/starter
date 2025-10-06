import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_route.dart';
import '../../main.dart';
import 'agora_rtc_service.dart';
import 'call_screen.dart';
import 'local_video.dart';
import 'remote_video.dart';

class CallPipWidget extends StatelessWidget {
  const CallPipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Main video view
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    AgoraRtcService.i.isVideoMuted,
                    AgoraRtcService.i.callState,
                    AgoraRtcService.i.duration,
                    AgoraRtcService.i.isRemoteVideoOn,
                  ]),
                  builder: (context, child) {
                    if (!AgoraRtcService.i.isRemoteVideoOn.value) {
                      return Container(
                        color: Colors.black87,
                        child: Visibility(
                          visible: AgoraRtcService.i.callScreenArgs != null,
                          child: Builder(
                            builder: (context) {
                              return CallerInfoItem(
                                userInfo:
                                    AgoraRtcService.i.callScreenArgs!.user,
                                small: true,
                              );
                            },
                          ),
                        ),
                      );
                    }

                    return RemoteVideo();
                  },
                ),
              ),

              Positioned(
                top: paddingLarge,
                left: paddingLarge,
                child: GestureDetector(
                  onTap: () {
                    AgoraRtcService.i.exitPipMode();
                    navigate(navigatorKey.currentContext!, CallScreen.path);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Controls overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: AgoraRtcService.i.isAudioMuted,
                      builder: (context, isMuted, child) {
                        return GestureDetector(
                          onTap: AgoraRtcService.i.tougleMicrophone,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isMuted ? Colors.red : Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isMuted ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),

                    // End call button
                    GestureDetector(
                      onTap: () {
                        AgoraRtcService.i.endCall();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
