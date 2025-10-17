import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/admin/widget/clinicBarChart.dart';
import 'package:darbk/admin/widget/genderPieChart.dart';
import 'package:darbk/admin/widget/recoveryLineChart.dart';
import 'package:darbk/admin/widget/treatmentProgress.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int patientCount = 0;
  int physioCount = 0;
  int clinicCount = 0;
  int completedPlans = 0;
  int totalSessions = 0;
  String selectedMetric = 'Patients';
  String selectedRecoveryPeriod = 'Week';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final firestore = FirebaseFirestore.instance;
    final patients = await firestore.collection('patients').get();
    final physios = await firestore.collection('physiotherapists').get();
    final plans = await firestore.collection('treatmentPlans').get();

    final Set<String> clinics =
        physios.docs.map((doc) => doc['clinic']?.toString() ?? 'Unknown').toSet();

    int completed = plans.docs.where((doc) => doc['status'] == 'completed').length;

    int sessionTotal = 0;
    for (var doc in plans.docs) {
      final data = doc.data();
      if (data.containsKey('sessionsData')) {
        final sessions = data['sessionsData'] as List<dynamic>;
        sessionTotal += sessions.length;
      }
    }

    setState(() {
      patientCount = patients.size;
      physioCount = physios.size;
      clinicCount = clinics.length;
      completedPlans = completed;
      totalSessions = sessionTotal;
      isLoading = false;
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF14abc2), size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome, Admin 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Patients', '$patientCount', Icons.people),
              _buildStatCard('Physios', '$physioCount', Icons.medical_services),
              _buildStatCard('Clinics', '$clinicCount', Icons.local_hospital),
              _buildStatCard('Completed Plans', '$completedPlans', Icons.check_circle_outline),
              _buildStatCard('Total Sessions', '$totalSessions', Icons.event_note),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClinicBarChart(
                  selectedMetric: selectedMetric,
                  onChanged: (val) => setState(() => selectedMetric = val!),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                flex: 1,
                child: GenderPieChart(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: RecoveryLineChart(selectedPeriod: selectedRecoveryPeriod),
              ),
              const SizedBox(width: 24),
              const Expanded(
                flex: 1,
                child: TreatmentProgressDonutChart(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
