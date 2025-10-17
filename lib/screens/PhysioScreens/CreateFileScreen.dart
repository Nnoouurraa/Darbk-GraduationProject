import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';

class CreateFileScreen extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;
  const CreateFileScreen({super.key, required this.appointment, required this.patient});

  @override
  State<CreateFileScreen> createState() => _CreateFileScreenState();
}

class _CreateFileScreenState extends State<CreateFileScreen> {
  final List<String> injuriesList = [
    "Low Back Pain", "Herniated Disc", "Neck Pain / Whiplash",
    "Frozen Shoulder", "Rotator Cuff Tear", "Shoulder Impingement",
    "Tennis Elbow", "Golfer’s Elbow", "Carpal Tunnel Syndrome",
    "Hip Bursitis", "Hip Labral Tear", "ACL Tear", "Meniscus Tear",
    "Patellofemoral Pain Syndrome", "Ankle Sprain", "Achilles Tendonitis",
    "Plantar Fasciitis", "Hamstring Strain", "Muscles", "Balance", "Tendon",
  ];

  String selectedDuration = "2 months";
  String customDuration = "";
  int selectedSession = 3;
  final Set<String> selectedInjuries = {};

  final List<String> durationOptions = [
    "2 months", "3 months", "4 months", "5 months", "6 months",
    "7 months", "8 months", "9 months", "1 year", "Other",
  ];

  final List<int> sessionOptions = List.generate(22, (index) => index + 3);

  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showMissingInjuriesAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFDEAEA),
        title: Row(
          children: const [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Missing Information',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          "You must fill all requirements \ check again.",
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (selectedInjuries.isEmpty) {
      _showMissingInjuriesAlert();
      return;
    }

    final String finalDurationName = selectedDuration == "Other" ? customDuration : selectedDuration;
    final durationData = {'name': finalDurationName, 'level': 'On Plan', 'progress': 0};
    final injuriesData = selectedInjuries.map((injuryName) => {
      'name': injuryName,
      'level': 'On Plan',
      'progress': 0,
    }).toList();

    final emptySessions = List.generate(
      selectedSession,
      (index) => {
        'sessionNumber': index + 1,
        'exercises': [],
        'notes': '',
        'date': null,
        'status': null,
      },
    );

    final treatmentPlan = {
      'status': "progress",
      'duration': durationData,
      'sessions': selectedSession,
      'sessionsData': emptySessions,
      'injuries': injuriesData,
      'appointmentId': widget.appointment.id,
      'patientId': widget.appointment.patientId,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('treatmentPlans')
          .doc(widget.appointment.id)
          .set(treatmentPlan);

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({'status': 'middle'});

      await NotificationService().sendNotification(
        receiverId: widget.appointment.patientId,
        message: "Your treatment plan has been created.",
        type: 'Create File',
        appointmentId: widget.appointment.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Treatment plan submitted! Patient will receive it shortly."),
          backgroundColor: Color(0xFF14abc2),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PhysioHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("New Patient File", style: TextStyle(color: Color(0xFF14abc2), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          // Patient Info
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
                  radius: 30,
                  backgroundColor: Color(0xFF14abc2),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.patient.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Age: ${calculateAge(widget.patient.birthdate.toDate())} | ${widget.patient.gender}"),
                      Text("Weight: ${widget.patient.weight} | Height: ${widget.patient.height}"),
                      const SizedBox(height: 6),
                      Text("Problem: ${widget.appointment.problem}", style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Duration
          const Text("Treatment Duration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedDuration,
            items: durationOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
            onChanged: (value) => setState(() => selectedDuration = value ?? "2 months"),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          if (selectedDuration == "Other")
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextFormField(
                onChanged: (val) => customDuration = val,
                decoration: InputDecoration(
                  hintText: "Enter custom duration",
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF14abc2)),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Sessions
          const Text("Number of Sessions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: selectedSession,
            items: sessionOptions.map((s) => DropdownMenuItem(value: s, child: Text("$s sessions"))).toList(),
            onChanged: (val) => setState(() => selectedSession = val ?? 3),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 30),

          // Injuries
          const Text("Select Injuries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...injuriesList.map((injury) => CheckboxListTile(
            value: selectedInjuries.contains(injury),
            onChanged: (val) => setState(() {
              val == true ? selectedInjuries.add(injury) : selectedInjuries.remove(injury);
            }),
            title: Text(injury),
            activeColor: const Color(0xFF14abc2),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.trailing,
          )),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14abc2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
