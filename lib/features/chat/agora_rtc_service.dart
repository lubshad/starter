import 'dart:convert';
import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/repository.dart';
import '../../exporter.dart';

// Call-related states
import 'dart:async';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/shared_preferences_services.dart';
import 'agora_rtm_service.dart';
import 'call_pip_widget.dart';
import 'call_screen.dart';

enum CallState { outgoingCall, connected, ended, incomingCall }

class AgoraRtcService {
  static AgoraRtcService get i => _instance;
  static final AgoraRtcService _instance = AgoraRtcService._private();
  AgoraRtcService._private();

  RtcEngine? engine;

  // Call state management
  final ValueNotifier<CallState> callState = ValueNotifier(
    CallState.outgoingCall,
  );
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  Timer? callTimer;
  Stopwatch? callStopwatch;
  final ValueNotifier<bool> isLocalMainView = ValueNotifier(false);
  final ValueNotifier<bool> areControlsVisible = ValueNotifier(true);

  ValueNotifier<bool> isAudioMuted = ValueNotifier(false);
  ValueNotifier<bool> isVideoMuted = ValueNotifier(true);
  ValueNotifier<bool> isSpeakerOn = ValueNotifier(false);

  /// Initialize the Agora RTC engine for voice/video calls
  Future<void> initializeAgoraRtc({required String appId}) async {
    engine = createAgoraRtcEngine();
    await engine?.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  CallScreenArgs? callScreenArgs;

  void setArguments(ChatUserInfo user, String channel, CallState initialState) {
    callScreenArgs = CallScreenArgs(
      user: user,
      channelName: channel,
      initialState: initialState,
    );
    callState.value = initialState;
  }

  /// Join a channel for RTC communication
  Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
  }) async {
    await engine?.joinChannel(
      token: token,
      channelId: channelId,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: uid,
    );
  }

  /// Leaves the channel and releases resources
  Future<void> cleanupAgoraEngine() async {
    ChatClient.getInstance.chatManager.removeEventHandler("call-decline");
    await SharedPreferencesService.i.setValue(key: incomingCallKey, value: "");
    await FlutterCallkitIncoming.endAllCalls();
    stopCallTimer();
    isAudioMuted.value = false;
    isVideoMuted.value = true;
    callState.value = CallState.ended;
    duration.value = Duration.zero;
    isLocalMainView.value = false;
    areControlsVisible.value = true;
    callScreenArgs = null;
    isRemoteVideoOn.value = false;
    await engine?.leaveChannel();
    await engine?.release();
  }

  /// Toggle microphone mute/unmute
  void tougleMicrophone() {
    isAudioMuted.value = !isAudioMuted.value;
    engine?.muteLocalAudioStream(isAudioMuted.value).then((value) {
      logInfo("audio mute : \\${isAudioMuted.value}");
    });
  }

  /// Toggle video on/off
  void tougleVideo() async {
    if (isVideoMuted.value) {
      final permission = await Permission.camera.request();
      if (permission == PermissionStatus.permanentlyDenied) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(
              'Camera Permission Denied',
              style: context.montserrat60016,
            ),
            content: Text(
              'Camera permission required to enable video call',
              style: context.montserrat40014,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: Text(
                  'Open Settings',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      }
      if (permission != PermissionStatus.granted) return;
    }
    isVideoMuted.value = !isVideoMuted.value;
    if (!isVideoMuted.value) {
      await engine?.enableVideo();
      await engine?.enableLocalVideo(true);
      await engine?.startPreview();
      if (!isSpeakerOn.value) {
        tougleSpeakerMode();
      }
    } else {
      await engine?.enableLocalVideo(false);
      await engine?.stopPreview();
    }
    logInfo("video mute : \\${isVideoMuted.value}");
  }

  /// Toggle speaker mode on/off
  void tougleSpeakerMode() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await engine?.setEnableSpeakerphone(isSpeakerOn.value);
  }

  void setCallState(CallState state) {
    callState.value = state;
  }

  void startCallTimer() {
    callState.value = CallState.connected;
    callStopwatch = Stopwatch()..start();
    callTimer?.cancel();
    callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = callStopwatch?.elapsed ?? Duration.zero;
      duration.value = elapsed;
    });
  }

  void stopCallTimer() {
    callStopwatch?.stop();
    callTimer?.cancel();
  }

  void resetCallState() {
    callState.value = CallState.ended;
    duration.value = Duration.zero;
    stopCallTimer();
    isLocalMainView.value = false;
    areControlsVisible.value = true;
  }

  void endCall() async {
    if (AgoraRtcService.i.callState.value == CallState.connected) {
      AgoraRTMService.i.sendCallStatusCMD(
        id: callScreenArgs!.user.userId,
        user: AgoraRTMService.i.currentUser!,
        channel: callScreenArgs!.channelName,
        type: CmdActionType.endCalling,
      );
    } else {
      AgoraRTMService.i.sendCallStatusCMD(
        id: callScreenArgs!.user.userId,
        user: AgoraRTMService.i.currentUser!,
        channel: callScreenArgs!.channelName,
        type: CmdActionType.callDecline,
      );
    }
    await cleanupAgoraEngine();
    if (isPipMode) {
      exitPipMode();
    } else {
      Navigator.maybePop(navigatorKey.currentContext!);
    }
  }

  bool isPipMode = false;

  void enterPipMode() async {
    PictureInPicture.startPiP(pipWidget: CallPipWidget());
    isPipMode = true;
  }

  void exitPipMode() async {
    PictureInPicture.stopPiP();
    isPipMode = false;
  }

  void callDeclineListener() {
    ChatClient.getInstance.chatManager.removeEventHandler("call-decline");
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
              AgoraRtcService.i.endCall();
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  ValueNotifier<bool> isRemoteVideoOn = ValueNotifier(false);

  void setupEventHandlers() {
    AgoraRtcService.i.engine?.registerEventHandler(
      RtcEngineEventHandler(
        onVideoStopped: () {
          logInfo("onVideoStopped");
        },
        onVideoDeviceStateChanged: (deviceId, deviceType, deviceState) {
          logInfo("onVideoDeviceStateChanged");
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              logInfo("onRemoteVideoStateChanged $remoteUid, $state, $reason");
              switch (reason) {
                case RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted:
                case RemoteVideoStateReason.remoteVideoStateReasonRemoteOffline:
                  isRemoteVideoOn.value = false;
                  break;
                case RemoteVideoStateReason.remoteVideoStateReasonRemoteUnmuted:
                  isRemoteVideoOn.value = true;
                  break;
                default:
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
          startCallTimer();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              logInfo("Remote user $remoteUid left");
              // AgoraRtcService.i.endCall();
            },
      ),
    );
  }

  void joinAgoraRTC() {
    AgoraRtcService.i.initializeAgoraRtc(appId: agoraConfig.appId).then((
      value,
    ) {
      DataRepository.i
          .generateRTCToken(channel: callScreenArgs!.channelName)
          .then((config) {
            setupEventHandlers();
            AgoraRtcService.i
                .joinChannel(
                  token: config.token,
                  channelId: callScreenArgs!.channelName,
                  uid: int.parse(AgoraRTMService.i.currentUser?.userId ?? "0"),
                )
                .then((value) {
                  if (AgoraRtcService.i.callState.value ==
                      CallState.outgoingCall) {
                    AgoraRTMService.i.sendCallStatusCMD(
                      type: CmdActionType.startCalling,
                      id: callScreenArgs!.user.userId,
                      user: AgoraRTMService.i.currentUser!,
                      channel: callScreenArgs!.channelName,
                    );
                  }
                });
          })
          .onError((error, stackTrace) {
            AgoraRtcService.i.endCall();
          });
    });
    HapticFeedback.lightImpact();
  }
}


extension AgoraRTMExtension on DataRepository {

  Future<AgoraConfig> generateRTCToken({required String channel}) async {
    try {
      final response = await Dio().get(
        "https://us-central1-eventxpro-66c0b.cloudfunctions.net/generateRtcToken",
        queryParameters: {
          "uid": int.parse(AgoraRTMService.i.currentUser?.userId ?? "0"),
          "channel": channel,
        },
      );
      return AgoraConfig.fromMap(response.data);
    } catch (e) {
      throw handleError(e);
    }
  }
}