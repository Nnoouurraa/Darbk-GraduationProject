import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecoveryLineChart extends StatefulWidget {
  final String selectedPeriod;

  const RecoveryLineChart({super.key, required this.selectedPeriod});

  @override
  State<RecoveryLineChart> createState() => _RecoveryLineChartState();
}

class _RecoveryLineChartState extends State<RecoveryLineChart> {
  Map<String, int> recoveryCounts = {};
  bool isLoading = true;
  late String selectedPeriod;

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.selectedPeriod;
    fetchRecoveryData();
  }

  Future<void> fetchRecoveryData() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('treatmentPlans')
        .where('status', isEqualTo: 'completed')
        .get();

    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final timestamp = doc['createdAt'];
      if (timestamp != null && timestamp is Timestamp) {
        final date = timestamp.toDate();
        final label = selectedPeriod == 'Week'
            ? DateFormat.E().format(date) // e.g., Mon
            : DateFormat.MMM().format(date); // e.g., Jan

        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    setState(() {
      recoveryCounts = counts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = selectedPeriod == 'Week'
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

    final data = labels.map((label) => (recoveryCounts[label] ?? 0).toDouble()).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recovery Rate",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedPeriod,
                      items: ['Week', 'Month']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPeriod = value;
                          });
                          fetchRecoveryData();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              int i = value.toInt();
                              if (i >= 0 && i < labels.length) {
                                return Text(labels[i], style: const TextStyle(fontSize: 12));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(enabled: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: const Color(0xFF14abc2),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Total Recovery Cases: ${recoveryCounts.values.fold(0, (a, b) => a + b)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
