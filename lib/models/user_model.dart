import 'package:cloud_firestore/cloud_firestore.dart';

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

  // PERBAIKAN 1: Menerima DocumentSnapshot agar konsisten dengan model lain
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id, // UID otomatis diambil dari ID dokumen
      name: data['name'] ?? '',
      email: data['email'] ?? '',

      // PERBAIKAN 2: Menggunakan cara modern parsing Enum (lebih aman)
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'], // Membandingkan "admin" == "admin"
        orElse: () => UserRole.operator, // Default jika error/kosong
      ),

      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role
          .name, // Modern: langsung menghasilkan string "admin", "operator", dll
      'isActive': isActive,
    };
  }
}
