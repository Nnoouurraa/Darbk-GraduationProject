import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/PhysioScreens/d_AppointmentDetails.dart';
import 'package:darbk/screens/PhysioScreens/diagnosis.dart';
import 'package:darbk/screens/PhysioScreens/d_Calendar.dart';
import 'package:darbk/screens/PhysioScreens/d_form.dart';
import 'package:darbk/screens/PhysioScreens/d_chats.dart';
import 'package:darbk/screens/PhysioScreens/d_Notifications.dart';
import 'package:darbk/screens/PhysioScreens/d_PhysioProfile.dart';
import 'package:darbk/screens/PhysioScreens/history_patients.dart';
import 'package:intl/intl.dart';

class PhysioHomeScreen extends StatefulWidget {
  const PhysioHomeScreen({super.key});

  @override
  State<PhysioHomeScreen> createState() => _PhysioHomeScreenState();
}

class _PhysioHomeScreenState extends State<PhysioHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loadding = true;
  PhysiotherapistCardModel? physiotherapistCardModel;

  List<Appointment> appointments = [];
  Map<String, Patient> patientMap = {};

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchAppointments();
  }

  Future<void> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('physiotherapists').doc(uid).get();
      if (doc.exists) {
        setState(() {
          physiotherapistCardModel = PhysiotherapistCardModel.fromMap(doc.data()!);
          loadding = false;
        });
      }
    }
  }

  Future<void> fetchAppointments() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot = await _firestore
        .collection('appointments')
        .where('physioId', isEqualTo: uid)
        .get();

    final List<Appointment> loadedAppointments = [];
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final appointmentTimestamp = (data['date'] as Timestamp).toDate();

      if (!appointmentTimestamp.isBefore(startOfDay) &&
    appointmentTimestamp.isBefore(endOfDay)) {
        final patientId = data['patientId'];
        final patientDoc = await _firestore.collection('patients').doc(patientId).get();
        final patient = Patient.fromMap(patientDoc.data()!);
        patientMap[doc.id] = patient;
        loadedAppointments.add(Appointment.fromMap(data, doc.id));
      }
    }

    setState(() {
      appointments = loadedAppointments;
      loadding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loadding || physiotherapistCardModel == null
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateWithFade(context, PhysioProfileScreen()),
                      child: Row(
                        children: [
                          physiotherapistCardModel!.imagePath.isEmpty
                              ? const CircleAvatar(
                                  backgroundColor: Color(0xFF14abc2),
                                  radius: 24,
                                  child: Icon(Icons.person, color: Colors.white),
                                )
                              : CircleAvatar(
                                  backgroundColor: const Color(0xFF14abc2),
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                      physiotherapistCardModel!.imagePath),
                                ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Hello, Dr ${physiotherapistCardModel!.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () => _navigateWithFade(
                      context,
                      DNotificationScreen(doctorId: physiotherapistCardModel!.uid),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Schedule",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.archive_outlined, color: Colors.black),
                          onPressed: () => _navigateWithFade(
                            context,
                            const HistoryPatientsScreen(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: patientMap.isEmpty || appointments.isEmpty
                          ? const Center(child: Text("No data"))
                          : ListView.separated(
                              itemCount: appointments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = appointments[index];
                                final patient = patientMap[item.id];
                                final isCompleted = item.status == 'completed';
                                final isNew = item.status == 'new';
                                final isMiddle = item.status == 'middle';
                                final disableTap = isCompleted || (isMiddle && item.sessionNumber == 0);

                                return GestureDetector(
                                  onTap: disableTap
                                      ? null
                                      : () {
                                          _navigateWithFade(
                                            context,
                                            isNew
                                                ? Diagnosis(appointment: item, patient: patient!)
                                                : d_AppointmentDetails(appointment: item, patient: patient!),
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: disableTap
                                          ? Colors.grey[300]
                                          : const Color(0xFFE5F8FA),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            if (isNew)
                                              const Text(
                                                'New',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            const CircleAvatar(
                                              backgroundColor: Color(0xFF14abc2),
                                              radius: 24,
                                              child: Icon(Icons.person, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                patient!.fullName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (!isNew)
                                                Text(
                                                  "Session ${item.sessionNumber}",
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "${DateFormat('MMM dd').format(item.date)}\t\t${item.time}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
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
            ),
            bottomNavigationBar: _buildFooter(context, 'home'),
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
                color: currentScreen == 'calendar' ? activeColor : inactiveColor,
              ),
            ),
            GestureDetector(
              onTap: () {},
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
                    color: currentScreen == 'form' ? activeColor : inactiveColor,
                  ),
                  if (currentScreen == 'form')
                    Container(height: 3, width: 25, color: activeColor),
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
