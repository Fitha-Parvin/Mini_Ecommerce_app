class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Anonymous',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}
