import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPatientsScreen extends StatefulWidget {
  const HistoryPatientsScreen({super.key});

  @override
  State<HistoryPatientsScreen> createState() => _HistoryPatientsScreenState();
}

class _HistoryPatientsScreenState extends State<HistoryPatientsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = true;
  List<Map<String, dynamic>> completedPatients = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedPatients();
  }

  Future<void> fetchCompletedPatients() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot =
        await _firestore
            .collection('treatmentPlans')
            .where('status', isEqualTo: 'completed')
            .get();

    List<Map<String, dynamic>> patientsList = [];

    for (var doc in querySnapshot.docs) {
      final treatmentData = doc.data();
      final treatmentId = doc.id;

      final appointmentDoc =
          await _firestore.collection('appointments').doc(treatmentId).get();
      if (!appointmentDoc.exists) continue;

      final appointmentData = appointmentDoc.data()!;
      if (appointmentData['physioId'] != uid) continue;

      final patientId = appointmentData['patientId'];
      final patientDoc =
          await _firestore.collection('patients').doc(patientId).get();

      if (patientDoc.exists) {
        final patient = patientDoc.data()!;
        patientsList.add({
          "name": "${patient['firstName']} ${patient['lastName']}",
          "lastSession": "Session ${treatmentData['sessions']}",
          "completionDate":
              treatmentData['createdAt'] ??
              "N/A", // You may need to store this in Firestore
        });
      }
    }

    setState(() {
      completedPatients = patientsList;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Archived Patients',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : completedPatients.isEmpty
              ? const Center(child: Text("No archived patients found."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: completedPatients.length,
                itemBuilder: (context, index) {
                  final patient = completedPatients[index];
                  Timestamp timestamp = patient['completionDate'];
                  DateTime dateTime = timestamp.toDate();
                  String formattedDate = DateFormat(
                    'MMMM d, y',
                  ).format(dateTime);
                  return Card(
                    color: const Color(0xFFF9F9F9),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF14abc2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        patient['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Last Session: ${patient['lastSession']}"),
                          Text("Completed on: $formattedDate"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
