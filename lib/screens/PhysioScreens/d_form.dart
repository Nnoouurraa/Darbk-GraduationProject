import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/d_Calendar.dart';
import 'package:darbk/screens/PhysioScreens/d_chats.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';
import 'package:darbk/screens/PhysioScreens/d_Patientprofile.dart';

class DForm extends StatefulWidget {
  const DForm({super.key});

  @override
  State<DForm> createState() => _DFormState();
}

class _DFormState extends State<DForm> {
  List<Appointment> appointments = [];
  Map<String, Patient> patientMap = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TreatmentPlan> treatmentPlansMap = {};

  bool loadding = true;
  Future<void> fetchAppointments() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot =
        await _firestore
            .collection('appointments')
            .where('physioId', isEqualTo: uid)
            .get();

    final List<Appointment> loadedAppointments = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final appointmentId = doc.id;
      final patientId = data['patientId'];

      // Fetch the treatment plan and check status
      final treatmentDoc =
          await _firestore
              .collection('treatmentPlans')
              .doc(appointmentId)
              .get();

      if (treatmentDoc.exists && treatmentDoc.data()?['status'] == 'progress') {
        // Fetch patient
        final patientDoc =
            await _firestore.collection('patients').doc(patientId).get();
        final patient = Patient.fromMap(patientDoc.data()!);
        patientMap[appointmentId] = patient;

        // Parse treatment plan
        final treatmentPlan = TreatmentPlan.fromMap(
          treatmentDoc.data()!,
          treatmentDoc.id,
        );
        treatmentPlansMap[appointmentId] = treatmentPlan;

        // Add appointment
        loadedAppointments.add(Appointment.fromMap(data, appointmentId));
      }
    }

    setState(() {
      appointments = loadedAppointments;
      loadding = false;
    });
  }

  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    fetchAppointments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Patients',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(context, 'form'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patient...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  loadding
                      ? Center(child: CircularProgressIndicator())
                      : appointments.isEmpty
                      ? const Center(
                        child: Text(
                          'No data',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                      : ListView.separated(
                        itemCount: appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final patient =
                              patientMap[appointment
                                  .id]; // Use the same doc.id as key
                          final treatmentPlan =
                              treatmentPlansMap[appointment.id];
                          final injuriesText =
                              treatmentPlan?.injuries
                                  .map((e) => e.name)
                                  .join(', ') ??
                              '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DPatientProfile(
                                        patient: patient,
                                        treatmentPlan: treatmentPlan!,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFE5F8FA),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Color(0xFF14abc2),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                            '${patient!.firstName} ${patient.lastName}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              patient.gender == 'Male'
                                                  ? Icons.male
                                                  : Icons.female,
                                              size: 18,
                                              color: Color(0xFF14abc2),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          injuriesText,

                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  BottomAppBar _buildFooter(BuildContext context, String currentScreen) {
    Color activeColor = const Color(0xFF14abc2);
    Color inactiveColor = Colors.grey;

    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _navigateWithFade(context, const DCalendar()),
              child: Icon(
                Icons.calendar_today,
                color:
                    currentScreen == 'calendar' ? activeColor : inactiveColor,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, PhysioHomeScreen()),
              child: Icon(
                Icons.home,
                color: currentScreen == 'home' ? activeColor : inactiveColor,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, DForm()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color:
                        currentScreen == 'form' ? activeColor : inactiveColor,
                  ),
                  if (currentScreen == 'form') Container(color: activeColor),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, const DChats()),
              child: Icon(
                Icons.chat_bubble_outline,
                color: currentScreen == 'chat' ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateWithFade(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
