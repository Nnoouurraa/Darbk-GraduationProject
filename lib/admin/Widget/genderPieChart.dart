import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GenderPieChart extends StatefulWidget {
  const GenderPieChart({super.key});

  @override
  State<GenderPieChart> createState() => _GenderPieChartState();
}

class _GenderPieChartState extends State<GenderPieChart> {
  int maleCount = 0;
  int femaleCount = 0;

  @override
  void initState() {
    super.initState();
    fetchGenderData();
  }

  Future<void> fetchGenderData() async {
    final snapshot = await FirebaseFirestore.instance.collection('patients').get();
    int male = 0, female = 0;

    for (var doc in snapshot.docs) {
      final gender = doc['gender'];
      if (gender == 'Male') male++;
      if (gender == 'Female') female++;
    }

    setState(() {
      maleCount = male;
      femaleCount = female;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = maleCount + femaleCount;
    if (total == 0) return const CircularProgressIndicator();

    final femalePercent = (femaleCount / total) * 100;
    final malePercent = (maleCount / total) * 100;


    final List<Map<String, dynamic>> genderData = [
    {"label": "Female", "value": femalePercent, "color": const Color(0xFF14abc2)},
    {"label": "Male", "value": malePercent, "color": const Color(0xFF0E7490)},
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
          const Text("Gender Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sectionsSpace: 4,
                sections: genderData.map((data) {
                  return PieChartSectionData(
                    color: data['color'],
                    value: data['value'],
                    title: '${data['value'].toStringAsFixed(1)}%',
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
            children: genderData
                .map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: e['color'], margin: const EdgeInsets.only(right: 6)),
                        Text("${e['label']} (${e['value'].toStringAsFixed(1)}%)"),
                      ],
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
