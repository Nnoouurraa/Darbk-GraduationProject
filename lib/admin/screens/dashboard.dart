// ✅ Rewritten AdminDashboard with single sidebar and dynamic content switching

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darbk/admin/screens/chat_popup.dart';
import 'package:darbk/admin/screens/admin_login_screen.dart';
import 'package:darbk/admin/screens/all_patients_screen.dart';
import 'package:darbk/admin/screens/all_physios_screen.dart';
import 'package:darbk/admin/screens/all_clinics_screen.dart';
import 'package:darbk/admin/screens/all_exercises_screen.dart';
import 'package:darbk/admin/screens/all_injuries_screen.dart';
import 'package:darbk/admin/screens/admin_chat_screen.dart';
import 'package:darbk/admin/screens/dashboard_content.dart';
import 'package:darbk/admin/screens/physio_requests.dart';
import 'package:darbk/admin/widget/sidebaritem.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool showChat = false;
  Offset _chatOffset = const Offset(800, 200);
  Offset _physioBoxOffset = const Offset(1000, 600);

  String currentScreen = "Dashboard";

  void toggleChat() => setState(() => showChat = !showChat);

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case 'Patients':
        return const AllPatientsScreen();
      case 'Physios':
        return const AllPhysiosScreen();
      case 'Clinics':
        return const AllClinicsScreen();
      case 'Exercises':
        return const AllExercisesScreen();
      case 'Injuries':
        return const AllInjuriesScreen();
      default:
        return const DashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebar(),
              Expanded(child: getCurrentScreen()),
            ],
          ),
          if (showChat)
            Positioned(
              left: _chatOffset.dx,
              top: _chatOffset.dy,
              child: Draggable(
                feedback: _buildChatPopup(currentUserId),
                childWhenDragging: const SizedBox(),
                onDragEnd: (details) => setState(() => _chatOffset = details.offset),
                child: _buildChatPopup(currentUserId),
              ),
            ),
          Positioned(
            left: _physioBoxOffset.dx,
            top: _physioBoxOffset.dy,
            child: Draggable(
              feedback: const PhysioRequests(),
              childWhenDragging: const SizedBox(),
              onDragEnd: (details) => setState(() => _physioBoxOffset = details.offset),
              child: const PhysioRequests(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: currentScreen == "Dashboard",
            onTap: () => setState(() => currentScreen = "Dashboard"),
          ),
          SidebarItem(
            icon: Icons.people,
            label: 'Patients',
            isActive: currentScreen == "Patients",
            onTap: () => setState(() => currentScreen = "Patients"),
          ),
          SidebarItem(
            icon: Icons.medical_services,
            label: 'Physios',
            isActive: currentScreen == "Physios",
            onTap: () => setState(() => currentScreen = "Physios"),
          ),
          SidebarItem(
            icon: Icons.local_hospital,
            label: 'Clinics',
            isActive: currentScreen == "Clinics",
            onTap: () => setState(() => currentScreen = "Clinics"),
          ),
          SidebarItem(
            icon: Icons.fitness_center,
            label: 'Exercises',
            isActive: currentScreen == "Exercises",
            onTap: () => setState(() => currentScreen = "Exercises"),
          ),
          SidebarItem(
            icon: Icons.healing,
            label: 'Injuries',
            isActive: currentScreen == "Injuries",
            onTap: () => setState(() => currentScreen = "Injuries"),
          ),
          const Spacer(),
          const Divider(),
          SidebarItem(
            icon: Icons.chat,
            label: 'Chat',
            isActive: showChat,
            onTap: toggleChat,
          ),
          SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isActive: false,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatPopup(String currentUserId) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: ChatPopup(
          currentUserId: currentUserId,
          onChatSelected: (chatId, userId, name, role) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminChatScreen(
                  chatId: chatId,
                  otherUserId: userId,
                  otherUserName: name,
                  otherUserRole: role,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}