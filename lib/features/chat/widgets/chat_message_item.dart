// import 'dart:convert';
// import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../exporter.dart';
// import '../../../main.dart';
// import '../../../mixins/event_listener.dart';
// import '../../../widgets/common_sheet.dart';
// import '../../../widgets/user_avatar.dart';
// import '../agora_rtm_service.dart';
// import 'chat_bottom_bar.dart';
// import 'chat_file_message_widget.dart';
// import 'chat_image_message_widget.dart';
// import 'chat_reactions.dart';
// import 'chat_voice_message_widget.dart';
// import 'reaction_bar.dart';
// import 'reply_message_widget.dart';

// class ChatMessageItem extends StatefulWidget {
//   const ChatMessageItem({
//     super.key,
//     required this.item,
//     required this.other,
//     this.showAvatar = false,
//     this.onScrollToMessage,
//   });

//   final ChatMessage item;
//   final ChatUserInfo other;
//   final bool showAvatar;
//   final Function(String messageId)? onScrollToMessage;

//   @override
//   State<ChatMessageItem> createState() => ChatMessageItemState();
// }

// class ChatMessageItemState extends State<ChatMessageItem>
//     with TickerProviderStateMixin {
//   late final GlobalKey _messageBubbleKey = GlobalKey(
//     debugLabel: widget.item.msgId,
//   );
//   final ValueNotifier<bool> shouldHighlight = ValueNotifier(false);

//   @override
//   initState() {
//     if (!widget.item.hasReadAck &&
//         widget.item.from != ChatClient.getInstance.currentUserId) {
//       if (widget.item.chatType == ChatType.GroupChat) {
//         ChatClient.getInstance.chatManager.sendGroupMessageReadAck(
//           widget.item.msgId,
//           widget.item.conversationId!,
//         );
//       } else {
//         ChatClient.getInstance.chatManager.sendMessageReadAck(widget.item);
//       }
//     }
//     if (!widget.item.hasReadAck &&
//         widget.item.from != ChatClient.getInstance.currentUserId) {
//       if (widget.item.chatType == ChatType.GroupChat) {
//         ChatClient.getInstance.chatManager.sendGroupMessageReadAck(
//           widget.item.msgId,
//           widget.item.conversationId!,
//         );
//       } else {
//         ChatClient.getInstance.chatManager.sendMessageReadAck(widget.item);
//       }
//     }

//     super.initState();
//   }

//   void _scrollToRepliedMessage(String messageId) {
//     if (widget.onScrollToMessage != null) {
//       widget.onScrollToMessage!(messageId);
//       HapticFeedback.lightImpact();
//     }
//   }

//   void highlightMessage() {
//     shouldHighlight.value = true;

//     Future.delayed(Duration(milliseconds: 1500), () {
//       if (mounted) {
//         shouldHighlight.value = false;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     shouldHighlight.dispose();
//     super.dispose();
//   }

//   Future<ChatMessageReaction?> getSelectedReaction(ChatMessage message) async {
//     final reactions = await message.reactionList();
//     return reactions.firstWhereOrNull((element) => element.isAddedBySelf);
//   }

//   void showReactionPopup(ChatMessage message, Offset tapPosition) async {
//     final overlay = Overlay.of(context);
//     final size = Size.zero;
//     const verticalGap = padding;

//     final selectedReaction = await getSelectedReaction(message);

//     OverlayEntry? entry;
//     entry = OverlayEntry(
//       builder: (context) => ReactionPopupPositioner(
//         selectedReaction: selectedReaction?.reaction,
//         bubbleOffset: tapPosition,
//         bubbleSize: size,
//         verticalGap: verticalGap,
//         onEmojiSelected: (emoji) async {
//           await onReactionSelected(message, emoji);
//           entry?.remove();
//         },
//         onAddPressed: () async {
//           showEmojiPicker();
//           entry?.remove();
//         },
//         onDismiss: () => entry?.remove(),
//       ),
//     );
//     overlay.insert(entry);
//   }

//   Future<void> onReactionSelected(ChatMessage message, String emoji) async {
//     final reactions = await message.reactionList();

//     final addedReaction = reactions.firstWhereOrNull(
//       (element) => element.isAddedBySelf,
//     );

//     if (addedReaction != null) {
//       logInfo("remove reaction: $emoji");
//       await AgoraRTMService.i.removeReactionFromMessage(
//         message.msgId,
//         addedReaction.reaction,
//       );
//       if (addedReaction.reaction != emoji) {
//         await AgoraRTMService.i.addReactionToMessage(message.msgId, emoji);
//       }
//     } else {
//       logInfo("add reaction successfully: $emoji");
//       await AgoraRTMService.i.addReactionToMessage(message.msgId, emoji);
//     }
//   }

