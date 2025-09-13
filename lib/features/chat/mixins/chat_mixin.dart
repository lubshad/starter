import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

import 'package:flutter/widgets.dart';
import '../../../core/app_route.dart';
import '../../../main.dart';
import '../../../services/snackbar_utils.dart';
import '../chat_screen.dart';

mixin ChatMixin {
  ValueNotifier<bool> buttonLoading = ValueNotifier(false);
  void messageUser(String id, {BuildContext? context}) {
    buttonLoading.value = true;
    ChatClient.getInstance.userInfoManager
        .fetchUserInfoById([id.toString()])
        .then((value) {
          buttonLoading.value = false;
          navigate(
            // ignore: use_build_context_synchronously
            context ?? navigatorKey.currentContext!,
            ChatScreen.path,
            arguments: ChatScreenArg(id: id.toString()),
          );
        })
        .onError((error, stackTrace) {
          buttonLoading.value = false;
          showErrorMessage(error);
        });
  }
}
