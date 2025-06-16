import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:starter/exporter.dart';
import 'package:starter/services/fcm_service.dart';

class AgoraUtils {
  static final AgoraUtils _instance = AgoraUtils._internal();
  factory AgoraUtils() {
    return _instance;
  }
  AgoraUtils._internal();
  static AgoraUtils get i => _instance;
  Future<void> initSdk() async {
    ChatOptions options = ChatOptions(appKey: "411355671#1562187");
    options.enableFCM("774863640399");
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
      await ChatClient.getInstance.userInfoManager.updateUserInfo(
        avatarUrl: avatarUrl,
        nickname: name,
      );
      FCMService().setupNotification().then((value) async {
        logInfo(value);
        await ChatClient.getInstance.pushManager.updatePushNickname(name);
        await ChatClient.getInstance.pushManager.updateFCMPushToken(value);
      });
      logInfo("login succeed, userId: $userid");
      return true;
    } on ChatError catch (e) {
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

  Future<ChatMessage> sendTypingIndicator({required String id}) async {
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: "typing",
      deliverOnlineOnly: true,
      chatType: ChatType.Chat,
    );

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }
}
