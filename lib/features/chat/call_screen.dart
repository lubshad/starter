import 'dart:async';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../exporter.dart';
import '../../mixins/state_mixin.dart';
import '../../services/snackbar_utils.dart';
import '../../widgets/user_avatar.dart';
import 'local_video.dart';
import 'remote_video.dart';
import 'agora_rtc_service.dart';

class CallScreenArgs {
  final ChatUserInfo user;
  final String channelName;
  final CallState initialState;

  CallScreenArgs({
    required this.user,
    required this.channelName,
    required this.initialState,
  });
}

class CallScreen extends StatefulWidget {
  static const String path = "/call-screen";

  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with StateFullMixin {
  Future<void> requestPermissions() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      logError("need permissions to make calls");
      showErrorMessage("Accept all permissions to make calls");
    }
  }

  @override
  void initState() {
    if ([CallState.outgoingCall].contains(AgoraRtcService.i.callState.value)) {
      AgoraRtcService.i.joinAgoraRTC();
    }
    AgoraRtcService.i.callDeclineListener();
    super.initState();
  }

  bool get _isVideoCallActive =>
      AgoraRtcService.i.callState.value == CallState.connected &&
      !(AgoraRtcService.i.isVideoMuted.value);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (AgoraRtcService.i.callState.value == CallState.connected ||
            AgoraRtcService.i.callState.value == CallState.outgoingCall) {
          AgoraRtcService.i.enterPipMode();
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => AgoraRtcService.i.areControlsVisible.value =
                  !AgoraRtcService.i.areControlsVisible.value,
              child: ValueListenableBuilder<bool>(
                valueListenable: AgoraRtcService.i.isLocalMainView,
                builder: (context, isLocal, _) {
                  return isLocal ? LocalVideo() : RemoteVideo();
                },
              ),
            ),

            Positioned(
              right: 16,
              top: kToolbarHeight + 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: AgoraRtcService.i.isLocalMainView,
                builder: (context, isLocal, _) {
                  return GestureDetector(
                    onTap: () => AgoraRtcService.i.isLocalMainView.value =
                        !AgoraRtcService.i.isLocalMainView.value,
                    child: Container(
                      width: 120.h,
                      height: 180.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isLocal ? RemoteVideo() : LocalVideo(),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  );
                },
              ),
            ),

            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    Widget controls = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AgoraRtcService.i.isVideoMuted,
          AgoraRtcService.i.callState,
          AgoraRtcService.i.duration,
          AgoraRtcService.i.isRemoteVideoOn,
          AgoraRtcService.i.isLocalMainView,
        ]),
        builder: (context, child) {
          final visible =
              AgoraRtcService.i.callScreenArgs != null &&
              (!AgoraRtcService.i.isRemoteVideoOn.value
                  ? !AgoraRtcService.i.isRemoteVideoOn.value &&
                        !AgoraRtcService.i.isLocalMainView.value
                  : false);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Visibility(
                  visible: visible,
                  child: Builder(
                    builder: (context) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(),
                          UserAvatar(
                            size: 100.h,
                            imageUrl: AgoraRtcService
                                .i
                                .callScreenArgs!
                                .user
                                .avatarUrl,
                            // addMediaUrl: false,
                          ),
                          gapLarge,
                          Text(
                            AgoraRtcService.i.callScreenArgs!.user.nickName ??
                                "",
                            style: TextStyle(
                              fontSize: 26.sp,
                              color: Colors.white,
                            ),
                          ),
                          gap,
                          callstatusText(),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Visibility(
                visible: AgoraRtcService.i.callState.value != CallState.ended,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Builder(
                  builder: (context) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double buttonSize = (constraints.maxWidth / 9).clamp(
                          48.0,
                          72.0,
                        );
                        double spacing =
                            (constraints.maxWidth - (buttonSize * 6)) / 7;

                        Widget sizedActionButton(Widget child) => SizedBox(
                          width: buttonSize,
                          height: buttonSize,
                          child: child,
                        );

                        List<Widget> buttons = [
                          if (AgoraRtcService.i.callState.value ==
                              CallState.connected)
                            ValueListenableBuilder(
                              valueListenable: AgoraRtcService.i.isAudioMuted,
                              builder: (context, isMuted, child) {
                                return sizedActionButton(
                                  actionButton(
                                    icon: isMuted ? Icons.mic_off : Icons.mic,
                                    active: isMuted,
                                    onTap: AgoraRtcService.i.tougleMicrophone,
                                  ),
                                );
                              },
                            ),
                          if (AgoraRtcService.i.callState.value ==
                              CallState.incomingCall) ...[
                            sizedActionButton(
                              actionButton(
                                icon: Icons.call,
                                color: Colors.green,
                                onTap: AgoraRtcService.i.joinAgoraRTC,
                              ),
                            ),
                            Gap(paddingLarge * 1.5),
                          ],
                          sizedActionButton(
                            actionButton(
                              icon: Icons.call_end,
                              color: Colors.redAccent,
                              onTap: AgoraRtcService.i.endCall,
                            ),
                          ),
                          if (AgoraRtcService.i.callState.value ==
                              CallState.connected)
                            ValueListenableBuilder(
                              valueListenable: AgoraRtcService.i.isSpeakerOn,
                              builder: (context, isSpeakerOn, child) {
                                return sizedActionButton(
                                  actionButton(
                                    icon: isSpeakerOn
                                        ? Icons.volume_up
                                        : Icons.hearing,
                                    active: isSpeakerOn,
                                    onTap: AgoraRtcService.i.tougleSpeakerMode,
                                  ),
                                );
                              },
                            ),
                          if (AgoraRtcService.i.callState.value ==
                              CallState.connected)
                            ValueListenableBuilder(
                              valueListenable: AgoraRtcService.i.isVideoMuted,
                              builder: (context, isVideoMuted, child) {
                                return sizedActionButton(
                                  actionButton(
                                    icon: !isVideoMuted
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                    active: !isVideoMuted,
                                    onTap: AgoraRtcService.i.tougleVideo,
                                  ),
                                );
                              },
                            ),
                          if (AgoraRtcService.i.callState.value ==
                                  CallState.connected &&
                              _isVideoCallActive)
                            sizedActionButton(
                              actionButton(
                                icon: Icons.cameraswitch,
                                onTap: () =>
                                    AgoraRtcService.i.engine?.switchCamera(),
                              ),
                            ),
                        ];

                        List<Widget> spacedButtons = [];
                        for (int i = 0; i < buttons.length; i++) {
                          spacedButtons.add(buttons[i]);
                          if (i != buttons.length - 1) {
                            spacedButtons.add(SizedBox(width: spacing));
                          }
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: spacedButtons,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    if (AgoraRtcService.i.callState.value == CallState.connected &&
        _isVideoCallActive) {
      controls = ValueListenableBuilder<bool>(
        valueListenable: AgoraRtcService.i.areControlsVisible,
        builder: (context, visible, child) {
          return AnimatedSlide(
            offset: visible ? Offset(0, 0) : Offset(0, 1),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: IgnorePointer(ignoring: !visible, child: child!),
            ),
          );
        },
        child: controls,
      );
    }

    return controls;
  }

  Widget actionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
    Color? color,
  }) {
    final bgColor = color ?? (active ? Colors.blueAccent : Colors.grey[800]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 64.h,
        height: 64.h,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor!.withAlpha(0.4.alpha),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 28.sp, color: Colors.white),
      ),
    );
  }
}

Text callstatusText() {
  return Text(
    [
          CallState.outgoingCall,
          CallState.incomingCall,
        ].contains(AgoraRtcService.i.callState.value)
        ? "Calling..."
        : AgoraRtcService.i.callState.value == CallState.connected
        ? AgoraRtcService.i.duration.value.toHoursMinutesSeconds
        : "Call Ended",
    style: const TextStyle(color: Colors.grey),
  );
}
