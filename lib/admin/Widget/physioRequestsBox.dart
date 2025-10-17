import 'package:flutter/material.dart';

class PhysioRequestsBox extends StatelessWidget {
  const PhysioRequestsBox({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> requests = [
      "Dr. Thamer Alshahrani",
      "Dr. Lina Alnasser",
      "Dr. Omar Alghamdi"
    ];

    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🧾 Physio Requests",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...requests.map((name) => _buildRequestItem(name)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF14abc2)),
                onPressed: () {
                  // Handle accept
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  // Handle reject
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
