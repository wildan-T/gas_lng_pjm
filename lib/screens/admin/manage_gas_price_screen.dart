import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/dummy_data.dart';

class ManageGasPriceScreen extends StatefulWidget {
  @override
  _ManageGasPriceScreenState createState() => _ManageGasPriceScreenState();
}

class _ManageGasPriceScreenState extends State<ManageGasPriceScreen> {
  final _priceController = TextEditingController();
  double _currentPrice = DummyData.currentGasPrice;

  @override
  void initState() {
    super.initState();
    _priceController.text = _currentPrice.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updatePrice() async {
    final newPrice = double.tryParse(_priceController.text);
    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harga tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text(
          'Update harga gas dari Rp ${NumberFormat('#,##0', 'id_ID').format(_currentPrice)} '
          'menjadi Rp ${NumberFormat('#,##0', 'id_ID').format(newPrice)} per m³?',
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

    if (confirm == true) {
      setState(() {
        DummyData.currentGasPrice = newPrice;
        _currentPrice = newPrice;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harga gas berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Harga Gas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Gas Saat Ini',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(_currentPrice)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    Text(
                      'per m³',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Periode: $monthYear',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Update Harga Gas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Baru (Rp per m³)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Contoh: 15000',
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updatePrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text('Update Harga', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Riwayat Harga (Mock)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _HistoryTile(
              month: 'September 2025',
              price: 15000,
            ),
            _HistoryTile(
              month: 'Agustus 2025',
              price: 14500,
            ),
            _HistoryTile(
              month: 'Juli 2025',
              price: 14000,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String month;
  final double price;

  _HistoryTile({required this.month, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.history, color: Colors.grey),
        title: Text(month),
        trailing: Text(
          'Rp ${NumberFormat('#,##0', 'id_ID').format(price)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}