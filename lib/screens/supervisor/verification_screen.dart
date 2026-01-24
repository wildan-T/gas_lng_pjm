import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/gas_record_model.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import 'dart:convert';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  List<GasRecord> _unverifiedRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnverifiedRecords();
  }

  Future<void> _loadUnverifiedRecords() async {
    setState(() => _isLoading = true);
    final dataService = Provider.of<DataService>(context, listen: false);
    final records = await dataService.getUnverifiedRecords();
    setState(() {
      _unverifiedRecords = records;
      _isLoading = false;
    });
  }

  Future<void> _verifyRecord(GasRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verifikasi Data'),
        content: Text(
          'Apakah data ini sudah benar?\n\nMesin: ${record.machineName}\nJumlah: ${record.amount} m³',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Verifikasi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = Provider.of<AuthService>(
        context,
        listen: false,
      ).currentUser!;
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.verifyRecord(record.id, user.uid, user.name);
      _loadUnverifiedRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diverifikasi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verifikasi Data')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _unverifiedRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Semua data sudah diverifikasi!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUnverifiedRecords,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _unverifiedRecords.length,
                itemBuilder: (context, index) {
                  final record = _unverifiedRecords[index];
                  return _VerificationCard(
                    record: record,
                    onVerify: () => _verifyRecord(record),
                  );
                },
              ),
            ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final GasRecord record;
  final VoidCallback onVerify;

  _VerificationCard({required this.record, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(record.timestamp),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text('Pending'),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.person, color: Colors.grey),
              title: Text(record.operatorName),
              subtitle: Text('Operator'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.precision_manufacturing, color: Colors.grey),
              title: Text(record.machineName),
              subtitle: Text('Mesin'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.local_gas_station, color: Colors.blue),
              title: Text(
                '${numberFormat.format(record.amount)} m³',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Jumlah Gas'),
            ),
            // Setelah ListTile jumlah gas, tambahkan:
            if (record.photoBase64 != null) ...[
              SizedBox(height: 12),
              Text(
                'Foto Meteran:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(record.photoBase64!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
            ],
            if (record.notes != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(record.notes!),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: onVerify,
                icon: Icon(Icons.check_circle),
                label: Text('Verifikasi Data', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
