// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../../exporter.dart';
import '../../services/fcm_service.dart';

class AgoraConfig {
  final String appKey;
  final String senderId;
  final String token;
  AgoraConfig({
    required this.appKey,
    required this.senderId,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appKey': appKey,
      'senderId': senderId,
      'token': token,
    };
  }

  factory AgoraConfig.fromMap(Map<String, dynamic> map) {
    return AgoraConfig(
      appKey: map['appKey'] as String,
      senderId: map['senderId'] as String,
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AgoraConfig.fromJson(String source) =>
      AgoraConfig.fromMap(json.decode(source) as Map<String, dynamic>);
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
    await ChatClient.getInstance.init(options);
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

  Future<bool> signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
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

  Future<ChatMessage?> sendTypingIndicator({required String id}) async {
    if (serverUtcTime.subtract(Duration(seconds: 2)).isBefore(lastTypingSend)) {
      return null;
    }
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: "typing",
      deliverOnlineOnly: true,
      chatType: ChatType.Chat,
    );

    lastTypingSend = serverUtcTime;

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }
}
