import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:starter/core/app_route.dart';
import 'package:starter/features/chat/agora_utils.dart';
import 'package:starter/widgets/list_tile_shimmer.dart';
import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/no_item_found.dart';
import 'message_listing_screen.dart';

class ChatListingScreen extends StatefulWidget {
  static const String path = "/chat-listing";

  final NameId user;

  const ChatListingScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatListingScreen> createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen> {
  PagingController<String?, ChatConversation> pagingController =
      PagingController(firstPageKey: null);
  @override
  void initState() {
    pagingController.addPageRequestListener(
      (pageKey) => getData(pageKey),
    );
    AgoraUtils.i.initSdk().then(
      (value) {
        AgoraUtils.i
            .signIn(userid: widget.user.id, usertoken: widget.user.secondary)
            .then(
          (value) {
            pagingController.refresh();
          },
        );
      },
    );
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
            options: ConversationFetchOptions(cursor: pageKey))
        .then((value) {
      if (value.cursor == null ||
          value.cursor!.isEmpty ||
          value.cursor == "undefined") {
        pagingController.appendLastPage(value.data);
        return;
      } else {
        pagingController.appendPage(value.data, value.cursor);
      }
    }).onError(
      (error, stackTrace) {
        pagingController.error = error;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.name} Chat List"),
      ),
      body: RefreshIndicator(
          onRefresh: () async => pagingController.refresh(),
          child: PagedListView<String?, ChatConversation>.separated(
            padding: const EdgeInsets.all(padding),
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate(
                firstPageErrorIndicatorBuilder: (context) => SizedBox(
                      height: 400,
                      child: ErrorWidgetWithRetry(
                          exception: pagingController.error,
                          retry: pagingController.refresh),
                    ),
                noItemsFoundIndicatorBuilder: (context) => const NoItemsFound(),
                firstPageProgressIndicatorBuilder: (context) => Column(
                      children: List.generate(
                        4,
                        (index) => const ListTileShimmer(),
                      ),
                    ),
                itemBuilder: (context, item, index) => ListTile(
                      onTap: () => navigate(
                        context,
                        MessageListingScreen.path,
                        arguments: item,
                      ),
                      title: Text(item.id.toString()),
                    )),
            separatorBuilder: (context, index) => gap,
          )),
    );
  }
}
