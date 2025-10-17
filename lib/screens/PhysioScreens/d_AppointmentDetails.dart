import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/d_UpdatePerfor.dart';
import 'package:intl/intl.dart';

class d_AppointmentDetails extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;
  const d_AppointmentDetails({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  State<d_AppointmentDetails> createState() => _d_AppointmentDetailsState();
}

class _d_AppointmentDetailsState extends State<d_AppointmentDetails> {
  bool _isLoading = true;
  TreatmentPlan? _treatmentPlan;

  @override
  void initState() {
    super.initState();
    fetchTreatmentPlan(widget.appointment.patientId);
  }

  Future<void> fetchTreatmentPlan(String patientId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('treatmentPlans')
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _treatmentPlan = TreatmentPlan.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
    } catch (e) {
      print('Error fetching treatment plan: $e');
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  void _navigateWithFade(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: screen),
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
        title: Text(
          'Session ${widget.appointment.sessionNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF14abc2),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧍‍♂️ Patient Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 6),
                          Text(
                            "${DateFormat('MMM dd yy').format(widget.appointment.date)}\t\t${widget.appointment.time}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 💥 Injuries Section
              const Text(
                "Injuries",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _treatmentPlan == null
                      ? const Center(child: Text('No treatment plan found.'))
                      : Column(
                          children: _treatmentPlan!.injuries.map((injury) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.medical_services_outlined,
                                    color: Color(0xFF14abc2),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      injury.name,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

              const SizedBox(height: 40),

              // 📝 Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _treatmentPlan == null
                      ? null
                      : () => _navigateWithFade(
                            context,
                            UpdateProgressScreen(
                              sessionNumber: widget.appointment.sessionNumber,
                              treatmentPlan: _treatmentPlan!,
                              appointment: widget.appointment,
                            ),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14abc2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Update Performance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
