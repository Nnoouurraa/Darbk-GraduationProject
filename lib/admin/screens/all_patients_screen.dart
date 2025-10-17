import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllPatientsScreen extends StatelessWidget {
  const AllPatientsScreen({super.key});

  int calculateAge(Timestamp? birthdate) {
    if (birthdate == null) return 0;
    final birth = birthdate.toDate();
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<String> fetchTreatmentStatus(String patientId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('treatmentPlans')
          .where('patientId', isEqualTo: patientId)
          .get();

      if (query.docs.isEmpty) return 'under';

      // If ANY treatment plan is completed, return 'completed'
      for (var doc in query.docs) {
        final status = doc['status']?.toString().toLowerCase();
        if (status == 'completed') {
          return 'completed';
        }
      }

      return 'under'; // None were completed
    } catch (e) {
      print('Error: $e');
      return 'under';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Patient List",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14abc2),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('patients').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final patients = snapshot.data!.docs;

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
                          DataColumn(label: Text("Gender")),
                          DataColumn(label: Text("Age")),
                          DataColumn(label: Text("Weight")),
                          DataColumn(label: Text("Height")),
                          DataColumn(label: Text("Treatment Status")),
                        ],
                        rows: patients.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final String name = "${data['firstName']} ${data['lastName']}";
                          final String gender = data['gender'] ?? '';
                          final int age = calculateAge(data['birthdate']);
                          final int weight = (data['weight'] as num).toInt();
                          final int height = (data['height'] as num).toInt();

                          return DataRow(
                            cells: [
                              DataCell(Text(name)),
                              DataCell(Text(gender)),
                              DataCell(Text("$age")),
                              DataCell(Text("$weight kg")),
                              DataCell(Text("$height cm")),
                              DataCell(
                                FutureBuilder<String>(
                                  future: fetchTreatmentStatus(doc.id),
                                  builder: (context, snapshot) {
                                    final status = snapshot.data ?? 'under';
                                    final isCompleted = status == 'completed';
                                    final Color statusColor = isCompleted
                                        ? const Color(0xFF14abc2)
                                        : Colors.orange;
                                    final String label = isCompleted
                                        ? 'Completed'
                                        : 'Under Completion';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
