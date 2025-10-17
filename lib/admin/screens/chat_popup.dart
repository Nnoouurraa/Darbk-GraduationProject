import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPopup extends StatelessWidget {
  final String currentUserId;
  final void Function(String chatId, String userId, String name, String role) onChatSelected;

  const ChatPopup({
    super.key,
    required this.currentUserId,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .orderBy('lastTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final users = List<String>.from(chat['users']);
            final otherUserId = users.firstWhere((id) => id != currentUserId);
            final lastMessage = chat['lastMessage'] ?? "";
            final timestamp = chat['lastTimestamp'] as Timestamp?;
            final timeAgo = timestamp != null ? timeago.format(timestamp.toDate()) : "";

            return FutureBuilder<Map<String, dynamic>?>(
              future: _getUserDetails(otherUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text("Loading..."));
                }

                final userInfo = snapshot.data;
                if (userInfo == null) {
                  return const ListTile(title: Text("Unknown User"));
                }

                final name = userInfo['name'];
                final role = userInfo['role'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF14abc2),
                    child: Icon(
                      role == 'physiotherapist' ? Icons.medical_services : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(name.isEmpty ? "Unknown User" : name),
                  subtitle: Text(role.toUpperCase()),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeAgo,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () => onChatSelected(chat.id, otherUserId, name, role),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final role = userDoc['role'];
      final collection = role == 'physiotherapist' ? 'physiotherapists' : role == 'patient' ? 'patients' : null;

      if (collection == null) return null;

      final profileDoc = await FirebaseFirestore.instance.collection(collection).doc(userId).get();
      if (!profileDoc.exists) return null;

      final firstName = profileDoc['firstName'] ?? '';
      final lastName = profileDoc['lastName'] ?? '';
      final name = role == 'physiotherapist' ? 'Dr. $firstName $lastName' : '$firstName $lastName';

      return {
        'name': name,
        'role': role,
      };
    } catch (e) {
      print("❌ Error loading user details: $e");
      return null;
    }
  }
}
