import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatFileMessageWidget extends StatelessWidget {
  const ChatFileMessageWidget({
    super.key,
    required this.chatMessage,
    required this.color,
  });

  final ChatMessage chatMessage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    ChatFileMessageBody message = chatMessage.body as ChatFileMessageBody;
    return ListTile(
      onTap: () async {
        if (message.remotePath == null) {
          await OpenFilex.open(message.localPath);
        } else {
          launchUrl(Uri.parse(message.remotePath!));
        }
      },
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.file_present_outlined, color: color),
      dense: true,
      title: Text(message.displayName ?? "", style: TextStyle(color: color)),
    );
  }
}
