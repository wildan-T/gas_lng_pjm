import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service_mock.dart';
import '../../models/forecast_model.dart';

class ForecastInputScreen extends StatefulWidget {
  const ForecastInputScreen({Key? key}) : super(key: key);

  @override
  _ForecastInputScreenState createState() => _ForecastInputScreenState();
}

class _ForecastInputScreenState extends State<ForecastInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productionController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1, // Next month
  );
  
  bool _isLoading = false;
  ForecastOrder? _existingForecast;

  @override
  void initState() {
    super.initState();
    _loadExistingForecast();
  }

  Future<void> _loadExistingForecast() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final forecast = await dataService.getForecast(
      _selectedDate.year,
      _selectedDate.month,
    );
    
    if (forecast != null && mounted) {
      setState(() {
        _existingForecast = forecast;
        _productionController.text = forecast.forecastProduction.toStringAsFixed(0);
        _notesController.text = forecast.notes;
      });
    }
  }

  Future<void> _selectMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: 'Pilih Bulan Forecast',
    );
    
    if (result != null) {
      setState(() {
        _selectedDate = DateTime(result.year, result.month);
        _existingForecast = null;
        _productionController.clear();
        _notesController.clear();
      });
      _loadExistingForecast();
    }
  }

  Future<void> _saveForecast() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      
      final forecast = ForecastOrder(
        id: _existingForecast?.id ?? 
            'forecast_${_selectedDate.year}_${_selectedDate.month}',
        year: _selectedDate.year,
        month: _selectedDate.month,
        forecastProduction: double.parse(_productionController.text),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        createdBy: 'Supervisor', // TODO: Get from auth
      );
      
      await dataService.addOrUpdateForecast(forecast);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingForecast != null
                  ? 'Forecast berhasil diperbarui'
                  : 'Forecast berhasil disimpan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.yMMMM('id_ID').format(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Forecast Produksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Period Selection
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.blue),
                title: Text('Periode Forecast'),
                subtitle: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _selectMonth,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Production Forecast
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Produksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _productionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Unit (Pcs)',
                        hintText: 'Contoh: 1800000',
                        prefixIcon: Icon(Icons.precision_manufacturing),
                        border: OutlineInputBorder(),
                        helperText: 'Total produksi yang direncanakan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi target produksi';
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
            
            // Notes
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Catatan tambahan (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Info Card
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data ini akan digunakan untuk menghitung estimasi kebutuhan gas bulan ini.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveForecast,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _existingForecast != null
                            ? 'Update Forecast'
                            : 'Simpan Forecast',
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
    _productionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}