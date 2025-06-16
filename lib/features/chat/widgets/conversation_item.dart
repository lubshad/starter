import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:starter/exporter.dart';
import 'package:starter/features/chat/chat_screen.dart';
import 'package:starter/widgets/network_resource.dart';
import 'package:starter/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart';
import '../../../core/app_route.dart';

class ConversationItem extends StatelessWidget {
  const ConversationItem({super.key, required this.item});

  final ChatConversation item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        navigate(context, ChatScreen.path, arguments: item);
      },
      leading: NetworkResource(
        ChatClient.getInstance.userInfoManager.fetchUserInfoById([item.id]),
        loading: UserAvatar(imageUrl: "", size: 42.h),
        error: (error) => UserAvatar(imageUrl: "", size: 42.h),
        success: (userinfo) => UserAvatar(
          imageUrl: userinfo.values.first.avatarUrl ?? "",
          size: 42.h,
          username: userinfo.values.first.nickName ?? "",
        ),
      ),
      title: NetworkResource(
        ChatClient.getInstance.userInfoManager.fetchUserInfoById([item.id]),
        loading: SizedBox(),
        error: (error) => SizedBox(),
        success: (userinfo) => Text(
          userinfo.values.first.nickName ?? "",
          style: context.roboto50016,
        ),
      ),
      subtitle: lastMessageBuilder(context, item),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NetworkResource(
            item.latestMessage(),
            loading: SizedBox(),

            error: (error) => SizedBox(),
            success: (lastMessage) {
              if (lastMessage == null) return SizedBox();
              return Text(
                format(
                  DateTime.fromMillisecondsSinceEpoch(lastMessage.localTime),
                ),
                style: context.roboto40013,
              );
            },
          ),
          NetworkResource(
            item.messagesCount(),
            error: (error) => SizedBox(),
            loading: SizedBox(),
            success: (count) => Visibility(
              visible: count > 0,
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
                        count.toString(),
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
          ),
        ],
      ),
    );
  }

  Widget lastMessageBuilder(BuildContext context, ChatConversation convo) {
    return NetworkResource(
      convo.latestMessage(),
      loading: SizedBox(),
      error: (p0) => SizedBox(),
      success: (ChatMessage? message) {
        if (message == null) return SizedBox();
        switch (message.body.type) {
          case MessageType.TXT:
            return Text(
              (message.body as ChatTextMessageBody).content,
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
                    (message.body as ChatFileMessageBody).displayName ?? "",
                    style: context.roboto40013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          default:
            return Text(
              message.body.toString(),
              style: context.roboto40013,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
        }
      },
    );
  }
}
