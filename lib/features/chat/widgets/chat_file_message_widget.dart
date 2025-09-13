import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class ChatFileMessageWidget extends StatefulWidget {
  const ChatFileMessageWidget({
    super.key,
    required this.chatMessage,
    required this.color,
  });

  final ChatMessage chatMessage;
  final Color color;

  @override
  State<ChatFileMessageWidget> createState() => _ChatFileMessageWidgetState();
}

class _ChatFileMessageWidgetState extends State<ChatFileMessageWidget> {
  late ChatFileMessageBody message;

  ValueNotifier<DownloadStatus> downloadStatus = ValueNotifier(
    DownloadStatus.PENDING,
  );
  final ValueNotifier<int> _progress = ValueNotifier(0);

  @override
  initState() {
    message = widget.chatMessage.body as ChatFileMessageBody;
    downloadStatus.value = message.fileStatus;
    addDownloadListener();
    super.initState();
  }

  @override
  dispose() {
    removeDownloadListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        if (downloadStatus.value == DownloadStatus.PENDING) {
          ChatClient.getInstance.chatManager.downloadAttachment(
            widget.chatMessage,
          );
        } else {
          await OpenFile.open(message.localPath);
        }
      },
      contentPadding: EdgeInsets.zero,
      leading: ValueListenableBuilder(
        valueListenable: downloadStatus,
        builder: (context, status, child) {
          if (status == DownloadStatus.DOWNLOADING) {
            return ValueListenableBuilder(
              valueListenable: _progress,
              builder: (context, value, child) {
                return CircularProgressIndicator(value: value / 100);
              },
            );
          } else if (status == DownloadStatus.SUCCESS) {
            return Icon(Icons.file_present_outlined, color: widget.color);
          } else {
            return Icon(Icons.download, color: widget.color);
          }
        },
      ),
      dense: true,
      title: Text(
        message.displayName ?? "",
        style: TextStyle(color: widget.color),
      ),
    );
  }

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
}
