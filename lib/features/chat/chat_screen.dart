// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';
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
import 'group_members_screen.dart';
import 'sound_player_service.dart';
import 'widgets/chat_date_seperator_item.dart';
import 'widgets/chat_message_item.dart';
import 'widgets/chat_bottom_bar.dart';

class ChatScreenArg {
  final String id;
  final ChatConversationType type;

  ChatScreenArg({required this.id, this.type = ChatConversationType.Chat});
}

class ChatScreen extends StatefulWidget {
  static const String path = "/chat-screen";
  final ChatScreenArg arguments;

  const ChatScreen({super.key, required this.arguments});

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
  ChatConversation? conversation;
  bool isLoading = true;
  String? error;

  ChatUserInfo? userInfo;
  ChatGroup? groupInfo;

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
        removeMessages([deletedMessage]);
      }
    });
    _fetchConversation();
    super.initState();
  }

  Future<void> _fetchConversation() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get the conversation by ID
      conversation = (await ChatClient.getInstance.chatManager.getConversation(
        widget.arguments.id,
        type: widget.arguments.type,
      ))!;

      if (widget.arguments.type == ChatConversationType.GroupChat) {
        groupInfo = await ChatClient.getInstance.groupManager
            .fetchGroupInfoFromServer(widget.arguments.id);
      } else {
        // Get user info for the conversation
        userInfo =
            (await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
              widget.arguments.id,
            ])).values.first;
      }

      setState(() {
        isLoading = false;
      });

      // Initialize chat features after conversation is loaded
      addChatEventHandler();
      fetchCurrentPresenceStatus();
      clearUnreadMessages();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      logError("Error fetching conversation: $e");
    }
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
    if (conversation == null) return;
    if (widget.arguments.type == ChatConversationType.GroupChat) return;
    try {
      final status = await ChatClient.getInstance.presenceManager
          .fetchPresenceStatus(members: [conversation!.id]);
      if (status.isNotEmpty) {
        final currentStatus = status.first.statusDescription;
        presenceStatus.value = currentStatus.isNotEmpty
            ? currentStatus
            : "Offline";
      }
      await ChatClient.getInstance.presenceManager.subscribe(
        members: [conversation!.id],
        expiry: Duration(hours: 1).inSeconds,
      );
    } catch (e) {
      logError("Error fetching presence status: $e");
      presenceStatus.value = "Offline";
    }
  }

  void clearUnreadMessages() async {
    if (conversation == null) return;
    final unreadCount = await conversation!.unreadCount();
    if (unreadCount == 0) return;
    conversation!.markAllMessagesAsRead();
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

  void removeMessages(List<ChatMessage> messages) {
    for (final message in messages) {
      final newList = List<ChatMessage>.from(pagingController.items!);
      newList.removeWhere((element) => element.msgId == message.msgId);
      pagingController.value = pagingController.value.copyWith(
        pages: [newList],
      );
    }
  }

  void addChatEventHandler() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'chat_event_handler',
      ChatEventHandler(
        onMessagesRecalled: (messages) {
          if (pagingController.items != null) {
            removeMessages(messages);
          }
        },

        onMessagesReceived: (messages) {
          if (conversation != null &&
              messages.first.conversationId == conversation!.id) {
            insertNewMessage(messages.first);
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
            insertNewMessage(msg);
            SoundPlayerService.i.playMsgSendAudio();
            setState(() {});
          }
        },
      ),
    );
    addPresenceEventHandler();
    logInfo("chat_event_handler added");
  }

  void insertNewMessage(ChatMessage message) {
    final currentState = pagingController.value;
    final newPages = List<List<ChatMessage>>.from(currentState.pages ?? []);
    final firstPage = List<ChatMessage>.from(newPages.removeAt(0));

    // if (newPages.isNotEmpty) {
    // Insert at the beginning of the first page
    firstPage.insert(0, message);
    // } else {
    // If no pages exist, create a new page
    newPages.insert(0, firstPage);
    // }

    pagingController.value = currentState.copyWith(pages: newPages);
  }

  void addPresenceEventHandler() {
    if (widget.arguments.type == ChatConversationType.GroupChat) return;
    ChatClient.getInstance.presenceManager.addEventHandler(
      'presence_event_handler',
      ChatPresenceEventHandler(
        onPresenceStatusChanged: (list) {
          if (conversation == null) return;
          for (var presence in list) {
            if (presence.publisher != conversation!.id) return;
            presenceStatus.value = presence.statusDescription == "Online"
                ? "Online"
                : "Offline";
          }
        },
      ),
    );
  }

  Future<List<ChatMessage>> fetchMessages(String? pageKey) async {
    if (conversation == null) return <ChatMessage>[];
    try {
      logInfo("Fetching messages for conversation: ${conversation!.id}");
      logInfo("Using cursor: $cursor");

      final messages = await conversation!.loadMessages(startMsgId: cursor);

      logInfo("Loaded ${messages.length} messages");

      if (messages.isEmpty) {
        logInfo("No more messages to load");
        // Set cursor to null to indicate no more pages
        return <ChatMessage>[];
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
    if (conversation != null) {
      EventListener.i.sendEvent(
        Event(eventType: EventType.converstaionUpdate, data: conversation!.id),
      );
    }
    pagingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String get avatarUrl => widget.arguments.type == ChatConversationType.Chat
      ? userInfo!.avatarUrl ?? ""
      : jsonDecode(groupInfo?.extension ?? "{}")["groupIcon"] ?? "";

  String get name => widget.arguments.type == ChatConversationType.Chat
      ? userInfo!.nickName ?? ""
      : groupInfo!.name ?? "";

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading..."),
          surfaceTintColor: Colors.transparent,
          leading: backButtonWithSafety(context),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || conversation == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Error"),
          surfaceTintColor: Colors.transparent,
          leading: backButtonWithSafety(context),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                error ?? "Conversation not found",
                style: context.montserrat40014,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchConversation(),
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(imageUrl: avatarUrl, addMediaUrl: false, size: 38.h),
            gap,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.montserrat60015.copyWith(
                    color: Color(0xff3C3F4E),
                  ),
                ),
                Visibility(
                  visible: groupInfo == null && userInfo != null,
                  child: ValueListenableBuilder<String>(
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
                ),
              ],
            ),
          ],
        ),
        surfaceTintColor: Colors.transparent,
        leading: backButtonWithSafety(context),
        actions: [
          if (widget.arguments.type == ChatConversationType.Chat)
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () async {
                final channel =
                    "${AgoraRTMService.i.currentUser?.userId ?? ""}-${conversation!.id}";
                final permission = await Permission.microphone.request();
                if (permission != PermissionStatus.granted) return;
                showCallSheet(
                  userInfo!,
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
                  userInfo!,
                  channel,
                  initialState: CallState.outgoingCall,
                );
              },
            )
          else
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                navigate(
                  context,
                  GroupMembersScreen.path,
                  arguments: conversation!.id,
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
                            FutureBuilder(
                              future:
                                  widget.arguments.type ==
                                      ChatConversationType.GroupChat
                                  ? ChatClient.getInstance.userInfoManager
                                        .fetchUserInfoById([message.from!])
                                  : Future.value({userInfo!.userId: userInfo!}),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return PersonListingTileShimmer();
                                }
                                return ChatMessageItem(
                                  showAvatar:
                                      widget.arguments.type ==
                                      ChatConversationType.GroupChat,
                                  key: messageKeys[message.msgId],
                                  item: item,
                                  other: asyncSnapshot.data!.values.first,
                                  onScrollToMessage: scrollToMessage,
                                );
                              },
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
      bottomNavigationBar: ChatBottomBar(arguments: widget.arguments),
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
    final items = List<ChatMessage>.from(pagingController.items!);
    items.replaceRange(mesgIndex, mesgIndex + 1, messages);
    pagingController.value = pagingController.value.copyWith(pages: [items]);
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
