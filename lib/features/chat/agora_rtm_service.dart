// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_route.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../services/fcm_service.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/custom_appbar.dart';
import '../profile_screen/common_controller.dart';
import 'agora_rtc_service.dart';
import 'call_screen.dart';
import 'messages_view.dart';

final agoraConfig = AgoraConfig(
  appKey: "411355671#1562187",
  senderId: "774863640399",
  token: "",
  appId: "fba212c248f64309802c8c5f8f5e9172",
);

String publicGroupId = "292656738533378";

String rtmTokenUrl =
    "https://us-central1-eventxpro-66c0b.cloudfunctions.net/generateRtmToken";

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
    await ChatUIKit.instance.init(options: options);
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
    voicecallEnabled = false;
    videocallEnabled = false;
    ChatUIKitTimeFormatter.instance.formatterHandler = (context, type, time) {
      return DateTime.fromMillisecondsSinceEpoch(time).timeFormat;
    };
  }

  Future<void> joinPublicGroup(String groupId) async {
    try {
      await ChatUIKit.instance.joinPublicGroup(groupId: groupId);
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
        "user": CommonController.i.profileDetails!.toMap(),
      });
      await ChatUIKit.instance.updateUserInfo(ext: extension);
      currentUser = ChatUIKitProvider.instance.getProfileById(userid);
      return true;
    } catch (e) {
      if (e is ChatError && e.code == 200) {
        logInfo("login succeed, userId: $userid");
        final extension = jsonEncode({
          "user": CommonController.i.profileDetails!.toJson(),
        });
        await ChatUIKit.instance.updateUserInfo(ext: extension);
        currentUser = ChatUIKitProvider.instance.getProfileById(userid);
        return true;
      }
      logInfo("login failed, userId: $userid, error: $e");
      return false;
    }
  }

  bool get isLoggedIn => ChatUIKit.instance.currentUserId != null;

  void updateFcmToken() {
    if (!isLoggedIn) return;
    FCMService.token.then((value) async {
      logInfo(value);
      if (value?.isEmpty ?? true) return;
      await ChatClient.getInstance.pushManager.updateFCMPushToken(value!);
    });
  }

  Future<bool> signOut() async {
    try {
      await ChatUIKit.instance.logout();
      logInfo("sign out succeed");
      return true;
    } on ChatError catch (e) {
      logInfo("sign out failed, code: ${e.code}, desc: ${e.description}");
      return false;
    }
  }

  ChatUIKitProfile? currentUser;

  Future<ChatMessage?> sendCallStatusCMD({
    required String id,
    required ChatUIKitProfile user,
    required String channel,
    required CmdActionType type,
  }) async {
    final action = jsonEncode({
      "type": type.name,
      "from": user.toMap(),
      "channel": channel,
    });
    var msg = ChatMessage.createCmdSendMessage(
      targetId: id,
      action: action,
      chatType: ChatType.Chat,
      deliverOnlineOnly: true,
    );
    return await ChatUIKit.instance.sendMessage(message: msg);
  }

  Future initiateIncommingCall(RemoteMessage message) async {
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

  Future<void> showCallSheet(
    ChatUIKitProfile user,
    String channel, {
    CallState initialState = CallState.incomingCall,
  }) async {
    AgoraRtcService.i.setArguments(user, channel, initialState);
    navigate(navigatorKey.currentContext!, CallScreen.path, duplicate: false);
  }

  void startCall(ChatUIKitProfile profile) async {
    final channel = "${ChatUIKit.instance.currentUserId ?? ""}-${profile.id}";
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) return;
    showCallSheet(profile, channel, initialState: CallState.outgoingCall);
    if (permission == PermissionStatus.permanentlyDenied) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(
            'Microphone Acces Required',
            style: context.montserrat60016,
          ),
          content: Text(
            'Please enable microphone permission in settings in order to make calls',
            style: context.montserrat40014,
          ),

          actions: <Widget>[
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
                'Open Setttigs',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      );
    }
    if (permission != PermissionStatus.granted) return;

    showCallSheet(profile, channel, initialState: CallState.outgoingCall);
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
        screen = MessagesViewWrapped(profile: profile);
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
                  navigate(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    arguments: MessagesViewArguments(profile: profile),
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
            onTap: (context, model) => navigate(
              context,
              ChatUIKitRouteNames.contactDetailsView,
              arguments: ContactDetailsViewArguments(profile: model.profile),
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
                  navigate(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    arguments: MessagesViewArguments(
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

extension ChatProfileExtension on ChatUIKitProfile {
  Map<String, dynamic> toMap() {
    final data = {
      "id": this.id.toString(),
      "nickname": nickname,
      "avatarUrl": avatarUrl,
      "type": type.name,
      "extension": extension,
    };
    return data;
  }

  static ChatUIKitProfile fromJson(Map<String, dynamic> json) {
    return ChatUIKitProfile.contact(
      id: json["id"].toString(),
      nickname: json["nickname"],
      avatarUrl: json["avatarUrl"],
      extension: json["extension"],
    );
  }
}

bool voicecallEnabled = false;
bool videocallEnabled = false;

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
