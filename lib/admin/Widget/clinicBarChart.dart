import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClinicBarChart extends StatefulWidget {
  final String selectedMetric;
  final Function(String?) onChanged;

  const ClinicBarChart({
    super.key,
    required this.selectedMetric,
    required this.onChanged,
  });

  @override
  State<ClinicBarChart> createState() => _ClinicBarChartState();
}

class _ClinicBarChartState extends State<ClinicBarChart> {
  Map<String, int> clinicPatients = {};
  Map<String, int> clinicPhysios = {};
  Map<String, int> clinicBookings = {};
  List<String> clinics = [];

  @override
  void initState() {
    super.initState();
    fetchClinicData();
  }

  Future<void> fetchClinicData() async {
  final firestore = FirebaseFirestore.instance;
  final Map<String, int> patients = {};
  final Map<String, int> physios = {};
  final Map<String, int> bookings = {};
  final Map<String, String> physioToClinic = {};
  final Set<String> countedPatients = {};

  // Fetch physiotherapists and map physioId to clinic
  final physioSnap = await firestore.collection('physiotherapists').get();
  for (var doc in physioSnap.docs) {
    final clinic = doc['clinic'] ?? 'Unknown';
    final physioId = doc.id;
    physioToClinic[physioId] = clinic;
    physios[clinic] = (physios[clinic] ?? 0) + 1;
  }

  // Fetch appointments and derive clinic information
  final appointmentsSnap = await firestore.collection('appointments').get();
  for (var doc in appointmentsSnap.docs) {
    final physioId = doc['physioId'];
    final patientId = doc['patientId'];
    final clinic = physioToClinic[physioId] ?? 'Unknown';

    // Count bookings
    bookings[clinic] = (bookings[clinic] ?? 0) + 1;

    // Count unique patients per clinic based on appointment
    final key = '$clinic|$patientId';
    if (!countedPatients.contains(key)) {
      patients[clinic] = (patients[clinic] ?? 0) + 1;
      countedPatients.add(key);
    }
  }

  final allClinics = {
    ...physios.keys,
    ...patients.keys,
    ...bookings.keys,
  }.where((clinic) => clinic != 'Unknown').toList();

  setState(() {
    clinicPatients = patients;
    clinicPhysios = physios;
    clinicBookings = bookings;
    clinics = allClinics;
  });
}


  @override
  Widget build(BuildContext context) {
    List<double> data = clinics.map((clinic) {
    
      if (widget.selectedMetric == 'Patients') return (clinicPatients[clinic] ?? 0).toDouble();
      if (widget.selectedMetric == 'Physios') return (clinicPhysios[clinic] ?? 0).toDouble();
      if (widget.selectedMetric == 'Bookings') return (clinicBookings[clinic] ?? 0).toDouble();
      return 0.0;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Clinic Data Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: widget.selectedMetric,
                items: ['Patients', 'Physios', 'Bookings']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                 .toList(),
                onChanged: widget.onChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: (data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) + 2 : 10),
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(clinics.length, (index) {
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: data[index],
                      width: 24,
                      color: const Color(0xFF14abc2),
                      borderRadius: BorderRadius.circular(6),
                    )
                  ]);
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        return Text(index < clinics.length ? clinics[index] : '');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 