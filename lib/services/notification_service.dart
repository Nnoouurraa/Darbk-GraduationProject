import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends a notification to a specific user or doctor
  Future<void> sendNotification({
    required String receiverId,
    required String message,
    required String type, // e.g. 'booking', 'accepted'
    String? appointmentId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': receiverId,
        'message': message,
        'type': type,
        'appointmentId': appointmentId,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
