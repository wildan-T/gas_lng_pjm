import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service_mock.dart';
import '../../models/user_model.dart';
import '../operator/operator_home_screen.dart';
import '../supervisor/supervisor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../management/management_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final user = authService.currentUser!;
      
      Widget homeScreen;
      switch (user.role) {
        case UserRole.operator:
          homeScreen = OperatorHomeScreen();
          break;
        case UserRole.supervisor:
          homeScreen = SupervisorHomeScreen();
          break;
        case UserRole.admin:
          homeScreen = AdminHomeScreen();
          break;
        case UserRole.management:
          homeScreen = ManagementDashboard();
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => homeScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_gas_station, size: 80, color: Colors.blue),
              SizedBox(height: 24),
              Text(
                'Gas LNG Monitoring',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                'PT Panata Jaya Mandiri',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 48),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 24),

              Text('Demo Accounts:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('operator@pjm.com - Operator'),
              Text('supervisor@pjm.com - Supervisor'),
              Text('admin@pjm.com - Admin'),
              Text('manager@pjm.com - Management'),
            ],
          ),
        ),
      ),
    );
  }
}