//   double maxWidth(MessageType messageType) {
//     switch (messageType) {
//       case MessageType.TXT:
//       case MessageType.IMAGE:
//         return ScreenUtil().screenWidth * .7;
//       case MessageType.VOICE:
//         return ScreenUtil().screenWidth * .7;
//       case MessageType.CMD:
//       case MessageType.FILE:
//         return ScreenUtil().screenWidth * .6;
//       default:
//         return ScreenUtil().screenWidth * .5;
//     }
//   }

//   void replyToMessage() {
//     bool isMe = ChatClient.getInstance.currentUserId == widget.item.from;
//     final senderInfo = isMe ? AgoraRTMService.i.currentUser! : widget.other;

//     final replyData = ReplyMessageData.fromChatMessage(widget.item, senderInfo);

//     repliedText.value = jsonEncode({
//       'reply_to_msg_id': replyData.messageId,
//       'reply_to_content': replyData.content,
//       'reply_to_sender': replyData.senderName,
//       'reply_to_type': replyData.messageType.name,
//     });

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMe = ChatClient.getInstance.currentUserId == widget.item.from;
//     final replyData = ReplyMessageData.fromMessageAttributes(
//       widget.item.attributes,
//     );
//     return ValueListenableBuilder(
//       valueListenable: shouldHighlight,
//       builder: (context, value, child) {
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: isMe
//               ? MainAxisAlignment.end
//               : MainAxisAlignment.start,
//           children: [
//             if (!isMe && widget.showAvatar)
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: padding,
//                 ).copyWith(bottom: paddingLarge),

