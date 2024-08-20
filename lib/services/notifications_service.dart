import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messageStreamController = BehaviorSubject<RemoteMessage>();

  // request permission : call this on startup
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print('User declined permission');
    }
  }

  // setup the interactions
  void setupInteractions() {
    // user received message
    FirebaseMessaging.onMessage.listen(
      (event) {
        print('Got a message while in the forgrounf');
        print('Message data: ${event.data}');

        _messageStreamController.sink.add(event);
      },
    );

    // user opened message
    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) {
        print('Message clicked!');
      },
    );
  }

  void dispose() {
    _messageStreamController.close();
  }

  /*
  Setup token listners
  Each device has a token, we will get this token so that we know which device to send a notification to.
  */
  void setupTokenListeners() {
    _firebaseMessaging.getToken().then(
      (token) {
        saveTokenToDatabase(token);
      },
    );

    _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);
  }

  // save device token
  void saveTokenToDatabase(String? token) {
    // get current user id
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // if the current user is logged in and has a device token, save it to data
    if (userId != null && token != null) {
      FirebaseFirestore.instance.collection('Users').doc(userId).set(
        {
          'fcmToken': token,
        },
        SetOptions(merge: true),
      );
    }
  }

  /* Clear device token
    It's important to clear the device token in the case that the user logs out,
    we don't want to be still sending notifications to the device.
    when any user logs back in, the new device token will be saved. 
  */
  Future<void> clearTokenOnLogout(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      print('Token cleared');
    } catch (e) {
      print('Failed to clear token : ${e}');
    }
  }
}
