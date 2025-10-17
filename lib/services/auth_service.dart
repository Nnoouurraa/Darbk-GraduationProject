import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darbk/models/patient_model.dart'; // Make sure the path matches your structure

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Patient? _patientData;

  Patient? get patient => _patientData;

  /// Fetch patient data from Firestore and store it locally
  Future<Patient?> fetchPatientData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('patients').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      _patientData = Patient.fromMap(doc.data()!);
      return _patientData;
    }

    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    _patientData = null;
    await _auth.signOut();
  }

  /// Refresh user data manually (e.g. after form update)
  Future<void> refreshPatientData() async {
    await fetchPatientData();
  }
}
