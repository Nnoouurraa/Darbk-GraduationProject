import 'package:flutter/material.dart';

class AllInjuriesScreen extends StatelessWidget {
  const AllInjuriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> injuries = [
      "Low Back Pain",
      "Herniated Disc",
      "Neck Pain / Whiplash",
      "Frozen Shoulder",
      "Rotator Cuff Tear",
      "Shoulder Impingement",
      "Tennis Elbow",
      "Golfer’s Elbow",
      "Carpal Tunnel Syndrome",
      "Hip Bursitis",
      "Hip Labral Tear",
      "ACL Tear",
      "Meniscus Tear",
      "Patellofemoral Pain Syndrome",
      "Ankle Sprain",
      "Achilles Tendonitis",
      "Plantar Fasciitis",
      "Hamstring Strain",
      "Muscles",
      "Balance",
      "Tendon",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        title: const Text("All Injuries"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Injury List",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  itemCount: injuries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        injuries[index],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      leading: const Icon(Icons.local_hospital_outlined, color: Color(0xFF14abc2)),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
