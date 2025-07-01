import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatImageMessageWidget extends StatelessWidget {
  const ChatImageMessageWidget({super.key, required this.chatMessage});
  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    ChatImageMessageBody message = chatMessage.body as ChatImageMessageBody;
    final thumbWidget = message.remotePath == null
        ? Image.file(File(message.localPath), fit: BoxFit.cover)
        : CachedNetworkImage(
            imageUrl: message.thumbnailRemotePath!,
            fit: BoxFit.cover,
          );
    final originalWidget = message.remotePath == null
        ? Image.file(File(message.localPath), fit: BoxFit.cover)
        : CachedNetworkImage(imageUrl: message.remotePath!, fit: BoxFit.cover);
    return OpenContainer(
      closedBuilder: (BuildContext context, void Function() action) {
        return AspectRatio(aspectRatio: 1, child: thumbWidget);
      },
      openBuilder:
          (BuildContext context, void Function({Object? returnValue}) action) {
            return Scaffold(
              appBar: AppBar(title: Text(message.displayName ?? "")),
              body: Center(child: Center(child: originalWidget)),
            );
          },
    );
  }
}
