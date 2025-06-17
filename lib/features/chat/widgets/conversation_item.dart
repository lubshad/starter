import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:starter/exporter.dart';
import 'package:starter/features/chat/chat_listing.dart';
import 'package:starter/features/chat/chat_screen.dart';
import 'package:starter/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart';
import '../../../core/app_route.dart';

class ConversationItem extends StatelessWidget {
  const ConversationItem({super.key, required this.item});

  final ConversationModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        navigate(context, ChatScreen.path, arguments: item);
      },
      leading: UserAvatar(
        imageUrl: item.user.avatarUrl ?? "",
        size: 42.h,
        username: item.user.nickName ?? "",
      ),
      title: Text(item.user.nickName ?? "", style: context.roboto50016),
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
                style: context.roboto40013,
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
                  color: iconbgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      item.unreadCount.toString(),
                      style: context.roboto40013.copyWith(
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
  }

  Widget lastMessageBuilder(BuildContext context, ConversationModel convo) {
    return Builder(
      builder: (context) {
        if (convo.latestMessage == null) return SizedBox();
        switch (convo.latestMessage!.body.type) {
          case MessageType.TXT:
            return Text(
              (convo.latestMessage!.body as ChatTextMessageBody).content,
              style: context.roboto40013,
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
                    style: context.roboto40013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          default:
            return Text(
              convo.latestMessage!.body.toString(),
              style: context.roboto40013,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
        }
      },
    );
  }
}
