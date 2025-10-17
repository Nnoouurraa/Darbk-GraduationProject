// 🔹 FILE: physio_requests.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhysioRequests extends StatelessWidget {
  const PhysioRequests({super.key});

  Future<void> approvePhysio(String uid) async {
    await FirebaseFirestore.instance.collection('physiotherapists').doc(uid).update({
      'status': 'approved',
    });
  }

  Future<void> rejectPhysio(String uid) async {
    await FirebaseFirestore.instance.collection('physiotherapists').doc(uid).update({
      'status': 'rejected',
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('physiotherapists')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }
        if (snapshot.hasError) {
          return _errorCard();
        }

        final docs = snapshot.data?.docs ?? [];
        return Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🧾 Physio Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                if (docs.isEmpty)
                  const Text("No pending requests."),
                ...docs.map((doc) => _buildRequestItem(doc)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestItem(QueryDocumentSnapshot doc) {
    final name = "${doc['firstName']} ${doc['lastName']}";
    final license = doc.data().toString().contains('license') ? doc['license'] : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Color(0xFF14abc2)),
                    onPressed: () => approvePhysio(doc.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => rejectPhysio(doc.id),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2, bottom: 6),
            child: Text("License: $license", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          )
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _errorCard() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text(
            "Something went wrong.\nCheck console for details.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
