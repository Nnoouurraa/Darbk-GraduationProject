// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:darbk/screens/p.homePage.dart';
import 'package:darbk/services/appointment_service.dart';
import 'package:darbk/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;
  final int nextSession;
  final String selectedTime;
  final PhysiotherapistCardModel therapist;

  const AppointmentDetailsScreen({
    super.key,
    required this.selectedDate,
    required this.nextSession,
    required this.selectedTime,
    required this.therapist,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _problemController = TextEditingController();
  final DateTime patientDOB = DateTime(2000, 5, 10); // TEMP: replace later
  final String gender = "Female"; // TEMP: replace with dynamic gender if needed

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _confirmBooking() async {
    final patientId = FirebaseAuth.instance.currentUser?.uid;
    if (patientId == null) return;

    final int nextSessionNumber = widget.nextSession;

    if (nextSessionNumber > 0) {
      // Updating existing treatment session
      final treatmentPlanRef = FirebaseFirestore.instance
          .collection('treatmentPlans')
          .doc(patientId);
      final doc = await treatmentPlanRef.get();

      if (doc.exists) {
        final sessionsData = List<Map<String, dynamic>>.from(doc['sessionsData']);
        for (var i = 0; i < sessionsData.length; i++) {
          if (sessionsData[i]['sessionNumber'] == nextSessionNumber) {
            sessionsData[i]['status'] = 'progress';
            break;
          }
        }
        await treatmentPlanRef.update({'sessionsData': sessionsData});
      }

      await FirebaseFirestore.instance.collection('appointments').doc(patientId).update({
        'status': 'middle',
        'sessionNumber': nextSessionNumber,
        'date': widget.selectedDate,
        'time': widget.selectedTime,
        'problem': _problemController.text,
        'timestamp': Timestamp.now(),
      });

      await AppointmentService().bookSlot(
        therapistId: widget.therapist.uid,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        isBooked: true,
      );

      Navigator.of(context).push(_confirmationRoute());
    } else {
      // First-time appointment
      final appointmentData = {
        'date': widget.selectedDate,
        'time': widget.selectedTime,
        'patientId': patientId,
        'physioId': widget.therapist.uid,
        'problem': _problemController.text,
        'sessionNumber': 0,
        'status': 'new',
        'timestamp': FieldValue.serverTimestamp(),
      };

      final patientDoc =
          await FirebaseFirestore.instance.collection('patients').doc(patientId).get();

      if (patientDoc.exists) {
        final patient = Patient.fromMap(patientDoc.data()!);
        final fullName = patient.fullName;
        final String formattedDate =
            DateFormat('MMMM d, y – h:mm a').format(widget.selectedDate);

        await NotificationService().sendNotification(
          receiverId: widget.therapist.uid,
          message:
              "New booking: $fullName scheduled Session $nextSessionNumber on $formattedDate.",
          type: 'booking',
          appointmentId: patientId,
        );
      }

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(patientId)
          .set(appointmentData);

      await AppointmentService().bookSlot(
        therapistId: widget.therapist.uid,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        isBooked: true,
      );

      await NotificationService().sendNotification(
        receiverId: widget.therapist.uid,
        message: 'A new patient has booked a session.',
        type: 'booking',
        appointmentId: patientId,
      );

      Navigator.of(context).push(_confirmationRoute());
    }
  }

  PageRouteBuilder _confirmationRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const ConfirmationScreen(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, y').format(widget.selectedDate);
    final formattedTime = widget.selectedTime;
    final age = calculateAge(patientDOB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Therapist Info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.therapist.imagePath.isNotEmpty
                        ? Image.network(
                            widget.therapist.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF14abc2),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.therapist.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(widget.therapist.title, style: const TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.therapist.experience,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _infoRow('Date & Time', '$formattedDate, $formattedTime'),
              const SizedBox(height: 16),
              _infoRow('Age', '$age years'),
              const SizedBox(height: 16),
              _infoRow('Gender', gender),

              const SizedBox(height: 24),
              const Text(
                'Tell us about your problem',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _problemController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your issue...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF14abc2),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14abc2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}


// ------------------- Confirmation Screen --------------------

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeP()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14abc2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Your appointment\nhas been confirmed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You will be redirected to the home screen shortly.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
