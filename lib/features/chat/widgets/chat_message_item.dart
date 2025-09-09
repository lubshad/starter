import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import '../../../exporter.dart';
import '../../../main.dart';
import '../../../widgets/common_sheet.dart';
import '../../../widgets/user_avatar.dart';
import '../agora_rtm_service.dart';
import 'chat_file_message_widget.dart';
import 'chat_image_message_widget.dart';
import 'chat_reactions.dart';
import 'chat_voice_message_widget.dart';
import 'reaction_bar.dart';

class ChatMessageItem extends StatefulWidget {
  const ChatMessageItem({
    super.key,
    required this.item,
    required this.other,
    this.showAvatar = false,
  });

  final ChatMessage item;
  final ChatUserInfo other;
  final bool showAvatar;

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  @override
  initState() {
    if (!widget.item.hasReadAck &&
        widget.item.from != ChatClient.getInstance.currentUserId) {
      ChatClient.getInstance.chatManager.sendMessageReadAck(widget.item);
    }
    super.initState();
  }

  /// Gets the user's selected reaction for a given message
  Future<ChatMessageReaction?> getSelectedReaction(ChatMessage message) async {
    final reactions = await message.reactionList();
    return reactions.firstWhereOrNull((element) => element.isAddedBySelf);
  }

  void showReactionPopup(ChatMessage message) async {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    const verticalGap = padding;

    final selectedReaction = await getSelectedReaction(message);

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => ReactionPopupPositioner(
        selectedReaction: selectedReaction?.reaction,
        bubbleOffset: offset,
        bubbleSize: size,
        verticalGap: verticalGap,
        onEmojiSelected: (emoji) async {
          await onReactionSelected(message, emoji);
          entry?.remove();
        },
        onAddPressed: () async {
          showEmojiPicker();
          entry?.remove();
        },
        onDismiss: () => entry?.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Future<void> onReactionSelected(ChatMessage message, String emoji) async {
    final reactions = await message.reactionList();

    final addedReaction = reactions.firstWhereOrNull(
      (element) => element.isAddedBySelf,
    );

    if (addedReaction != null) {
      logInfo("remove reaction: $emoji");
      await AgoraRTMService.i.removeReactionFromMessage(
        message.msgId,
        addedReaction.reaction,
      );
      if (addedReaction.reaction != emoji) {
        await AgoraRTMService.i.addReactionToMessage(message.msgId, emoji);
      }
    } else {
      logInfo("add reaction successfully: $emoji");
      await AgoraRTMService.i.addReactionToMessage(message.msgId, emoji);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = ChatClient.getInstance.currentUserId == widget.item.from;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe && widget.showAvatar)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
            ).copyWith(bottom: paddingLarge),

            child: UserAvatar(
              size: 35.w,
              imageUrl: widget.other.avatarUrl,
              // addMediaUrl: false,
            ),
          ),
        Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(paddingLarge),
                          onDoubleTap: () => showReactionPopup(widget.item),
                          onLongPress: () => showReactionPopup(widget.item),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 1.sw * .5,
                              minWidth: 80.w,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: padding,
                            ),
                            decoration: BoxDecoration(
                              color: Color(isMe ? 0xFF832FB7 : 0xFFEEEEEE),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(paddingLarge),
                                bottomRight: Radius.circular(
                                  isMe ? 0 : paddingLarge,
                                ),
                                bottomLeft: Radius.circular(
                                  isMe ? paddingLarge : 0,
                                ),
                                topRight: Radius.circular(paddingLarge),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    switch (widget.item.body.type) {
                                      case MessageType.TXT:
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: padding,
                                            horizontal: padding,
                                          ),
                                          child: Text(
                                            (widget.item.body
                                                    as ChatTextMessageBody)
                                                .content,
                                            style: context.bodySmall.copyWith(
                                              color: isMe
                                                  ? Colors.white
                                                  : Color(0xFF505050),
                                            ),
                                          ),
                                        );
                                      case MessageType.IMAGE:
                                        return ChatImageMessageWidget(
                                          chatMessage: widget.item,
                                        );
                                      case MessageType.FILE:
                                        return ChatFileMessageWidget(
                                          chatMessage: widget.item,
                                          color: isMe
                                              ? Colors.white
                                              : Color(0xFF505050),
                                        );
                                      case MessageType.VOICE:
                                        return ChatVoiceMessageWidget(
                                          chat: widget.item,
                                        );
                                      case MessageType.CMD:
                                        final action = jsonDecode(
                                          (widget.item.body
                                                  as ChatCmdMessageBody)
                                              .action,
                                        );
                                        return Text(
                                          action["type"],
                                          style: context.bodySmall.copyWith(
                                            color: isMe
                                                ? Colors.white
                                                : Color(0xFF505050),
                                          ),
                                        );
                                      default:
                                        return Text(
                                          widget.item.body.toString(),
                                          style: context.bodySmall.copyWith(
                                            color: isMe
                                                ? Colors.white
                                                : Color(0xFF505050),
                                          ),
                                        );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: paddingTiny,
                      right: padding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(
                                  widget.item.localTime,
                                ).timeFormat ??
                                "",
                            style: context.bodySmall.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 9.sp,
                              color: isMe ? Colors.white : Color(0xFF505050),
                            ),
                          ),
                          buildTick(widget.item),
                        ],
                      ),
                    ),
                  ],
                ),
                ReactionBar(message: widget.item),
              ],
            ),
          ],
        ),
        if (isMe && widget.showAvatar)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
            ).copyWith(bottom: paddingLarge),
            child: UserAvatar(
              size: 35.w,
              imageUrl: AgoraRTMService.i.currentUser?.avatarUrl,
              // addMediaUrl: false,
            ),
          ),
      ],
    );
  }

  Widget buildTick(ChatMessage message) {
    bool isMe = ChatClient.getInstance.currentUserId == message.from;
    if (!isMe) return SizedBox.shrink();

    if (message.hasReadAck) {
      return Icon(Icons.done_all, color: Colors.blue, size: 16.sp);
    }
    if (message.hasDeliverAck) {
      return Icon(Icons.done_all, color: Colors.grey, size: 16.sp);
    }
    if (message.status == MessageStatus.SUCCESS) {
      return Icon(Icons.done, color: Colors.grey, size: 16.sp);
    }
    if (message.status == MessageStatus.PROGRESS) {
      return Icon(Icons.access_time, color: Colors.grey, size: 16.sp);
    }
    if (message.status == MessageStatus.FAIL) {
      return Icon(Icons.error, color: Colors.red, size: 16.sp);
    }
    return SizedBox.shrink();
  }

  void showEmojiPicker() async {
    final selectedReaction = await getSelectedReaction(widget.item);

    await showModalBottomSheet(
      context: navigatorKey.currentContext!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommonBottomSheet(
        popButton: SizedBox.shrink(),
        // headerWidget: BottomSheetHandle(),
        child: GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          children: commonEmojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                onReactionSelected(widget.item, emoji);
                Navigator.pop(context);
              },
              child: Center(
                child: selectedReaction?.reaction == emoji
                    ? Container(
                        padding: EdgeInsets.all(paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
                      )
                    : Text(emoji, style: TextStyle(fontSize: 28.sp)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
