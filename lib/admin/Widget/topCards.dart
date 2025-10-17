import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopCards extends StatefulWidget {
  const TopCards({super.key});

  @override
  State<TopCards> createState() => _TopCardsState();
}

class _TopCardsState extends State<TopCards> {
  String topClinic = "Loading...";
  String bestPhysio = "Loading...";
  int clinicCount = 0;
  int physioCount = 0;

  @override
  void initState() {
    super.initState();
    fetchTopData();
  }

  Future<void> fetchTopData() async {
    final firestore = FirebaseFirestore.instance;
    final plans = await firestore.collection('treatmentPlans').get();
    final physios = await firestore.collection('physiotherapists').get();

    Map<String, int> clinicMap = {};
    Map<String, int> physioMap = {};
    Map<String, String> physioNames = {};
    Map<String, String> physioClinics = {};

    for (var doc in physios.docs) {
      final data = doc.data();
      final id = doc.id;
      final name = "Dr. ${data['firstName']} ${data['lastName']}";
      final clinic = data['clinic'] ?? "Unknown";

      physioNames[id] = name;
      physioClinics[id] = clinic;
    }

    for (var doc in plans.docs) {
      final data = doc.data();
      if (data['status'] == 'completed') {
        final physioId = data['physioId'];
        final clinic = physioClinics[physioId] ?? "Unknown";

        clinicMap[clinic] = (clinicMap[clinic] ?? 0) + 1;
        physioMap[physioId] = (physioMap[physioId] ?? 0) + 1;
      }
    }

    final topClinicEntry = clinicMap.entries.isNotEmpty
        ? clinicMap.entries.reduce((a, b) => a.value > b.value ? a : b)
        : const MapEntry("N/A", 0);

    final topPhysioEntry = physioMap.entries.isNotEmpty
        ? physioMap.entries.reduce((a, b) => a.value > b.value ? a : b)
        : const MapEntry("N/A", 0);

    setState(() {
      topClinic = "${topClinicEntry.key}";
      clinicCount = topClinicEntry.value;
      bestPhysio = physioNames[topPhysioEntry.key] ?? "N/A";
      physioCount = topPhysioEntry.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Top Clinic",
            subtitle: topClinic,
            value: "$clinicCount plans",
            icon: Icons.local_hospital_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: "Best Physio",
            subtitle: bestPhysio,
            value: "$physioCount plans",
            icon: Icons.medical_services_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF14abc2).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF14abc2), size: 28),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
