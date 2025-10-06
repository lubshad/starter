import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:starter/core/app_route.dart';
import 'package:starter/features/chat/agora_rtm_service.dart';

import '../../exporter.dart';
import '../../widgets/custom_appbar.dart';

class MessagesViewWrapped extends StatefulWidget {
  const MessagesViewWrapped({super.key, required this.profile});

  final ChatUIKitProfile profile;

  @override
  State<MessagesViewWrapped> createState() => _MessagesViewWrappedState();
}

class _MessagesViewWrappedState extends State<MessagesViewWrapped>
    with PresenceObserver, ChatObserver, MessageObserver {
  final soloud = SoLoud.instance;
  AudioSource? onlineAudio;
  AudioSource? typingAudio;
  AudioSource? messageSend;
  AudioSource? messageRecieved;
  @override
  void initState() {
    super.initState();
    ChatUIKit.instance.addObserver(this);
    fetchCurrentPresenceStatus();
    initilizeAudio();
  }

  @override
  void onTyping(List<String> messages) {
    super.onTyping(messages);
    if (messages.isEmpty) return;
    final currentMessage = messages.firstWhereOrNull(
      (element) => element == widget.profile.id,
    );
    if (currentMessage == null) return;
    soloud.play(typingAudio!);
  }

  @override
  void onMessagesReceived(List<ChatMessage> messages) {
    super.onMessagesReceived(messages);
    if (messages.isEmpty) return;
    final currentMessage = messages.firstWhereOrNull(
      (element) => element.from == widget.profile.id,
    );
    if (currentMessage == null) return;
    if (currentMessage.body.type == MessageType.CMD) return;
    soloud.play(messageRecieved!);
  }

  @override
  void onMessageSendSuccess(String msgId, ChatMessage message) {
    super.onMessageSendSuccess(msgId, message);
    if (message.body.type == MessageType.CMD) return;
    soloud.play(messageSend!);
  }

  void initilizeAudio() async {
    await soloud.init();
    onlineAudio = await soloud.loadAsset(Assets.sounds.online);
    typingAudio = await soloud.loadAsset(Assets.sounds.typing);
    messageSend = await soloud.loadAsset(Assets.sounds.messageSend);
    messageRecieved = await soloud.loadAsset(Assets.sounds.messageRecieved);
  }

  @override
  void onPresenceStatusChanged(List<Presence> list) {
    super.onPresenceStatusChanged(list);
    if (list.isEmpty) return;
    final currentUserPresence = list.firstWhereOrNull(
      (element) => element.publisher == widget.profile.id,
    );
    if (currentUserPresence == null) return;
    presenceStatus.value = currentUserPresence.statusDescription;
    if (currentUserPresence.statusDescription == "Online") {
      soloud.play(onlineAudio!);
    }
  }

  @override
  dispose() {
    ChatUIKit.instance.removeObserver(this);
    soloud.deinit();
    super.dispose();
  }

  ValueNotifier<String> presenceStatus = ValueNotifier("Offline");

  void fetchCurrentPresenceStatus() async {
    try {
      final status = await ChatUIKit.instance.fetchPresenceStatus(
        members: [widget.profile.id],
      );
      if (status.isNotEmpty) {
        final currentStatus = status.first.statusDescription;
        presenceStatus.value = currentStatus.isNotEmpty
            ? currentStatus
            : "Offline";
      }
      await ChatUIKit.instance.subscribe(
        members: [widget.profile.id],
        expiry: Duration(hours: 1).inSeconds,
      );
    } catch (e) {
      logError("Error fetching presence status: $e");
      presenceStatus.value = "Offline";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: widget.profile.showName ?? "",
        subtitle: ValueListenableBuilder(
          valueListenable: presenceStatus,
          builder: (context, value, child) {
            return Row(
              children: [
                Icon(
                  value == "Online" ? Icons.circle : Icons.circle,
                  size: 10,
                  color: value == "Online"
                      ? Color(0xff008000)
                      : Color(0xff666666),
                ),
                gap,
                Text(
                  value,
                  style: context.bodySmall.copyWith(color: Color(0xff666666)),
                ),
              ],
            );
          },
        ),
        actions: Builder(
          builder: (context) {
            final isGroup = widget.profile.type == ChatUIKitProfileType.group;
            if (!isGroup) {
              return Visibility(
                visible: voicecallEnabled,
                child: InkWell(
                  onTap: () => AgoraRTMService.i.startCall(widget.profile),
                  child: Icon(Icons.call),
                ),
              );
            }
            return InkWell(
              onTap: () {
                navigate(
                  context,
                  ChatUIKitRouteNames.groupMembersView,
                  arguments: GroupMembersViewArguments(profile: widget.profile),
                );
              },
              child: Icon(Icons.group),
            );
          },
        ),
      ),
      body: MessagesView(
        enableAppBar: false,
        profile: widget.profile,
        onMoreActionsItemsHandler: (context, items) {
          items.removeWhere(
            (element) => [
              ChatUIKitActionType.contactCard,
              ChatUIKitActionType.file,
            ].contains(element.actionType),
          );
          return items;
        },
      ),
    );
  }
}
