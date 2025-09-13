import 'dart:convert';

import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:starter/widgets/person_tile.dart';
import 'package:timeago/timeago.dart';
import '../../../core/app_route.dart';
import '../../../main.dart';
import '../../../widgets/user_avatar.dart';
import '../chat_screen.dart';
import '../models/conversation_model.dart';
import '../../../exporter.dart';

class ConversationItem extends StatelessWidget {
  const ConversationItem({super.key, required this.item});

  final ConversationModel item;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: item.conversation.type == ChatConversationType.Chat
          ? ChatClient.getInstance.userInfoManager.fetchUserInfoById([
              item.conversation.id,
            ])
          : ChatClient.getInstance.groupManager.fetchGroupInfoFromServer(
              item.conversation.id,
            ),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return PersonListingTileShimmer();
        }
        final imageUrl = asyncSnapshot.data is Map<String, ChatUserInfo>
            ? (asyncSnapshot.data as Map<String, ChatUserInfo>)
                  .values
                  .first
                  .avatarUrl
            : jsonDecode(
                    (asyncSnapshot.data as ChatGroup).extension ?? "{}",
                  )["groupIcon"] ??
                  "";
        final name = asyncSnapshot.data is Map<String, ChatUserInfo>
            ? (asyncSnapshot.data as Map<String, ChatUserInfo>)
                  .values
                  .first
                  .nickName
            : (asyncSnapshot.data as ChatGroup).name;
        return ListTile(
          onTap: () {
            navigate(
              navigatorKey.currentContext!,
              ChatScreen.path,
              arguments: ChatScreenArg(
                id: item.conversation.id,
                type: item.conversation.type,
              ),
            );
          },
          leading: UserAvatar(
            imageUrl: imageUrl,
            size: 42.h,
            username: name ?? "",
            addMediaUrl: false,
          ),
          title: AutoSizeText(
            name ?? "",
            style: context.montserrat50017,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: lastMessageBuilder(context, item),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(
                builder: (context) {
                  if (item.latestMessage == null) return SizedBox();
                  return Text(
                    format(
                      DateTime.fromMillisecondsSinceEpoch(
                        item.latestMessage!.localTime,
                      ),
                    ),
                    style: context.montserrat40013,
                  );
                },
              ),
              Visibility(
                visible: item.unreadCount > 0,
                child: Padding(
                  padding: EdgeInsets.all(paddingTiny),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingSmall,
                      vertical: paddingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          item.unreadCount.toString(),
                          style: context.montserrat40013.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget lastMessageBuilder(BuildContext context, ConversationModel convo) {
    return Builder(
      builder: (context) {
        if (convo.latestMessage == null) return SizedBox();
        switch (convo.latestMessage!.body.type) {
          case MessageType.TXT:
            return Text(
              (convo.latestMessage!.body as ChatTextMessageBody).content,
              style: context.montserrat40013,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          case MessageType.FILE:
            return Row(
              children: [
                Icon(Icons.attachment, color: Color(0xff9A9BB1)),
                gap,
                Expanded(
                  child: AutoSizeText(
                    (convo.latestMessage!.body as ChatFileMessageBody)
                            .displayName ??
                        "",
                    style: context.montserrat40013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          case MessageType.IMAGE:
            return Row(
              children: [
                Icon(Icons.image, color: Color(0xff9A9BB1)),
                gap,
                Expanded(
                  child: AutoSizeText(
                    (convo.latestMessage!.body as ChatFileMessageBody)
                            .displayName ??
                        "",
                    style: context.montserrat40013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          case MessageType.VOICE:
            return Row(
              children: [
                Icon(Icons.voice_chat, color: Color(0xff9A9BB1)),
                gap,
                Expanded(
                  child: AutoSizeText(
                    "${(convo.latestMessage!.body as ChatVoiceMessageBody).duration} Seconds",
                    style: context.montserrat40013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          default:
            return Text(
              convo.latestMessage!.body.toString(),
              style: context.montserrat40013,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
        }
      },
    );
  }
}
