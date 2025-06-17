// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:starter/features/chat/agora_utils.dart';
import 'package:starter/features/chat/widgets/conversation_item.dart';
import 'package:starter/widgets/list_tile_shimmer.dart';

import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/no_item_found.dart';

class ConversationModel {
  final ChatConversation conversation;
  final ChatUserInfo user;
  final ChatMessage? latestMessage;
  final int unreadCount;
  ConversationModel({
    required this.conversation,
    required this.user,
    this.latestMessage,
    required this.unreadCount,
  });
}

class ChatListingScreen extends StatefulWidget {
  static const String path = "/chat-listing";

  final NameId user;

  const ChatListingScreen({super.key, required this.user});

  @override
  State<ChatListingScreen> createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen> {
  PagingController<String?, ConversationModel> pagingController =
      PagingController(firstPageKey: null);
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) => getData(pageKey));
    AgoraUtils.i.initSdk().then((value) {
      AgoraUtils.i
          .signIn(
            userid: widget.user.id,
            usertoken: widget.user.secondary,
            avatarUrl: widget.user.third,
            name: widget.user.name,
          )
          .then((value) async {
            pagingController.refresh();
          });
    });
    super.initState();
  }

  @override
  dispose() {
    AgoraUtils.i.signOut().then((value) {});
    super.dispose();
  }

  getData(String? pageKey) async {
    final connected = await ChatClient.getInstance.isConnected();
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
      appBar: AppBar(title: Text("${widget.user.name} Chat List")),
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
