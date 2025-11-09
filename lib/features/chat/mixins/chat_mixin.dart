import 'package:agora_chat_uikit/chat_uikit.dart';

import 'package:flutter/widgets.dart';
import 'package:starter/core/repository.dart';
import 'package:starter/features/chat/agora_rtm_service.dart';
import '../../../core/app_route.dart';
import '../../../main.dart';

mixin ChatMixin {
  ValueNotifier<bool> buttonLoading = ValueNotifier(false);
  void messageUser(
    String id,
    String name,
    String profileImage) async {
    buttonLoading.value = true;
    ChatUIKitProfile? chatProfile = ChatUIKitProvider.instance.getProfileById(
      id,
    );
    if (chatProfile == null) {
      await DataRepository.i.generateRTMToken(
        username: id,
        avatarUrl: profileImage,
        nickname: name,
      );
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
    buttonLoading.value = false;
    navigate(
      navigatorKey.currentContext!,
      ChatUIKitRouteNames.messagesView,
      arguments: MessagesViewArguments(profile: chatProfile),
    );
  }
}
