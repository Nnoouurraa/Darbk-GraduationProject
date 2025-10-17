class PhysiotherapistCardModel {
  final String uid;
  final String name;
  final String title;
  final String experience;
  final String clinic;
  final String email;
  final String specialty;
  final String gender;
  final String imagePath;

  PhysiotherapistCardModel({
    required this.uid,
    required this.name,
    required this.title,
    required this.experience,
    required this.clinic,
    required this.email,
    required this.specialty,
    required this.gender,
    required this.imagePath,
  });

  factory PhysiotherapistCardModel.fromMap(Map<String, dynamic> data) {
    return PhysiotherapistCardModel(
      uid: data['uid'] ?? '',
      name: '${data['firstName']} ${data['lastName']}',
      title: data['title'] ?? '',
      experience: data['experience'] ?? '',
      clinic: data['clinic'] ?? '',
      email: data['email'] ?? '',
      specialty: data['specialty'] ?? '',
      gender: data['gender'] ?? '',
      imagePath: data['profileImage']??'',
    );
  }
}
