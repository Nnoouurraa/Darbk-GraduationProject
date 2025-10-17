import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:intl/intl.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Appointment?> getMyAppointment(String userId) async {
    try {
      final doc = await _firestore.collection('appointments').doc(userId).get();
      if (doc.exists) {
        return Appointment.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print("Error fetching appointment: $e");
    }
    return null;
  }

  Future<PhysiotherapistCardModel?> getPhysiotherapistDetails(
    String uid,
  ) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('physiotherapists')
              .doc(uid)
              .get();
      if (doc.exists) {
        return PhysiotherapistCardModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print("Error getting physiotherapist details: $e");
    }
    return null;
  }

  Future<void> bookSlot({
    required String therapistId,
    required DateTime selectedDate,
    required String selectedTime,
    required bool isBooked,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final docRef = FirebaseFirestore.instance
        .collection('physiotherapists')
        .doc(therapistId)
        .collection('availableSlots')
        .doc(formattedDate);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      print('No slots found for this date');
      return;
    }

    final data = snapshot.data()!;
    final slots = List<Map<String, dynamic>>.from(data['slots']);

    // Update the selected slot's `isBooked` field
    final updatedSlots =
        slots.map((slot) {
          if (slot['time'] == selectedTime) {
            return {
              'time': slot['time'],
              'isBooked': isBooked, // mark as booked
            };
          }
          return slot;
        }).toList();

    await docRef.update({'slots': updatedSlots});
  }
}
