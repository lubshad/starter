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
  const UserListingScreen({super.key});

  @override
  State<UserListingScreen> createState() => _UserListingScreenState();
}

class _UserListingScreenState extends State<UserListingScreen> {
  PagingController<int, NameId> pagingController = PagingController(
    firstPageKey: 1,
  );
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
            "007eJxTYLCTujJp52GJj+1CB6cbdr2avyNw7tGXe0TdA/vWdHILPuxRYEhLSjQyNEo2MrFIMzMxNrC0MDBKtkg2TbNIM021NDQ3kkz2zWgIZGRgOcfPxMjAysAIhCC+CoORhZmpcaKBga6JuUmirqFhmoFuorFZKpAwTDFKM7a0MDMzBABksCW1",
        third: profileImages.first,
      ),

      NameId(
        id: "zannan",
        name: "Zannan",
        third: profileImages[1],
        secondary:
            "007eJxTYMjaWSqwzngf80kJk+BwVzuXj3rl9RNaWrRnizr+3/Tgwk0FhrSkRCNDo2QjE4s0MxNjA0sLA6Nki2TTNIs001RLQ3MjtWTfjIZARoasDc+YGBlYGRiBEMRXYbBIskwzMkk00DUxN0nUNTRMM9C1MDMw0DU0t0w0sbC0SDMyMwAAzG4lFA==",
      ),
      NameId(
        id: "adarsh",
        name: "Adarsh",
        third: profileImages[2],
        secondary:
            "007eJxTYLCxfLVnwyv/eIl9Tbf22i/vbYiqPXPhltP9tQtO298zjxFQYEhLSjQyNEo2MrFIMzMxNrC0MDBKtkg2TbNIM021NDQ34tnrldEQyMjA/3QjEyMDKwMjEIL4KgypBilp5mapBrom5haGuoaGaQa6lonJabqpxskpicYGieaWyYkAKfspIw==",
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Listing")),
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
              retry: pagingController.refresh,
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => const NoItemsFound(),
          firstPageProgressIndicatorBuilder: (context) => ListTileShimmer(),
          itemBuilder: (context, item, index) => ListTile(
            onTap: () =>
                navigate(context, ChatListingScreen.path, arguments: item),
            title: Text(item.name),
          ),
        ),
        separatorBuilder: (context, index) => gap,
      ),
    );
  }
}
