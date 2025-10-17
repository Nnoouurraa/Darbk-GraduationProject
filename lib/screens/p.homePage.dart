import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:darbk/screens/BookingScreen.dart';
import 'package:darbk/services/appointment_service.dart';
import 'package:darbk/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:darbk/screens/physiotherapistListScreen.dart';
import 'package:darbk/screens/formScreen.dart';
import 'package:darbk/screens/chatsScreen.dart';
import 'package:darbk/screens/patientProfile.dart';
import 'package:darbk/screens/NotificationScreen.dart';

class HomeP extends StatefulWidget {
  const HomeP({super.key});

  @override
  State<HomeP> createState() => _HomePState();
}

class _HomePState extends State<HomeP> {
  Patient? patient;
  bool isLoading = true;
  Appointment? _appointment;
  TreatmentPlan? _treatmentPlan;

  PhysiotherapistCardModel? _physiotherapist;
  @override
  void initState() {
    super.initState();
    fetchPatientData();
    _fetchAppointment();
    fetchTreatmentPlan();
  }

  Future<void> fetchPatientData() async {
    AuthService authService = AuthService();

    authService.fetchPatientData().then((Patient? modelPatient) {
      setState(() {
        patient = modelPatient;
        isLoading = false;
      });
    });
  }

  Future<void> _fetchAppointment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Step 1: Fetch the appointment
      final appointment = await AppointmentService().getMyAppointment(userId);

