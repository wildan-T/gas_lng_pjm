import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format currency
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/forecast_model.dart';
import 'manage_gas_price_screen.dart'; // Import screen ini untuk navigasi

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _priceDisplayController =
      TextEditingController(); // Hanya untuk display
  final _thresholdLowController = TextEditingController();
  final _thresholdHighController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  SystemSettings? _settings;
  double _realGasPrice = 0; // Menyimpan harga asli dari source of truth

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  @override
  void dispose() {
    _priceDisplayController.dispose();
    _thresholdLowController.dispose();
    _thresholdHighController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    final dataService = Provider.of<DataService>(context, listen: false);

    try {
      // 1. Ambil System Settings (Thresholds)
      final settings = await dataService.getSystemSettings();

      // 2. Ambil Harga Gas yang ASLI (Current Price)
      final gasPriceObj = await dataService.getCurrentGasPrice();

      if (mounted) {
        setState(() {
          _settings = settings;

          // Set Harga (Read Only) dari source yang benar
          if (gasPriceObj != null) {
            _realGasPrice = gasPriceObj.pricePerM3;
            _priceDisplayController.text = NumberFormat.currency(
              locale: 'id_ID',
              symbol: '',
              decimalDigits: 0,
            ).format(_realGasPrice);
          } else {
            _priceDisplayController.text = "0";
          }

          // Set Thresholds
          if (settings != null) {
            _thresholdLowController.text = settings.efficiencyThresholdLow
                .toStringAsFixed(0);
            _thresholdHighController.text = settings.efficiencyThresholdHigh
                .toStringAsFixed(0);
          } else {
            _thresholdLowController.text = "-10";
            _thresholdHighController.text = "10";
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      // PENTING: Saat menyimpan SystemSettings, kita masukkan harga gas yang sedang aktif (_realGasPrice)
      // agar data di DB tidak null/error, meskipun field ini sebenarnya redudansi.
      final newSettings = SystemSettings(
        id: _settings?.id ?? 'system_config',
        gasPricePerM3: _realGasPrice, // Gunakan harga asli yg didapat saat load
        efficiencyThresholdLow: double.parse(_thresholdLowController.text),
        efficiencyThresholdHigh: double.parse(_thresholdHighController.text),
        updatedAt: DateTime.now(),
        updatedBy: user?.uid ?? 'Admin',
      );

      await dataService.updateSystemSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konfigurasi efisiensi berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Helper navigasi ke manage price
  void _navigateToManagePrice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageGasPriceScreen()),
    ).then((_) {
      // Refresh data saat kembali dari layar Manage Price
      _loadAllSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Pengaturan Sistem')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan Sistem')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // BAGIAN HARGA GAS (READ ONLY)
            Card(
              elevation: 2,
              color: Colors.grey[50], // Memberikan kesan read-only
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text(
                              'Harga Gas (Global)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        // Tombol Shortcut Edit
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Ubah Harga',
                          onPressed: _navigateToManagePrice,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceDisplayController,
                      readOnly: true, // <--- KUNCI: Tidak bisa diedit di sini
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Harga Saat Ini (Read Only)',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor:
                            Colors.grey[200], // Visual cue bahwa ini disabled
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.grey,
                        ),
                        helperText:
                            'Ubah harga melalui tombol edit di kanan atas',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // BAGIAN THRESHOLD (EDITABLE)
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Konfigurasi Threshold Efisiensi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),

                    // Low Threshold
                    TextFormField(
                      controller: _thresholdLowController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Batas Bawah (Efisien)',
                        hintText: 'Contoh: -10',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        helperText: 'Deviasi <= nilai ini = Efisien',
                        prefixIcon: Icon(
                          Icons.trending_down,
                          color: Colors.green,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        if (double.tryParse(value) == null)
                          return 'Harus angka valid';
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // High Threshold
                    TextFormField(
                      controller: _thresholdHighController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Batas Atas (Boros)',
                        hintText: 'Contoh: 10',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        helperText: 'Deviasi > nilai ini = Boros',
                        prefixIcon: Icon(Icons.trending_up, color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Wajib diisi';
                        if (double.tryParse(value) == null)
                          return 'Harus angka valid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Simpan Konfigurasi Threshold',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
