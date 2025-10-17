import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final DateTime date;
  final String time;
  final String physioId;
  final String patientId;
  final String problem;
  final int sessionNumber;
  final String status;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.physioId,
    required this.patientId,
    required this.problem,
    required this.sessionNumber,
    required this.status,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String documentId) {
    return Appointment(
      id: documentId,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? 'N/A',
      physioId: data['physioId'] ?? 'Unknown',
      patientId: data['patientId'] ?? 'Unknown',
      problem: data['problem'] ?? '',
      sessionNumber: data['sessionNumber'] ?? 1,
      status: data['status'] ?? 'unknown',
    );
  }
}
