import 'package:flutter/material.dart';
import 'package:gas_lng_pjm/screens/operator/input_gas_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/gas_record_model.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GasRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthService>(context, listen: false).currentUser!;
    final dataService = Provider.of<DataService>(context, listen: false);
    final records = await dataService.getRecordsByOperator(user.uid);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  // Fungsi baru untuk menangani navigasi dan refresh
  Future<void> _editRecord(GasRecord record) async {
    // Tunggu sampai layar Input ditutup
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputGasScreen(recordToEdit: record),
      ),
    );

    // SETELAH KEMBALI, LANGSUNG REFRESH DATA
    _loadRecords();
  }

  Future<void> _deleteRecord(String recordId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Hapus data ini?'),
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
      await dataService.deleteRecord(recordId);
      _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Data berhasil dihapus')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Input (Belum Diverifikasi)')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada data pending',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecords,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return _RecordCard(
                    record: record,
                    onDelete: () => _deleteRecord(record.id),
                    onEdit: () => _editRecord(record),
                  );
                },
              ),
            ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final GasRecord record;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  _RecordCard({
    required this.record,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
                  labelStyle: TextStyle(color: Colors.orange.shade900),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 20,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                Text(record.machineName, style: TextStyle(fontSize: 15)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.local_gas_station, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '${numberFormat.format(record.amount)} m³',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (record.notes != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 8),
            // TOMBOL AKSI (EDIT & HAPUS)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TOMBOL EDIT BARU
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: Text('Edit', style: TextStyle(color: Colors.blue)),
                ),

                SizedBox(width: 8),

                // TOMBOL HAPUS LAMA
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
