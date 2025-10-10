import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../constants.dart';
import '../../core/repository.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/no_item_found.dart';
import 'models/notification_model.dart';
import 'notification_listing_item.dart';

class NotificationListingScreen extends StatefulWidget {
  static const String path = "/notification-listing";

  const NotificationListingScreen({super.key});

  @override
  State<NotificationListingScreen> createState() =>
      _NotificationListingScreenState();
}

class _NotificationListingScreenState extends State<NotificationListingScreen> {
  late final PagingController<int, NotificationModel> pagingController;

  @override
  void initState() {
    super.initState();
    pagingController = PagingController(
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => _fetchNotifications(pageKey),
    );
  }

  Future<List<NotificationModel>> _fetchNotifications(int pageKey) async {
    final value = await DataRepository.i.fetchNotifications(pageNo: pageKey);
    return value.results;
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagingListener(
          controller: pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, NotificationModel>.separated(
                fetchNextPage: fetchNextPage,
                state: state,
                padding: const EdgeInsets.all(middlePadding),
                builderDelegate: PagedChildBuilderDelegate(
                  firstPageErrorIndicatorBuilder: (context) => SizedBox(
                    height: 400,
                    child: ErrorWidgetWithRetry(
                      exception: state.error as Exception,
                      retry: pagingController.refresh,
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const NoItemsFound(),
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(
                      4,
                      (index) => const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Placeholder(),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, index) =>
                      NotificationListingItem(item: item),
                ),
                separatorBuilder: (context, index) => gapLarge,
              ),
        ),
      ),
    );
  }
}
