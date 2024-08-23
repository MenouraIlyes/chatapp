import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersSteam() {
    return _firestore.collection("Users").snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            // loop each individual user
            final user = doc.data();

            // return user
            return user;
          },
        ).toList();
      },
    );
  }

  // get all the users except blocked users
  Stream<List<Map<String, dynamic>>> getUsersSteamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap(
      (snapshot) async {
        // get blocked user ids
        final blockedUserIds = snapshot.docs
            .map(
              (doc) => doc.id,
            )
            .toList();

        // get all users
        final usersSnapshot = await _firestore.collection('Users').get();

        // return as stream list
        return usersSnapshot.docs
            .where(
              (doc) =>
                  doc.data()['email'] != currentUser.email &&
                  !blockedUserIds.contains(doc.id),
            )
            .map(
              (doc) => doc.data(),
            )
            .toList();
      },
    );
  }

  // send messages
  Future<void> sendMessage(String receiverID, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;

    // get timestamp
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      message: message,
      receiverID: receiverID,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // this ensure the chatroomID is the same for any 2 people
    String chatRoomID = ids.join("_");

    // add new message to the database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // get last message as a Stream
  Stream<Map<String, dynamic>?> getLastMessageStream(
      String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    // Listen for real-time updates on the last message in the chat
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    });
  }

  // Report user
  Future<void> reportUser(String messageID, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageID,
      'messageOwnerId': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // create reports collection
    await _firestore.collection("Reports").add(report);
  }

  // Block user
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection("BlockedUsers")
        .doc(userID)
        .set({});
  }

  // Unblock user
  Future<void> UnblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection("BlockedUsers")
        .doc(blockedUserID)
        .delete();
  }

  // Get blocked users stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userID) {
    return _firestore
        .collection('Users')
        .doc(userID)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap(
      (snapshot) async {
        // get list of blocked user id
        final blockedUserIds = snapshot.docs
            .map(
              (doc) => doc.id,
            )
            .toList();

        final userDocs = await Future.wait(
          blockedUserIds.map(
            (id) => _firestore.collection('Users').doc(id).get(),
          ),
        );

        // return as a list
        return userDocs
            .map(
              (doc) => doc.data() as Map<String, dynamic>,
            )
            .toList();
      },
    );
  }
}
