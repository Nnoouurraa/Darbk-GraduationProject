import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentPlan {
  final String id;
  final String status;
  final DurationData duration;
  final int sessions;
  final List<Injury> injuries;
  final String appointmentId;
  final String patientId;
  final DateTime createdAt;
  final List<SessionData> sessionsData;

  TreatmentPlan({
    required this.id,
    required this.duration,
    required this.sessions,
    required this.injuries,
    required this.status,
    required this.appointmentId,
    required this.patientId,
    required this.createdAt,
    required this.sessionsData,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'duration': duration.toMap(),
      'sessions': sessions,
      'injuries': injuries.map((injury) => injury.toMap()).toList(),
      'appointmentId': appointmentId,
      'patientId': patientId,
      'createdAt': createdAt,
      'sessionsData': sessionsData.map((s) => s.toMap()).toList(),
    };
  }

  factory TreatmentPlan.fromMap(Map<String, dynamic> map, String id) {
    return TreatmentPlan(
      id: id,
      status: map['status'] ?? 'progress',
      duration: DurationData.fromMap(map['duration']),
      sessions: map['sessions'] ?? 0,
      injuries:
          (map['injuries'] as List<dynamic>)
              .map((injury) => Injury.fromMap(injury))
              .toList(),
      appointmentId: map['appointmentId'] ?? '',
      patientId: map['patientId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      sessionsData:
          (map['sessionsData'] as List<dynamic>)
              .map((s) => SessionData.fromMap(s))
              .toList(),
    );
  }
}

/// Model for Duration Data
class DurationData {
  final String name;
  final String level;
  final double progress;

  DurationData({
    required this.name,
    required this.level,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'level': level, 'progress': progress};
  }

  factory DurationData.fromMap(Map<String, dynamic> map) {
    return DurationData(
      name: map['name'] ?? '',
      level: map['level'] ?? '',
      progress:
          (map['progress'] is num) ? (map['progress'] as num).toDouble() : 0.0,
    );
  }
}

class Injury {
  final String name;
  final String level;
  final double progress; // <-- change to double here!

  Injury({required this.name, required this.level, required this.progress});

  Map<String, dynamic> toMap() {
    return {'name': name, 'level': level, 'progress': progress};
  }

  factory Injury.fromMap(Map<String, dynamic> map) {
    return Injury(
      name: map['name'] ?? '',
      level: map['level'] ?? '',
      progress:
          (map['progress'] is num) ? (map['progress'] as num).toDouble() : 0.0,
    );
  }
}

class SessionData {
  final int sessionNumber;
  final List<Exercise> exercises;
  final String notes;
  final DateTime? date;
  final String status; // <-- New field added

  SessionData({
    required this.sessionNumber,
    required this.exercises,
    required this.notes,
    required this.date,
    required this.status, // <-- Add to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionNumber': sessionNumber,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
      'date': date,
      'status': status, // <-- Add to map
    };
  }

  factory SessionData.fromMap(Map<String, dynamic> map) {
    return SessionData(
      sessionNumber: map['sessionNumber'] ?? 0,
      exercises:
          (map['exercises'] as List<dynamic>)
              .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList(),
      notes: map['notes'] ?? '',
      date: map['date'] != null ? (map['date'] as Timestamp).toDate() : null,
      status: map['status'] ?? 'pending', // <-- Default to 'pending' if null
    );
  }
}

class Exercise {
  final String name;
  final String frequencyPerWeek;

  Exercise({required this.name, required this.frequencyPerWeek});

  Map<String, dynamic> toMap() {
    return {'name': name, 'frequencyPerWeek': frequencyPerWeek};
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      frequencyPerWeek: map['frequencyPerWeek'] ?? '0',
    );
  }
}
