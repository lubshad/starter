import 'package:flutter/material.dart';

import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/network_resource.dart';
import '../../widgets/no_item_found.dart';
import '../../widgets/person_tile.dart';
import 'agora_rtm_service.dart';
import 'chats.dart';

List<NameId> usersList = [
  NameId(id: "58", name: "Zannan", third: profileImages.first),
  NameId(id: "18", name: "Eventxpro", third: profileImages[1]),
  NameId(id: "50", name: "Adarsh", third: profileImages[2]),
  NameId(id: "51", name: "Afnan", third: profileImages[3]),
];

class UserListingScreen extends StatefulWidget {
  const UserListingScreen({super.key});

  @override
  State<UserListingScreen> createState() => _UserListingScreenState();
}

class _UserListingScreenState extends State<UserListingScreen> {
  Future<List<NameId>>? _usersFuture;

  Future<void> fetchUsers() async {
    // Replace with real network call when available
    _usersFuture = Future.value(usersList);
    setState(() {});
  }

  @override
  void initState() {
    fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Listing")),
      body: buildUserListing(),
    );
  }

  Widget buildUserListing() {
    return NetworkResource<List<NameId>>(
      _usersFuture,
      loading: PersonListingTileShimmer(),
      error: (e) => SizedBox(
        height: 400,
        child: ErrorWidgetWithRetry(exception: e, retry: fetchUsers),
      ),
      success: (items) {
        if (items.isEmpty) return const NoItemsFound();
        return ListView.separated(
          padding: const EdgeInsets.all(padding),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              onTap: () async {
                await AgoraRTMService.i.signOut();
                AgoraRTMService.i
                    .signIn(
                      userid: item.id,
                      avatarUrl: item.third,
                      name: item.name,
                    )
                    .then((value) {
                      for (NameId user in usersList.where(
                        (element) => element.id != item.id,
                      )) {
                        AgoraRTMService.i.sendMessageWithReply(
                          id: user.id,
                          message: "hi",
                        );
                      }
                      navigate(
                        // ignore: use_build_context_synchronously
                        context,
                        ChatPage.path,
                        arguments: item,
                      );
                    });
              },
              title: Text(item.name),
            );
          },
          separatorBuilder: (context, index) => gap,
        );
      },
    );
  }
}
