import 'package:darbk/models/treatment_plan.dart';
import 'package:flutter/material.dart';
import 'ExerciseDetailScreen.dart';

class HomeworkScreen extends StatelessWidget {
  final SessionData sessionData;

  HomeworkScreen({super.key, required this.sessionData});

  // Sample exercises
  final List<Map<String, String>> exercises = [
    {"name": "Hamstring Stretch", "frequency": "3/7 week"},
    {"name": "Leg Raise", "frequency": "2/7 week"},
    {"name": "Single-leg Balance", "frequency": "3/7 week"},
    {"name": "Catch and Throw", "frequency": "1/7 week"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5F8FA),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Session ${sessionData.sessionNumber}, Home Exercise',
          style: const TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: sessionData.exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  Exercise exercise = sessionData.exercises[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ExerciseDetailScreen(
                                exerciseName: exercise.name,
                                frequency: exercise.frequencyPerWeek,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF6F6F6),
                        border: Border.all(
                          color: const Color(0xFF14abc2).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "   ${exercise.frequencyPerWeek} / week",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Doctor Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sessionData.notes,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
