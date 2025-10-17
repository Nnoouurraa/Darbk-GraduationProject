import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/patient_model.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';
import 'package:darbk/screens/PhysioScreens/d_form.dart';
import 'package:darbk/screens/PhysioScreens/d_chats.dart';

class DCalendar extends StatefulWidget {
  const DCalendar({super.key});

  @override
  State<DCalendar> createState() => _DCalendarState();
}

class _DCalendarState extends State<DCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _timeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = true;
  PhysiotherapistCardModel? physiotherapistCardModel;
  List<Appointment> appointments = [];
  Map<String, Patient> patientMap = {};

  void _changeMonth(bool next) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + (next ? 1 : -1),
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDay = date;
    });
  }

  List<String> _getAppointmentsForSelectedDay() {
    if (_selectedDay == null) return [];

    String selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final filtered = appointments.where((appointment) {
      final appointmentDate = DateFormat('yyyy-MM-dd').format(appointment.date);
      return appointmentDate == selectedDate;
    }).toList();

    return filtered.map((a) {
      final patient = patientMap[a.patientId];
      final time = DateFormat('hh:mm a').format(a.date);
      return "$time - ${patient?.fullName ?? 'Unknown'}";
    }).toList();
  }

  Future<void> fetchAppointments() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot = await _firestore
        .collection('appointments')
        .where('physioId', isEqualTo: uid)
        .get();

    final List<Appointment> loadedAppointments = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final patientId = data['patientId'];

      final patientDoc =
          await _firestore.collection('patients').doc(patientId).get();
      final patient = Patient.fromMap(patientDoc.data()!);

      patientMap[patientId] = patient;

      loadedAppointments.add(Appointment.fromMap(data, doc.id));
    }

    setState(() {
      appointments = loadedAppointments;
      loading = false;
    });
  }

  Future<void> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('physiotherapists').doc(uid).get();
      if (doc.exists) {
        setState(() {
          physiotherapistCardModel = PhysiotherapistCardModel.fromMap(doc.data()!);
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchAppointments();
  }

  void _showFridayAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFDEAEA),
        title: Row(
          children: const [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Clinics are closed on Friday!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Sorry, you cannot add a session on Friday as all clinics are closed.',
          style: TextStyle(color: Colors.black87, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  void _showSuccessAlert(String formattedDate) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Color(0xFF14abc2), size: 28),
            SizedBox(width: 8),
            Text(
              'Success!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF14abc2),
              ),
            ),
          ],
        ),
        content: Text(
          "You added a new session for $formattedDate successfully.",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF14abc2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = List.generate(
      DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month),
      (index) => DateTime(_focusedDay.year, _focusedDay.month, index + 1),
    );

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
        title: const Text(
          'Calendar',
          style: TextStyle(color: Color(0xFF14abc2), fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildFooter(context, 'calendar'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => _changeMonth(false), icon: const Icon(Icons.chevron_left)),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedDay),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: () => _changeMonth(true), icon: const Icon(Icons.chevron_right)),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                itemCount: daysInMonth.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final day = daysInMonth[index];
                  final isSelected = _selectedDay != null &&
                      DateFormat('yyyy-MM-dd').format(_selectedDay!) == DateFormat('yyyy-MM-dd').format(day);
                  return GestureDetector(
                    onTap: () => _selectDate(day),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF14abc2) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF14abc2)),
                    onPressed: () {
                      if (_selectedDay != null && _selectedDay!.weekday == DateTime.friday) {
                        _showFridayAlert();
                        return;
                      }

                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Add New Session", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _timeController,
                                decoration: const InputDecoration(
                                  labelText: 'Time (e.g., 3:00 PM)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF14abc2),
                                ),
                                onPressed: () async {
                                  if (_selectedDay != null && _timeController.text.isNotEmpty) {
                                    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
                                    String newSlot = _timeController.text;

                                    final docRef = FirebaseFirestore.instance
                                        .collection('physiotherapists')
                                        .doc(physiotherapistCardModel!.uid)
                                        .collection('availableSlots')
                                        .doc(formattedDate);

                                    final snapshot = await docRef.get();
                                    List<Map<String, dynamic>> currentSlots = [];

                                    if (snapshot.exists && snapshot.data()?['slots'] != null) {
                                      currentSlots = List<Map<String, dynamic>>.from(snapshot.data()!['slots']);
                                    }

                                    bool alreadyExists = currentSlots.any((slot) => slot['time'] == newSlot);

                                    if (!alreadyExists) {
                                      currentSlots.add({'time': newSlot, 'isBooked': false});
                                      await docRef.set({
                                        'date': formattedDate,
                                        'slots': currentSlots,
                                      }, SetOptions(merge: true));

                                      Navigator.pop(context);
                                      _showSuccessAlert(formattedDate);
                                      _timeController.clear();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("This slot already exists.")),
                                      );
                                    }
                                  }
                                },
                                child: const Text("Submit", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _selectedDay == null
                  ? const Center(child: Text("Select a day to view appointments"))
                  : _getAppointmentsForSelectedDay().isEmpty
                      ? const Center(child: Text("No appointments available."))
                      : ListView.builder(
                          itemCount: _getAppointmentsForSelectedDay().length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF14abc2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getAppointmentsForSelectedDay()[index],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  BottomAppBar _buildFooter(BuildContext context, String currentScreen) {
    const activeColor = Color(0xFF14abc2);
    const inactiveColor = Colors.grey;

    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.calendar_today, color: currentScreen == 'calendar' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, const PhysioHomeScreen()),
              child: Icon(Icons.home, color: currentScreen == 'home' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, DForm()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined, color: currentScreen == 'form' ? activeColor : inactiveColor),
                  if (currentScreen == 'form') Container(height: 3, width: 25, color: activeColor),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, const DChats()),
              child: Icon(Icons.chat_bubble_outline, color: currentScreen == 'chat' ? activeColor : inactiveColor),
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
