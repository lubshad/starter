import 'dart:async';
import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/repository.dart';
import '../../exporter.dart';
import '../../services/shared_preferences_services.dart';
import '../../services/snackbar_utils.dart';
import '../../widgets/user_avatar.dart';
import 'agora_utils.dart';

enum CallState { outgoingCall, connected, ended, incomingCall }

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
  final CallScreenArgs args;

  static const String path = "/call-screen";

  const CallScreen({super.key, required this.args});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallState _callState;
  String _duration = "00:00";
  Timer? _timer;
  Stopwatch? _stopwatch;

  Future<void> requestPermissions() async {
    final permission = await [
      Permission.microphone,
      Permission.camera,
    ].request();
    if (permission.values.any(
      (element) => element != PermissionStatus.granted,
    )) {
      logError("need permissions to make calls");
      showErrorMessage("Accept all permissions to make calls");
    }
  }

  @override
  void initState() {
    _callState = widget.args.initialState;
    requestPermissions();
    if ([CallState.outgoingCall, CallState.connected].contains(_callState)) {
      _joinAgoraRTC();
    }
    _callDeclineListener();
    super.initState();
  }

  void _callDeclineListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "call-decline",
      ChatEventHandler(
        onCmdMessagesReceived: (messages) {
          final messageBody = messages.first.body as ChatCmdMessageBody;
          final action = jsonDecode(messageBody.action) as Map<String, dynamic>;
          CmdActionType actionType = CmdActionType.fromValue(action["type"]);
          switch (actionType) {
            case CmdActionType.callDecline:
            case CmdActionType.endCalling:
              _endCall();
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  void setupEventHandlers() {
    AgoraUtils.i.setupVoiceCallEventHanders(
      RtcEngineEventHandler(
        onVideoStopped: () {
          logInfo("onVideoStopped");
        },
        onVideoDeviceStateChanged: (deviceId, deviceType, deviceState) {
          logInfo("onVideoDeviceStateChanged");
          logInfo(deviceId);
          logInfo(deviceType);
          logInfo(deviceState);
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              logInfo("onRemoteVideoStateChanged");
              logInfo(connection);
              logInfo(remoteUid);
              logInfo(state);
              logInfo(reason);
              logInfo(elapsed);
              if (state == RemoteVideoState.remoteVideoStateStopped &&
                  !AgoraUtils.i.isVideoMuted.value) {
                AgoraUtils.i.tougleVideo();
              }
            },
        onError: (err, msg) {
          logError(err);
          logError(msg);
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logInfo("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logInfo("Remote user $remoteUid joined");
          _startCallTimer();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              logInfo("Remote user $remoteUid left");
              _endCall();
            },
      ),
    );
  }

  void _joinAgoraRTC() {
    AgoraUtils.i.initializeAgoraVoiceSDK(agoraConfig).then((value) {
      // add event handlers before joining channel
      setupEventHandlers();
      // joining channel

      DataRepository.i
          .generateRTCToken(channel: widget.args.channelName)
          .then((config) {
            AgoraUtils.i.joinChannel(config, widget.args.channelName).then((
              value,
            ) {
              if (_callState == CallState.outgoingCall) {
                AgoraUtils.i.sendCallStatusCMD(
                  type: CmdActionType.startCalling,
                  id: widget.args.user.userId,
                  user: AgoraUtils.i.currentUser!,
                  channel: widget.args.channelName,
                );
              }
            });
          })
          .onError((error, stackTrace) {
            _endCall();
          });
    });
  }

  void _startCallTimer() {
    _callState = CallState.connected;
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final elapsed = _stopwatch?.elapsed ?? Duration.zero;
      final min = elapsed.inMinutes.toString().padLeft(2, '0');
      final sec = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
      setState(() => _duration = "$min:$sec");
    });
  }

  void _endCall() async {
    if (_callState == CallState.connected) {
      AgoraUtils.i.sendCallStatusCMD(
        id: widget.args.user.userId,
        user: widget.args.user,
        channel: widget.args.channelName,
        type: CmdActionType.endCalling,
      );
    } else {
      AgoraUtils.i.sendCallStatusCMD(
        id: widget.args.user.userId,
        user: widget.args.user,
        channel: widget.args.channelName,
        type: CmdActionType.callDecline,
      );
    }
    setState(() {
      _callState = CallState.ended;
    });
    _stopwatch?.stop();
    _timer?.cancel();
    await FlutterCallkitIncoming.endAllCalls();
    await SharedPreferencesService.i.setValue(key: incomingCallKey, value: "");
    AgoraUtils.i.cleanupAgoraEngine();
    if (mounted) Navigator.maybePop(context);
  }

  @override
  void dispose() {
    if (_callState == CallState.connected) {
      _stopwatch?.stop();
      _timer?.cancel();
    }
    ChatClient.getInstance.chatManager.removeEventHandler("call-decline");
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(child: remoteVideo()),
          Positioned(
            right: middlePadding,
            top: kToolbarHeight,
            width: SizeUtils.width * .4,
            child: localVideo(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: AgoraUtils.i.isVideoMuted,
                    builder: (context, videoMuted, child) {
                      return Visibility(
                        visible: videoMuted,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(),
                            UserAvatar(
                              size: 100.h,
                              imageUrl: widget.args.user.avatarUrl,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.args.user.nickName ?? "",
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              [
                                    CallState.outgoingCall,
                                    CallState.incomingCall,
                                  ].contains(_callState)
                                  ? "Calling..."
                                  : _callState == CallState.connected
                                  ? _duration
                                  : "Call Ended",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: _callState != CallState.ended,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Builder(
                    builder: (context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Visibility(
                            visible: CallState.connected == _callState,
                            child: ValueListenableBuilder(
                              valueListenable: AgoraUtils.i.isAudioMuted,
                              builder: (context, isMuted, child) {
                                return _actionButton(
                                  icon: isMuted ? Icons.mic_off : Icons.mic,
                                  active: isMuted,
                                  onTap: AgoraUtils.i.tougleMicrophone,
                                );
                              },
                            ),
                          ),
                          Visibility(
                            visible: CallState.incomingCall == _callState,
                            child: _actionButton(
                              icon: Icons.call,
                              color: Colors.green,
                              onTap: _joinAgoraRTC,
                            ),
                          ),
                          _actionButton(
                            icon: Icons.call_end,
                            color: Colors.redAccent,
                            onTap: _endCall,
                          ),
                          Visibility(
                            visible: CallState.connected == _callState,

                            child: ValueListenableBuilder(
                              valueListenable: AgoraUtils.i.isSpeakerOn,
                              builder: (context, isSpeakerOn, child) {
                                return _actionButton(
                                  icon: isSpeakerOn
                                      ? Icons.volume_up
                                      : Icons.hearing,
                                  active: isSpeakerOn,
                                  onTap: AgoraUtils.i.tougleSpeakerMode,
                                );
                              },
                            ),
                          ),
                          Visibility(
                            visible: CallState.connected == _callState,
                            child: ValueListenableBuilder(
                              valueListenable: AgoraUtils.i.isVideoMuted,
                              builder: (context, isVideoMuted, child) {
                                return _actionButton(
                                  icon: !isVideoMuted
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  active: !isVideoMuted,
                                  onTap: AgoraUtils.i.tougleVideo,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
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
        width: 64,
        height: 64,
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
        child: Icon(icon, size: 28, color: Colors.white),
      ),
    );
  }

  // Displays remote video view
  Widget localVideo() {
    return AspectRatio(
      aspectRatio: .8,
      child: ValueListenableBuilder(
        valueListenable: AgoraUtils.i.isVideoMuted,
        builder: (context, videoMuted, child) {
          return Visibility(
            visible: !videoMuted,
            child: Builder(
              builder: (context) {
                return AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: AgoraUtils.i.engine!,
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

  // Displays remote video view
  Widget remoteVideo() {
    return ValueListenableBuilder(
      valueListenable: AgoraUtils.i.isVideoMuted,
      builder: (context, videoMuted, child) {
        return Visibility(
          visible: !videoMuted,
          child: Builder(
            builder: (context) {
              return AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: AgoraUtils.i.engine!,
                  canvas: VideoCanvas(
                    uid: int.tryParse(widget.args.user.userId),
                  ),
                  connection: RtcConnection(channelId: widget.args.channelName),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
