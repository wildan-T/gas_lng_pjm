import 'package:flutter/material.dart';
import 'package:gas_lng_pjm/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final users = await dataService.getAllUsers();

    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  // === FITUR Dialog Tambah User ===
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddUserDialog(
        onSave: (email, password, name, role) async {
          setState(() => _isLoading = true);
          try {
            // Panggil fungsi di AuthService
            await Provider.of<AuthService>(
              context,
              listen: false,
            ).createUserByAdmin(
              email: email,
              password: password,
              name: name,
              role: role.name,
            );

            await _fetchUsers(); // Refresh list setelah tambah

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User baru berhasil dibuat'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal membuat user: $e'),
                backgroundColor: Colors.red,
              ),
            );
          } finally {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(
        user: user,
        onSave: (updatedUser) async {
          setState(() => _isLoading = true);
          try {
            await Provider.of<DataService>(
              context,
              listen: false,
            ).updateUserProfile(updatedUser);
            await _fetchUsers(); // Refresh list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User berhasil diupdate'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola User')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: _showAddUserDialog,
        tooltip: 'Tambah User Baru',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text('Tidak ada data user'))
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(user.role),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(
                                  user.role,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(user.role),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (!user.isActive)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'NON-AKTIF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditUserDialog(user),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.supervisor:
        return Colors.orange;
      case UserRole.management:
        return Colors.purple;
      case UserRole.operator:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// === WIDGET Dialog Input User Baru ===
class _AddUserDialog extends StatefulWidget {
  final Function(String email, String password, String name, UserRole role)
  onSave;

  _AddUserDialog({required this.onSave});

  @override
  __AddUserDialogState createState() => __AddUserDialogState();
}

class __AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.operator; // Default role
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah User Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    !v!.contains('@') ? 'Email tidak valid' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                obscureText: _isObscure,
                validator: (v) => v!.length < 6 ? 'Min. 6 karakter' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: 'Role / Jabatan'),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _emailController.text.trim(),
                _passwordController.text,
                _nameController.text.trim(),
                _selectedRole,
              );
              Navigator.pop(context);
            }
          },
          child: Text('Buat User'),
        ),
      ],
    );
  }
}

// ... imports

class _EditUserDialog extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onSave;

  _EditUserDialog({required this.user, required this.onSave});

  @override
  __EditUserDialogState createState() => __EditUserDialogState();
}

class __EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController; // Controller untuk Nama
  late UserRole _selectedRole;
  late bool _isActive;
  bool _isSendingReset = false; // Loading state untuk reset password

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user.name,
    ); // Isi nama lama
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Email (Read Only)
              Text(
                'Email: ${widget.user.email}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 16),

              // 1. EDIT NAMA
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),

              // 2. EDIT ROLE
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role User',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              SizedBox(height: 16),

              // 3. EDIT STATUS
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Status Aktif'),
                subtitle: Text(
                  _isActive ? 'User dapat login' : 'User diblokir',
                ),
                value: _isActive,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() => _isActive = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Buat object user baru dengan data update (termasuk NAMA BARU)
              final updatedUser = UserModel(
                uid: widget.user.uid,
                name: _nameController.text.trim(), // Ambil nama dari controller
                email: widget.user.email,
                role: _selectedRole,
                isActive: _isActive,
              );
              widget.onSave(updatedUser);
              Navigator.pop(context);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
