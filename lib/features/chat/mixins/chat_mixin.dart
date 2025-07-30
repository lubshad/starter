import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/widgets.dart';
import '../../../core/app_route.dart';
import '../../../main.dart';
import '../../../services/snackbar_utils.dart';
import '../chat_screen.dart';
import '../models/conversation_model.dart';

mixin ChatMixin {
  ValueNotifier<bool> buttonLoading = ValueNotifier(false);
  void messageUser(int id, {BuildContext? context}) {
    buttonLoading.value = true;
    ChatClient.getInstance.userInfoManager
        .fetchUserInfoById([id.toString()])
        .then((value) {
          buttonLoading.value = false;
          navigate(
            // ignore: use_build_context_synchronously
            context ?? navigatorKey.currentContext!,
            ChatScreen.path,
            arguments: ConversationModel(
              conversation: ChatConversation.fromJson({
                "convId": id.toString(),
              }),
              user: value.values.first,
              unreadCount: 0,
            ),
          );
        })
        .onError((error, stackTrace) {
          buttonLoading.value = false;
          showErrorMessage(error);
        });
  }
}
