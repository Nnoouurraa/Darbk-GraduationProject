import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:darbk/models/chatmodel.dart';
import 'package:darbk/screens/PhysioScreens/d_Chat.dart';
import 'package:darbk/screens/PhysioScreens/d_Calendar.dart';
import 'package:darbk/screens/PhysioScreens/PhysioHomeScreen.dart';
import 'package:darbk/screens/PhysioScreens/d_form.dart';



class DChats extends StatelessWidget {
  final String adminId = 'mvquIwPS3QY9RyHMVr7ftNGyC2k1';

  const DChats({super.key});

  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<Map<String, dynamic>> fetchUserInfo(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();

    if (userData == null || !userData.containsKey('role')) {
      return {'firstName': 'Unknown', 'lastName': '', 'profilePhoto': null};
    }

    final role = userData['role'];
    String collection = role == 'patient' ? 'patients' : 'physiotherapists';
    final profileDoc = await FirebaseFirestore.instance.collection(collection).doc(uid).get();
    return profileDoc.data() ?? {'firstName': 'Unknown', 'lastName': '', 'profilePhoto': null};
  }

  void _openChat(BuildContext context, String currentUserId, String otherUserId, String name) {
    final chatId = generateChatId(currentUserId, otherUserId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DChatScreen(
          chatId: chatId,
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          otherUserName: name,
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
                    color: currentScreen == 'form' ? activeColor : inactiveColor,
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final adminChatId = generateChatId(currentUserId, adminId);

    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Color(0xFF14abc2))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: _buildFooter(context, 'chat'),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildFixedAdminTile(context, currentUserId, adminChatId),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: currentUserId)
                  .orderBy('lastTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final chats = snapshot.data!.docs
                    .where((doc) => !List<String>.from(doc['users']).contains(adminId))
                    .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

             //  if (chats.isEmpty) return const Center(child: Text("No conversations yet."));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final otherUserId = chat.users.firstWhere((id) => id != currentUserId);
                    final formattedTime = DateFormat.Hm().format(chat.lastTimestamp);

                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchUserInfo(otherUserId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ListTile(title: Text("Loading..."));
                        }

                        final user = snapshot.data!;
                        final name = "${user['firstName']} ${user['lastName']}";
                        final imageUrl = user['profilePhoto'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF14abc2),
                            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                            child: imageUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(name),
                          subtitle: Text(chat.lastMessage),
                          trailing: Text(formattedTime, style: const TextStyle(fontSize: 12)),
                          onTap: () => _openChat(
                            context,
                            currentUserId,
                            otherUserId,
                            name,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedAdminTile(BuildContext context, String currentUserId, String adminChatId) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFF14abc2),
        child: Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
      title: const Text("Admin", style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () => _openChat(
        context,
        currentUserId,
        adminId,
        "Admin",
      ),
    );
  }
}
