// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import '../../exporter.dart';
import '../../services/fcm_service.dart';
import '../../services/shared_preferences_services.dart';
final agoraConfig = AgoraConfig(
  appKey: "411355671#1562187",
  senderId: "774863640399",
  token: "",
  appId: "fba212c248f64309802c8c5f8f5e9172",
);

class AgoraConfig {
  final String appKey;
  final String senderId;
  final String token;
  final String appId;
  AgoraConfig({
    required this.appKey,
    required this.senderId,
    required this.token,
    required this.appId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appKey': appKey,
      'senderId': senderId,
      'token': token,
      'appId': appId,
    };
  }

  factory AgoraConfig.fromMap(Map<String, dynamic> map) {
    return AgoraConfig(
      appId: map["appId"] as String,
      appKey: map['appKey'] as String,
      senderId: map['senderId'] as String,
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgoraConfig.fromJson(String source) =>
      AgoraConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum CmdActionType {
  startCalling,
  endCalling,
  callDecline,
  startTyping,
  endTyping;

  static CmdActionType fromValue(dynamic value) {
    return CmdActionType.values.firstWhere((element) => element.name == value);
  }
}

class AgoraUtils {
  static final AgoraUtils _instance = AgoraUtils._internal();
  factory AgoraUtils() => _instance;
  AgoraUtils._internal();
  static AgoraUtils get i => _instance;
  Future<void> initSdk(AgoraConfig config) async {
    ChatOptions options = ChatOptions(
      appKey: config.appKey,
      autoLogin: false,
      debugMode: true,
    );
    options.enableFCM(config.senderId);
    options.enableAPNs(config.senderId);
    await ChatClient.getInstance.init(options);
  }

  RtcEngine? engine;

  // Set up the Agora RTC engine instance
  Future<void> initializeAgoraVoiceSDK(AgoraConfig config) async {
    engine = createAgoraRtcEngine();
    await engine?.initialize(
      RtcEngineContext(
        appId: config.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  // Join a channel
  Future<void> joinChannel(AgoraConfig config, String channel) async {
    await engine?.joinChannel(
      token: config.token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        autoSubscribeAudio:
            true, // Automatically subscribe to all audio streams
        publishMicrophoneTrack: true, // Publish microphone-captured audio
        // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: int.parse(currentUser?.userId ?? "0"),
    );
  }

  // Register an event handler for Agora RTC
  void setupVoiceCallEventHanders(RtcEngineEventHandler handler) {
    engine?.registerEventHandler(handler);
  }

  ChatUserInfo? currentUser;

  Future<bool> signIn({
    required String userid,
    required String usertoken,
    required String avatarUrl,
    required String name,
  }) async {
    try {
      await ChatClient.getInstance.loginWithToken(userid, usertoken);
      currentUser = await ChatClient.getInstance.userInfoManager.fetchOwnInfo();
      FCMService().setupNotification().then((value) async {
        logInfo(value);
        await ChatClient.getInstance.pushManager.updateFCMPushToken(value);
      });
      logInfo("login succeed, userId: $userid");
      return true;
    } on ChatError catch (e) {
      if (e.code == 200) {
        currentUser = await ChatClient.getInstance.userInfoManager
            .fetchOwnInfo();
      }
      logInfo("login failed, code: ${e.code}, desc: ${e.description}");
      return false;
    }
  }

  Future<bool> signOut([bool unbindDevice = false]) async {
    try {
      await ChatClient.getInstance.logout(unbindDevice);
      currentUser = null;
      logInfo("sign out succeed");
      return true;
    } on ChatError catch (e) {
      logInfo("sign out failed, code: ${e.code}, desc: ${e.description}");
      return false;
    }
  }

  Future<ChatMessage> sendMessage({
    required String id,
    required String message,
  }) async {
    var msg = ChatMessage.createTxtSendMessage(targetId: id, content: message);
    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendImageMessage({
    required String id,
    required File file,
  }) async {
    var msg = ChatMessage.createImageSendMessage(
      targetId: id,
      filePath: file.path,
      displayName: file.uri.pathSegments.last,
    );
    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendFileMessage({
    required String id,
    required File file,
  }) async {
    var msg = ChatMessage.createFileSendMessage(
      targetId: id,
      filePath: file.path,
      displayName: file.uri.pathSegments.last,
    );

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendVoiceMessage({
    required String id,
    required File file,
    required Duration duration,
  }) async {
    var msg = ChatMessage.createVoiceSendMessage(
      targetId: id,
      filePath: file.path,
      duration: duration.inSeconds,
    );
    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  DateTime lastTypingSend = serverUtcTime;

  bool get isLoggedIn => currentUser != null;

  Future<ChatMessage?> sendTypingIndicator({required String id}) async {
    if (serverUtcTime.subtract(Duration(seconds: 2)).isBefore(lastTypingSend)) {
      return null;
    }
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: jsonEncode({"type": CmdActionType.startTyping.name}),
      deliverOnlineOnly: true,
      chatType: ChatType.Chat,
    );

    lastTypingSend = serverUtcTime;

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  // Leaves the channel and releases resources
  Future<void> cleanupAgoraEngine() async {
    await engine?.leaveChannel();
    await engine?.release();
    isAudioMuted.value = false;
    isVideoMuted.value = true;
  }

  Future<ChatMessage?> sendCallStatusCMD({
    required String id,
    required ChatUserInfo user,
    required String channel,
    required CmdActionType type,
  }) async {
    final action = jsonEncode({
      "type": type.name,
      "from": user.toJson(),
      "channel": channel,
    });
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: action,
      chatType: ChatType.Chat,
      deliverOnlineOnly: true,
    );
    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  ValueNotifier<bool> isAudioMuted = ValueNotifier(false);

  void tougleMicrophone() {
    isAudioMuted.value = !isAudioMuted.value;
    engine?.muteLocalAudioStream(isAudioMuted.value).then((value) {
      logInfo("audio mute : ${isAudioMuted.value}");
    });
  }

  ValueNotifier<bool> isVideoMuted = ValueNotifier(true);

  ValueNotifier<bool> isSpeakerOn = ValueNotifier(false);

  void tougleVideo() async {
    isVideoMuted.value = !isVideoMuted.value;
    if (!isVideoMuted.value) {
      await engine?.enableVideo();
      await engine?.startPreview();
      if (!isSpeakerOn.value) {
        tougleSpeakerMode();
      }
    } else {
      await engine?.disableVideo();
      await engine?.stopPreview();
    }
    logInfo("video mute : ${isVideoMuted.value}");
  }

  void tougleSpeakerMode() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await engine?.setEnableSpeakerphone(isSpeakerOn.value);
  }

  Future<void> initiateIncommingCall(RemoteMessage message) async {
    var extraParams = message.data["e"];
    if (extraParams == null) return;
    extraParams = jsonDecode(extraParams);
    if (CmdActionType.fromValue(extraParams["type"]) !=
        CmdActionType.startCalling) {
      return;
    }
    final fromUser = ChatUserInfo.fromJson(extraParams["from"]);
    final channel = extraParams["channel"];

    await SharedPreferencesService.i.setValue(
      key: incomingCallKey,
      value: jsonEncode({"from": fromUser.toJson(), "channel": channel}),
    );

    CallKitParams callKitParams = CallKitParams(
      id: Uuid().v4(),
      nameCaller: fromUser.nickName,
      appName: 'Eventxpro Attendees',
      avatar: fromUser.avatarUrl,
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      callingNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Calling...',
        callbackText: 'Hang Up',
      ),
      duration: 30000,
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: true,
      ),
      ios: IOSParams(
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: false,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
