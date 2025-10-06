// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import '../../core/app_route.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../services/fcm_service.dart';
import '../../widgets/custom_appbar.dart';
import '../profile_screen/common_controller.dart';

final agoraConfig = AgoraConfig(
  appKey: "41997883#1598640",
  senderId: "361182296433",
  token: "",
  appId: "c8c3a8dd47ba4d6e9e11e2bb83735994",
);

String publicGroupId = "292656738533378";

String rtmTokenUrl = "https://generatertmtoken-3aykugpx2a-uc.a.run.app";

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

class AgoraRTMService {
  static final AgoraRTMService _instance = AgoraRTMService._internal();
  AgoraRTMService._internal();
  static AgoraRTMService get i => _instance;
  Future<void> initSdk(AgoraConfig config) async {
    ChatOptions options = ChatOptions(
      appKey: config.appKey,
      requireDeliveryAck: true,
      debugMode: kDebugMode,
      autoLogin: false,
      chatAreaCode: ChatAreaCode.AS,
    );
    options.enableFCM(config.senderId);
    options.enableAPNs(config.senderId);
    await ChatClient.getInstance.init(options);
    setupChatUI();
  }

  void setupChatUI() {
    ChatUIKitSettings.avatarRadius = CornerRadius.large;
    ChatUIKitSettings.enableMessageThread = false;
    ChatUIKitSettings.enablePinMsg = false;
    ChatUIKitSettings.enableMessageReport = false;
    ChatUIKitSettings.enableMessageTranslation = false;
    ChatUIKitSettings.enableMessageForward = false;
    ChatUIKitSettings.enableMessageEdit = false;
    ChatUIKitSettings.enableMessageMultiSelect = false;
    ChatUIKitTimeFormatter.instance.formatterHandler = (context, type, time) {
      return DateTime.fromMillisecondsSinceEpoch(time).timeFormat;
    };
  }

  // ChatUserInfo? currentUser;

