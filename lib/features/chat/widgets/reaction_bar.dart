import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import '../../../exporter.dart';
import '../../../main.dart';

import '../../../widgets/person_tile.dart';
import '../agora_rtm_service.dart';
import 'bottomsheet_handle.dart';

class ReactionBar extends StatefulWidget {
  final ChatMessage message;
  const ReactionBar({super.key, required this.message});

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  List<ChatMessageReaction> reactions = [];

  @override
  void initState() {
    fetchReactions();
    addReactionEventHandler();
    super.initState();
  }

  @override
  dispose() {
    removeReactionEventHandler();
    super.dispose();
  }

  void fetchReactions() {
    widget.message.reactionList().then((value) {
      reactions = value;
      setState(() {});
    });
  }

  void addReactionEventHandler() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'reaction_event_handler${widget.message.msgId}',
      ChatEventHandler(
        onMessageReactionDidChange: (events) {
          if (events.isEmpty) return;
          final event = events.first;
          if (event.messageId != widget.message.msgId) return;
          fetchReactions();
        },
      ),
    );
  }

  void removeReactionEventHandler() {
    ChatClient.getInstance.chatManager.removeEventHandler(
      'reaction_event_handler${widget.message.msgId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -4),
      child: Builder(
        builder: (context) {
          if (reactions.isEmpty) return SizedBox.shrink();
          return InkWell(
            borderRadius: BorderRadius.circular(middlePadding),
            onTap: () {
              showReactionUsersSheet();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(middlePadding),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.purple.shade100, width: 1.h),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: paddingTiny,
                vertical: paddingTiny,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: reactions.map((r) {
                  final isMine = r.userList.contains(
                    AgoraRTMService.i.currentUser!.userId,
                  );
                  return Row(
                    children: [
                      Text(
                        r.reaction,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isMine
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isMine ? Colors.purple : Colors.black,
                        ),
                      ),
                      gapTiny,
                      if (r.userList.length > 1)
                        Padding(
                          padding: EdgeInsets.only(right: padding),
                          child: Text(
                            r.userList.length.toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void showReactionUsersSheet() async {
    Map<ChatUserInfo, ChatMessageReaction> reactionMap = {};
    final userIds = reactions
        .expand((reaction) => reaction.userList)
        .toSet()
        .toList();
    final userInfos = await ChatClient.getInstance.userInfoManager
        .fetchUserInfoById(userIds);
    for (var reaction in reactions) {
      for (var user in reaction.userList) {
        reactionMap[userInfos[user]!] = reaction;
      }
    }
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final totalReactions = reactions.fold(
          0,
          (sum, reaction) => sum + reaction.userList.length,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            BottomSheetHandle(),
            gapLarge,

            Text(
              ''
              '$totalReactions ${totalReactions == 1 ? 'reaction' : 'reactions'}',
              style: context.bodySmall,
            ),
            Divider(),
            ...reactionMap.entries.map((user) {
              final isMine = user.value.isAddedBySelf;
              return PersonTile(
                onTap: () {
                  if (isMine) {
                    AgoraRTMService.i.removeReactionFromMessage(
                      widget.message.msgId,
                      user.value.reaction,
                    );
                  } else {
                    // navigate(
                    //   navigatorKey.currentContext!,
                    //   AttendeeDetailsScreen.path,
                    //   arguments: int.parse(user.value.userList.first),
                    // );
                    return;
                  }

                  Navigator.pop(context);
                },
                hasDivider: false,
                hasSubTitle: true,
                addMediaUrl: false,
                imageUrl: user.key.avatarUrl,
                name: isMine ? 'You' : user.key.nickName ?? '',
                department: isMine ? 'Tap to remove' : '',
                trailing: Text(
                  user.value.reaction,
                  style: context.bodySmall,
                ),
              );
            }),
            gapXXL,
          ],
        );
      },
    );
  }
}
