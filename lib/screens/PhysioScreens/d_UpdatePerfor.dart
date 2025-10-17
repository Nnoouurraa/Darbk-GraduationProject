
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:darbk/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';

class UpdateProgressScreen extends StatefulWidget {
  final int sessionNumber;
  final Appointment appointment;
  final TreatmentPlan treatmentPlan;

  const UpdateProgressScreen({
    super.key,
    required this.sessionNumber,
    required this.treatmentPlan,
    required this.appointment,
  });

  @override
  State<UpdateProgressScreen> createState() => _UpdateProgressScreenState();
}

class _UpdateProgressScreenState extends State<UpdateProgressScreen> {
  final Map<String, String> injuryStatus = {};
  String timingStatus = 'On Plan';
  final TextEditingController physioNoteController = TextEditingController();

  final List<String> options = ['On Plan', 'Advanced', 'Late'];

  final List<String> allExercises = [
    'Squat', 'Bridge with Leg', 'Bunded Side Walk', 'Slow Split Squats',
    'Deadlift Hip Hinge', 'Resisted Leg Extension', 'Lateral Lunge',
    'Heel Raises', 'Hamstring Stretch', 'Doorway Pec Stretch',
    'Cat-Cow Stretch', 'Bird-Dog'
  ];

  final Map<String, bool> selectedExercises = {};
  final Map<String, String> frequencyPerWeek = {};

  void _handleSubmit() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(children: const [
          Icon(Icons.check_circle, color: Color(0xFF14abc2)),
          SizedBox(width: 8),
          Text("Success!", style: TextStyle(
            color: Color(0xFF14abc2), fontWeight: FontWeight.bold))
        ]),
        content: const Text("Update submitted successfully!",
          style: TextStyle(fontSize: 15, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF14abc2)),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PhysioHomeScreen()),
      (route) => false,
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(children: const [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text("Incomplete Data", style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold))
        ]),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _submitTreatmentPlan() async {
    if (physioNoteController.text.trim().isEmpty) {
      _showErrorAlert("Please fill all requirements before submitting. \ check again");
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('treatmentPlans')
          .doc(widget.treatmentPlan.id);

      final snapshot = await docRef.get();
      final data = snapshot.data();
      List<dynamic> sessionsData = data?['sessionsData'] ?? [];

      final updatedExercises = selectedExercises.entries
          .where((e) => e.value)
          .map((e) => {
            'name': e.key,
            'frequencyPerWeek': frequencyPerWeek[e.key] ?? '0',
          }).toList();

      final sessionIndex = sessionsData.indexWhere(
        (s) => s['sessionNumber'] == widget.sessionNumber,
      );

      final newDate = DateTime.now();

      if (sessionIndex != -1) {
        sessionsData[sessionIndex] = {
          ...sessionsData[sessionIndex],
          'exercises': updatedExercises,
          'notes': physioNoteController.text,
          'date': newDate,
          'status': 'booked',
        };
      } else {
        sessionsData.add({
          'sessionNumber': widget.sessionNumber,
          'date': newDate,
          'notes': physioNoteController.text,
          'exercises': updatedExercises,
          'status': 'booked',
        });
      }

      double calculateProgressIncrement(String status, int totalSessions) {
        final timeline = 1 / totalSessions;
        switch (status) {
          case 'Advanced': return timeline * 1.5;
          case 'On Plan': return timeline * 1.2;
          case 'Late': return timeline * 1.0;
          default: return timeline;
        }
      }

      final totalSessions = widget.treatmentPlan.sessions;
      final oldDurationProgress = widget.treatmentPlan.duration.progress ?? 0.0;
      final durationIncrement = calculateProgressIncrement(
        timingStatus, totalSessions);
      final newDurationProgress =
        (oldDurationProgress + durationIncrement).clamp(0.0, 1.0);

      final updatedInjuries = widget.treatmentPlan.injuries.map((injury) {
        final level = injuryStatus[injury.name] ?? 'On Plan';
        final oldProgress = injury.progress ?? 0.0;
        final increment = calculateProgressIncrement(level, totalSessions);
        final newProgress = (oldProgress + increment).clamp(0.0, 1.0);

        return {
          'name': injury.name,
          'level': level,
          'progress': newProgress,
        };
      }).toList();

      final treatmentPlan = {
        'duration': {
          'name': widget.treatmentPlan.duration.name,
          'level': timingStatus,
          'progress': newDurationProgress,
        },
        'injuries': updatedInjuries,
        'appointmentId': widget.appointment.id,
        'patientId': widget.appointment.patientId,
        'sessionsData': sessionsData,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.update(treatmentPlan);
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({'status': 'completed'});

      await NotificationService().sendNotification(
        receiverId: widget.appointment.patientId,
        message: "Your session details have been updated.",
        type: 'Update Session',
        appointmentId: widget.appointment.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Treatment plan submitted! Patient will receive it shortly."),
          backgroundColor: Color(0xFF14abc2),
          duration: Duration(seconds: 1),
        ),
      );

      _handleSubmit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 Widget _buildDropdown(String value, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          options
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildExerciseCheckbox(String exerciseName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(width: 1.5, color: Color(0xFF14abc2)),
              visualDensity: VisualDensity.compact,
            ),
          ),
          child: CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
            dense: true,
            title: Text(exerciseName, style: const TextStyle(fontSize: 15)),
            value: selectedExercises[exerciseName] ?? false,
            activeColor: const Color(0xFF14abc2),
            onChanged: (value) {
              setState(() {
                selectedExercises[exerciseName] = value ?? false;
              });
            },
          ),
        ),
        if (selectedExercises[exerciseName] == true)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 12),
            child: Row(
              children: [
                const Text(
                  "Times/week:",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  height: 32,
                  child: TextFormField(
                    initialValue: frequencyPerWeek[exerciseName] ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed <= 7) {
                        setState(() {
                          frequencyPerWeek[exerciseName] = val;
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF14abc2),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF14abc2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Performance Session',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session ${widget.sessionNumber}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ...widget.treatmentPlan.injuries.map(
                    (injury) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            injury.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Select current status",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            injuryStatus[injury.name] ?? 'On Plan',
                            (val) {
                              setState(() {
                                injuryStatus[injury.name] = val ?? 'On Plan';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Home Exercise",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select performed exercises and set frequency",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ...allExercises.map(_buildExerciseCheckbox),
                  const SizedBox(height: 24),
                  const Text(
                    "Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(timingStatus, (val) {
                    setState(() {
                      timingStatus = val ?? 'On Plan';
                    });
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    "Physiotherapist Notes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Leave session-specific comments or observations",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: physioNoteController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Write your notes here...",
                      filled: true,
                      fillColor: const Color(0xFFF6F6F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTreatmentPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14abc2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 