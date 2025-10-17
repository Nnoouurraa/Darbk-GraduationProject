import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/models/treatment_plan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homework_screen.dart';
import 'package:darbk/screens/p.homePage.dart';
import 'package:darbk/screens/patientProfile.dart';
import 'package:darbk/screens/chatsScreen.dart';
import 'package:darbk/screens/physiotherapistListScreen.dart';

class Formscreen extends StatefulWidget {
  const Formscreen({super.key});

  @override
  State<Formscreen> createState() => _FormscreenState();
}

class _FormscreenState extends State<Formscreen> {
  TreatmentPlan? _treatmentPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTreatmentPlan();
  }

  Future<void> fetchTreatmentPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('treatmentPlans')
              .where('patientId', isEqualTo: userId)
              .where('status', isEqualTo: 'progress')
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _treatmentPlan = TreatmentPlan.fromMap(doc.data(), doc.id);
      }
    }

    setState(() {
      _isLoading = false;
    });
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
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Sessions',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(context, 'form'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _treatmentPlan == null
              ? const Center(child: Text('No treatment plan found.'))
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Treatment plan state',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        itemCount: _treatmentPlan!.sessionsData.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          SessionData sessionData =
                              _treatmentPlan!.sessionsData[index];
                          bool isCompleted = sessionData.date != null;
                          return GestureDetector(
                            onTap:
                                isCompleted
                                    ? () {
                                      _navigateWithFade(
                                        context,
                                        HomeworkScreen(
                                          sessionData: sessionData,
                                        ),
                                      );
                                    }
                                    : null,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isCompleted
                                          ? const Color(0xFF14abc2)
                                          : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    isCompleted
                                        ? const Color(0xFF14abc2)
                                        : Colors.grey.shade300,
                                child: Text(
                                  sessionData.sessionNumber.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isCompleted
                                            ? Colors.white
                                            : Colors.black54,
                                  ),
                                ),
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
