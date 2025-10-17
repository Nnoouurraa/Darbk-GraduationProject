import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllPhysiosScreen extends StatelessWidget {
  const AllPhysiosScreen({super.key});

  int calculateAge(dynamic birthdate) {
    DateTime? birth;
    if (birthdate is Timestamp) {
      birth = birthdate.toDate();
    } else if (birthdate is String) {
      birth = DateTime.tryParse(birthdate);
    }

    if (birth == null) return 0;

    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Physiotherapist List",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('physiotherapists').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No physiotherapists found.'));
                  }

                  final physios = snapshot.data!.docs;

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 32,
                        columns: const [
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Title")),
                          DataColumn(label: Text("Experience")),
                          DataColumn(label: Text("Clinic")),
                          DataColumn(label: Text("Age")),
                          DataColumn(label: Text("Status")),
                        ],
                        rows: physios.map((doc) {
                          final data = doc.data();
                          final String name = "Dr. ${data['firstName']} ${data['lastName']}";
                          final String title = data['title'] ?? 'N/A';
                          final String clinic = data['clinic'] ?? 'N/A';
                          final experienceRaw = data['experience'];
                          final match = RegExp(r'\d+').firstMatch(experienceRaw.toString());
                          final years = match != null ? int.parse(match.group(0)!) : 0;
                          final experienceDisplay = '+$years Years';
                          final int age = calculateAge(data['birthdate']);
                          final String status = data['status'] ?? 'Unknown';

                          return DataRow(
                            cells: [
                              DataCell(Text(name)),
                              DataCell(Text(title)),
                              DataCell(Text(experienceDisplay)),
                              DataCell(Text(clinic)),
                              DataCell(Text("$age")),
                              DataCell(Text(status)),
                            ],
                          );
                        }).toList(),
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
