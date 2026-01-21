import '../models/user_model.dart';
import '../utils/dummy_data.dart';

class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Mock Login
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    // Simple mock authentication
    _currentUser = DummyData.users.firstWhere(
      (user) => user.email == email,
      orElse: () => DummyData.users[0],
    );
    
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    return _currentUser != null && roles.contains(_currentUser!.role);
  }
}