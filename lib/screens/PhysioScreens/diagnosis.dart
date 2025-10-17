// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/screens/PhysioScreens/CreateFileScreen.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';
import 'package:darbk/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Diagnosis extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;  
  const Diagnosis({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  State<Diagnosis> createState() => _DiagnosisState();
}

class _DiagnosisState extends State<Diagnosis> {
  void _navigateWithFade(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showMessageThenNavigateToCreateFile(BuildContext context) async {
    await showDialog(  
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              "Success!",
              style: TextStyle(
                color: Color(0xFF14abc2),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Well done! Your diagnosis is a step toward healing.",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF14abc2),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    _navigateWithFade(
      context,
      CreateFileScreen(
        appointment: widget.appointment,
        patient: widget.patient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          'New Patient',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 💠 Patient Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF14abc2),
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.fullName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DateFormat('MMM dd yy').format(widget.appointment.date)}\t\t${widget.appointment.time}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // Scrollable Info Chips Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _infoChip("Gender: ${widget.patient.gender}"),
                              const SizedBox(width: 10),
                              _infoChip("Weight: ${widget.patient.weight}"),
                              const SizedBox(width: 10),
                              _infoChip("Height: ${widget.patient.height}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🩺 Patient Problem Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Patient Problem",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF14abc2).withOpacity(0.2)),
              ),
              child: Text(
                widget.appointment.problem,
                style: const TextStyle(fontSize: 15),
              ),
            ),

            const Spacer(),

            // 🚀 Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _showMessageThenNavigateToCreateFile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14abc2),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Create File"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(widget.appointment.id)
                            .delete();

                        await NotificationService().sendNotification(
                          receiverId: widget.appointment.patientId,
                          message: "Diagnosis is incomplete. Kindly book another session to continue your treatment plan .",
                          type: 'Reschedule',
                          appointmentId: widget.appointment.id,
                        );

                        // Show success SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Appointment cancelled. Notification sent.",
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Navigate after short delay (to ensure SnackBar is visible)
                        await Future.delayed(const Duration(milliseconds: 800));

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => PhysioHomeScreen()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade800,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Preschedule"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🧩 Reusable info chip
  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14abc2).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
      ),
    );
  }
}
