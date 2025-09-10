// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class ConversationModel {
  final ChatConversation conversation;
  final ChatUserInfo user;
  final ChatMessage? latestMessage;
  final int unreadCount;
  ConversationModel({
    required this.conversation,
    required this.user,
    this.latestMessage,
    required this.unreadCount,
  }); 

  @override
  bool operator ==(covariant ConversationModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.conversation.id == conversation.id ;
  }

  @override
  int get hashCode {
    return conversation.id.hashCode;
  }

  static ConversationModel fromMap(dynamic e) {
    return ConversationModel(
      conversation: e['conversation'] as ChatConversation,
      user: e['user'] as ChatUserInfo,
      latestMessage: e['latestMessage'] as ChatMessage?,
      unreadCount: e['unreadCount'] as int,
    );
  }
}
