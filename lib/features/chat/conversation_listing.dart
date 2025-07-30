// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../services/fcm_service.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
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
  PagingController<String?, ConversationModel> pagingController =
      PagingController(firstPageKey: null);
  void loginUser() {
    if (AgoraRTMService.i.isLoggedIn) return;
    DataRepository.i.generateRTMToken(CommonController.i.profileDetails!).then((
      agoraConfig,
    ) {
      AgoraRTMService.i
          .signIn(
            userid: CommonController.i.profileDetails!.id.toString(),
            usertoken: agoraConfig.token,
            avatarUrl: CommonController.i.profileDetails!.image ?? "",
            name: CommonController.i.profileDetails?.name ?? "",
          )
          .then((value) async {
            pagingController.refresh();
            addChatEventHandler();
            await Future.delayed(const Duration(seconds: 2));
            if (pagingController.itemList?.isEmpty == true) {
              await ChatClient.getInstance.chatManager
                  .fetchConversationsByOptions(
                    options: ConversationFetchOptions(pageSize: 50),
                  )
                  .then((value) {
                    pagingController.refresh();
                  });
            }
            pagingController.refresh();
          });
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
        if (appLifecycleState == AppLifecycleState.paused) {
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
    pagingController.addPageRequestListener((pageKey) => getData(pageKey));
    allowedEvents = [
      EventType.converstaionUpdate,
      EventType.paused,
      EventType.resumed,
    ];
    listenForEvents((event) {
      if (event.eventType == EventType.paused) {
        appLifecycleState = AppLifecycleState.paused;
      } else if (event.eventType == EventType.resumed) {
        appLifecycleState = AppLifecycleState.resumed;
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
    if (SharedPreferencesService.i.getValue(key: incomingCallKey).isEmpty) {
      return;
    }
    Map<String, dynamic> data = jsonDecode(
      SharedPreferencesService.i.getValue(key: incomingCallKey),
    );
    ChatUserInfo from = ChatUserInfo.fromJson(data["from"]);
    String channelName = data["channel"];
    showCallSheet(from, channelName, initialState: CallState.connected);
    return;
  }

  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  Future<void> updateOrAddConversation(String conversationId) async {
    final chatConversation = await ChatClient.getInstance.chatManager
        .getConversation(conversationId);
    final latestMessage = await chatConversation!.latestMessage();
    final ConversationModel conversation = ConversationModel(
      latestMessage: latestMessage,
      conversation: chatConversation,
      user: (await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
        conversationId,
      ])).values.first,
      unreadCount: await chatConversation.unreadCount(),
    );
    if (pagingController.itemList!
        .map((e) => e.conversation.id)
        .contains(conversation.conversation.id)) {
      final index = pagingController.itemList!
          .map((e) => e.conversation.id)
          .toList()
          .indexOf(conversation.conversation.id);
      pagingController.itemList!.replaceRange(index, index + 1, [conversation]);
    } else {
      pagingController.itemList!.add(conversation);
    }
    setState(() {});
  }

  void removeChatEventHandler() {
    ChatClient.getInstance.chatManager.removeEventHandler(
      'convo_chat_event_handler',
    );
  }

  @override
  dispose() {
    disposeEventListener();
    removeChatEventHandler();
    super.dispose();
  }

  Future<void> getData(String? pageKey) async {
    if (!AgoraRTMService.i.isLoggedIn) {
      pagingController.appendLastPage([]);
      return;
    }
    ChatClient.getInstance.chatManager
        .loadAllConversations()
        .then((value) async {
          final users =
              (await ChatClient.getInstance.userInfoManager.fetchUserInfoById(
                value.map((e) => e.id).toList(),
              )).values.toList();

          final latestMessages = await Future.wait(
            value.map((e) => e.latestMessage()),
          );

          final unreadCounts = await Future.wait(
            value.map((e) => e.unreadCount()),
          );

          final conversations = value.indexed
              .map(
                (conversation) => ConversationModel(
                  conversation: conversation.$2,
                  user: users[conversation.$1],
                  latestMessage: latestMessages[conversation.$1],
                  unreadCount: unreadCounts[conversation.$1],
                ),
              )
              .toList();

          pagingController.appendLastPage(conversations);
        })
        .onError((error, stackTrace) {
          pagingController.error = error;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagedListView<String?, ConversationModel>.separated(
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
            noItemsFoundIndicatorBuilder: (context) => const NoItemsFound(),
            firstPageProgressIndicatorBuilder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingLarge),
              child: Column(
                children: List.generate(4, (index) => const ListTileShimmer()),
              ),
            ),
            itemBuilder: (context, item, index) => ConversationItem(item: item),
          ),
          separatorBuilder: (context, index) => gap,
        ),
      ),
    );
  }
}
