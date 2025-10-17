import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/screens/p.homePage.dart';

class SignupStep2 extends StatefulWidget {
  final String uid;
  final String email;

  const SignupStep2({super.key, required this.uid, required this.email});

  @override
  State<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  String? selectedGender;
  DateTime? selectedDate;
  bool isSaving = false;
  bool showConfirmation = false;

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _saveInfo() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        selectedGender == null ||
        selectedDate == null) {
      _showError("Please complete all fields.");
      return;
    }

    try {
      setState(() => isSaving = true);

      await _firestore.collection("patients").doc(widget.uid).set({
        "uid": widget.uid,
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": widget.email,
        "birthdate": Timestamp.fromDate(selectedDate!), // ✅ Correct format
        "gender": selectedGender,
        "weight": double.parse(weightController.text.trim()), // ✅ As number
        "height": double.parse(heightController.text.trim()), // ✅ As number
        "role": "patient",
        "assignedPhysio": null,
        "treatmentPlan": null,
        "sessionCompleted": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showConfirmation();
    } catch (e) {
      print("⚠️ Error saving patient info: $e");
      _showError("Failed to save info. Try again.");
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showConfirmation() {
    setState(() => showConfirmation = true);
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const HomeP(),
          ),
        ),
      );
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _textFieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xffb9b9b9),
        fontSize: 14,
        fontFamily: 'Poppins-Regular',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xffc4c4c4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xff14abc2), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: _textFieldDecoration(label),
        keyboardType: label.contains("Weight") || label.contains("Height")
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextField(
            decoration: _textFieldDecoration(
              selectedDate == null
                  ? 'Birthdate'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: _textFieldDecoration('Gender'),
        items: ['Male', 'Female'].map((gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) => setState(() => selectedGender = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showConfirmation
        ? _buildConfirmationScreen()
        : Scaffold(
            backgroundColor: Colors.white,
            body: isSaving
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF14abc2)))
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Image.asset('images/image_512157.png', height: 80),
                              const SizedBox(height: 20),
                              const Text(
                                "Complete Your Profile",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff808080),
                                  fontFamily: 'Poppins-SemiBold',
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildTextField(firstNameController, "First Name"),
                              _buildTextField(lastNameController, "Last Name"),
                              _buildDatePicker(),
                              _buildDropdown(),
                              _buildTextField(weightController, "Weight (kg)"),
                              _buildTextField(heightController, "Height (cm)"),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: 200,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _saveInfo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF14abc2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "Finish",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins-SemiBold',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
  }

  Widget _buildConfirmationScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF14abc2)),
            SizedBox(height: 20),
            Text(
              "Your account has been created successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF14abc2),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins-SemiBold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
