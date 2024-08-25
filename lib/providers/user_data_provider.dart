import 'package:chatapp/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDataProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
  final user = ref.watch(userProvider).asData?.value;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .snapshots();
  }
  return const Stream.empty();
});

final userDataStateProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final userDataFutureProvider =
    FutureProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(userProvider).asData?.value;
  if (user != null) {
    return FirebaseFirestore.instance.collection("Users").doc(user.uid).get();
  }
  throw Exception('User not found');
});
