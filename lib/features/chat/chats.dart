import 'dart:convert';

import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:starter/core/app_route.dart';
import 'package:starter/mixins/event_listener.dart';
import '../../main.dart';
import '../../services/fcm_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/default_loading_widget.dart';
import '../profile_screen/common_controller.dart';
import 'agora_rtm_service.dart';
import 'user_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const String path = "/chat-page";

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with ChatSDKEventsObserver, EventListenerMixin, ChatObserver {
  List<ChatUIKitProfile> joinedGroups = [];

  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    ChatUIKit.instance.addObserver(this);
    initiateChat();

    allowedEvents = [EventType.inactive, EventType.resumed];

    listenForEvents((event) {
      if (event.eventType == EventType.inactive) {
        appLifecycleState = AppLifecycleState.inactive;
        ChatUIKit.instance.publishPresence('Offline');
      } else if (event.eventType == EventType.resumed) {
        appLifecycleState = AppLifecycleState.resumed;
        ChatUIKit.instance.publishPresence('Online');
      }
    });
  }

  @override
  void onCmdMessagesReceived(List<ChatMessage> messages) {
    super.onCmdMessagesReceived(messages);
    if (messages.first.body.type != MessageType.CMD) return;
    final messageBody = messages.first.body as ChatCmdMessageBody;
    final action = jsonDecode(messageBody.action) as Map<String, dynamic>;
    CmdActionType actionType = CmdActionType.fromValue(action["type"]);

    switch (actionType) {
      case CmdActionType.startCalling:
        final fromUser = ChatProfileExtension.fromJson(action["from"]);
        final channel = action["channel"];
        if (appLifecycleState == AppLifecycleState.inactive) {
          AgoraRTMService.i.initiateIncommingCall(
            RemoteMessage(
              data: {
                "e": jsonEncode({
                  "from": fromUser.toMap(),
                  "channel": channel,
                  "type": CmdActionType.startCalling.name,
                }),
              },
            ),
          );
        } else {
          AgoraRTMService.i.showCallSheet(fromUser, channel);
        }
        break;
      case CmdActionType.endCalling:
        FlutterCallkitIncoming.endAllCalls();
        break;
      default:
    }
  }

  @override
  void onMessagesReceived(List<ChatMessage> messages) async {
    super.onMessagesReceived(messages);
    if (messages.first.body.type == MessageType.CMD) return;
    final userinfo = (await ChatUIKit.instance.fetchUserInfoByIds([
      messages.first.from!,
    ])).values.first;

    if (simpleRouteObserver.currentRouteName != ChatUIKitRouteNames.messagesView) {
      await FCMService().showNotification(
        title: userinfo.nickName,
        body: (messages.first.body as ChatTextMessageBody).content,
      );
    }
  }

  // @override
  // void onChatUIKitEventsReceived(ChatUIKitEvent event) {
  //   super.onChatUIKitEventsReceived(event);
  //   debugPrint(event.toString());
  // }

  ValueNotifier<bool> loading = ValueNotifier(true);

  @override
  void onChatSDKEventEnd(ChatSDKEvent event, ChatError? error) {
    super.onChatSDKEventEnd(event, error);
    if (event == ChatSDKEvent.loginWithToken) {
      loading.value = false;
      AgoraRTMService.i.updateFcmToken();
      ChatUIKit.instance.publishPresence('Online');
      // initiatePublicGroup();
    }
  }

  @override
  void dispose() {
    ChatUIKit.instance.removeObserver(this);
    ChatUIKit.instance.publishPresence('Offline');
    disposeEventListener();
    super.dispose();
  }

  void initiateChat() async {
    while (!CommonController.i.initialized) {
      await Future.delayed(const Duration(seconds: 1));
    }

    await AgoraRTMService.i.signIn(
      userid: CommonController.i.profileDetails?.id ?? "",
      avatarUrl: CommonController.i.profileDetails?.image ?? "",
      name: CommonController.i.profileDetails?.name ?? "",
    );
  }

  void initiatePublicGroup() async {
    joinedGroups.clear();
    ChatUIKit.instance.fetchJoinedGroups().then((groups) async {
      if (groups.isEmpty) {
        await ChatUIKit.instance.joinPublicGroup(groupId: publicGroupId);
        initiatePublicGroup();
      } else {
        final conversations = (await ChatUIKit.instance.getAllConversations())
            .map((e) => e.id);
        for (var groupInfo in groups) {
          if (conversations.contains(groupInfo.groupId)) continue;

          joinedGroups.add(
            ChatUIKitProvider.instance.getProfileById(groupInfo.groupId) ??
                ChatUIKitProfile.group(
                  id: groupInfo.groupId,
                  groupName: groupInfo.name,
                  avatarUrl:
                      jsonDecode(groupInfo.extension ?? "{}")["groupIcon"] ??
                      "",
                ),
          );
        }
        if (joinedGroups.isNotEmpty) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "Chats"),
      body: Builder(
        builder: (context) {
          return ValueListenableBuilder(
            valueListenable: loading,
            builder: (context, value, child) {
              if (value) {
                return LoadingWidget();
              }
              return UserProviderWidget(
                child: ConversationsView(
                  beforeWidgets: joinedGroups
                      .map(
                        (e) => InkWell(
                          onTap: () {
                            navigate(
                              navigatorKey.currentContext!,
                              ChatUIKitRouteNames.groupDetailsView,
                              arguments: GroupDetailsViewArguments(profile: e),
                            );
                          },
                          child: ChatUIKitGroupListViewItem(
                            GroupItemModel(profile: e),
                          ),
                        ),
                      )
                      .toList(),
                  enableSearchBar: false,
                  onItemTap: (context, model) {
                    navigate(
                      navigatorKey.currentContext!,
                      ChatUIKitRouteNames.messagesView,
                      arguments: MessagesViewArguments(profile: model.profile),
                    );
                  },
                  enableAppBar: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
