import 'package:chatapp/providers/chat_service_provider.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(userProvider).asData?.value;
  if (user != null) {
    return ref.watch(chatServiceProvider).getBlockedUsersStream(user.uid);
  }
  return const Stream.empty();
});
