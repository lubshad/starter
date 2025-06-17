import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:starter/features/chat/agora_utils.dart';

import '../../../exporter.dart';
import '../../../widgets/user_avatar.dart';

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({super.key, required this.item, required this.other});

  final ChatMessage item;
  final ChatUserInfo other;

  @override
  Widget build(BuildContext context) {

    bool isMe = ChatClient.getInstance.currentUserId == item.from;
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe) Gap(paddingLarge * 1.5),
            if (!isMe) UserAvatar(size: 25.h, imageUrl: other.avatarUrl),
            Container(
              constraints: BoxConstraints(maxWidth: SizeUtils.width * .6),
              margin: EdgeInsets.only(
                right: isMe ? 8 : 50,
                left: isMe ? 50 : 8,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: padding,
              ),
              decoration: BoxDecoration(
                color: Color(isMe ? 0xFF832FB7 : 0xFFEEEEEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(paddingLarge),
                  bottomRight: Radius.circular(isMe ? 0 : paddingLarge),
                  bottomLeft: Radius.circular(isMe ? paddingLarge : 0),
                  topRight: Radius.circular(paddingLarge),
                ),
              ),
              child: Builder(
                builder: (context) {
                  switch (item.body.type) {
                    case MessageType.TXT:
                      return Text(
                        (item.body as ChatTextMessageBody).content,
                        style: context.bodySmall.copyWith(
                          color: isMe ? Colors.white : Color(0xFF505050),
                        ),
                      );
                    case MessageType.IMAGE:
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(padding),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          imageUrl:
                              (item.body as ChatImageMessageBody)
                                  .thumbnailRemotePath ??
                              "",
                        ),
                      );
                    case MessageType.FILE:
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.file_present_outlined,
                          color: isMe ? Colors.white : Color(0xFF505050),
                        ),
                        dense: true,
                        title: Text(
                          (item.body as ChatFileMessageBody).displayName ?? "",
                          style: TextStyle(
                            color: isMe ? Colors.white : Color(0xFF505050),
                          ),
                        ),
                      );
                    default:
                      return Text(
                        item.body.toString(),
                        style: context.bodySmall.copyWith(
                          color: isMe ? Colors.white : Color(0xFF505050),
                        ),
                      );
                  }
                },
              ),
            ),
            if (isMe)
              UserAvatar(
                size: 25.h,
                imageUrl: AgoraUtils.i.currentUser?.avatarUrl,
              ),
            Gap(paddingLarge * 1.5),
          ],
        ),
        gapSmall,
        Padding(
          padding: EdgeInsets.only(
            right: isMe ? paddingXL * 1.2 : 0,
            left: isMe ? 0 : paddingXL * 1.2,
          ),
          child: Align(
            alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Text(
              DateTime.fromMillisecondsSinceEpoch(item.localTime).timeFormat ??
                  "",
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 9.fSize,
                color: Color(0xFF505050),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
