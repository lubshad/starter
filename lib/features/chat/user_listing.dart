import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'chat_listing.dart';

class UserListingScreen extends StatefulWidget {
  const UserListingScreen({
    super.key,
  });

  @override
  State<UserListingScreen> createState() => _UserListingScreenState();
}

class _UserListingScreenState extends State<UserListingScreen> {
  PagingController<int, NameId> pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) => getData(pageKey));
  }

  getData(int pageKey) async {
    pagingController.appendLastPage([
      NameId(
          id: "lubshad",
          name: "Lubshad",
          secondary:
              "007eJxTYIgv2Dk3ZVHy6eOvfe965W/dkGb86WhdaN0zhW7zTsNXUlsVGNKSEo0MjZKNTCzSzEyMDSwtDIySLZJN0yzSTFMtDc2NugV8MhoCGRnYju1hZmRgZWAEQhBfhcHIwszUONHAQNfE3CRR19AwzUA30dgsFUgYphilGVtamJkZAgDhaicp"),
      NameId(
          id: "zannan",
          name: "Zannan",
          secondary:
              "007eJxTYEgKicyfOUdxxz2fxkWf0ta6r7DZuK0n31pNbs260s70p0IKDGlJiUaGRslGJhZpZibGBpYWBkbJFsmmaRZppqmWhuZG6wR8MhoCGRlS3RmYGBlYGRiBEMRXYbBIskwzMkk00DUxN0nUNTRMM9C1MDMw0DU0t0w0sbC0SDMyMwAAC1okwQ=="),
      NameId(
          id: "adarsh",
          name: "Adarsh",
          secondary:
              "007eJxTYLCxfLVnwyv/eIl9Tbf22i/vbYiqPXPhltP9tQtO298zjxFQYEhLSjQyNEo2MrFIMzMxNrC0MDBKtkg2TbNIM021NDQ34tnrldEQyMjA/3QjEyMDKwMjEIL4KgypBilp5mapBrom5haGuoaGaQa6lonJabqpxskpicYGieaWyYkAKfspIw=="),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Listing"),
      ),
      body: buildUserListing(),
    );
  }

  Widget buildUserListing() {
    return RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagedListView<int, NameId>.separated(
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
              firstPageProgressIndicatorBuilder: (context) => ListTileShimmer(),
              itemBuilder: (context, item, index) => ListTile(
                    onTap: () => navigate(context, ChatListingScreen.path,
                        arguments: item),
                    title: Text(item.name),
                  )),
          separatorBuilder: (context, index) => gap,
        ));
  }
}
