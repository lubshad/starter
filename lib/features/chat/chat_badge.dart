import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:starter/theme/theme.dart';

class ChatBadge extends StatefulWidget {
  const ChatBadge({super.key});

  @override
  State<ChatBadge> createState() => _ChatBadgeState();
}

class _ChatBadgeState extends State<ChatBadge> with ChatObserver {
  int unreadMessageCount = 0;

  @override
  void initState() {
    ChatUIKit.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    ChatUIKit.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> showUnreadMessageCount() async {
    final count = await ChatUIKit.instance.getUnreadMessageCount();
    setState(() {
      unreadMessageCount = count;
    });
  }

  @override
  void onMessagesReceived(List<ChatMessage> messages) {
    super.onMessagesReceived(messages);
    showUnreadMessageCount();
  }

  @override
  void onMessagesRead(List<Message> messages) {
    super.onMessagesRead(messages);
    showUnreadMessageCount();
  }

  @override
  Widget build(BuildContext context) {
    if (unreadMessageCount == 0) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 1, 4, 2),
      constraints: const BoxConstraints(minWidth: 20, maxHeight: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        unreadMessageCount > 99 ? '99+' : unreadMessageCount.toString(),
        style: context.kanit40008.copyWith(color: Colors.white),
      ),
    );
  }
}
