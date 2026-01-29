import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Untuk decode Base64
import '../../models/gas_record_model.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';

class ManageRecordsScreen extends StatefulWidget {
  @override
  _ManageRecordsScreenState createState() => _ManageRecordsScreenState();
}

class _ManageRecordsScreenState extends State<ManageRecordsScreen> {
  List<GasRecord> _allRecords = [];
  List<GasRecord> _filteredRecords = [];
  bool _isLoading = true;
  String _filterStatus = 'Semua'; // Pilihan: 'Semua', 'Pending', 'Verified'

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      // Mengambil SEMUA data record (pastikan fungsi getGasRecords ada di DataService)
      final records = await dataService.getGasRecords();

      setState(() {
        _allRecords = records;
        _applyFilter(); // Terapkan filter saat data masuk
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filterStatus == 'Semua') {
        _filteredRecords = _allRecords;
      } else if (_filterStatus == 'Pending') {
        _filteredRecords = _allRecords.where((r) => !r.isVerified).toList();
      } else if (_filterStatus == 'Verified') {
        _filteredRecords = _allRecords.where((r) => r.isVerified).toList();
      }
    });
  }

  void _onFilterChanged(String status) {
    setState(() {
      _filterStatus = status;
      _applyFilter();
    });
  }

  Future<void> _verifyRecord(GasRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Verifikasi'),
        content: Text(
          'Pastikan data ini valid:\n\n'
          'Mesin: ${record.machineName}\n'
          'Jumlah: ${record.amount} m³\n'
          'Operator: ${record.operatorName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Verifikasi Valid'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = Provider.of<AuthService>(
          context,
          listen: false,
        ).currentUser!;
        final dataService = Provider.of<DataService>(context, listen: false);

        await dataService.verifyRecord(record.id, user.uid, user.name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diverifikasi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRecords(); // Reload data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal verifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord(GasRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Data?'),
        content: Text(
          'Data ini akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.deleteRecord(record.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadRecords();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal hapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Record Gas')),
      body: Column(
        children: [
          // === BAGIAN FILTER ===
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                SizedBox(width: 8),
                _buildFilterChip('Pending'),
                SizedBox(width: 8),
                _buildFilterChip('Verified'),
              ],
            ),
          ),

          // === LIST DATA ===
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRecords,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        return _RecordCard(
                          record: _filteredRecords[index],
                          onVerify: () =>
                              _verifyRecord(_filteredRecords[index]),
                          onDelete: () =>
                              _deleteRecord(_filteredRecords[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filterStatus == label;
    Color color;
    if (label == 'Pending')
      color = Colors.orange;
    else if (label == 'Verified')
      color = Colors.green;
    else
      color = Colors.blue;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      onSelected: (bool selected) {
        if (selected) _onFilterChanged(label);
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  final GasRecord record;
  final VoidCallback onVerify;
  final VoidCallback onDelete;

  _RecordCard({
    required this.record,
    required this.onVerify,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Warna status)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: record.isVerified
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      record.isVerified ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: record.isVerified ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      record.isVerified ? 'VERIFIED' : 'PENDING VERIFICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: record.isVerified
                            ? Colors.green.shade800
                            : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                // Tombol Hapus (Kecil di pojok)
                InkWell(
                  onTap: onDelete,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Utama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(record.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${numberFormat.format(record.amount)} m³',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24),

                // Detail Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.precision_manufacturing,
                        'Mesin',
                        record.machineName,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person,
                        'Oleh',
                        record.operatorName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Foto Meteran (Jika ada)
                if (record.photoBase64 != null &&
                    record.photoBase64!.isNotEmpty) ...[
                  Text(
                    'Bukti Foto:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(record.photoBase64!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Catatan
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Catatan: ${record.notes}',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Action Button (Hanya jika belum verified)
                if (!record.isVerified)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onVerify,
                      icon: Icon(Icons.verified_user),
                      label: Text('Verifikasi Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  // Info Verifikator jika sudah verified
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Diverifikasi oleh: ${record.verifiedByName ?? record.verifiedBy ?? "Supervisor"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
