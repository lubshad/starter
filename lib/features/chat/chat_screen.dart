// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../mixins/event_listener.dart';
import '../../services/file_picker_service.dart';
import '../../services/snackbar_utils.dart';
import '../../widgets/bottom_button_padding.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'agora_utils.dart';
import 'call_screen.dart';
import 'models/conversation_model.dart';
import 'widgets/chat_message_item.dart';

class ChatScreen extends StatefulWidget {
  static const String path = "/chat-screen";
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  PagingController<String?, ChatMessage> pagingController = PagingController(
    firstPageKey: null,
  );

  @override
  void initState() {
    pagingController.addPageRequestListener(
      (pageKey) => fetchMessages(pageKey),
    );
    addChatEventHandler();
    widget.conversation.conversation.markAllMessagesAsRead().then((value) {
      logInfo("all msg read");
    });
    super.initState();
  }

  void removeChatEventHandler() {
    ChatClient.getInstance.chatManager.removeEventHandler('chat_event_handler');
  }

  final scrollController = ScrollController();

  void scrolltoBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: animationDurationLarge,
      curve: Curves.fastOutSlowIn,
    );
  }

  void addChatEventHandler() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'chat_event_handler',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          if (messages.first.conversationId ==
              widget.conversation.conversation.id) {
            pagingController.itemList?.insert(0, messages.first);
            setState(() {});
            scrolltoBottom();
          }
        },
        onCmdMessagesReceived: onCmdMessagesRecieved,
      ),
    );
    logInfo("chat_event_handler added");
  }

  Future<void> fetchMessages(String? pageKey) async {
    ChatClient.getInstance.chatManager
        .fetchHistoryMessagesByOption(
          widget.conversation.conversation.id,
          widget.conversation.conversation.type,
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
    removeChatEventHandler();
    EventListener.i.sendEvent(
      Event(
        eventType: EventType.converstaionUpdate,
        data: widget.conversation.conversation.id,
      ),
    );
    super.dispose();
  }

  final RecorderController recorderController = RecorderController();

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.user.nickName.toString()),
        actions: [
          IconButton(
            onPressed: () {
              final channel =
                  "${AgoraUtils.i.currentUser?.userId ?? ""}-${widget.conversation.conversation.id}";
              [Permission.microphone, Permission.camera].request().then((
                value,
              ) {
                if (value.values.any(
                  (element) => element != PermissionStatus.granted,
                )) {
                  return;
                }
                navigate(
                  navigatorKey.currentContext!,
                  CallScreen.path,
                  arguments: CallScreenArgs(
                    user: widget.conversation.user,
                    channelName: channel,
                    initialState: CallState.outgoingCall,
                  ),
                  duplicate: false,
                );
              });
            },
            icon: Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => pagingController.refresh(),
              child: PagedListView<String?, ChatMessage>.separated(
                reverse: true,
                padding: const EdgeInsets.all(padding),
                pagingController: pagingController,
                scrollController: scrollController,
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
                  itemBuilder: (context, item, index) => ChatMessageItem(
                    item: item,
                    other: widget.conversation.user,
                  ),
                ),
                separatorBuilder: (context, index) => gap,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: typing,
            builder: (context, value, child) {
              return AnimatedContainer(
                height: value ? 20.h : 0,
                curve: Curves.fastOutSlowIn,
                duration: 100.ms,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    gapXL,
                    SpinKitThreeBounce(
                      color: Colors.black,
                      size: 20.h,
                    ).animate().scale(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          if (recorderController.isRecording) {
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    recorderController.stop().then((value) async {
                      await File(value!).delete();
                      setState(() {});
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
                Expanded(
                  child: AudioWaveforms(
                    waveStyle: WaveStyle(
                      showMiddleLine: false,
                      extendWaveform: true,
                    ),
                    margin: EdgeInsets.symmetric(vertical: padding),
                    size: Size(SizeUtils.width, kToolbarHeight),
                    recorderController: recorderController,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    recorderController.stop().then((value) {
                      setState(() {});
                      if (value == null) return;
                      AgoraUtils.i
                          .sendVoiceMessage(
                            id: widget.conversation.conversation.id,
                            file: File(value),
                            duration: recorderController.recordedDuration,
                          )
                          .then((value) {
                            pagingController.itemList?.insert(0, value);
                            setState(() {});
                          });
                    });
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            );
          }
          return BottomButtonPadding(
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
                        .sendFileMessage(
                          id: widget.conversation.conversation.id,
                          file: file,
                        )
                        .then((value) {
                          pagingController.itemList?.insert(0, value);
                          setState(() {});
                        });
                  },
                ),
                gap,
                Expanded(
                  child: SizedBox(
                    height: kToolbarHeight / 1.2,
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
                        id: widget.conversation.conversation.id,
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
                              // return;
                              final image =
                                  await FilePickerService.pickFileOrImage(
                                    imageSource: ImageSource.gallery,
                                    crop: false,
                                  );
                              if (image == null) return;
                              AgoraUtils.i
                                  .sendImageMessage(
                                    id: widget.conversation.conversation.id,
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
                            onPressed: () async {
                              if (!(await recorderController
                                  .checkPermission())) {
                                showErrorMessage("You need to give permission");
                                return;
                              }
                              if (!recorderController.hasPermission) return;
                              recorderController.record().then((value) {
                                setState(() {});
                              });
                            },
                          ),
                        ],
                      );
                    }
                    return IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => AgoraUtils.i
                          .sendMessage(
                            id: widget.conversation.conversation.id,
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
          );
        },
      ),
    );
  }

  void onCmdMessagesRecieved(List<ChatMessage> messages) {
    final messageBody = messages.first.body as ChatCmdMessageBody;
    final action = jsonDecode(messageBody.action) as Map<String, dynamic>;
    CmdActionType actionType = CmdActionType.fromValue(action["type"]);

    switch (actionType) {
      case CmdActionType.startTyping:
        showTyping();
        break;
      default:
    }
  }

  ValueNotifier<bool> typing = ValueNotifier(false);

  Timer? typingTimer;

  void showTyping() {
    typingTimer?.cancel();
    typing.value = true;
    typingTimer = Timer(Duration(seconds: 3), () {
      typing.value = false;
    });
  }
}

Future<void> showCallSheet(
  ChatUserInfo user,
  String channel, {
  CallState initialState = CallState.incomingCall,
}) async {
  navigate(
    navigatorKey.currentContext!,
    CallScreen.path,
    arguments: CallScreenArgs(
      user: user,
      channelName: channel,
      initialState: initialState,
    ),
    duplicate: false,
  );
}