  Future<ChatMessage> sendMessageWithReply({
    required String id,
    required String message,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSender,
    MessageType? replyToType,
    ChatType chatType = ChatType.Chat,
  }) async {
    var msg = ChatMessage.createTxtSendMessage(
      targetId: id,
      content: message,
      chatType: chatType,
    );

    // Add reply information as extensions
    if (replyToMessageId != null) {
      msg.attributes = {
        'reply_to_msg_id': replyToMessageId,
        'reply_to_content': replyToContent ?? '',
        'reply_to_sender': replyToSender ?? '',
        'reply_to_type': replyToType?.name ?? 'TXT',
      };
    }

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendImageMessageWithReply({
    required String id,
    required File file,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSender,
    MessageType? replyToType,
    ChatType chatType = ChatType.Chat,
  }) async {
    var msg = ChatMessage.createImageSendMessage(
      targetId: id,
      filePath: file.path,
      displayName: file.uri.pathSegments.last,
      chatType: chatType,
    );

    if (replyToMessageId != null) {
      msg.attributes = {
        'reply_to_msg_id': replyToMessageId,
        'reply_to_content': replyToContent ?? '',
        'reply_to_sender': replyToSender ?? '',
        'reply_to_type': replyToType?.name ?? 'TXT',
      };
    }

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendFileMessageWithReply({
    required String id,
    required File file,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSender,
    MessageType? replyToType,
    ChatType chatType = ChatType.Chat,
  }) async {
    var msg = ChatMessage.createFileSendMessage(
      targetId: id,
      filePath: file.path,
      displayName: file.uri.pathSegments.last,
      chatType: chatType,
    );

    if (replyToMessageId != null) {
      msg.attributes = {
        'reply_to_msg_id': replyToMessageId,
        'reply_to_content': replyToContent ?? '',
        'reply_to_sender': replyToSender ?? '',
        'reply_to_type': replyToType?.name ?? 'TXT',
      };
    }

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<ChatMessage> sendVoiceMessageWithReply({
    required String id,
    required File file,
    required Duration duration,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSender,
    MessageType? replyToType,
    ChatType chatType = ChatType.Chat,
  }) async {
    var msg = ChatMessage.createVoiceSendMessage(
      targetId: id,
      filePath: file.path,
      duration: duration.inSeconds,
      chatType: chatType,
    );

    if (replyToMessageId != null) {
      msg.attributes = {
        'reply_to_msg_id': replyToMessageId,
        'reply_to_content': replyToContent ?? '',
        'reply_to_sender': replyToSender ?? '',
        'reply_to_type': replyToType?.name ?? 'TXT',
      };
    }

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<void> joinPublicGroup(String groupId) async {
    try {
      await ChatClient.getInstance.groupManager.joinPublicGroup(groupId);
      logInfo("✅ Joined group: $groupId");
    } catch (e) {
      logInfo("❌ Failed to join group: $e");
    }
  }

  Future<bool> signIn({
    required String userid,
    required String avatarUrl,
    required String name,
  }) async {
    try {
      if (isLoggedIn && ChatUIKit.instance.currentUserId != userid) {
        await signOut();
      }
      final config = await DataRepository.i.generateRTMToken(
        username: userid,
        avatarUrl: avatarUrl,
        nickname: name,
      );
      await ChatUIKit.instance.loginWithToken(
        userId: userid,
        token: config.token,
      );
      logInfo("login succeed, userId: $userid");
      final extension = jsonEncode({
        "user": CommonController.i.profileDetails?.toMap(),
      });
      await ChatUIKit.instance.updateUserInfo(ext: extension);
      return true;
    } catch (e) {
      if (e is ChatError && e.code == 200) {
        logInfo("login succeed, userId: $userid");
        final extension = jsonEncode({
          "user": CommonController.i.profileDetails?.toJson(),
        });
        await ChatUIKit.instance.updateUserInfo(ext: extension);
        return true;
      }
      logInfo("login failed, userId: $userid, error: $e");
      return false;
    }
  }

  bool get isLoggedIn => ChatClient.getInstance.currentUserId != null;

  void updateFcmToken() {
    if (!isLoggedIn) return;
    FCMService.token.then((value) async {
      logInfo(value);
      if (value?.isEmpty ?? true) return;
      await ChatClient.getInstance.pushManager.updateFCMPushToken(value!);
    });
  }

  Future<bool> signOut([bool unbindDevice = false]) async {
    try {
      await ChatClient.getInstance.logout(unbindDevice);
      logInfo("sign out succeed");
      return true;
    } on ChatError catch (e) {
      logInfo("sign out failed, code: ${e.code}, desc: ${e.description}");
      return false;
    }
  }

  DateTime lastTypingSend = serverUtcTime;

  Future<ChatMessage?> sendTypingIndicator({
    required String id,
    ChatType chatType = ChatType.Chat,
  }) async {
    if (serverUtcTime.subtract(Duration(seconds: 2)).isBefore(lastTypingSend)) {
      return null;
    }
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: jsonEncode({"type": CmdActionType.startTyping.name}),
      deliverOnlineOnly: true,
      chatType: chatType,
    );

    lastTypingSend = serverUtcTime;

    return await ChatClient.getInstance.chatManager.sendMessage(msg);
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

  // Future initiateIncommingCall(RemoteMessage message) async {
  //   var extraParams = message.data["e"];
  //   if (extraParams == null) return;
  //   extraParams = jsonDecode(extraParams);
  //   if (CmdActionType.fromValue(extraParams["type"]) !=
  //       CmdActionType.startCalling) {
  //     return;
  //   }
  //   final fromUser = ChatUserInfo.fromJson(extraParams["from"]);
  //   final channel = extraParams["channel"];

  //   await SharedPreferencesService.i.setValue(
  //     key: incomingCallKey,
  //     value: jsonEncode({"from": fromUser.toJson(), "channel": channel}),
  //   );

  //   CallKitParams callKitParams = CallKitParams(
  //     id: Uuid().v4(),
  //     nameCaller: fromUser.nickName,
  //     appName: 'Eventxpro Attendees',
  //     avatar: fromUser.avatarUrl,
  //     type: 0,
  //     textAccept: 'Accept',
  //     textDecline: 'Decline',
  //     missedCallNotification: NotificationParams(
  //       showNotification: true,
  //       isShowCallback: false,
  //       subtitle: 'Missed call',
  //       callbackText: 'Call back',
  //     ),
  //     callingNotification: const NotificationParams(
  //       showNotification: true,
  //       isShowCallback: false,
  //       subtitle: 'Calling...',
  //       callbackText: 'Hang Up',
  //     ),
  //     duration: 30000,
  //     android: const AndroidParams(
  //       isCustomNotification: true,
  //       isShowLogo: true,
  //       ringtonePath: 'system_ringtone_default',
  //       backgroundColor: '#0955fa',
  //       actionColor: '#4CAF50',
  //       textColor: '#ffffff',
  //       incomingCallNotificationChannelName: "Incoming Call",
  //       missedCallNotificationChannelName: "Missed Call",
  //       isShowCallID: true,
  //     ),
  //     ios: IOSParams(
  //       handleType: 'generic',
  //       supportsVideo: false,
  //       maximumCallGroups: 1,
  //       maximumCallsPerCallGroup: 1,
  //       audioSessionMode: 'default',
  //       audioSessionActive: false,
  //       audioSessionPreferredSampleRate: 44100.0,
  //       audioSessionPreferredIOBufferDuration: 0.005,
  //       supportsDTMF: true,
  //       supportsHolding: false,
  //       supportsGrouping: false,
  //       supportsUngrouping: false,
  //       ringtonePath: 'system_ringtone_default',
  //     ),
  //   );
  //   await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  // }

  Future<void> addReactionToMessage(String msgId, String reaction) async {
    try {
      await ChatClient.getInstance.chatManager.addReaction(
        messageId: msgId,
        reaction: reaction,
      );
      logInfo("success:");
    } on ChatError catch (error) {
      logInfo("fail: $error");
    }
  }

  Future<void> removeReactionFromMessage(
    String messageId,
    String reaction,
  ) async {
    try {
      await ChatClient.getInstance.chatManager.removeReaction(
        messageId: messageId,
        reaction: reaction,
      );
      logInfo("Reaction removed successfully");
    } on ChatError catch (e) {
      logInfo("Failed to remove reaction: ${e.code} - ${e.description}");
    }
  }

  Route<dynamic>? handleAgoraRoutes(RouteSettings settings) {
    final Widget screen;
    switch (settings.name) {
      case ChatUIKitRouteNames.contactsView:
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("Contacts")),
          body: ContactsView(enableAppBar: false, enableSearchBar: false),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.newRequestsView:
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("New Requests")),
          body: NewRequestsView(enableAppBar: false),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.groupsView:
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("Groups")),
          body: GroupsView(enableAppBar: false),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.messagesView:
        final profile = (settings.arguments as MessagesViewArguments).profile;
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(
            title: profile.showName ?? "",
            actions: Builder(
              builder: (context) {
                final isGroup = profile.type == ChatUIKitProfileType.group;
                if (!isGroup) return SizedBox();
                return InkWell(
                  onTap: () {
                    ChatUIKitRoute.pushOrPushNamed(
                      context,
                      ChatUIKitRouteNames.groupMembersView,
                      GroupMembersViewArguments(profile: profile),
                    );
                  },
                  child: Icon(Icons.group),
                );
              },
            ),
          ),
          body: MessagesView(
            enableAppBar: false,
            profile: profile,
            onMoreActionsItemsHandler: (context, items) {
              items.removeWhere(
                (element) => [
                  ChatUIKitActionType.contactCard,
                  ChatUIKitActionType.file,
                ].contains(element.actionType),
              );
              return items;
            },
          ),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.contactDetailsView:
      case ChatUIKitRouteNames.newRequestDetailsView:
        final profile = settings.arguments is ContactDetailsViewArguments
            ? (settings.arguments as ContactDetailsViewArguments).profile
            : (settings.arguments as NewRequestDetailsViewArguments).profile;
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("Contact Details")),
          body: ContactDetailsView(
            enableAppBar: false,
            actionsBuilder: (context, defaultList) => [
              ChatUIKitDetailContentAction(
                title: ChatUIKitLocal.contactDetailViewSend.localString(
                  context,
                ),
                icon: 'assets/images/chat.png',
                iconSize: const Size(32, 32),
                packageName: ChatUIKitImageLoader.packageName,
                onTap: (context) {
                  ChatUIKitRoute.pushOrPushNamed(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    MessagesViewArguments(profile: profile),
                  );
                },
              ),
            ],
            profile: profile,
          ),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.groupMembersView:
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("Group Members")),
          body: GroupMemberListView(
            enableSearchBar: false,
            onTap: (context, model) => ChatUIKitRoute.pushOrPushNamed(
              context,
              ChatUIKitRouteNames.contactDetailsView,
              ContactDetailsViewArguments(profile: model.profile),
            ),
            groupId:
                (settings.arguments as GroupMembersViewArguments).profile.id,
          ),
        );
        return pageRoute(settings, screen);
      case ChatUIKitRouteNames.groupDetailsView:
        screen = Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: CustomAppBar(title: ("Group Details")),
          body: GroupDetailsView(
            enableAppBar: false,
            profile: (settings.arguments as GroupDetailsViewArguments).profile,
            actionsBuilder: (context, defaultList) => [
              ChatUIKitDetailContentAction(
                title: ChatUIKitLocal.groupDetailViewSend.localString(context),
                icon: 'assets/images/chat.png',
                iconSize: const Size(32, 32),
                packageName: ChatUIKitImageLoader.packageName,
                onTap: (context) {
                  ChatUIKitRoute.pushOrPushNamed(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    MessagesViewArguments(
                      profile: (settings.arguments as GroupDetailsViewArguments)
                          .profile,
                    ),
                  );
                },
              ),
            ],
          ),
        );
        return pageRoute(settings, screen);
    }
    final chatRoute = ChatUIKitRoute.instance.generateRoute(settings);

    if (chatRoute != null) return chatRoute;
    return null;
  }
}

extension AgoraRTMExtension on DataRepository {
  Future<AgoraConfig> generateRTMToken({
    required String username,
    required String avatarUrl,
    required String nickname,
  }) async {
    final response = await Dio().get(
      rtmTokenUrl,
      queryParameters: {
        "username": username,
        "avatarurl": avatarUrl,
        "nickname": nickname,
      },
    );
    return AgoraConfig.fromMap(response.data);
  }
}
