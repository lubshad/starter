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
  PagingController<int, NotificationModel> pagingController = PagingController(
    firstPageKey: 1,
  );
  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) => getData(pageKey));
  }

  Future<void> getData(int pageKey) async {
    DataRepository.i.fetchNotifications(pageNo: pageKey).then((value) {
      if (value.isLastPage) {
        pagingController.appendLastPage(value.newItems);
      } else {
        pagingController.appendPage(value.newItems, value.nextPage);
      }
    }).onError((error, stackTrace) {
      pagingController.error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagedListView<int, NotificationModel>.separated(
          padding: const EdgeInsets.all(middlePadding),
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
              children: List.generate(4, (index) => Placeholder()),
            ),
            itemBuilder: (context, item, index) =>
                NotificationListingItem(item: item),
          ),
          separatorBuilder: (context, index) => gapLarge,
        ),
      ),
    );
  }
}