//                 child: UserAvatar(
//                   size: 35.h,
//                   imageUrl: widget.other.avatarUrl,
//                   addMediaUrl: false,
//                 ),
//               ),
//             Column(
//               crossAxisAlignment: isMe
//                   ? CrossAxisAlignment.end
//                   : CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: isMe
//                       ? CrossAxisAlignment.end
//                       : CrossAxisAlignment.start,
//                   children: [
//                     Stack(
//                       children: [
//                         Builder(
//                           builder: (context) {
//                             return GestureDetector(
//                               key: _messageBubbleKey,
//                               onDoubleTapDown: (details) {
//                                 HapticFeedback.lightImpact();
//                                 final tapPosition = details.globalPosition;
//                                 showReactionPopup(widget.item, tapPosition);
//                               },
//                               onLongPressStart: (details) {
//                                 HapticFeedback.lightImpact();
//                                 showMessageOptions();
//                               },
//                               child: AnimatedContainer(
//                                 duration: Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                                 constraints: BoxConstraints(
//                                   maxWidth: maxWidth(widget.item.body.type),
//                                   minWidth: 80.h,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: padding,
//                                   vertical: padding,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Color(
//                                     isMe ? 0xFF832FB7 : 0xFFEEEEEE,
//                                   ).withAlpha(value ? 0.3.alpha : 1.0.alpha),
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(paddingLarge),
//                                     bottomRight: Radius.circular(
//                                       isMe ? 0 : paddingLarge,
//                                     ),
//                                     bottomLeft: Radius.circular(
//                                       isMe ? paddingLarge : 0,
//                                     ),
//                                     topRight: Radius.circular(paddingLarge),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (replyData != null)
//                                       ReplyMessageWidget(
//                                         replyData: replyData,
//                                         isMe: isMe,
//                                         onTap: () => _scrollToRepliedMessage(
//                                           replyData.messageId,
//                                         ),
//                                       ),
//                                     Builder(
//                                       builder: (context) {
//                                         switch (widget.item.body.type) {
//                                           case MessageType.TXT:
//                                             return Padding(
//                                               padding: EdgeInsets.symmetric(
//                                                 vertical: padding,
//                                                 horizontal: padding,
//                                               ),
//                                               child: Text(
//                                                 (widget.item.body
//                                                         as ChatTextMessageBody)
//                                                     .content,
//                                                 style: context.bodySmall
//                                                     .copyWith(
//                                                       color: isMe
//                                                           ? Colors.white
//                                                           : Color(0xFF505050),
//                                                     ),
//                                               ),
//                                             );
//                                           case MessageType.IMAGE:
//                                             return ChatImageMessageWidget(
//                                               chatMessage: widget.item,
//                                             );
//                                           case MessageType.FILE:
//                                             return ChatFileMessageWidget(
//                                               chatMessage: widget.item,
//                                               color: isMe
//                                                   ? Colors.white
//                                                   : Color(0xFF505050),
//                                             );
//                                           case MessageType.VOICE:
//                                             return ChatVoiceMessageWidget(
//                                               chat: widget.item,
//                                             );
//                                           case MessageType.CMD:
//                                             final action = jsonDecode(
//                                               (widget.item.body
//                                                       as ChatCmdMessageBody)
//                                                   .action,
//                                             );
//                                             return Text(
//                                               action["type"],
//                                               style: context.bodySmall.copyWith(
//                                                 color: isMe
//                                                     ? Colors.white
//                                                     : Color(0xFF505050),
//                                               ),
//                                             );
//                                           default:
//                                             return Text(
//                                               widget.item.body.toString(),
//                                               style: context.bodySmall.copyWith(
//                                                 color: isMe
//                                                     ? Colors.white
//                                                     : Color(0xFF505050),
//                                               ),
//                                             );
//                                         }
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         Positioned(
//                           bottom: paddingTiny,
//                           right: padding,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Text(
//                                 DateTime.fromMillisecondsSinceEpoch(
//                                       widget.item.localTime,
//                                     ).timeFormat ??
//                                     "",
//                                 style: context.bodySmall.copyWith(
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 9.sp,
//                                   color: isMe
//                                       ? Colors.white
//                                       : Color(0xFF505050),
//                                 ),
//                               ),
//                               buildTick(widget.item),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     ReactionBar(
//                       message: widget.item,
//                       ontap: () {
//                         showEmojiPicker();
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             if (isMe && widget.showAvatar)
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: padding,
//                 ).copyWith(bottom: paddingLarge),
//                 child: UserAvatar(
//                   size: 35.h,
//                   imageUrl: AgoraRTMService.i.currentUser?.avatarUrl,
//                   addMediaUrl: false,
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildTick(ChatMessage message) {
//     bool isMe = ChatClient.getInstance.currentUserId == message.from;
//     if (!isMe) return SizedBox.shrink();

//     if (message.hasReadAck) {
//       return Icon(Icons.done_all, color: Colors.blue, size: 16.sp);
//     }
//     if (message.hasDeliverAck) {
//       return Icon(Icons.done_all, color: Colors.grey, size: 16.sp);
//     }
//     if (message.status == MessageStatus.SUCCESS) {
//       return Icon(Icons.done, color: Colors.grey, size: 16.sp);
//     }
//     if (message.status == MessageStatus.PROGRESS) {
//       return Icon(Icons.access_time, color: Colors.grey, size: 16.sp);
//     }
//     if (message.status == MessageStatus.FAIL) {
//       return Icon(Icons.error, color: Colors.red, size: 16.sp);
//     }
//     return SizedBox.shrink();
//   }

//   void showEmojiPicker() async {
//     final selectedReaction = await getSelectedReaction(widget.item);

//     await showModalBottomSheet(
//       context: navigatorKey.currentContext!,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => CommonBottomSheet(
//         headerWidget: BottomSheetHandle(),

//         popButton: SizedBox.shrink(),
//         child: GridView.count(
//           crossAxisCount: 6,
//           shrinkWrap: true,
//           children: commonEmojis.map((emoji) {
//             return GestureDetector(
//               onTap: () {
//                 onReactionSelected(widget.item, emoji);
//                 Navigator.pop(context);
//               },
//               child: Center(
//                 child: selectedReaction?.reaction == emoji
//                     ? Container(
//                         padding: EdgeInsets.all(paddingSmall),
//                         decoration: BoxDecoration(
//                           color: Colors.purple.shade50,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
//                       )
//                     : Text(emoji, style: TextStyle(fontSize: 28.sp)),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   void showMessageOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => CommonBottomSheet(
//         headerWidget: BottomSheetHandle(),
//         popButton: SizedBox.shrink(),
//         child: Column(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.reply),
//               title: const Text('Reply'),
//               onTap: () => replyToMessage(),
//             ),
//             Visibility(
//               visible: widget.item.body.type == MessageType.TXT,
//               child: ListTile(
//                 leading: const Icon(Icons.copy),
//                 title: const Text('Copy'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   String textToCopy = '';
//                   if (widget.item.body.type == MessageType.TXT) {
//                     textToCopy =
//                         (widget.item.body as ChatTextMessageBody).content;
//                   }
//                   await Clipboard.setData(ClipboardData(text: textToCopy));
//                 },
//               ),
//             ),
//             Visibility(
//               visible: canDeleteMessage(),
//               child: ListTile(
//                 leading: const Icon(Icons.delete),
//                 title: const Text('Delete'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Delete Message'),
//                       content: const Text(
//                         'Are you sure you want to delete this message',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () {},
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () async {
//                             Navigator.pop(context);
//                             ChatClient.getInstance.chatManager
//                                 .recallMessage(widget.item.msgId)
//                                 .then((value) {
//                                   return EventListener.i.sendEvent(
//                                     Event(
//                                       eventType: EventType.chatDeleted,
//                                       data: widget.item,
//                                     ),
//                                   );
//                                 });
//                           },
//                           child: const Text('Delete'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   bool canDeleteMessage() {
//     final isMe = ChatClient.getInstance.currentUserId == widget.item.from;
//     final serverTimeMillis = widget.item.serverTime;
//     final serverTime = DateTime.fromMillisecondsSinceEpoch(serverTimeMillis);
//     final now = DateTime.now();
//     final difference = now.difference(serverTime);
//     final isWithin2Min = difference.inMinutes < 2;
//     return isMe && isWithin2Min;
//   }
// }
