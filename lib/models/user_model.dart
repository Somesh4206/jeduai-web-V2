class UserModel {
  String uid;
  String email;
  String role; // 'Student', 'Staff', 'Admin'
  String name;
  String? profileImage;
  // Add more fields as needed

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.profileImage,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      role: data['role'],
      name: data['name'],
      profileImage: data['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'profileImage': profileImage,
    };
  }
}