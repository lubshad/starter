import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'conversation_listing.dart';

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

  Future<void> getData(int pageKey) async {
    pagingController.appendLastPage([
      NameId(
        id: "lubshad",
        name: "Lubshad",
        secondary:
            "007eJxTYFjMZb/ujGV26q+afe/Eg+TUKlODbt7b80FF7Z32f4uoTb0KDGlJiUaGRslGJhZpZibGBpYWBkbJFsmmaRZppqmWhuZGe18EZAjwMTCkCR5lZGRgZWBkYGQA8dkZckqTijMSUwBkgB92",
        third: profileImages.first,
      ),

      NameId(
        id: "zannan",
        name: "Zannan",
        third: profileImages[1],
        secondary:
            "007eJxTYNAv1SjZqjRdo6zh+/9IpdQkW36x3zu+dm/il4val/96VbkCQ1pSopGhUbKRiUWamYmxgaWFgVGyRbJpmkWaaaqloblR/Wb/jIZARoZmryZWRgZWBkYgBPFVGCySLNOMTBINdE3MTRJ1DQ3TDHQtzAwMdA3NLRNNLCwt0ozMDAD0RCVJ",
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
            onTap: () => navigate(
              context,
              ConversationListingScreen.path,
              arguments: item,
            ),
            title: Text(item.name),
          ),
        ),
        separatorBuilder: (context, index) => gap,
      ),
    );
  }
}
