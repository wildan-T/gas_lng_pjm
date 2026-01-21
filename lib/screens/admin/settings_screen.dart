import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service_mock.dart';
import '../../models/forecast_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _thresholdLowController = TextEditingController();
  final _thresholdHighController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  SystemSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final settings = await dataService.getSystemSettings();
    
    if (mounted) {
      setState(() {
        _settings = settings;
        _priceController.text = settings.gasPricePerM3.toStringAsFixed(0);
        _thresholdLowController.text = settings.efficiencyThresholdLow.toStringAsFixed(0);
        _thresholdHighController.text = settings.efficiencyThresholdHigh.toStringAsFixed(0);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      
      final newSettings = SystemSettings(
        id: _settings!.id,
        gasPricePerM3: double.parse(_priceController.text),
        efficiencyThresholdLow: double.parse(_thresholdLowController.text),
        efficiencyThresholdHigh: double.parse(_thresholdHighController.text),
        updatedAt: DateTime.now(),
        updatedBy: 'Admin', // TODO: Get from auth
      );
      
      await dataService.updateSystemSettings(newSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Pengaturan Sistem')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Sistem'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Gas Price
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Harga Gas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga per m³',
                        hintText: 'Contoh: 15000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                        helperText: 'Harga gas LNG per meter kubik',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi harga gas';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Harap masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Efficiency Thresholds
            Card(
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
                          'Threshold Efisiensi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Low Threshold (Efisien)
                    TextFormField(
                      controller: _thresholdLowController,
                      keyboardType: TextInputType.numberWithOptions(signed: true),
                      decoration: InputDecoration(
                        labelText: 'Batas Efisien',
                        hintText: 'Contoh: -10',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        helperText: 'Deviasi <= nilai ini = Efisien',
                        prefixIcon: Icon(Icons.trending_down, color: Colors.green),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi batas efisien';
                        }
                        final number = double.tryParse(value);
                        if (number == null) {
                          return 'Harap masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // High Threshold (Boros)
                    TextFormField(
                      controller: _thresholdHighController,
                      keyboardType: TextInputType.numberWithOptions(signed: true),
                      decoration: InputDecoration(
                        labelText: 'Batas Boros',
                        hintText: 'Contoh: 10',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        helperText: 'Deviasi > nilai ini = Boros',
                        prefixIcon: Icon(Icons.trending_up, color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi batas boros';
                        }
                        final number = double.tryParse(value);
                        if (number == null) {
                          return 'Harap masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Explanation
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Efisiensi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Efisien: Deviasi ≤ ${_thresholdLowController.text}%'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Normal: ${_thresholdLowController.text}% < Deviasi ≤ ${_thresholdHighController.text}%'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Boros: Deviasi > ${_thresholdHighController.text}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
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
                        'Simpan Pengaturan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _thresholdLowController.dispose();
    _thresholdHighController.dispose();
    super.dispose();
  }
}