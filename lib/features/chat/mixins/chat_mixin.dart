import 'package:agora_chat_uikit/chat_uikit.dart';

import 'package:flutter/widgets.dart';
import '../../../core/app_route.dart';
import '../../../main.dart';

mixin ChatMixin {
  ValueNotifier<bool> buttonLoading = ValueNotifier(false);
  void messageUser(String id, {BuildContext? context}) async {
    buttonLoading.value = true;
    ChatUIKitProfile? chatProfile = ChatUIKitProvider.instance.getProfileById(
      id,
    );
    if (chatProfile == null) {
      final chatUserInfo =
          (await ChatClient.getInstance.userInfoManager.fetchUserInfoById([
            id,
          ])).values.firstOrNull;
      if (chatUserInfo == null) return;
      chatProfile = ChatUIKitProfile.contact(
        id: id,
        nickname: chatUserInfo.nickName,
        avatarUrl: chatUserInfo.avatarUrl,
      );
    }
    ChatUIKitProvider.instance.addProfiles([chatProfile]);
    navigate(
      context ?? navigatorKey.currentContext!,
      ChatUIKitRouteNames.messagesView,
      arguments: MessagesViewArguments(profile: chatProfile),
    );
  }
}
