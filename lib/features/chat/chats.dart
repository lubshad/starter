import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:starter/features/chat/agora_rtm_service.dart';
import 'package:starter/features/chat/user_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const String path = "/chat-page";

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatUIKitProfile> joinedGroups = [];
  @override
  void initState() {
    super.initState();
    ChatUIKit.instance.fetchPublicGroups().then((groups) async {
      if (groups.data.isEmpty) {
        ChatUIKit.instance.joinPublicGroup(groupId: publicGroupId);
      } else {
        final conversations = (await ChatUIKit.instance.getAllConversations())
            .map((e) => e.id);
        for (var groupInfo in groups.data) {
          if (conversations.contains(groupInfo.groupId)) continue;
          final group = await ChatUIKit.instance.fetchGroupInfo(
            groupId: groupInfo.groupId,
          );
          joinedGroups.add(
            ChatUIKitProvider.instance.getProfileById(groupInfo.groupId) ??
                ChatUIKitProfile.group(
                  id: groupInfo.groupId,
                  groupName: groupInfo.name,
                  avatarUrl: group.extension,
                ),
          );
        }
        if (joinedGroups.isNotEmpty) setState(() {});
      }
    });
    AgoraRTMService.i.updateFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return UserProviderWidget(
      child: ConversationsView(
        afterWidgets: joinedGroups
            .map(
              (e) => InkWell(
                onTap: () {
                  ChatUIKitRoute.pushOrPushNamed(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    MessagesViewArguments(profile: e),
                  );
                },
                child: ChatUIKitGroupListViewItem(GroupItemModel(profile: e)),
              ),
            )
            .toList(),
        enableSearchBar: false,
        appBarModel: ChatUIKitAppBarModel(
          leadingActions: [],
          showBackButton: false,
          trailingActions: [
            ChatUIKitAppBarAction(
              actionType: ChatUIKitActionType.contactCard,
              onTap: (context) {
                ChatUIKitRoute.pushOrPushNamed(
                  context,
                  ChatUIKitRouteNames.contactsView,
                  ContactsViewArguments(
                    appBarModel: ChatUIKitAppBarModel(
                      leadingActions: [],
                      trailingActions: [],
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Icon(Icons.group),
                  if (ChatUIKit.instance.contactRequestCount() > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
