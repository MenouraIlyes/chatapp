import 'package:chatapp/providers/chat_service_provider.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastMessageProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, otherUserID) {
  final user = ref.watch(userProvider).asData?.value;
  if (user != null) {
    return ref
        .watch(chatServiceProvider)
        .getLastMessageStream(user.uid, otherUserID);
  }
  return const Stream.empty();
});
