import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:darbk/screens/Define_screen.dart';
import 'package:intl/intl.dart';

class PhysioProfileScreen extends StatefulWidget {
  const PhysioProfileScreen({super.key});

  @override
  State<PhysioProfileScreen> createState() => _PhysioProfileScreenState();
}

class _PhysioProfileScreenState extends State<PhysioProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? physioData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc =
          await _firestore.collection('physiotherapists').doc(uid).get();
      if (doc.exists) {
        setState(() {
          physioData = doc.data();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final uid = _auth.currentUser!.uid;

    final ref = FirebaseStorage.instance.ref().child("physio_profile/$uid.jpg");

    try {
      await ref.putFile(File(pickedImage.path));
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('physiotherapists').doc(uid).update({
        'profileImage': downloadUrl,
      });

      fetchProfile(); // Refresh UI
    } on FirebaseException catch (e) {
      print("Error uploading image: ${e.code} - ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || physioData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF14abc2)),
        ),
      );
    }

    final fieldsToShow = {
      'First Name': physioData!['firstName'],
      'Last Name': physioData!['lastName'],
      'Gender': physioData!['gender'],
      'Birthdate': _formatDate(physioData!['birthdate']),
      'Specialty': physioData!['specialty'],
      'Title': physioData!['title'],
      'Clinic': physioData!['clinic'],
      'License': physioData!['license'],
      'Experience': physioData!['experience'],
      'Email': physioData!['email'],
      'Status': physioData!['status'],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFE5F8FA),
                  backgroundImage:
                      physioData!['profileImage'] != null
                          ? NetworkImage(physioData!['profileImage'])
                          : null,
                  child:
                      physioData!['profileImage'] == null
                          ? const Icon(
                            Icons.person,
                            color: Color(0xFF14abc2),
                            size: 50,
                          )
                          : null,
                ),
                IconButton(
                  onPressed: _uploadImage,
                  icon: const Icon(Icons.edit, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...fieldsToShow.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF14abc2).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DefineScreen()),
                    (route) => false,
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
                  'Log Out',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic birthdate) {
    try {
      DateTime date;
      if (birthdate is String) {
        date = DateTime.parse(birthdate);
      } else if (birthdate is Timestamp) {
        date = birthdate.toDate();
      } else {
        return "Unknown";
      }
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return "Invalid Date";
    }
  }
}
