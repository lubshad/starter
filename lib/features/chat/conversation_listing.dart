// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../services/fcm_service.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/network_resource.dart';
import '../../widgets/no_item_found.dart';
import '../profile_screen/common_controller.dart';
import 'agora_rtc_service.dart';
import 'agora_rtm_service.dart';
import 'chat_screen.dart';
import 'models/conversation_model.dart';
import 'widgets/conversation_item.dart';

class ConversationListingScreen extends StatefulWidget {
  static const String path = "/chat-listing";

  const ConversationListingScreen({super.key});

  @override
  State<ConversationListingScreen> createState() =>
      _ConversationListingScreenState();
}

class _ConversationListingScreenState extends State<ConversationListingScreen>
    with EventListenerMixin {
  Future<List<ConversationModel>>? conversationsFuture;
  void loginUser() {
    if (AgoraRTMService.i.isLoggedIn) return;
    AgoraRTMService.i
        .signIn(
          userid: CommonController.i.profileDetails!.id.toString(),
          avatarUrl: CommonController.i.profileDetails!.image ?? "",
          name: CommonController.i.profileDetails?.name ?? "",
        )
        .then((value) async {
          addChatEventHandler();
          await Future.delayed(const Duration(seconds: 2));
          loadConversations();
        });
  }

  void addChatEventHandler() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'convo_chat_event_handler',
      ChatEventHandler(
        onMessagesReceived: (messages) async {
          if (messages.first.body.type != MessageType.TXT) return;
          final userinfo =
              (await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
                messages.first.from!,
              ])).values.first;
          final chatEventHandler = ChatClient.getInstance.chatManager
              .getEventHandler("chat_event_handler");
          if (chatEventHandler == null) {
            await FCMService().showNotification(
              title: userinfo.nickName,
              body: (messages.first.body as ChatTextMessageBody).content,
            );
          }
        },
        onCmdMessagesReceived: onCmdMessagesRecieved,
      ),
    );
    ChatClient.getInstance.presenceManager.publishPresence('Online');
    logInfo("convo_chat_event_handler added");
  }

  void onCmdMessagesRecieved(List<ChatMessage> messages) {
    final messageBody = messages.first.body as ChatCmdMessageBody;
    final action = jsonDecode(messageBody.action) as Map<String, dynamic>;
    CmdActionType actionType = CmdActionType.fromValue(action["type"]);

    switch (actionType) {
      case CmdActionType.startCalling:
        final fromUser = ChatUserInfo.fromJson(action["from"]);
        final channel = action["channel"];
        if (appLifecycleState == AppLifecycleState.inactive) {
          AgoraRTMService.i.initiateIncommingCall(
            RemoteMessage(
              data: {
                "e": jsonEncode({
                  "from": fromUser.toJson(),
                  "channel": channel,
                  "type": CmdActionType.startCalling.name,
                }),
              },
            ),
          );
        } else {
          showCallSheet(fromUser, channel);
        }
        break;
      case CmdActionType.endCalling:
        FlutterCallkitIncoming.endAllCalls();
        break;
      default:
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loginUser();
      checkOngoingCall();
    });
    loadConversations();
    allowedEvents = [
      EventType.converstaionUpdate,
      EventType.inactive,
      EventType.resumed,
    ];
    listenForEvents((event) {
      if (event.eventType == EventType.inactive) {
        appLifecycleState = AppLifecycleState.inactive;
        ChatClient.getInstance.presenceManager.publishPresence('Offline');
      } else if (event.eventType == EventType.resumed) {
        appLifecycleState = AppLifecycleState.resumed;
        ChatClient.getInstance.presenceManager.publishPresence('Online');
        checkOngoingCall();
      } else if (event.eventType == EventType.converstaionUpdate) {
        updateOrAddConversation(event.data);
      }
    });
    super.initState();
  }

  Future<void> checkOngoingCall() async {
    final ongoingCalls = (await FlutterCallkitIncoming.activeCalls() as List);
    if (ongoingCalls.isEmpty) return;
    final incomingString = await SharedPreferencesService.i.getValue(
      key: incomingCallKey,
    );
    if (incomingString.isEmpty) {
      return;
    }
    Map<String, dynamic> data = jsonDecode(incomingString);
    ChatUserInfo from = ChatUserInfo.fromJson(data["from"]);
    String channelName = data["channel"];
    showCallSheet(from, channelName, initialState: CallState.connected);
    return;
  }

  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  Future<void> updateOrAddConversation(String conversationId) async {
    // Reload conversations when a conversation is updated
    loadConversations();
  }

  void removeChatEventHandler() {
    ChatClient.getInstance.chatManager.removeEventHandler(
      'convo_chat_event_handler',
    );
    ChatClient.getInstance.presenceManager.publishPresence('Offline');
  }

  @override
  dispose() {
    disposeEventListener();
    removeChatEventHandler();
    super.dispose();
  }

  void loadConversations() {
    if (!AgoraRTMService.i.isLoggedIn) {
      conversationsFuture = Future.value([]);
      setState(() {});
      return;
    }

    conversationsFuture = _fetchConversations();
    setState(() {});
  }

  Future<List<ConversationModel>> _fetchConversations() async {
    final value = await ChatClient.getInstance.chatManager
        .loadAllConversations();

    final users =
        (await ChatClient.getInstance.userInfoManager.fetchUserInfoById(
          value.map((e) => e.id).toList(),
        )).values.toList();

    final latestMessages = await Future.wait(
      value.map((e) => e.latestMessage()),
    );

    final unreadCounts = await Future.wait(value.map((e) => e.unreadCount()));

    return value.indexed
        .map(
          (conversation) => ConversationModel(
            conversation: conversation.$2,
            user: users[conversation.$1],
            latestMessage: latestMessages[conversation.$1],
            unreadCount: unreadCounts[conversation.$1],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadConversations(),
        child: NetworkResource<List<ConversationModel>>(
          conversationsFuture,
          loading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: paddingLarge),
            child: Column(
              children: List.generate(4, (index) => const ListTileShimmer()),
            ),
          ),
          error: (error) => SizedBox(
            height: 400,
            child: ErrorWidgetWithRetry(
              exception: error,
              retry: loadConversations,
            ),
          ),
          success: (conversations) {
            if (conversations.isEmpty) {
              return const NoItemsFound();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(padding),
              itemCount: conversations.length,
              itemBuilder: (context, index) =>
                  ConversationItem(item: conversations[index]),
              separatorBuilder: (context, index) => gap,
            );
          },
        ),
      ),
    );
  }
}
