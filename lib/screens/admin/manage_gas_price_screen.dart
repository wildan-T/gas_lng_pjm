import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

class ManageGasPriceScreen extends StatefulWidget {
  @override
  _ManageGasPriceScreenState createState() => _ManageGasPriceScreenState();
}

class _ManageGasPriceScreenState extends State<ManageGasPriceScreen> {
  final _priceController = TextEditingController();
  double _currentPrice = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPrice();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // Mengambil harga terbaru dari Firestore
  Future<void> _loadCurrentPrice() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final gasPrice = await dataService.getCurrentGasPrice();

      if (mounted) {
        setState(() {
          if (gasPrice != null) {
            _currentPrice = gasPrice.pricePerM3;
            _priceController.text = _currentPrice.toStringAsFixed(0);
          } else {
            // Default jika belum ada data di database
            _currentPrice = 0;
            _priceController.text = "";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat harga: $e')));
      }
    }
  }

  Future<void> _updatePrice() async {
    // 1. Validasi Input
    final newPrice = double.tryParse(
      _priceController.text.replaceAll('.', ''),
    ); // Hapus titik jika user pakai format ribuan

    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harga tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Konfirmasi Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Update'),
        content: Text(
          'Update harga gas dari:\n'
          'Rp ${NumberFormat('#,##0', 'id_ID').format(_currentPrice)}\n\n'
          'Menjadi:\n'
          'Rp ${NumberFormat('#,##0', 'id_ID').format(newPrice)} per m³?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 3. Proses Update ke Firebase
    setState(() => _isSaving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dataService = Provider.of<DataService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Panggil fungsi update di DataService
      await dataService.updateGasPrice(newPrice, user.uid);

      if (mounted) {
        setState(() {
          _currentPrice = newPrice;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harga gas berhasil diupdate ke Database'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);
    final currencyFormat = NumberFormat('#,##0', 'id_ID');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Kelola Harga Gas')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Kelola Harga Gas')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Harga Saat Ini
            Card(
              color: Colors.green.shade50,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Harga Gas Aktif',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Icon(Icons.local_offer, color: Colors.green),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp ${currencyFormat.format(_currentPrice)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    Text(
                      'per m³',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                    Divider(height: 24, color: Colors.green.shade200),
                    Text(
                      'Periode: $monthYear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            Text(
              'Update Harga Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Input Field
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Baru (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Contoh: 15000',
                helperText: 'Masukkan angka tanpa titik/koma',
              ),
            ),

            SizedBox(height: 24),

            // Tombol Update
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updatePrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
              ),
            ),

            SizedBox(height: 24),

            // Info Tambahan (Opsional)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Perubahan harga akan mempengaruhi perhitungan biaya untuk data yang diinput setelah ini.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
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
