// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'agora_rtc_service.dart';
import 'agora_rtm_service.dart';
import 'call_screen.dart';
import 'models/conversation_model.dart';
import 'sound_player_service.dart';
import 'widgets/chat_date_seperator_item.dart';
import 'widgets/chat_message_item.dart';
import 'widgets/chat_bottom_bar.dart';

class ChatScreen extends StatefulWidget {
  static const String path = "/chat-screen";
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ValueNotifier<bool> typing = ValueNotifier(false);
  Timer? typingTimer;

  PagingController<String?, ChatMessage> pagingController = PagingController(
    firstPageKey: null,
  );

  @override
  void initState() {
    pagingController.addPageRequestListener(
      (pageKey) => fetchMessages(pageKey),
    );
    addChatEventHandler();
    clearUnreadMessages();
    super.initState();
  }

  void clearUnreadMessages() async {
    final unreadCount = await widget.conversation.conversation.unreadCount();
    if (unreadCount == 0) return;
    widget.conversation.conversation.markAllMessagesAsRead();
  }

  void removeChatEventHandler() {
    ChatClient.getInstance.chatManager.removeEventHandler('chat_event_handler');
    ChatClient.getInstance.chatManager.removeMessageEvent(
      'message_event_handler',
    );
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
            SoundPlayerService.i.playMsgReceivedAudio();
          }
        },
        onCmdMessagesReceived: onCmdMessagesRecieved,
        onMessagesRead: onMessageUpdate,
        onMessagesDelivered: onMessageUpdate,
      ),
    );
    ChatClient.getInstance.chatManager.addMessageEvent(
      "message_event_handler",
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          if (msg.body is ChatCmdMessageBody) return;
          if (pagingController.itemList?.map((e) => e.msgId).contains(msgId) ??
              false) {
            onMessageUpdate([msg]);
          } else {
            pagingController.itemList!.insert(0, msg);
            SoundPlayerService.i.playMsgSendAudio();
            setState(() {});
          }
        },
      ),
    );
    logInfo("chat_event_handler added");
  }

  Future<void> fetchMessages(String? pageKey) async {
    widget.conversation.conversation
        .loadMessages(startMsgId: pagingController.nextPageKey ?? "")
        .then((value) {
          final reversed = value.reversed.toList();
          if (reversed.length < 20) {
            pagingController.appendLastPage(reversed);
          } else {
            pagingController.appendPage(reversed, reversed.last.msgId);
          }
        });
  }

  @override
  void dispose() {
    removeChatEventHandler();
    clearUnreadMessages();
    EventListener.i.sendEvent(
      Event(
        eventType: EventType.converstaionUpdate,
        data: widget.conversation.conversation.id,
      ),
    );
    pagingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.user.nickName.toString()),
        actions: [
          Material(
            shadowColor: Colors.black26,
            elevation: 2.0,
            borderRadius: BorderRadius.circular(padding),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(padding),
              splashColor: Colors.grey[200],
              onTap: () async {
                final channel =
                    "${AgoraRTMService.i.currentUser?.userId ?? ""}-${widget.conversation.conversation.id}";
                final permission = await Permission.camera.request();
                if (permission != PermissionStatus.granted) return;
                AgoraRtcService.i.setArguments(
                  widget.conversation.user,
                  channel,
                  CallState.outgoingCall,
                );
                navigate(
                  navigatorKey.currentContext!,
                  CallScreen.path,
                  duplicate: false,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Icon(Icons.call),
              ),
            ),
          ),
          gap,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => pagingController.refresh(),
              child: PagedListView<String?, ChatMessage>.separated(
                reverse: true,
                padding: const EdgeInsets.all(paddingLarge),
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
                  firstPageProgressIndicatorBuilder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: paddingLarge,
                    ),
                    child: Column(
                      children: List.generate(
                        4,
                        (index) => const ListTileShimmer(),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, index) {
                    final messages = pagingController.itemList!;
                    final currentDate = DateTime.fromMillisecondsSinceEpoch(
                      item.serverTime,
                    );
                    DateTime? prevDate;
                    if (index < messages.length - 1) {
                      prevDate = DateTime.fromMillisecondsSinceEpoch(
                        messages[index + 1].serverTime,
                      );
                    }
                    final showSeperator =
                        prevDate == null || !currentDate.isSameDay(prevDate);
                    return Column(
                      children: [
                        if (showSeperator)
                          ChatDateSeperatorItem(date: currentDate),
                        ChatMessageItem(
                          key: ValueKey(item.msgId),
                          item: item,
                          other: widget.conversation.user,
                        ),
                      ],
                    );
                  },
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
      bottomNavigationBar: ChatBottomBar(conversation: widget.conversation),
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

  void showTyping() {
    typingTimer?.cancel();
    typing.value = true;
    typingTimer = Timer(Duration(seconds: 3), () {
      typing.value = false;
    });
  }

  void onMessageUpdate(List<ChatMessage> messages) {
    final mesgIndex = pagingController.itemList?.indexWhere(
      (element) => element.msgId == messages.first.msgId,
    );
    if (mesgIndex == null || mesgIndex.isNegative) return;
    pagingController.itemList!.replaceRange(mesgIndex, mesgIndex + 1, messages);
    setState(() {});
  }
}

Future<void> showCallSheet(
  ChatUserInfo user,
  String channel, {
  CallState initialState = CallState.incomingCall,
}) async {
  AgoraRtcService.i.setArguments(user, channel, initialState);
  navigate(navigatorKey.currentContext!, CallScreen.path, duplicate: false);
}
