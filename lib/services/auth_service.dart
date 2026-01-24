import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; //

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Cek status login saat aplikasi baru dibuka
  Future<void> autoLogin() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _fetchUserProfile(user.uid);
    }
  }

  // Login Real ke Firebase
  Future<bool> login(String email, String password) async {
    try {
      // 1. Authenticate Email/Password
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Ambil data Role & Nama dari Firestore
      await _fetchUserProfile(cred.user!.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      print('Auth Error: ${e.message}');
      return false;
    } catch (e) {
      print('General Error: $e');
      return false;
    }
  }

  // Helper untuk mengambil data user dari Firestore users/{uid}
  Future<void> _fetchUserProfile(String uid) async {
    try {
      print("DEBUG: Mencari user dengan UID: $uid"); // <-- Tambahkan ini

      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      print(
        "DEBUG: Apakah dokumen ditemukan? ${doc.exists}",
      ); // <-- Tambahkan ini

      if (doc.exists) {
        // Menggunakan factory fromFirestore yang sudah Anda buat di user_model.dart
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
      } else {
        print(
          "DEBUG: Dokumen tidak ada di collection 'users'",
        ); // <-- Tambahkan ini
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null;

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  // FITUR BARU: Admin membuat user baru tanpa logout
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String name,
    required String role, // String dari enum (misal: 'operator')
  }) async {
    FirebaseApp? tempApp;
    try {
      // 1. Inisialisasi Firebase App sekunder agar tidak mengganggu sesi Admin
      tempApp = await Firebase.initializeApp(
        name: 'temporaryRegister',
        options: Firebase.app().options,
      );

      // 2. Buat akun di Auth menggunakan App sekunder
      UserCredential cred = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(email: email, password: password);

      // 3. Simpan data profil ke Firestore (pakai _db utama tidak masalah)
      // Pastikan field-nya sesuai dengan UserModel Anda
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'isActive': true, // Default aktif
      });

      // 4. Hapus app sekunder
      await tempApp.delete();
    } catch (e) {
      // Pastikan app dihapus jika terjadi error
      await tempApp?.delete();
      print("Error create user: $e");
      rethrow; // Lempar error ke UI agar muncul SnackBar
    }
  }
}
