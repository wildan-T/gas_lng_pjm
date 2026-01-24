import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/machine_model.dart';
import '../../services/data_service.dart';

class ManageMachinesScreen extends StatefulWidget {
  @override
  _ManageMachinesScreenState createState() => _ManageMachinesScreenState();
}

class _ManageMachinesScreenState extends State<ManageMachinesScreen> {
  List<MachineModel> _machines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() => _isLoading = true);
    final dataService = Provider.of<DataService>(context, listen: false);
    final machines = await dataService.getMachines();
    setState(() {
      _machines = machines;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Mesin Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Mesin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      final machine = MachineModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text,
        location: locationController.text,
      );

      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.addMachine(machine);
      _loadMachines();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mesin berhasil ditambahkan')));
      }
    }
  }

  Future<void> _showEditDialog(MachineModel machine) async {
    final nameController = TextEditingController(text: machine.name);
    final locationController = TextEditingController(text: machine.location);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Mesin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Mesin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedMachine = MachineModel(
        id: machine.id,
        name: nameController.text,
        location: locationController.text,
      );

      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.updateMachine(updatedMachine);
      _loadMachines();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mesin berhasil diupdate')));
      }
    }
  }

  Future<void> _deleteMachine(MachineModel machine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Nonaktifkan mesin "${machine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.deleteMachine(machine);
      _loadMachines();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mesin berhasil dinonaktifkan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Mesin')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _machines.isEmpty
          ? Center(child: Text('Belum ada mesin terdaftar'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _machines.length,
              itemBuilder: (context, index) {
                final machine = _machines[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.precision_manufacturing),
                    ),
                    title: Text(
                      machine.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(machine.location),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(machine),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMachine(machine),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
