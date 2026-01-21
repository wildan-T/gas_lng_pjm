enum UserRole { operator, supervisor, admin, management }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.operator,
      ),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'isActive': isActive,
    };
  }
}