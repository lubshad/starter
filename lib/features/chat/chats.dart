import 'dart:convert';

import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
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

class _ChatPageState extends State<ChatPage> with ChatSDKEventsObserver {
  List<ChatUIKitProfile> joinedGroups = [];
  @override
  void initState() {
    super.initState();
    ChatUIKit.instance.addObserver(this);
    initiateChat();
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
      // initiatePublicGroup();
    }
  }

  @override
  void dispose() {
    ChatUIKit.instance.removeObserver(this);
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
                            ChatUIKitRoute.pushOrPushNamed(
                              navigatorKey.currentContext!,
                              ChatUIKitRouteNames.groupDetailsView,
                              GroupDetailsViewArguments(profile: e),
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
                    ChatUIKitRoute.pushOrPushNamed(
                      navigatorKey.currentContext!,
                      ChatUIKitRouteNames.messagesView,
                      MessagesViewArguments(profile: model.profile),
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
