import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  // Stands for Firebase Cloud Messaging
  FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialize() async {
    if (Platform.isIOS) {
      await _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      // Called when the app is in the foreground and we recive a push notification
      onMessage: (Map<String, dynamic> message) async {
        print("on Message: $message");
      },
      // Called when the app has been closed completely and it's opened
      // from the push notification directly
      onLaunch: (Map<String, dynamic> message) async {
        print("on Launch: $message");
        _serializeAndNavigate(message);
      },
      // Called when the app is in the background and it's opened
      // from the push notification
      onResume: (Map<String, dynamic> message) async {
        print("on Resume: $message");
        _serializeAndNavigate(message);
      },
    );
  }

  void _serializeAndNavigate(Map<String, dynamic> message) {
    var notificationData = message['data'];
    var view = message['view'];

    if (view != null) {
      // Navigate to the view
      if (view == 'detalls_compra') {
        // TODO: Fer que vagi cap a la pestanya que toca.
      }
    }
  }

  Future getToken() async {
    return await _fcm.getToken();
  }
}