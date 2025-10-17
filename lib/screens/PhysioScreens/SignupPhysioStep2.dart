import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darbk/screens/Define_screen.dart';

class SignupPhysioStep2 extends StatefulWidget {
  final String uid;
  final String email;

  const SignupPhysioStep2({super.key, required this.uid, required this.email});

  @override
  State<SignupPhysioStep2> createState() => _SignupPhysioStep2State();
}

class _SignupPhysioStep2State extends State<SignupPhysioStep2> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  String? selectedGender;
  String? selectedExperience;
  String? selectedClinic;
  DateTime? selectedDate;
  bool saving = false;
  bool showWaitingScreen = false;

  Future<void> _saveInfo() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        selectedGender == null ||
        selectedDate == null ||
        selectedClinic == null ||
        selectedExperience == null ||
        specialtyController.text.isEmpty ||
        titleController.text.isEmpty ||
        licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      setState(() => saving = true);

      await FirebaseFirestore.instance.collection('physiotherapists').doc(widget.uid).set({
        'uid': widget.uid,
        'email': widget.email,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'birthdate': selectedDate!.toIso8601String(),
        'gender': selectedGender,
        'clinic': selectedClinic,
        'specialty': specialtyController.text.trim(),
        'title': titleController.text.trim(),
        'license': licenseController.text.trim(),
        'experience': selectedExperience,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'role': 'physiotherapist',
      });

      setState(() => showWaitingScreen = true);
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      print("\u274C Error saving physio info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      setState(() => saving = false);
    }
    await Future.delayed(const Duration(seconds: 8));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DefineScreen()),
          (route) => false,
        );
      }
  }
   

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? icon}) {
    return InputDecoration(
      hintText: label,
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
      suffixIcon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return showWaitingScreen ? _buildWaitingScreen() : _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: saving
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
                          'Complete your Information',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xff808080),
                            fontFamily: 'Poppins-SemiBold',
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(firstNameController, 'First Name'),
                        _buildTextField(lastNameController, 'Last Name'),
                        _buildDatePicker(context),
                        _buildDropdown('Gender', ['Male', 'Female'], selectedGender,
                            (val) => setState(() => selectedGender = val)),
                        _buildDropdown('Clinic', ['Joint', 'Retruvia', '4 ways'], selectedClinic,
                            (val) => setState(() => selectedClinic = val)),
                        _buildTextField(specialtyController, 'Specialty'),
                        _buildTextField(titleController, 'Title'),
                        _buildTextField(licenseController, 'Professional License'),
                        _buildDropdown(
                          'Experience',
                          ['1 year', '2 years', '3 years', '4 years', '5 years', '6+ years'],
                          selectedExperience,
                          (val) => setState(() => selectedExperience = val),
                        ),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextField(
            decoration: _inputDecoration(
              selectedDate == null
                  ? 'Birthdate'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              icon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: _inputDecoration(label),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_bottom, size: 60, color: Color(0xFF14abc2)),
            SizedBox(height: 20),
            Text(
              'Thank you for registering!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins-SemiBold',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please wait until admin confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
