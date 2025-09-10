// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/person_tile.dart';
import '../../widgets/user_avatar.dart';
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

class _ChatScreenState extends State<ChatScreen> with EventListenerMixin {
  final Map<String, GlobalKey> messageKeys = {};
  final ScrollController scrollController = ScrollController();

  ValueNotifier<bool> typing = ValueNotifier(false);
  ValueNotifier<String> presenceStatus = ValueNotifier("Offline");
  Timer? typingTimer;

  String cursor = "";

  late final PagingController<String?, ChatMessage>
  pagingController = PagingController<String?, ChatMessage>(
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) return null;
      // This convenience getter increments the page key by 1, assuming keys start at 1.
      return state.hasNextPage ? cursor : null;
    },
    fetchPage: fetchMessages,
  );

  @override
  void initState() {
    allowedEvents = [EventType.chatDeleted];
    listenForEvents((event) {
      if (pagingController.items != null && event.data is ChatMessage) {
        final deletedMessage = event.data as ChatMessage;
        setState(() {
          pagingController.items?.removeWhere(
            (element) => element.msgId == deletedMessage.msgId,
          );
        });
      }
    });
    addChatEventHandler();
    fetchCurrentPresenceStatus();
    clearUnreadMessages();
    super.initState();
  }

  void scrollToMessage(String messageId) {
    final messageKey = messageKeys[messageId];
    if (messageKey != null && messageKey.currentContext != null) {
      final messageIndex = pagingController.items!.indexWhere(
        (msg) => msg.msgId == messageId,
      );

      if (messageIndex != -1) {
        Scrollable.ensureVisible(
          messageKey.currentContext!,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.5,
        ).then((_) {
          final chatMessageState =
              messageKey.currentState as ChatMessageItemState?;
          chatMessageState?.highlightMessage();
        });
      }
    }
  }

  void fetchCurrentPresenceStatus() async {
    try {
      final status = await ChatClient.getInstance.presenceManager
          .fetchPresenceStatus(members: [widget.conversation.user.userId]);
      if (status.isNotEmpty) {
        final currentStatus = status.first.statusDescription;
        presenceStatus.value = currentStatus.isNotEmpty
            ? currentStatus
            : "Offline";
      }
      await ChatClient.getInstance.presenceManager.subscribe(
        members: [widget.conversation.user.userId],
        expiry: Duration(hours: 1).inSeconds,
      );
    } catch (e) {
      logError("Error fetching presence status: $e");
      presenceStatus.value = "Offline";
    }
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
    ChatClient.getInstance.presenceManager.removeEventHandler(
      'presence_event_handler',
    );
  }

  void scrolltoTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: animationDurationLarge,
      curve: Curves.fastOutSlowIn,
    );
  }

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
        onMessagesRecalled: (messages) {
          if (pagingController.items != null) {
            for (final message in messages) {
              pagingController.items!.removeWhere(
                (element) => element.msgId == message.msgId,
              );
              setState(() {});
            }
          }
        },
        onMessagesReceived: (messages) {
          if (messages.first.conversationId ==
              widget.conversation.conversation.id) {
            pagingController.items!.insert(0, messages.first);
            setState(() {});
            scrolltoBottom();
            SoundPlayerService.i.playMsgReceivedAudio();
            HapticFeedback.lightImpact();
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
          if (pagingController.items!.map((e) => e.msgId).contains(msgId)) {
            onMessageUpdate([msg]);
          } else {
            pagingController.items!.insert(0, msg);
            SoundPlayerService.i.playMsgSendAudio();
            setState(() {});
          }
        },
      ),
    );
    addPresenceEventHandler();
    logInfo("chat_event_handler added");
  }

  void addPresenceEventHandler() {
    ChatClient.getInstance.presenceManager.addEventHandler(
      'presence_event_handler',
      ChatPresenceEventHandler(
        onPresenceStatusChanged: (list) {
          for (var presence in list) {
            if (presence.publisher != widget.conversation.user.userId) return;
            presenceStatus.value = presence.statusDescription == "Online"
                ? "Online"
                : "Offline";
          }
        },
      ),
    );
  }

  Future<List<ChatMessage>> fetchMessages(String? pageKey) async {
    try {
      logInfo(
        "Fetching messages for conversation: ${widget.conversation.conversation.id}",
      );
      logInfo("Using cursor: $cursor");

      final messages = await widget.conversation.conversation.loadMessages(
        startMsgId: cursor,
      );

      logInfo("Loaded ${messages.length} messages");

      if (messages.isEmpty) {
        logInfo("No more messages to load");
        // Set cursor to null to indicate no more pages
        return [];
      }

      final reversed = messages.reversed.toList();

      cursor = reversed.last.msgId;

      return reversed;
    } catch (e) {
      logError("Error fetching messages: $e");
      // Re-throw the error so PagingController can handle it
      rethrow;
    }
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
        title: Row(
          children: [
            UserAvatar(
              imageUrl: widget.conversation.user.avatarUrl ?? "",
              addMediaUrl: false,
              size: 38.h,
            ),
            gap,
            if (widget.conversation.user.nickName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.user.nickName.toString(),
                    style: context.montserrat60015.copyWith(
                      color: Color(0xff3C3F4E),
                    ),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: presenceStatus,
                    builder: (context, status, child) {
                      final isOnline = status.toLowerCase() == 'online';
                      return Row(
                        children: [
                          Text(
                            status,
                            style: context.montserrat40013.copyWith(
                              color: Color(0xff3C3F4E).withAlpha(0.6.alpha),
                            ),
                          ),
                          gap,
                          Icon(
                            Icons.circle,
                            size: 10.h,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
        surfaceTintColor: Colors.transparent,
        leading: backButtonWithSafety(context),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () async {
              final channel =
                  "${AgoraRTMService.i.currentUser?.userId ?? ""}-${widget.conversation.conversation.id}";
              final permission = await Permission.microphone.request();
              if (permission != PermissionStatus.granted) return;
              showCallSheet(
                widget.conversation.user,
                channel,
                initialState: CallState.outgoingCall,
              );
              if (permission == PermissionStatus.permanentlyDenied) {
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Microphone Acces Required',
                      style: context.montserrat60016,
                    ),
                    content: Text(
                      'Please enable microphone permission in settings in order to make calls',
                      style: context.montserrat40014,
                    ),

                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          openAppSettings();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Open Setttigs',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (permission != PermissionStatus.granted) return;

              showCallSheet(
                widget.conversation.user,
                channel,
                initialState: CallState.outgoingCall,
              );
            },
          ),
          gap,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => pagingController.refresh(),
              child: PagingListener(
                controller: pagingController,
                builder: (context, state, fetchNextPage) {
                  return PagedListView<String?, ChatMessage>.separated(
                    reverse: true,
                    padding: const EdgeInsets.all(paddingLarge),
                    scrollController: scrollController,
                    builderDelegate: PagedChildBuilderDelegate(
                      firstPageErrorIndicatorBuilder: (context) => SizedBox(
                        height: 400,
                        child: ErrorWidgetWithRetry(
                          exception: pagingController.error,
                          retry: pagingController.refresh,
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (context) => Center(
                        child: Image.asset(
                          Assets.pngs.noChat.path,
                          fit: BoxFit.cover,
                          width: ScreenUtil().screenWidth * .8,
                        ),
                      ),
                      firstPageProgressIndicatorBuilder: (context) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: paddingLarge,
                        ),
                        child: Column(
                          children: List.generate(
                            4,
                            (index) => const PersonListingTileShimmer(),
                          ),
                        ),
                      ),
                      itemBuilder: (context, item, index) {
                        final messages = pagingController.items!;
                        final message = messages[index];
                        if (!messageKeys.containsKey(message.msgId)) {
                          messageKeys[message.msgId] = GlobalKey();
                        }
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
                            prevDate == null ||
                            !currentDate.isSameDay(prevDate);
                        return Column(
                          children: [
                            if (showSeperator)
                              ChatDateSeperatorItem(date: currentDate),
                            ChatMessageItem(
                              key: messageKeys[message.msgId],
                              item: item,
                              other: widget.conversation.user,
                              onScrollToMessage: scrollToMessage,
                            ),
                          ],
                        );
                      },
                    ),
                    separatorBuilder: (context, index) => gap,
                    state: state,
                    fetchNextPage: fetchNextPage,
                  );
                },
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
    final mesgIndex = pagingController.items!.indexWhere(
      (element) => element.msgId == messages.first.msgId,
    );
    if (mesgIndex.isNegative) return;
    pagingController.items!.replaceRange(mesgIndex, mesgIndex + 1, messages);
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
