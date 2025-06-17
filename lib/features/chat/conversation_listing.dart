// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../services/fcm_service.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import '../profile_screen/common_controller.dart';
import 'agora_utils.dart';
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
  loginUser() {
    DataRepository.i
        .generateAgoraToken(CommonController.i.profileDetails!)
        .then((agoraConfig) {
          AgoraUtils.i.initSdk(agoraConfig).then((value) {
            AgoraUtils.i
                .signIn(
                  userid: CommonController.i.profileDetails!.email.toString(),
                  usertoken: agoraConfig.token,
                  avatarUrl: 
                    CommonController.i.profileDetails!.image ?? "",
                  name: CommonController.i.profileDetails?.name ?? "",
                )
                .then((value) async {
                  connected = true;
                  pagingController.refresh();
                });
          });
        });
  }

  addChatEventHandler() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'convo_chat_event_handler',
      ChatEventHandler(
        onMessagesReceived: (messages) async {
          if (messages.first.body.type != MessageType.TXT) return;
          final userinfo =
              (await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
                messages.first.from!,
              ])).values.first;
          await FCMService().showNotification(
            title: userinfo.nickName,
            body: (messages.first.body as ChatTextMessageBody).content,
          );
          EventListener.i.sendEvent(
            Event(
              eventType: EventType.converstaionUpdate,
              data: messages.first.conversationId,
            ),
          );
        },
      ),
    );
    logInfo("convo_chat_event_handler added");
  }

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) => getData(pageKey));

    allowedEvents = [
      EventType.resumed,
      EventType.paused,
      EventType.converstaionUpdate,
    ];
    loginUser();
    listenForEvents((event) {
      if (event.eventType == EventType.paused) {
        ChatClient.getInstance.logout(false).then((value) {
          logInfo("logout soft");
        });
      } else if (event.eventType == EventType.resumed) {
        loginUser();
      } else if (event.eventType == EventType.converstaionUpdate) {
        updateOrAddConversation(event.data);
      }
    });

    addChatEventHandler();

    super.initState();
  }

  updateOrAddConversation(String conversationId) async {
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
    if (pagingController.itemList!.contains(conversation)) {
      final index = pagingController.itemList!.indexOf(conversation);
      pagingController.itemList!.replaceRange(index, index + 1, [conversation]);
    } else {
      pagingController.itemList!.add(conversation);
    }
    setState(() {});
  }

  removeChatEventHandler() {
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

  bool connected = false;

  getData(String? pageKey) async {
    if (!connected) {
      pagingController.appendLastPage([]);
      return;
    }
    ChatClient.getInstance.chatManager
        .fetchConversationsByOptions(
          options: ConversationFetchOptions(cursor: pageKey),
        )
        .then((value) async {
          final users =
              (await ChatClient.getInstance.userInfoManager.fetchUserInfoById(
                value.data.map((e) => e.id).toList(),
              )).values.toList();

          final latestMessages = await Future.wait(
            value.data.map((e) => e.latestMessage()),
          );

          final unreadCounts = await Future.wait(
            value.data.map((e) => e.unreadCount()),
          );

          final conversations = value.data.indexed
              .map(
                (conversation) => ConversationModel(
                  conversation: conversation.$2,
                  user: users[conversation.$1],
                  latestMessage: latestMessages[conversation.$1],
                  unreadCount: unreadCounts[conversation.$1],
                ),
              )
              .toList();
          if (value.cursor == null ||
              value.cursor!.isEmpty ||
              value.cursor == "undefined") {
            pagingController.appendLastPage(conversations);
          } else {
            pagingController.appendPage(conversations, value.cursor);
          }
        })
        .onError((error, stackTrace) {
          pagingController.error = error;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat List")),
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
            firstPageProgressIndicatorBuilder: (context) => Column(
              children: List.generate(4, (index) => const ListTileShimmer()),
            ),
            itemBuilder: (context, item, index) => ConversationItem(item: item),
          ),
          separatorBuilder: (context, index) => gap,
        ),
      ),
    );
  }
}
