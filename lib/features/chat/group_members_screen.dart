
import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';
import 'package:flutter/material.dart';

import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../widgets/person_tile.dart';
import '../../widgets/network_resource.dart';
import 'chat_screen.dart';

class GroupMemberListItem extends StatelessWidget {
  final String userId;
  final Future<Map<String, ChatUserInfo>> Function(String) fetchUserInfo;

  const GroupMemberListItem({
    super.key,
    required this.userId,
    required this.fetchUserInfo,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkResource<Map<String, ChatUserInfo>>(
      fetchUserInfo(userId),
      loading: const PersonListingTileShimmer(),
      error: (error) => PersonTile(
        name: userId,
        hasDivider: true,
        trailing: const SizedBox.shrink(),
        onTap: () {
          navigate(
            context,
            ChatScreen.path,
            arguments: ChatScreenArg(id: userId),
          );
        },
      ),
      success: (data) {
        final info = data.values.first;
        return PersonTile(
          name: info.nickName ?? info.userId,
          imageUrl: info.avatarUrl,
          hasDivider: true,
          trailing: const SizedBox.shrink(),
          onTap: () {
            navigate(
              context,
              ChatScreen.path,
              arguments: ChatScreenArg(id: userId),
            );
          },
        );
      },
    );
  }
}

class GroupMembersScreen extends StatefulWidget {
  static const String path = "/group-members";
  final String groupId;

  const GroupMembersScreen({super.key, required this.groupId});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  final List<String> _memberIds = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMembers(initial: true);
    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _cursor != null &&
          _cursor!.isNotEmpty) {
        _fetchMembers();
      }
    });
  }

  Future<void> _fetchMembers({bool initial = false}) async {
    try {
      if (initial) {
        setState(() {
          _loading = true;
          _error = null;
        });
      } else {
        setState(() => _loadingMore = true);
      }
      final ChatCursorResult<String> res = await ChatClient
          .getInstance
          .groupManager
          .fetchMemberListFromServer(
            widget.groupId,
            pageSize: 50,
            cursor: _cursor,
          );
      _cursor = res.cursor?.isEmpty == true ? null : res.cursor;
      _memberIds.addAll(res.data);
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _loadingMore = false;
      });
      logError("Failed to fetch group members: $e");
    }
  }

  Future<void> _refresh() async {
    _cursor = null;
    _memberIds.clear();
    await _fetchMembers(initial: true);
  }

  Future<Map<String, ChatUserInfo>> _fetchUserInfo(String userId) async {
    return await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
      userId,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group members"),
        surfaceTintColor: Colors.transparent,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: context.montserrat40014),
                  gap,
                  ElevatedButton(
                    onPressed: () => _fetchMembers(initial: true),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _loading && _memberIds.isEmpty
                  ? ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) =>
                          const PersonListingTileShimmer(),
                    )
                  : ListView.separated(
                      controller: _controller,
                      itemCount: _memberIds.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox.shrink(),
                      itemBuilder: (context, index) {
                        if (_loadingMore && index == _memberIds.length) {
                          return const Padding(
                            padding: EdgeInsets.all(paddingLarge),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final String userId = _memberIds[index];
                        return GroupMemberListItem(
                          userId: userId,
                          fetchUserInfo: _fetchUserInfo,
                        );
                      },
                    ),
            ),
    );
  }
}
