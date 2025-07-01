import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';

import 'player_widget.dart';

class ChatVoiceMessageWidget extends StatelessWidget {
  const ChatVoiceMessageWidget({super.key, required this.chatMessage});

  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {},
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: PlayerWidget(chat: chatMessage),
    );
  }
}
