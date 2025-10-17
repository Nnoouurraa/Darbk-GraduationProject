import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllClinicsScreen extends StatefulWidget {
  const AllClinicsScreen({super.key});

  @override
  State<AllClinicsScreen> createState() => _AllClinicsScreenState();
}

class _AllClinicsScreenState extends State<AllClinicsScreen> {
  Map<String, int> physioCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinicData();
  }

  Future<void> _loadClinicData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Map<String, int> physioMap = {};

    try {
      final physiosSnapshot = await firestore.collection('physiotherapists').get();

      for (var doc in physiosSnapshot.docs) {
        final data = doc.data();
        final clinic = data['clinic'] ?? 'Unknown';
        physioMap[clinic] = (physioMap[clinic] ?? 0) + 1;
      }

      setState(() {
        physioCounts = physioMap;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allClinics = physioCounts.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        title: const Text("All Clinics"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Clinic Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text("Clinic Name")),
                        DataColumn(label: Text("Physios")),
                      ],
                      rows: allClinics.map((clinic) {
                        final physios = physioCounts[clinic] ?? 0;
                        return DataRow(cells: [
                          DataCell(Text(clinic)),
                          DataCell(Text('$physios')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
