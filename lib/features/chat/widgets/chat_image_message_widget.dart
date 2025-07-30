import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatImageMessageWidget extends StatefulWidget {
  const ChatImageMessageWidget({super.key, required this.chatMessage});
  final ChatMessage chatMessage;

  @override
  State<ChatImageMessageWidget> createState() => _ChatImageMessageWidgetState();
}

class _ChatImageMessageWidgetState extends State<ChatImageMessageWidget> {
  late ChatImageMessageBody message;

  ValueNotifier<DownloadStatus> downloadStatus = ValueNotifier(
    DownloadStatus.PENDING,
  );
  @override
  initState() {
    message = widget.chatMessage.body as ChatImageMessageBody;
    downloadStatus.value = message.fileStatus;
    addDownloadListener();
    super.initState();
  }

  @override
  void dispose() {
    removeDownloadListener();
    super.dispose();
  }

  final ValueNotifier<int> _progress = ValueNotifier(0);

  void addDownloadListener() {
    if ([
      DownloadStatus.DOWNLOADING,
      DownloadStatus.SUCCESS,
    ].contains(downloadStatus.value)) {
      return;
    }
    ChatClient.getInstance.chatManager.addMessageEvent(
      "download_event_handler_${widget.chatMessage.msgId}",
      ChatMessageEvent(
        onProgress: (msgId, progress) {
          if (msgId != widget.chatMessage.msgId) return;
          _progress.value = progress;
          downloadStatus.value = DownloadStatus.DOWNLOADING;
        },
        onSuccess: (msgId, msg) {
          if (msgId != widget.chatMessage.msgId) return;
          _progress.value = 100;
          downloadStatus.value = DownloadStatus.SUCCESS;
        },
        onError: (msgId, msg, error) {
          if (msgId != widget.chatMessage.msgId) return;
          _progress.value = 0;
          downloadStatus.value = DownloadStatus.FAILED;
        },
      ),
    );
  }

  void removeDownloadListener() {
    ChatClient.getInstance.chatManager.removeMessageEvent(
      "download_event_handler_${widget.chatMessage.msgId}",
    );
  }

  Widget get thumbWidget {
    if (downloadStatus.value == DownloadStatus.SUCCESS &&
        File(message.localPath).existsSync()) {
      return Image.file(File(message.localPath), fit: BoxFit.cover);
    } else if ((message.thumbnailStatus == DownloadStatus.SUCCESS ||
            message.thumbnailLocalPath?.isNotEmpty == true) &&
        File(message.thumbnailLocalPath!).existsSync()) {
      return Image.file(File(message.thumbnailLocalPath!), fit: BoxFit.cover);
    } else {
      return CachedNetworkImage(
        imageUrl: message.thumbnailRemotePath!,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (File(message.localPath).existsSync()) {
          OpenFile.open(message.localPath);
        } else if (message.thumbnailLocalPath?.isNotEmpty == true &&
            File(message.thumbnailLocalPath!).existsSync()) {
          OpenFile.open(message.thumbnailLocalPath!);
        } else {
          launchUrl(Uri.parse(message.remotePath!));
        }
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: ValueListenableBuilder(
          valueListenable: downloadStatus,
          builder: (context, status, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                thumbWidget,
                Builder(
                  builder: (context) {
                    if (status == DownloadStatus.DOWNLOADING) {
                      return ValueListenableBuilder(
                        valueListenable: _progress,
                        builder: (context, value, child) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: value / 100,
                            ),
                          );
                        },
                      );
                    } else if ([
                          DownloadStatus.PENDING,
                          DownloadStatus.FAILED,
                        ].contains(status) ||
                        !File(message.localPath).existsSync()) {
                      return IconButton(
                        onPressed: () async {
                          downloadStatus.value = DownloadStatus.DOWNLOADING;
                          await ChatClient.getInstance.chatManager
                              .downloadThumbnail(widget.chatMessage);
                          await ChatClient.getInstance.chatManager
                              .downloadAttachment(widget.chatMessage);
                        },
                        icon: Icon(Icons.download),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
