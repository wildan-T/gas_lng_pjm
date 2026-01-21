import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service_mock.dart';
import 'manage_machines_screen.dart';
import 'manage_gas_price_screen.dart';
import 'settings_screen.dart'; // ← NEW IMPORT
import '../management/management_dashboard.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.purple,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Role: ${user.role.toString().split('.').last.toUpperCase()}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Menu Administrasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // ========== EXISTING MENUS ==========
                  _MenuCard(
                    title: 'Kelola Mesin',
                    icon: Icons.precision_manufacturing,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageMachinesScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: 'Harga Gas',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageGasPriceScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: 'Kelola User',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fitur dalam pengembangan')),
                      );
                    },
                  ),
                  _MenuCard(
                    title: 'Lihat Laporan',
                    icon: Icons.bar_chart,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManagementDashboard(),
                        ),
                      );
                    },
                  ),

                  // ========== NEW MENU ==========
                  _MenuCard(
                    title: 'Pengaturan Sistem',
                    icon: Icons.settings,
                    color: Colors.blueGrey,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
