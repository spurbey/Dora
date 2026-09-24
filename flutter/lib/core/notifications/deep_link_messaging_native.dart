import 'package:firebase_messaging/firebase_messaging.dart';

/// Mobile-only FCM tap source. Excluded from web compilation.
Stream<Map<String, dynamic>> openedMessagePayloads() {
  return FirebaseMessaging.onMessageOpenedApp.map((message) {
    final payload = Map<String, dynamic>.from(message.data);
    final messageId = message.messageId;
    if (messageId != null && messageId.isNotEmpty) {
      payload.putIfAbsent('message_id', () => messageId);
    }
    return payload;
  }).where((payload) => payload.isNotEmpty);
}

Future<Map<String, dynamic>?> initialMessagePayload() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage == null) return null;
    final payload = Map<String, dynamic>.from(initialMessage.data);
    final messageId = initialMessage.messageId;
    if (messageId != null && messageId.isNotEmpty) {
      payload.putIfAbsent('message_id', () => messageId);
    }
    return payload.isEmpty ? null : payload;
  } catch (_) {
    return null;
  }
}
