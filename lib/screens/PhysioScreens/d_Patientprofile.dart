import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:darbk/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';

class DPatientProfile extends StatefulWidget {
  final Patient patient;
  final TreatmentPlan treatmentPlan;

  const DPatientProfile({
    super.key,
    required this.patient,
    required this.treatmentPlan,
  });

  @override
  State<DPatientProfile> createState() => _DPatientProfileState();
}

class _DPatientProfileState extends State<DPatientProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late int completedSessions;

  int get age {
    final birthDateTime = widget.patient.birthdate?.toDate();
    if (birthDateTime == null) return 0;
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDateTime.year;
    if (currentDate.month < birthDateTime.month ||
        (currentDate.month == birthDateTime.month &&
            currentDate.day < birthDateTime.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    completedSessions = widget.treatmentPlan.sessionsData
        .where((session) => session.date != null && (session.exercises?.isNotEmpty ?? false))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final treatmentPlan = widget.treatmentPlan;
    final injuries = treatmentPlan.injuries;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Patient File',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: ListView(
          children: [
            _buildPatientHeader(patient),
            const SizedBox(height: 30),
            const Text('Treatment Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Total duration with progress", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            _buildGradientBar(treatmentPlan.duration.progress),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ${treatmentPlan.duration.name}", style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Session Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(treatmentPlan.sessions, (index) {
                  bool isCompleted = index < completedSessions;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF14abc2) : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCompleted ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Injuries Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Track each injury recovery", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            ...injuries.map((injury) {
              final percentage = (injury.progress * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(injury.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 6),
                    _buildGradientBar(injury.progress),
                    const SizedBox(height: 4),
                    Text("Progress: $percentage%", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF14abc2),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("Age: $age | ${patient.gender}", style: const TextStyle(color: Colors.black87)),
                Text("Weight: ${patient.weight}kg | Height: ${patient.height}cm", style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF14abc2).withOpacity(0.9),
                  const Color(0xFF14abc2).withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              title: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF14abc2)),
                  SizedBox(width: 8),
                  Flexible(child: Text('Complete Treatment', overflow: TextOverflow.ellipsis)),
                ],
              ),
              content: const Text('Are you sure you want to complete this treatment plan?', style: TextStyle(fontSize: 15)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes', style: TextStyle(color: Color(0xFF14abc2)))),
              ],
            ),
          );

          if (confirm == true) {
            await _firestore
                .collection('treatmentPlans')
                .doc(widget.treatmentPlan.id)
                .update({'status': "completed"});

            await NotificationService().sendNotification(
              receiverId: widget.treatmentPlan.patientId,
              message: "Your treatment plan has been completed.",
              type: 'Treatment Completed',
              appointmentId: widget.treatmentPlan.appointmentId,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Treatment completed successfully!'),
                backgroundColor: Color(0xFF14abc2),
                duration: Duration(seconds: 2),
              ),
            );

            await Future.delayed(const Duration(seconds: 2));

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PhysioHomeScreen()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14abc2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Complete Treatment', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
