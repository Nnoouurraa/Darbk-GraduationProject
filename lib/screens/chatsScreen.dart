import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/screens/chatscreen.dart';
import 'package:darbk/screens/p.homePage.dart';
import 'package:darbk/screens/formScreen.dart';
import 'package:darbk/screens/physiotherapistListScreen.dart';
import 'package:darbk/screens/patientProfile.dart';

class ChatsScreen extends StatelessWidget {
  final String adminId = 'mvquIwPS3QY9RyHMVr7ftNGyC2k1';

  const ChatsScreen({super.key});

  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final adminChatId = generateChatId(currentUserId, adminId);

    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(color: Color(0xFF14abc2), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF14abc2),
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            title: const Text("Admin", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: adminChatId,
                  currentUserId: currentUserId,
                  otherUserId: adminId,
                  otherUserName: "Admin",
                ),
              ),
            ),
          ),
          const Divider(),
        //  const Expanded(
           // child: Center(
          //    child: Text("You can chat with Admin here."),
         //   ),
       //   ),
        ],
      ),
      bottomNavigationBar: _buildFooter(context, 'chat'),
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
              onTap: () => _navigateWithFade(context, Patientprofile()),
              child: Icon(Icons.person_outline,
                  color: currentScreen == 'profile' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, HomeP()),
              child: Icon(Icons.home,
                  color: currentScreen == 'home' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, Formscreen()),
              child: Icon(Icons.assignment_outlined,
                  color: currentScreen == 'form' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, PhysiotherapistListScreen()),
              child: Icon(Icons.search,
                  color: currentScreen == 'search' ? activeColor : inactiveColor),
            ),
            GestureDetector(
              onTap: () => _navigateWithFade(context, ChatsScreen()),
              child: Icon(Icons.chat_bubble_outline,
                  color: currentScreen == 'chat' ? activeColor : inactiveColor),
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
