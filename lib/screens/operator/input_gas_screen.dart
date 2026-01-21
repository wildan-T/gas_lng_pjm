import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/gas_record_model.dart';
import '../../models/machine_model.dart';
import '../../services/auth_service_mock.dart';
import '../../services/data_service_mock.dart';

class InputGasScreen extends StatefulWidget {
  const InputGasScreen({Key? key}) : super(key: key);

  @override
  _InputGasScreenState createState() => _InputGasScreenState();
}

class _InputGasScreenState extends State<InputGasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<Machine> _machines = [];
  Machine? _selectedMachine;
  bool _isLoading = false;
  bool _isLoadingMachines = true;
  String? _photoBase64; // ← NEW
  XFile? _imageFile; // ← NEW

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final machines = await dataService.getMachines();
    setState(() {
      _machines = machines;
      _isLoadingMachines = false;
      if (_machines.isNotEmpty) {
        _selectedMachine = _machines[0];
      }
    });
  }

  // ← NEW: Ambil foto
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (photo != null) {
        final bytes = await File(photo.path).readAsBytes();
        setState(() {
          _imageFile = photo;
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil foto: $e')),
      );
    }
  }

  // ← NEW: Pilih dari gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        setState(() {
          _imageFile = image;
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih foto: $e')),
      );
    }
  }

  // ← NEW: Hapus foto
  void _removePhoto() {
    setState(() {
      _imageFile = null;
      _photoBase64 = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih mesin terlebih dahulu')),
      );
      return;
    }

    // ← NEW: Validasi foto wajib
    if (_photoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📷 Foto meteran wajib diisi untuk akurasi data'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser!;
      final dataService = Provider.of<DataService>(context, listen: false);
      
      final record = GasRecord(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        amount: double.parse(_amountController.text),
        machineName: _selectedMachine!.name,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        operatorId: user.uid,
        operatorName: user.name,
        photoBase64: _photoBase64, // ← NEW
      );

      await dataService.addGasRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        _amountController.clear();
        _notesController.clear();
        _removePhoto(); // ← NEW
        setState(() => _selectedMachine = _machines.isNotEmpty ? _machines[0] : null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(title: Text('Input Konsumsi Gas LNG')),
      body: _isLoadingMachines
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.blue),
                        title: Text('Tanggal & Waktu'),
                        subtitle: Text(
                          DateTime.now().toString().substring(0, 16),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Machine Dropdown
                    DropdownButtonFormField<Machine>(
                      value: _selectedMachine,
                      decoration: InputDecoration(
                        labelText: 'Pilih Mesin',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.precision_manufacturing),
                      ),
                      items: _machines.map((machine) {
                        return DropdownMenuItem(
                          value: machine,
                          child: Text('${machine.name} (${machine.location})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedMachine = value);
                      },
                      validator: (value) => value == null ? 'Pilih mesin' : null,
                    ),
                    SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Gas (m³)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_gas_station),
                        hintText: 'Contoh: 120.5',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(value) == null) return 'Harus berupa angka';
                        if (double.parse(value) <= 0) return 'Harus lebih dari 0';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // ← NEW: Photo Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.camera_alt, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Foto Meteran Gas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'WAJIB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (_imageFile == null) ...[
                            Text(
                              'Ambil foto meteran untuk memastikan akurasi data',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _takePicture,
                                    icon: Icon(Icons.camera),
                                    label: Text('Ambil Foto'),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickFromGallery,
                                    icon: Icon(Icons.photo_library),
                                    label: Text('Dari Gallery'),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_imageFile!.path),
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: _removePhoto,
                                    icon: Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Foto tersimpan',
                              style: TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: 'Contoh: Konsumsi normal, tidak ada masalah',
                      ),
                    ),
                    SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Simpan Data', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}