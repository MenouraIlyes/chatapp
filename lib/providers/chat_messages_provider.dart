import 'package:chatapp/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatMessagesProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, otherUserID) {
  final user = ref.watch(userProvider).asData?.value;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc('chatRoomID')
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
  return const Stream.empty();
});