      if (appointment != null) {
        print(appointment.physioId);
        // Step 2: Fetch the physiotherapist's details using the uid from the appointment
        PhysiotherapistCardModel? physiotherapist = await AppointmentService()
            .getPhysiotherapistDetails(appointment.physioId);

        // Step 3: Set the data to the state
        setState(() {
          _appointment = appointment;
          _physiotherapist = physiotherapist!;
        });
      } else {
        _appointment = null;
      }
    }
  }

  Future<void> fetchTreatmentPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('treatmentPlans')
              .where('patientId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          _treatmentPlan = TreatmentPlan.fromMap(doc.data(), doc.id);
        });
      }
    }
  }

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

  int getNextSessionNumber() {
    if (_treatmentPlan == null || _treatmentPlan!.sessionsData.isEmpty) {
      return 1;
    }
    // Find the highest sessionNumber + 1
    final sessionNumbers =
        _treatmentPlan!.sessionsData
            .map((session) => session.sessionNumber)
            .toList();

    return (sessionNumbers.isNotEmpty
        ? sessionNumbers.reduce((a, b) => a > b ? a : b) + 1
        : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF14abc2)),
              )
              : patient == null
              ? const Center(child: Text("⚠️ No profile data found."))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      // Treatment plan is null
                      if (_treatmentPlan == null) ...[
                        if (_appointment != null) ...{
                          _buildAppointmentCard(),
                        } else ...{
                          const Text("No upcoming appointments"),
                        },
                        const SizedBox(height: 20),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: Center(
                            child: _buildEmptySection(
                              icon: Icons.healing,
                              text: "No treatment plan in progress",
                            ),
                          ),
                        ),
                      ]
                      // Treatment plan is completed
                      else if (_treatmentPlan!.status == 'completed') ...[
                        const Text("No upcoming appointments"),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: Center(
                            child: _buildEmptySection(
                              icon: Icons.healing,
                              text: "No treatment plan in progress",
                            ),
                          ),
                        ),
                      ]
                      // Treatment plan is in progress
                      else if (_treatmentPlan!.status == 'progress') ...[
                        if (_appointment != null) _buildAppointmentCard(),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGoalsSection(),
                            const SizedBox(height: 20),
                            _buildInjuriesList(),
                          ],
                        ),
                      ],

                      // Treatment Plan Section
                    ],
                  ),
                ),
              ),
    );
  }

  // 📦 Reusable empty state widget
  Widget _buildEmptySection({required IconData icon, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _navigateWithFade(context, Patientprofile()),
              child: Icon(Icons.person_outline, color: Colors.grey),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Color(0xFF14abc2)),
                Container(height: 3, width: 25, color: Color(0xFF14abc2)),
              ],
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, Formscreen()),
              child: Icon(Icons.assignment_outlined, color: Colors.grey),
            ),
            GestureDetector(
              onTap:
                  () => _navigateWithFade(context, PhysiotherapistListScreen()),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, ChatsScreen()),
              child: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF14abc2),
              radius: 24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'Hello, ${patient!.firstName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _navigateWithFade(context, NotificationsScreen()),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTherapistImage(),
          const SizedBox(width: 16),
          _buildAppointmentInfo(),
        ],
      ),
    );
  }

  Widget _buildTherapistImage() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              _physiotherapist!.imagePath.isNotEmpty
                  ? Image.network(
                    _physiotherapist!.imagePath,
                    width: 75,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                  : Icon(Icons.person, size: 75, color: Color(0xFF14abc2)),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
              const SizedBox(width: 4),
              Text(
                _physiotherapist!.experience,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _physiotherapist!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            _physiotherapist!.title,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          if (_appointment!.status == "new" ||
              (_treatmentPlan!.sessionsData.isNotEmpty &&
                  _treatmentPlan!.sessionsData.any(
                    (s) => s.status == 'progress',
                  )))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(_appointment!.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            (_treatmentPlan != null ||
                    _treatmentPlan!.sessionsData[0].status != 'progress')
                ? buildBookNextSessionButton(_treatmentPlan)
                : const SizedBox.shrink(), // fallback if _treatmentPlan is null
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Your Goals ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14abc2),
              ),
            ),
            Icon(Icons.flag, size: 20, color: Color(0xFF14abc2)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8FAFD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              CircularPercentIndicator(
                radius: 65.0,
                lineWidth: 8.0,
                percent:
                    _treatmentPlan!.duration.progress, // Keep it as 0.0 to 1.0
                center: Text(
                  '${(_treatmentPlan!.duration.progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                progressColor: const Color(0xFF14abc2),
                backgroundColor: Colors.black12,
              ),

              const SizedBox(height: 10),
              const Text(
                'Duration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _goalDetailRow('images/image5_7001693.png', '3 month'),
              const SizedBox(height: 6),
              _goalDetailRow(
                'images/image4_7001692.png',
                '${_treatmentPlan!.sessions} Sessions',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goalDetailRow(String imagePath, String text) {
    return Row(
      children: [
        Image.asset(imagePath, width: 16, height: 16),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInjuriesList() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _treatmentPlan!.injuries.map((injury) {
              return _injuryCard(title: injury.name, value: injury.progress);
            }).toList(),
      ),
    );
  }

  Widget _injuryCard({required String title, required double value}) {
    return Container(
      width: 151.453,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFFE8FAFD),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 35.0,
            lineWidth: 6.0,
            percent: value,
            progressColor: Color(0xFF14abc2),
            backgroundColor: Colors.black12,
            center: Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBookNextSessionButton(TreatmentPlan? treatmentPlan) {
    final List<SessionData> sessionsData = treatmentPlan!.sessionsData;
    final int totalSessions = treatmentPlan.sessions;

    // Find the last session with a non-null date
    int completedSessions =
        sessionsData.where((session) => session.date != null).length;

    // Determine next session number to book
    int nextSessionNumber = completedSessions + 1;

    // Hide button if all sessions are booked
    if (completedSessions >= totalSessions) {
      return SizedBox.shrink();
    }

    return CupertinoButton(
      onPressed: () async {
        _navigateWithFade(
          context,
          BookingScreen(
            physiotherapistCardModel: _physiotherapist!,
            nextSession: nextSessionNumber,
          ),
        );
        // int nextSessionNumber = completedSessions + 1;

        // // Update Firestore: mark status and timestamp
      },
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF14abc2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Book Session $nextSessionNumber',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
