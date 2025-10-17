import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String firstName;
  final String lastName;
  final String gender;
  final double weight;
  final double height;
  final Timestamp birthdate;

  Patient({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.weight,
    required this.height,
    required this.birthdate,
  });

  String get fullName => "$firstName $lastName";

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      birthdate: map['birthdate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'weight': weight,
      'height': height,
      'birthdate': birthdate,
    };
  }
}
