import 'package:darbk/models/patient_model.dart';
import 'package:darbk/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:darbk/screens/p.homePage.dart';
import 'package:darbk/screens/formScreen.dart';
import 'package:darbk/screens/chatsScreen.dart';
import 'package:darbk/screens/physiotherapistListScreen.dart';
import 'package:darbk/screens/Define_screen.dart';

class Patientprofile extends StatefulWidget {
  const Patientprofile({super.key});

  @override
  State<Patientprofile> createState() => _PatientprofileState();
}

class _PatientprofileState extends State<Patientprofile> {
  Patient? patient;
  bool isLoading = true;
  bool noData = false;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildFooter(context, 'profile'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF14abc2)),
              )
              : noData || patient == null
              ? const Center(child: Text("⚠️ No profile data found."))
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE5F8FA),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF14abc2),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoTile("Name", patient!.fullName),
                    _buildInfoTile("Gender", patient!.gender),
                    _buildInfoTile("Weight", "${patient!.weight} kg"),
                    _buildInfoTile("Height", "${patient!.height} cm"),
                    _buildInfoTile(
                      "Birthdate",
                      DateFormat(
                        'yyyy-MM-dd',
                      ).format(patient!.birthdate.toDate()),
                    ),
                    _buildInfoTile(
                      "Email",
                      FirebaseAuth.instance.currentUser?.email ??
                          "Not available",
                    ),
                    _buildInfoTile("Password", "********"),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DefineScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14abc2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF14abc2).withOpacity(0.2)),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Color(0xFF14abc2),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
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
            onTap: () => _navigateWithFade(context, const Patientprofile()),
            child: Icon(
              Icons.person_outline,
              color: currentScreen == 'profile' ? activeColor : inactiveColor,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateWithFade(context, const HomeP()),
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
            onTap: () => _navigateWithFade(context, const ChatsScreen()),
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
