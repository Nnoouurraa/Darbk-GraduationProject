import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TreatmentProgressDonutChart extends StatefulWidget {
  const TreatmentProgressDonutChart({super.key});

  @override
  State<TreatmentProgressDonutChart> createState() => _TreatmentProgressDonutChartState();
}

class _TreatmentProgressDonutChartState extends State<TreatmentProgressDonutChart> {
  int completed = 0;
  int inProgress = 0;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    final snapshot = await FirebaseFirestore.instance.collection('treatmentPlans').get();
    int complete = 0, progress = 0;

    for (var doc in snapshot.docs) {
      final status = doc['status'];
      if (status == 'completed') complete++;
      if (status == 'progress') progress++;
    }

    setState(() {
      completed = complete;
      inProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = completed + inProgress;
    if (total == 0) return const CircularProgressIndicator();

    final completePercent = (completed / total) * 100;
    final progressPercent = (inProgress / total) * 100;

    final List<Map<String, dynamic>> data = [
  {"label": "Complete", "value": completePercent, "color": const Color(0xFF0E7490)},
  {"label": "In Progress", "value": progressPercent, "color": const Color(0xFF14abc2)},
];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Treatment Progress Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                sections: data.map((entry) {
                  return PieChartSectionData(
                    color: entry['color'],
                    value: entry['value'],
                    title: '${entry['value'].toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: data
                .map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: e['color'], margin: const EdgeInsets.only(right: 6)),
                        Text("${e['label']} (${e['value'].toStringAsFixed(1)}%)"),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
