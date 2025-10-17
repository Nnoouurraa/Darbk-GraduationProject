import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/appointment.dart';
import 'package:darbk/models/physiotherapist.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:darbk/screens/BookingScreen.dart';
import 'package:darbk/screens/Formscreen.dart';
import 'package:darbk/screens/chatsScreen.dart';
import 'package:darbk/services/appointment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/p.homePage.dart';
import 'package:darbk/screens/patientProfile.dart';

class PhysiotherapistListScreen extends StatefulWidget {
  const PhysiotherapistListScreen({super.key});

  @override
  State<PhysiotherapistListScreen> createState() => _PhysiotherapistListScreenState();
}

class _PhysiotherapistListScreenState extends State<PhysiotherapistListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  TreatmentPlan? _treatmentPlan;
  Appointment? _appointment;

  @override
  void initState() {
    super.initState();
    fetchTreatmentPlan();
    _fetchAppointment();
  }

  Future<void> fetchTreatmentPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
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

  Future<void> _fetchAppointment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final appointment = await AppointmentService().getMyAppointment(userId);
      if (appointment != null) {
        setState(() {
          _appointment = appointment;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Physiotherapists',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search Physiotherapists by name',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<PhysiotherapistCardModel>>(
                future: _fetchPhysiotherapists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load physiotherapists.'));
                  }

                  final allPhysios = snapshot.data ?? [];
                  final filtered = _searchText.isEmpty
                      ? allPhysios
                      : allPhysios.where((p) => p.name.toLowerCase().contains(_searchText)).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No physiotherapists found.'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          final isCompleted = _treatmentPlan?.status == 'completed';
                          if (_appointment == null || isCompleted) {
                            _navigateWithFade(context, BookingScreen(
                              physiotherapistCardModel: p,
                              nextSession: 0,
                            ));
                          } else {
                           ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You already have an ongoing appointment.',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    ),
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
  ),
);

                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FAFD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: p.imagePath.isNotEmpty
                                    ? Image.network(p.imagePath, width: 70, height: 70, fit: BoxFit.cover)
                                    : const Icon(Icons.person, size: 70, color: Color(0xFF14abc2)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(p.title, style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                                        const SizedBox(width: 4),
                                        Text(p.experience, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.black54, size: 16),
                                      const SizedBox(width: 4),
                                      Text(p.clinic, style: const TextStyle(fontSize: 13, color: Colors.black)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context, 'search'),
    );
  }

  Future<List<PhysiotherapistCardModel>> _fetchPhysiotherapists() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('physiotherapists')
        .where('status', isEqualTo: 'approved')
        .get();

    return querySnapshot.docs.map((doc) => PhysiotherapistCardModel.fromMap(doc.data())).toList();
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

BottomAppBar _buildFooter(BuildContext context, String currentScreen) {
  Color activeColor = Color(0xFF14abc2);
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
            onTap: () => _navigateWithFade(context, Patientprofile()),
            child: Icon(
              Icons.person_outline,
              color: currentScreen == 'profile' ? activeColor : inactiveColor,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateWithFade(context, HomeP()),
            child: Icon(
              Icons.home,
              color: currentScreen == 'home' ? activeColor : inactiveColor,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateWithFade(context, Formscreen()),
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
            onTap:
                () => _navigateWithFade(context, PhysiotherapistListScreen()),
            child: Icon(
              Icons.search,
              color: currentScreen == 'search' ? activeColor : inactiveColor,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateWithFade(context, ChatsScreen()),
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
