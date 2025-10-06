import 'package:flutter/material.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../models/name_id.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/network_resource.dart';
import '../../widgets/no_item_found.dart';
import '../../widgets/person_tile.dart';
import '../profile_screen/common_controller.dart';
import '../profile_screen/profile_details_model.dart';
import 'agora_rtm_service.dart';
import 'chats.dart';
import 'mixins/chat_mixin.dart';

List<NameId> usersList = [
  NameId(
    id: "58",
    name: "Zannan",
    third: profileImages.first,
    secondary: "zannan@gmail.com",
  ),
  NameId(
    id: "18",
    name: "Eventxpro",
    third: profileImages[1],
    secondary: "eventxpro@gmail.com",
  ),
  NameId(
    id: "50",
    name: "Adarsh",
    third: profileImages[2],
    secondary: "adarsh@gmail.com",
  ),
  NameId(
    id: "51",
    name: "Afnan",
    third: profileImages[3],
    secondary: "afnan@gmail.com",
  ),
];

class UserListingScreen extends StatefulWidget {
  const UserListingScreen({super.key});

  @override
  State<UserListingScreen> createState() => _UserListingScreenState();
}

class _UserListingScreenState extends State<UserListingScreen>
    with ChatMixin, WidgetsBindingObserver {
  Future<List<NameId>>? _usersFuture;

  Future<void> fetchUsers() async {
    // Replace with real network call when available
    _usersFuture = Future.value(usersList);
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    fetchUsers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      EventListener.i.sendEvent(Event(eventType: EventType.resumed));
    } else if (state == AppLifecycleState.inactive) {
      EventListener.i.sendEvent(Event(eventType: EventType.inactive));
    }
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
                CommonController.i.profileDetails = ProfileDetailsModel(
                  id: item.id,
                  email: item.secondary,
                  name: item.name,
                  image: item.third,
                );
                CommonController.i.initialized = true;

                // ignore: use_build_context_synchronously
                navigate(context, ChatPage.path);
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
