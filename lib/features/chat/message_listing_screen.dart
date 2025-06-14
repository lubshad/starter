// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:starter/features/chat/widgets/chat_message_item.dart';
import 'package:starter/services/file_picker_service.dart';
import '../../exporter.dart';
import '../../widgets/bottom_button_padding.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'agora_utils.dart';

class MessageListingScreen extends StatefulWidget {
  static const String path = "/message-listing";
  final ChatConversation conversation;

  const MessageListingScreen({super.key, required this.conversation});

  @override
  State<MessageListingScreen> createState() => _MessageListingScreenState();
}

class _MessageListingScreenState extends State<MessageListingScreen> {
  PagingController<String?, ChatMessage> pagingController = PagingController(
    firstPageKey: null,
  );

  ChatUserInfo? other;

  @override
  void initState() {
    pagingController.addPageRequestListener(
      (pageKey) => fetchMessages(pageKey),
    );
    ChatClient.getInstance.userInfoManager
        .fetchUserInfoById([widget.conversation.id])
        .then((value) {
          other = value[widget.conversation.id];
        });
    addMessageListener();
    super.initState();
  }

  removeMessageListener() {
    ChatClient.getInstance.chatManager.removeEventHandler('chat_event_handler');
  }

  addMessageListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'chat_event_handler',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          if (messages.first.conversationId == widget.conversation.id) {
            pagingController.itemList?.insert(0, messages.first);
            setState(() {});
          }
        },
        onCmdMessagesReceived: onCmdMessagesRecieved,
      ),
    );
    logInfo("chat_event_handler added");
  }

  fetchMessages(String? pageKey) async {
    ChatClient.getInstance.chatManager
        .fetchHistoryMessagesByOption(
          widget.conversation.id,
          widget.conversation.type,
          cursor: pageKey,
        )
        .then((value) {
          if (value.cursor == null ||
              value.cursor!.isEmpty ||
              value.cursor == "undefined") {
            pagingController.appendLastPage(value.data);
          } else {
            pagingController.appendPage(value.data, value.cursor!);
          }
        });
  }

  @override
  dispose() {
    removeMessageListener();
    super.dispose();
  }

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id.toString())),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => pagingController.refresh(),
              child: PagedListView<String?, ChatMessage>.separated(
                reverse: true,
                padding: const EdgeInsets.all(padding),
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate(
                  firstPageErrorIndicatorBuilder: (context) => SizedBox(
                    height: 400,
                    child: ErrorWidgetWithRetry(
                      exception: pagingController.error,
                      retry: pagingController.refresh,
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const NoItemsFound(),
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(
                      4,
                      (index) => const ListTileShimmer(),
                    ),
                  ),
                  itemBuilder: (context, item, index) =>
                      ChatMessageItem(item: item, other: other!),
                ),
                separatorBuilder: (context, index) => gap,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: typing,
            builder: (context, value, child) {
              return Visibility(
                visible: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    gapXL,
                    SpinKitThreeBounce(
                      color: Colors.black,
                      size: 20,
                    ).animate().scale(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomButtonPadding(
        child: Row(
          children: [
            // add attachments button
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () async {
                final file = await FilePickerService.pickFile(
                  fileType: FileType.any,
                );
                if (file == null) return;
                AgoraUtils.i
                    .sendFileMessage(id: widget.conversation.id, file: file)
                    .then((value) {
                      pagingController.itemList?.insert(0, value);
                      setState(() {});
                    });
              },
            ),
            gap,
            Expanded(
              child: SizedBox(
                height: kToolbarHeight / 1.5,
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: 0,
                    ),
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => AgoraUtils.i.sendTypingIndicator(
                    id: widget.conversation.id,
                  ),
                ),
              ),
            ),
            gap,
            ValueListenableBuilder(
              valueListenable: messageController,
              builder: (context, value, child) {
                if (value.text.isEmpty) {
                  return Row(
                    children: [
                      // camera button
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () async {
                          final image = await FilePickerService.pickFileOrImage(
                            imageSource: ImageSource.gallery,
                            crop: false,
                          );
                          if (image == null) return;
                          AgoraUtils.i
                              .sendImageMessage(
                                id: widget.conversation.id,
                                file: image,
                              )
                              .then((value) {
                                pagingController.itemList?.insert(0, value);
                                setState(() {});
                              });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_voice),
                        onPressed: () {},
                      ),
                    ],
                  );
                }
                return IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => AgoraUtils.i
                      .sendMessage(
                        id: widget.conversation.id,
                        message: messageController.text,
                      )
                      .then((value) {
                        messageController.clear();
                        pagingController.itemList?.insert(0, value);
                        setState(() {});
                      }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onCmdMessagesRecieved(List<ChatMessage> messages) {
    if (messages.first.body is ChatCmdMessageBody) {
      showTyping();
    }
  }

  ValueNotifier<bool> typing = ValueNotifier(false);

  Timer? typingTimer;

  void showTyping() {
    typingTimer?.cancel();
    typing.value = true;
    typingTimer = Timer(Duration(seconds: 2), () {
      typing.value = false;
    });
  }
}
